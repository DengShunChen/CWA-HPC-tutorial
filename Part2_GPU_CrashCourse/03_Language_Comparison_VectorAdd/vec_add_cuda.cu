// 向量加法 — CUDA C；邏輯與 ../02_Vector_Add_GPU/vec_add_gpu.cu 相同，方便與 Fortran GPU 對照
#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>

__global__ void vectorAddKernel(const float *A, const float *B, float *C, int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n)
    C[i] = A[i] + B[i];
}

int main(void) {
  const int n = 10000000;
  const size_t size = (size_t)n * sizeof(float);
  float *h_A = (float *)malloc(size);
  float *h_B = (float *)malloc(size);
  float *h_C = (float *)malloc(size);
  float *d_A = nullptr, *d_B = nullptr, *d_C = nullptr;

  printf("初始化陣列...\n");
  for (int i = 0; i < n; i++) {
    h_A[i] = (float)i;
    h_B[i] = (float)i * 2.0f;
  }

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

  printf("\n========================================\n");
  printf("  CUDA C 向量加法\n");
  printf("========================================\n");
  printf("向量長度:     %d\n", n);
  printf("Kernel 時間:  %.6f 秒\n", (double)ms * 1e-3);
  printf("前 5 個結果:  %.0f %.0f %.0f %.0f %.0f\n",
         (double)h_C[0], (double)h_C[1], (double)h_C[2], (double)h_C[3],
         (double)h_C[4]);
  printf("\n");

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
