/*
 * Part2 / 07_Multi_Node_GPU_Example — mpi_cuda_rank_info.cu
 *
 * 目的（教學用最小 MPI + CUDA runtime 範例）：
 *   - 每個 MPI rank 在自己的「計算節點」上查詢本機可見的 GPU 數量與裝置名稱。
 *   - 列印 MPI rank、全域 size、hostname、以及節點內的 local rank（多進程同節點時用來分卡）。
 *
 * 多卡／多進程同節點：
 *   - Open MPI 通常會設定 OMPI_COMM_WORLD_LOCAL_RANK（0 .. 本節點進程數-1）。
 *   - 本程式以 dev = local_rank % nGpu 呼叫 cudaSetDevice(dev)，避免所有 rank 預設都用 device 0。
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

#include <unistd.h>

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

  /* ---------- 執行所在節點主機名（多節點時用來對照不同機器）---------- */
  char host[256];
  std::memset(host, 0, sizeof(host));
  if (gethostname(host, sizeof(host) - 1) != 0)
    std::snprintf(host, sizeof(host), "(gethostname-failed)");

  const int lr = local_rank_from_env();

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

  std::printf("[rank %d/%d] host=%s local_rank=%d gpus_on_node=%d cudaSetDevice(%d) name=%s\n",
              rank, size, host, lr, nGpu, dev, prop.name);

  MPI_Barrier(MPI_COMM_WORLD);
  if (rank == 0)
    std::printf("mpi_cuda_rank_info: OK (%d ranks).\n", size);
  MPI_Finalize();
  return 0;
}
