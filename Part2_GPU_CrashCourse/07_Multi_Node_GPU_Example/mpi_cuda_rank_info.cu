/*
 * Part2 / 07_Multi_Node_GPU_Example — mpi_cuda_rank_info.cu
 *
 * 目的（教學用最小 MPI + CUDA runtime 範例）：
 *   - 每個 MPI rank 在自己的「計算節點」上查詢本機可見的 GPU 數量與裝置名稱。
 *   - 列印 MPI rank、全域 size、hostname、以及節點內的 local rank（多進程同節點時用來分卡）。
 *   -（預設）額外做一點「有趣但輕量」的事：GPU 上跑 saxpy kernel + CPU buffer 的 MPI_Allreduce，
 *     讓你能同時觀察「CUDA kernel 時間」與「跨 rank 通訊」是否在同一個 job 裡正常。
 *
 * 多卡／多進程同節點：
 *   - 本程式優先用 `MPI_COMM_TYPE_SHARED` 分出來的 `node_rank`（0 .. 本節點進程數-1）。
 *   - 若 split 失敗，才退回讀常見環境變數（例如 `OMPI_COMM_WORLD_LOCAL_RANK`）。
 *   - 最後以 dev = node_rank % nGpu 呼叫 cudaSetDevice(dev)，避免所有 rank 預設都用 device 0。
 *
 * 多節點：
 *   - 每個 vnode 上常只有「該節點」的 GPU 對本進程可見；每節點若僅 1 GPU，則 nGpu=1、local_rank 多為 0，
 *     所有 rank 仍會用 dev=0，但不同 hostname 代表不同實體卡。
 *
 * 編譯／執行（見同目錄 Makefile、README、run_test_07.sh）：
 *   nvcc -ccbin mpicxx mpi_cuda_rank_info.cu -o mpi_cuda_rank_info
 *   mpirun -np 2 ./mpi_cuda_rank_info
 *
 * 若 cudaGetDeviceCount 失敗或 nGpu==0（無驅動、非 GPU 節點、driver 與 CUDA runtime 版本不符等），
 *   呼叫 MPI_Abort 讓 mpirun 以非零結束，便於批次腳本偵錯。
 */
#include <mpi.h>
#include <cuda_runtime.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <vector>

#include <unistd.h>

__global__ void saxpy_kernel(const float *x, const float *y, float *z, int n, float a) {
  const int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n)
    z[i] = a * x[i] + y[i];
}

static void cuda_check(cudaError_t err, const char *what) {
  if (err != cudaSuccess) {
    std::fprintf(stderr, "CUDA error (%s): %s\n", what, cudaGetErrorString(err));
    MPI_Abort(MPI_COMM_WORLD, 2);
  }
}

static int getenv_int(const char *name, int def) {
  const char *v = std::getenv(name);
  if (!v || v[0] == '\0')
    return def;
  return std::atoi(v);
}

static float getenv_float(const char *name, float def) {
  const char *v = std::getenv(name);
  if (!v || v[0] == '\0')
    return def;
  return static_cast<float>(std::atof(v));
}

/* 從常見批次／MPI 執行環境變數讀取「本節點內」之進程序號；都沒有則假設 0（單進程或單卡教學）。 */
static int local_rank_from_env() {
  static const char *keys[] = {
      "OMPI_COMM_WORLD_LOCAL_RANK", /* Open MPI */
      "MPI_LOCALRANKID",            /* 部分 MPI／平台 */
      "SLURM_LOCALID",              /* Slurm（若未來在 Slurm 上跑可沿用概念） */
  };
  for (const char *k : keys) {
    const char *v = std::getenv(k);
    if (v && v[0] != '\0')
      return std::atoi(v);
  }
  return 0;
}

