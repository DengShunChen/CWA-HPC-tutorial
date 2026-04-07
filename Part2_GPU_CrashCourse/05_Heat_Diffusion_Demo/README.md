# 05_Heat_Diffusion_Demo - 熱傳導模擬（實戰框架）

> 數值模擬實戰案例：2D 熱傳導方程

---

## 案例說明

使用**有限差分法**模擬 2D 熱傳導：

```
∂T/∂t = α (∂²T/∂x² + ∂²T/∂y²)
```

**物理意義**：熱能從高溫區域流向低溫區域。

---

## 分層任務設計

本章節依學員程度設計三層任務。講師可依課堂進度選擇執行深度。

### Must（入門 Beginner）：理解框架

- 閱讀本 README，理解 2D 有限差分法的基本概念
- 能說出 CPU 版與 GPU 版的主要差異（記憶體配置方式、kernel 概念）
- 觀看講師 Live Coding 示範，理解 Laplacian 計算過程
- **驗證方式**：能口頭回答「GPU 版需要多做哪些步驟？」（cudaMalloc、cudaMemcpy）

### Should（進階 Intermediate）：完成 MVP 版本

MVP（最小可交付版本）目標：能編譯、執行、看到溫度變化輸出。

**CPU 版 MVP 要求**：
- 完成 `main_cpu.cpp` 中所有 TODO
- 使用 512x512 網格、1000 個時間步
- 程式能輸出：初始最高溫度、最終最高溫度、執行時間
- **驗證方式**：最終最高溫度應低於初始值（熱量擴散），執行時間在數秒內

**GPU 版 MVP 要求**：
- 完成 `main_gpu.cu` 中所有 TODO
- 與 CPU 版使用相同參數
- 程式能輸出：Kernel 時間、最終最高溫度
- **驗證方式**：最終溫度與 CPU 版一致（誤差 < 0.01）、Kernel 時間顯著低於 CPU

### Could（專業 Professional）：效能分析與優化

- 完成 CPU 與 GPU 兩版，製作效能比較報告
- 測試不同網格大小（256/512/1024/2048）對加速比的影響
- 分析 GPU 版在不同 block size（8x8 / 16x16 / 32x32）下的效能差異
- 嘗試進階優化：使用 Shared Memory 減少 Global Memory 存取
- **產出**：一份包含「網格大小 vs 加速比」圖表與瓶頸分析的簡報或報告

---

## 實作框架

### CPU 版本 (`main_cpu.cpp` - 框架)

```cpp
// 2D 熱傳導 - CPU 實作框架
#include <iostream>
#include <chrono>
#include <cmath>
#include <cstring>

int main() {
  const int NX = 512;
  const int NY = 512;
  const int STEPS = 1000;
  const float alpha = 0.1f;
  const float dx = 1.0f;

  // TODO 1: 配置記憶體
  //   float* T_old = new float[NX * NY];
  //   float* T_new = new float[NX * NY];

  // TODO 2: 初始化（全部 0，中央 100x100 區域設為 100.0）
  //   memset(T_old, 0, NX * NY * sizeof(float));
  //   for (int i = NX/2-50; i < NX/2+50; i++)
  //     for (int j = NY/2-50; j < NY/2+50; j++)
  //       T_old[i * NY + j] = 100.0f;

  // TODO 3: 時間迭代（計時）
  //   auto start = std::chrono::high_resolution_clock::now();
  //   for (int step = 0; step < STEPS; step++) {
  //     for (int i = 1; i < NX-1; i++)
  //       for (int j = 1; j < NY-1; j++) {
  //         float laplacian = (T_old[(i+1)*NY+j] + T_old[(i-1)*NY+j]
  //                          + T_old[i*NY+(j+1)] + T_old[i*NY+(j-1)]
  //                          - 4.0f * T_old[i*NY+j]) / (dx * dx);
  //         T_new[i*NY+j] = T_old[i*NY+j] + alpha * laplacian;
  //       }
  //     std::swap(T_old, T_new);
  //   }
  //   auto end = std::chrono::high_resolution_clock::now();

  // TODO 4: 輸出結果
  //   找出最高溫度、印出執行時間

  // TODO 5: 釋放記憶體
  //   delete[] T_old;
  //   delete[] T_new;

  std::cout << "熱傳導模擬 - 請完成實作！" << std::endl;
  return 0;
}
```

