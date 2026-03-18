// 查詢 GPU 裝置資訊
// 用來確認 GPU 環境並了解 GPU 規格

#include <stdio.h>

int main() {
  int deviceCount;
  cudaGetDeviceCount(&deviceCount);
  
  printf("=========================================\n");
  printf("  GPU 裝置資訊查詢\n");
  printf("=========================================\n\n");
  
  if (deviceCount == 0) {
    printf("❌ 未偵測到 CUDA 相容的 GPU！\n");
    return 1;
  }
  
  printf("✓ 找到 %d 個 CUDA 裝置\n\n", deviceCount);
  
  for (int dev = 0; dev < deviceCount; dev++) {
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, dev);
    
    printf("--- 裝置 %d: %s ---\n", dev, prop.name);
    printf("  Compute Capability:    %d.%d\n", prop.major, prop.minor);
    printf("  總記憶體:              %.2f GB\n", prop.totalGlobalMem / 1e9);
    printf("  時脈頻率:              %.2f GHz\n", prop.clockRate / 1e6);
    printf("  多處理器 (SM) 數量:     %d\n", prop.multiProcessorCount);
    printf("  每個 Block 最大 Thread: %d\n", prop.maxThreadsPerBlock);
    printf("  記憶體頻寬:            ~%.0f GB/s\n", 
           2.0 * prop.memoryClockRate * (prop.memoryBusWidth / 8) / 1.0e6);
    printf("\n");
  }
  
  printf("=========================================\n");
  printf("環境檢查完成！可以開始使用 GPU 🚀\n");
  printf("=========================================\n");
  
  return 0;
}
