/*
 * MPI + CUDA 最小範例：每個 rank 報告 hostname、節點內 local rank、可見 GPU 數與所選 device。
 * 多卡節點：依 OMPI_COMM_WORLD_LOCAL_RANK（等）做 cudaSetDevice(local % nGpu)，避免全搶 device 0。
 */
#include <mpi.h>
#include <cuda_runtime.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <unistd.h>

static int local_rank_from_env() {
  static const char *keys[] = {
      "OMPI_COMM_WORLD_LOCAL_RANK",
      "MPI_LOCALRANKID",
      "SLURM_LOCALID",
  };
  for (const char *k : keys) {
    const char *v = std::getenv(k);
    if (v && v[0] != '\0')
      return std::atoi(v);
  }
  return 0;
}

int main(int argc, char **argv) {
  MPI_Init(&argc, &argv);
  int rank = 0, size = 1;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);

  char host[256];
  std::memset(host, 0, sizeof(host));
  if (gethostname(host, sizeof(host) - 1) != 0)
    std::snprintf(host, sizeof(host), "(gethostname-failed)");

  const int lr = local_rank_from_env();
  int nGpu = 0;
  const cudaError_t err = cudaGetDeviceCount(&nGpu);

  if (err != cudaSuccess || nGpu <= 0) {
    std::fprintf(stderr, "[rank %d/%d] host=%s cudaGetDeviceCount nGpu=%d err=%s\n", rank, size, host,
                 nGpu, cudaGetErrorString(err));
    MPI_Abort(MPI_COMM_WORLD, 1);
  }

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