int main(int argc, char **argv) {
  /* ---------- MPI 初始化與全域 rank / communicator size ---------- */
  MPI_Init(&argc, &argv);
  int rank = 0, size = 1;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  /* ---------- 節點內 shared-memory communicator（比環境變數更可靠）---------- */
  MPI_Comm node_comm = MPI_COMM_NULL;
  int node_rank = 0, node_size = 1;
  if (MPI_Comm_split_type(MPI_COMM_WORLD, MPI_COMM_TYPE_SHARED, rank, MPI_INFO_NULL, &node_comm) == MPI_SUCCESS &&
      node_comm != MPI_COMM_NULL) {
    MPI_Comm_rank(node_comm, &node_rank);
    MPI_Comm_size(node_comm, &node_size);
  } else {
    node_comm = MPI_COMM_NULL;
  }

  /* ---------- 執行所在節點主機名（多節點時用來對照不同機器）---------- */
  char host[256];
  std::memset(host, 0, sizeof(host));
  if (gethostname(host, sizeof(host) - 1) != 0)
    std::snprintf(host, sizeof(host), "(gethostname-failed)");

  const int lr_env = local_rank_from_env();
  const int lr = (node_comm != MPI_COMM_NULL) ? node_rank : lr_env;

  /* ---------- 本進程所見之 CUDA 裝置（僅限當前 OS 節點；受 CUDA_VISIBLE_DEVICES 影響）---------- */
  int nGpu = 0;
  const cudaError_t err = cudaGetDeviceCount(&nGpu);

  if (err != cudaSuccess || nGpu <= 0) {
    std::fprintf(stderr, "[rank %d/%d] host=%s cudaGetDeviceCount nGpu=%d err=%s\n", rank, size, host,
                 nGpu, cudaGetErrorString(err));
    MPI_Abort(MPI_COMM_WORLD, 1);
  }

  /* ---------- 依節點內序號輪流綁定 GPU，並讀取該裝置屬性 ---------- */
  const int dev = lr % nGpu;
  cudaSetDevice(dev);
  cudaDeviceProp prop{};
  cudaGetDeviceProperties(&prop, dev);

  std::printf("[rank %d/%d] host=%s local_rank=%d(env=%d) node_rank=%d/%d gpus_on_node=%d cudaSetDevice(%d) name=%s\n",
              rank, size, host, lr, lr_env, node_rank, node_size, nGpu, dev, prop.name);

  /* ---------- 小有趣：GPU kernel + 跨 rank MPI_Allreduce（預設開；可用環境變數關掉）---------- */
  const int do_extra = getenv_int("MCRI_EXTRA", 1);
  if (do_extra) {
    /* 預設別太大：避免在大型 job 裡不小心用超大向量做 CPU-side Allreduce */
    const int n = getenv_int("MCRI_N", 1 << 18); /* floats; default 262144 * 4B = 1MiB */
    const int repeats = getenv_int("MCRI_REPEATS", 50);
    const float a = getenv_float("MCRI_A", 2.0f);

    float *d_x = nullptr, *d_y = nullptr, *d_z = nullptr;
    cuda_check(cudaMalloc(&d_x, static_cast<size_t>(n) * sizeof(float)), "cudaMalloc d_x");
    cuda_check(cudaMalloc(&d_y, static_cast<size_t>(n) * sizeof(float)), "cudaMalloc d_y");
    cuda_check(cudaMalloc(&d_z, static_cast<size_t>(n) * sizeof(float)), "cudaMalloc d_z");

    /* 讓每個 rank 的輸入不同，方便驗證 allreduce 是否真的跨 rank 聚合 */
    std::vector<float> h_x(static_cast<size_t>(n));
    std::vector<float> h_y(static_cast<size_t>(n));
    for (int i = 0; i < n; ++i) {
      h_x[i] = static_cast<float>((i + rank * 97) % 251) * 1.0e-3f;
      h_y[i] = static_cast<float>((i + rank * 13) % 241) * 1.0e-3f;
    }
    cuda_check(cudaMemcpy(d_x, h_x.data(), h_x.size() * sizeof(float), cudaMemcpyHostToDevice), "H2D x");
    cuda_check(cudaMemcpy(d_y, h_y.data(), h_y.size() * sizeof(float), cudaMemcpyHostToDevice), "H2D y");

    const int threads = 256;
    const int blocks = (n + threads - 1) / threads;

    cudaEvent_t ev0{}, ev1{};
    cuda_check(cudaEventCreate(&ev0), "cudaEventCreate ev0");
    cuda_check(cudaEventCreate(&ev1), "cudaEventCreate ev1");

    cuda_check(cudaEventRecord(ev0), "cudaEventRecord ev0");
    for (int r = 0; r < repeats; ++r) {
      saxpy_kernel<<<blocks, threads>>>(d_x, d_y, d_z, n, a);
      cuda_check(cudaGetLastError(), "saxpy launch");
    }
    cuda_check(cudaEventRecord(ev1), "cudaEventRecord ev1");
    cuda_check(cudaEventSynchronize(ev1), "cudaEventSynchronize ev1");
    float ms_kernel = 0.0f;
    cuda_check(cudaEventElapsedTime(&ms_kernel, ev0, ev1), "cudaEventElapsedTime kernel");

    std::vector<float> h_partial(static_cast<size_t>(n));
    cuda_check(cudaMemcpy(h_partial.data(), d_z, h_partial.size() * sizeof(float), cudaMemcpyDeviceToHost), "D2H z");

    /* 用 float sum 做 allreduce（教學用；非嚴格數值分析） */
    MPI_Barrier(MPI_COMM_WORLD);
    double t0 = MPI_Wtime();
    MPI_Allreduce(MPI_IN_PLACE, h_partial.data(), n, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
    double t1 = MPI_Wtime();
    const double ms_mpi = (t1 - t0) * 1.0e3;

    /* rank0 做一個很小的 checksum，避免把整個向量印爆 */
    double chk = 0.0;
    if (rank == 0) {
      const int step = std::max(1, n / 4096);
      for (int i = 0; i < n; i += step)
        chk += static_cast<double>(h_partial[i]);
    }

    if (rank == 0) {
      const double bytes_moved = static_cast<double>(n) * sizeof(float) * static_cast<double>(repeats) * 3.0; /* 粗估讀 x,y 寫 z */
      const double gbps = (bytes_moved / (ms_kernel / 1.0e3)) / 1.0e9;
      std::printf(
          "extra: saxpy n=%d repeats=%d a=%.3f | kernel_time=%.3f ms (~%.3f GB/s effective, 粗估) | MPI_Allreduce(float sum)=%.3f ms | "
          "checksum(sampled)=%.6g\n",
          n, repeats, a, ms_kernel, gbps, ms_mpi, chk);
    }

    cudaEventDestroy(ev0);
    cudaEventDestroy(ev1);
    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_z);
  }

  if (node_comm != MPI_COMM_NULL && node_comm != MPI_COMM_WORLD)
    MPI_Comm_free(&node_comm);

  MPI_Barrier(MPI_COMM_WORLD);
  if (rank == 0)
    std::printf("mpi_cuda_rank_info: OK (%d ranks).\n", size);
  MPI_Finalize();
  return 0;
}
