// CUDA Hello World
// 第一個在 GPU 上執行的程式

#include <stdio.h>

// Kernel 函式：在 GPU 上執行
// __global__ 表示這是一個 kernel，可以從 host 呼叫，在 device 執行
__global__ void hello_from_gpu() {
  // threadIdx.x: 當前 thread 的 ID
  // blockIdx.x: 當前 block 的 ID
  printf("Hello from GPU! Block %d, Thread %d\n", blockIdx.x, threadIdx.x);
}

int main() {
  printf("========================================\n");
  printf("  CUDA Hello World\n");
  printf("========================================\n\n");
  
  printf("從 CPU (Host) 呼叫 GPU (Device) kernel...\n\n");
  
  // 呼叫 kernel
  // <<<blocks, threads_per_block>>>
  // 這裡使用 2 個 blocks，每個 block 有 4 個 threads
  hello_from_gpu<<<2, 4>>>();
  
  // 等待 GPU 完成
  cudaDeviceSynchronize();
  
  printf("\n========================================\n");
  printf("GPU 程式執行完成 ✓\n");
  printf("========================================\n");
  
  return 0;
}
