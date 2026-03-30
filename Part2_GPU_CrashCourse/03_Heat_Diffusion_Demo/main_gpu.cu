// 2D 熱傳導 — GPU 參考實作（與 main_cpu.cpp 同參數）

#include <cuda_runtime.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__global__ void heatDiffusionKernel(const float *T_old, float *T_new, int NX, int NY,
                                    float alpha, float dx) {
  const int j = blockIdx.x * blockDim.x + threadIdx.x;
  const int i = blockIdx.y * blockDim.y + threadIdx.y;
  if (i <= 0 || i >= NX - 1 || j <= 0 || j >= NY - 1)
    return;
  const int idx = i * NY + j;
  const float laplacian =
      (T_old[idx + NY] + T_old[idx - NY] + T_old[idx + 1] + T_old[idx - 1] -
       4.0f * T_old[idx]) /
      (dx * dx);
  T_new[idx] = T_old[idx] + alpha * laplacian;
}

static void checkCuda(cudaError_t e, const char *msg) {
  if (e != cudaSuccess) {
    fprintf(stderr, "%s: %s\n", msg, cudaGetErrorString(e));
    exit(EXIT_FAILURE);
  }
}

int main() {
  const int NX = 512, NY = 512, STEPS = 1000;
  const float alpha = 0.1f, dx = 1.0f;
  const size_t n = static_cast<size_t>(NX) * static_cast<size_t>(NY);
  const size_t bytes = n * sizeof(float);

  float *h = (float *)malloc(bytes);
  if (!h) {
    perror("malloc");
    return 1;
  }
  memset(h, 0, bytes);
  for (int i = NX / 2 - 50; i < NX / 2 + 50; ++i)
    for (int j = NY / 2 - 50; j < NY / 2 + 50; ++j)
      h[static_cast<size_t>(i) * NY + j] = 100.0f;

  float max_init = 0.f;
  for (size_t k = 0; k < n; ++k)
    max_init = fmaxf(max_init, h[k]);

  float *d_a = nullptr, *d_b = nullptr;
  checkCuda(cudaMalloc(&d_a, bytes), "cudaMalloc d_a");
  checkCuda(cudaMalloc(&d_b, bytes), "cudaMalloc d_b");
  checkCuda(cudaMemcpy(d_a, h, bytes, cudaMemcpyHostToDevice), "H2D");

  dim3 block(16, 16);
  dim3 grid((NY + block.x - 1) / block.x, (NX + block.y - 1) / block.y);

  cudaEvent_t ev0, ev1;
  cudaEventCreate(&ev0);
  cudaEventCreate(&ev1);
  cudaEventRecord(ev0);

  for (int step = 0; step < STEPS; ++step) {
    checkCuda(cudaMemset(d_b, 0, bytes), "cudaMemset");
    heatDiffusionKernel<<<grid, block>>>(d_a, d_b, NX, NY, alpha, dx);
    checkCuda(cudaGetLastError(), "kernel");
    float *t = d_a;
    d_a = d_b;
    d_b = t;
  }

  cudaEventRecord(ev1);
  cudaEventSynchronize(ev1);
  float ms = 0.f;
  cudaEventElapsedTime(&ms, ev0, ev1);

  checkCuda(cudaMemcpy(h, d_a, bytes, cudaMemcpyDeviceToHost), "D2H");

  float max_final = 0.f;
  for (size_t k = 0; k < n; ++k)
    max_final = fmaxf(max_final, h[k]);

  printf("========================================\n");
  printf("  2D 熱傳導 — GPU\n");
  printf("========================================\n");
  printf("網格:        %d x %d\n", NX, NY);
  printf("時間步數:    %d\n", STEPS);
  printf("初始最高溫:  %g\n", max_init);
  printf("最終最高溫:  %g\n", max_final);
  printf("Kernel+同步: %.6f 秒 (含每步 cudaMemset)\n", ms / 1000.0f);

  cudaFree(d_a);
  cudaFree(d_b);
  free(h);
  cudaEventDestroy(ev0);
  cudaEventDestroy(ev1);
  return 0;
}
