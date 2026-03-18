# 02_Vector_Add_GPU - 從 CPU 到 GPU

> 學習 CUDA 核心概念：Kernel、記憶體管理、效能測量

---

## 🎯 學習目標

1. 理解 Host (CPU) 與 Device (GPU) 的記憶體系統
2. 撰寫 CUDA Kernel 函式
3. 學習資料傳輸流程
4. 測量 GPU 效能

---

## 📝 CUDA 程式基本流程

```
1. 配置 Host 記憶體（CPU）
2. 配置 Device 記憶體（GPU）        ← cudaMalloc()
3. 將資料從 Host 傳到 Device      ← cudaMemcpy(H→D)
4. 執行 Kernel（GPU 運算）         ← kernel<<<...>>>()
5. 將結果從 Device 傳回 Host      ← cudaMemcpy(D→H)
6. 清理記憶體                      ← cudaFree(), free()
```

---

## 💡 核心概念解析

### 1. Kernel 函式

```cuda
__global__ void vectorAddKernel(float* A, float* B, float* C, int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;  // 計算索引
  
  if (i < n) {
    C[i] = A[i] + B[i];  // 每個 thread 處理一個元素
  }
}
```

- `__global__`：表示這是 kernel，從 CPU 呼叫，在 GPU 執行
- `blockIdx.x`：當前 block 的 ID
- `threadIdx.x`：當前 thread 在 block 中的 ID
- `blockDim.x`：每個 block 的 thread 數量

### 2. Thread 索引計算

假設：
- `blockDim.x = 256` (每個 block 有 256 threads)
- `gridDim = 4` (總共 4 個 blocks)

```
Block 0: threads 0-255    → 處理 A[0] ~ A[255]
Block 1: threads 256-511  → 處理 A[256] ~ A[511]
Block 2: threads 512-767  → 處理 A[512] ~ A[767]
Block 3: threads 768-1023 → 處理 A[768] ~ A[1023]
```

**索引公式**：
```cuda
i = blockIdx.x * blockDim.x + threadIdx.x
```

### 3. Kernel 執行配置

```cuda
int threadsPerBlock = 256;
int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;

vectorAddKernel<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, n);
```

- `<<<blocksPerGrid, threadsPerBlock>>>`：執行配置
- 向上取整確保所有元素都被處理

---

## 🔄 CPU vs GPU 程式對照

| 步驟 | CPU (C++) | GPU (CUDA) |
|-----|-----------|-----------|
| **記憶體配置** | `float* A = new float[n];` | `cudaMalloc(&d_A, size);` |
| **運算** | `for (i=0; i<n; i++) C[i]=A[i]+B[i];` | `kernel<<<...>>>(d_A, d_B, d_C, n);` |
| **記憶體釋放** | `delete[] A;` | `cudaFree(d_A);` |

---

## ⚡ 效能測量

### CUDA 事件計時

```cuda
cudaEvent_t start, stop;
cudaEventCreate(&start);
cudaEventCreate(&stop);

cudaEventRecord(start);
kernel<<<...>>>(...);  // 執行 kernel
cudaEventRecord(stop);

cudaEventSynchronize(stop);
float ms;
cudaEventElapsedTime(&ms, start, stop);
printf("時間: %.3f 毫秒\n", ms);
```

---

## 🚀 執行範例

```bash
# 編譯
make

# 執行
./vec_add_gpu
```

**預期輸出**：
```
初始化陣列...
將資料複製到 GPU...
GPU 配置: 39063 blocks x 256 threads = 10000128 threads

========================================
  GPU 向量加法完成 ⚡
========================================
向量長度:     10000000
Kernel 時間:  0.002500 秒
前 5 個結果:  0 3 6 9 12
```

---

## 🔍 常見問題

### Q: 為什麼需要 `if (i < n)` 檢查？

**A**: 因為 block 數量是向上取整，最後一個 block 可能有多餘的 threads 超出陣列範圍。

### Q: `cudaMemcpy` 很慢嗎？

**A**: 是的！PCIe 傳輸速度 (~16 GB/s) 遠慢於 GPU 記憶體頻寬 (~900 GB/s)。優化重點是**減少資料傳輸次數**。

### Q: 如何選擇 threadsPerBlock？

**A**: 通常使用 256 或 512。需要是 32 的倍數（warp size）。

---

## 💡 GPU 優化技巧預覽

1. **減少資料傳輸** - 盡可能在 GPU 上完成所有運算
2. **Coalesced Memory Access** - 相鄰 threads 存取相鄰記憶體
3. **選擇適當的 Block Size** - 通常 256-512 threads
4. **使用 Shared Memory** - 加速資料重用（進階）

---

**下一步：[`03_Heat_Diffusion_Demo`](../03_Heat_Diffusion_Demo/) 實戰案例！🔥**
