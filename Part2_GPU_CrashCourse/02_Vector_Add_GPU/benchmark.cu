// CPU vs GPU 向量加法計時對照（與 vec_add_gpu.cu 相同規模與 kernel 邏輯）

#include <chrono>
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>

__global__ void vectorAddKernel(const float *A, const float *B, float *C, int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n)
    C[i] = A[i] + B[i];
}

int main() {
  const int n = 10000000;
  const size_t size = static_cast<size_t>(n) * sizeof(float);

  float *h_A = (float *)malloc(size);
  float *h_B = (float *)malloc(size);
  float *h_C = (float *)malloc(size);
  for (int i = 0; i < n; ++i) {
    h_A[i] = static_cast<float>(i);
    h_B[i] = static_cast<float>(i) * 2.0f;
  }

  auto t_cpu0 = std::chrono::high_resolution_clock::now();
  for (int i = 0; i < n; ++i)
    h_C[i] = h_A[i] + h_B[i];
  auto t_cpu1 = std::chrono::high_resolution_clock::now();
  const double cpu_sec = std::chrono::duration<double>(t_cpu1 - t_cpu0).count();

  float *d_A, *d_B, *d_C;
  cudaMalloc(&d_A, size);
  cudaMalloc(&d_B, size);
  cudaMalloc(&d_C, size);
  cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

  const int threadsPerBlock = 256;
  const int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  cudaEventRecord(start);
  vectorAddKernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, n);
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  float ms = 0.f;
  cudaEventElapsedTime(&ms, start, stop);

  cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

  printf("========================================\n");
  printf("  向量加法 — CPU vs GPU（kernel 時間）\n");
  printf("========================================\n");
  printf("n = %d\n", n);
  printf("CPU 時間:     %.6f 秒（單執行緒迴圈）\n", cpu_sec);
  printf("GPU kernel:   %.6f 秒\n", ms / 1000.0f);
  printf("前 5 個結果:  %.0f %.0f %.0f %.0f %.0f\n", h_C[0], h_C[1], h_C[2], h_C[3],
         h_C[4]);

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);
  free(h_A);
  free(h_B);
  free(h_C);
  cudaEventDestroy(start);
  cudaEventDestroy(stop);
  return 0;
}
