# 03_Heat_Diffusion_Demo - 熱傳導模擬（實戰框架）

> 數值模擬實戰案例：2D 熱傳導方程

---

## 🎯 案例說明

使用**有限差分法**模擬 2D 熱傳導：

```
∂T/∂t = α (∂²T/∂x² + ∂²T/∂y²)
```

**物理意義**：熱能從高溫區域流向低溫區域。

---

## 📋 實作框架

本章節提供程式骨架，學員可作為進階練習：

### CPU 版本 (`main_cpu.cpp` - 框架)

```cpp
// 2D 熱傳導 - CPU 實作框架
#include <iostream>
#include <chrono>
#include <cmath>

int main() {
  const int NX = 512;   // X 方向網格數
  const int NY = 512;   // Y 方向網格數
  const int STEPS = 1000;  // 時間步數
  const float alpha = 0.1f;  // 熱擴散係數
  
  // TODO: 配置記憶體 (T_old, T_new)
  // TODO: 設定初始條件（中央高溫）
  // TODO: 時間迭代迴圈
  //   for (step = 0; step < STEPS; step++)
  //     for (i, j) in grid:
  //       T_new[i][j] = T_old[i][j] + alpha * Laplacian
  //   swap(T_old, T_new)
  // TODO: 輸出結果
  
  std::cout << "熱傳導模擬 - 請完成實作！" << std::endl;
  return 0;
}
```

### GPU 版本 (`main_gpu.cu` - 框架)

```cuda
// 2D 熱傳導 - GPU 實作框架
#include <stdio.h>
#include <cuda_runtime.h>

__global__ void heatDiffusionKernel(float* T_old, float* T_new, 
                                     int NX, int NY, float alpha) {
  // TODO: 計算當前 thread 負責的 (i, j)
  // TODO: 計算 Laplacian
  // TODO: 更新溫度
}

int main() {
  // TODO: 類似 CPU 版，但使用 GPU kernel
  printf("熱傳導模擬 GPU - 請完成實作！\n");
  return 0;
}
```

---

## 💡 學習重點

- 將 1D 向量運算擴展到 2D 網格
- 理解數值模擬的時間迭代
- 對比 CPU 與 GPU 的效能差異（預期 10-50 倍加速）

---

## 📚 提示

1. **初始條件**：中央設為高溫（如 100.0），邊界維持低溫（0.0）
2. **Laplacian 計算**：
   ```
   ∇²T = (T[i+1][j] + T[i-1][j] + T[i][j+1] + T[i][j-1] - 4*T[i][j]) / (dx²)
   ```
3. **GPU 索引**：`i = blockIdx.x * blockDim.x + threadIdx.x`
4. **視覺化（選做）**：可用 Python/Matplotlib 畫出溫度分布圖

---

**這是進階練習，建議在掌握前面章節後再挑戰！🚀**