### GPU 版本 (`main_gpu.cu` - 框架)

```cuda
// 2D 熱傳導 - GPU 實作框架
#include <stdio.h>
#include <cuda_runtime.h>

__global__ void heatDiffusionKernel(const float* T_old, float* T_new,
                                     int NX, int NY, float alpha, float dx) {
  // TODO A: 計算 2D 索引
  //   int i = blockIdx.y * blockDim.y + threadIdx.y;
  //   int j = blockIdx.x * blockDim.x + threadIdx.x;

  // TODO B: 邊界檢查 + Laplacian 計算
  //   if (i > 0 && i < NX-1 && j > 0 && j < NY-1) {
  //     float laplacian = (T_old[(i+1)*NY+j] + T_old[(i-1)*NY+j]
  //                      + T_old[i*NY+(j+1)] + T_old[i*NY+(j-1)]
  //                      - 4.0f * T_old[i*NY+j]) / (dx * dx);
  //     T_new[i*NY+j] = T_old[i*NY+j] + alpha * laplacian;
  //   }
}

int main() {
  const int NX = 512, NY = 512, STEPS = 1000;
  const float alpha = 0.1f, dx = 1.0f;
  const int size = NX * NY * sizeof(float);

  // TODO C: Host 記憶體配置與初始化（同 CPU 版）

  // TODO D: Device 記憶體配置
  //   float *d_T_old, *d_T_new;
  //   cudaMalloc(&d_T_old, size);
  //   cudaMalloc(&d_T_new, size);

  // TODO E: Host → Device 複製
  //   cudaMemcpy(d_T_old, h_T, size, cudaMemcpyHostToDevice);

  // TODO F: 設定 grid/block 並執行
  //   dim3 block(16, 16);
  //   dim3 grid((NY + block.x - 1) / block.x, (NX + block.y - 1) / block.y);
  //   for (int step = 0; step < STEPS; step++) {
  //     heatDiffusionKernel<<<grid, block>>>(d_T_old, d_T_new, NX, NY, alpha, dx);
  //     std::swap(d_T_old, d_T_new);  // 交換指標
  //   }

  // TODO G: Device → Host 複製 + 輸出結果

  // TODO H: 釋放記憶體

  printf("熱傳導模擬 GPU - 請完成實作！\n");
  return 0;
}
```

---

## 學習重點

- 將 1D 向量運算擴展到 2D 網格
- 理解數值模擬的時間迭代模式
- 對比 CPU 與 GPU 的效能差異（預期 10-50 倍加速，視網格大小）

---

## 提示

1. **初始條件**：中央設為高溫（100.0），邊界維持低溫（0.0）
2. **Laplacian 計算**：
   ```
   nabla^2 T = (T[i+1][j] + T[i-1][j] + T[i][j+1] + T[i][j-1] - 4*T[i][j]) / (dx^2)
   ```
3. **GPU 2D 索引**：使用 `dim3 block(16, 16)` 與 `dim3 grid(...)` 設定 2D 執行配置
4. **視覺化（選做）**：可用 Python/Matplotlib 畫出溫度分布圖

---

## 效能分析參考（Could 任務）

| 網格大小 | CPU 預期時間 | GPU 預期時間 | 預期加速比 |
|----------|-------------|-------------|-----------|
| 256x256 | ~0.5 秒 | ~0.05 秒 | ~10x |
| 512x512 | ~2 秒 | ~0.1 秒 | ~20x |
| 1024x1024 | ~8 秒 | ~0.3 秒 | ~25x |
| 2048x2048 | ~32 秒 | ~1 秒 | ~30x |

（實際數值依硬體而異，以上為數量級參考）

**進階優化方向**：
- Shared Memory Tiling：將每個 block 需要的資料載入 shared memory，減少 global memory 存取
- 使用 `__restrict__` 提示編譯器無指標別名
- 嘗試不同 block size 對 occupancy 的影響

---

**這是進階練習，建議在掌握前面章節後再挑戰！**
