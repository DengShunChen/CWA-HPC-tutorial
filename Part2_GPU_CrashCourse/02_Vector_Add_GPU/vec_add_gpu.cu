// 向量加法 - CUDA GPU 版本
// 展示如何將 CPU 程式移植到 GPU

#include <stdio.h>
#include <cuda_runtime.h>

// GPU Kernel：在 GPU 上執行的向量加法
__global__ void vectorAddKernel(const float* A, const float* B, float* C, int n) {
  // 計算當前 thread 負責處理的元素索引
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  
  // 確保不超過陣列範圍
  if (i < n) {
    C[i] = A[i] + B[i];
  }
}

int main() {
  const int n = 10000000;  // 一千萬個元素
  const int size = n * sizeof(float);
  
  // Host (CPU) 記憶體
  float *h_A, *h_B, *h_C;
  h_A = (float*)malloc(size);
  h_B = (float*)malloc(size);
  h_C = (float*)malloc(size);
  
  // 初始化 Host 陣列
  printf("初始化陣列...\n");
  for (int i = 0; i < n; i++) {
    h_A[i] = (float)i;
    h_B[i] = (float)i * 2.0f;
  }
  
  // Device (GPU) 記憶體
  float *d_A, *d_B, *d_C;
  cudaMalloc(&d_A, size);
  cudaMalloc(&d_B, size);
  cudaMalloc(&d_C, size);
  
  // 1. 將資料從 Host 複製到 Device
  printf("將資料複製到 GPU...\n");
  cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
  
  // 2. 設定 kernel 執行配置
  int threadsPerBlock = 256;
  int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;
  printf("GPU 配置: %d blocks x %d threads = %d threads\n", 
         blocksPerGrid, threadsPerBlock, blocksPerGrid * threadsPerBlock);
  
  // 3. 建立 CUDA 事件用於計時
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  
  // 開始計時
  cudaEventRecord(start);
  
  // 4. 執行 kernel
  vectorAddKernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, n);
  
  // 結束計時
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  
  float milliseconds = 0;
  cudaEventElapsedTime(&milliseconds, start, stop);
  
  // 5. 將結果從 Device 複製回 Host
  cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
  
  // 輸出結果
  printf("\n========================================\n");
  printf("  GPU 向量加法完成 ⚡\n");
  printf("========================================\n");
  printf("向量長度:     %d\n", n);
  printf("Kernel 時間:  %.6f 秒\n", milliseconds / 1000.0f);
  printf("前 5 個結果:  %.0f %.0f %.0f %.0f %.0f\n", 
         h_C[0], h_C[1], h_C[2], h_C[3], h_C[4]);
  printf("\n");
  
  // 清理記憶體
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
