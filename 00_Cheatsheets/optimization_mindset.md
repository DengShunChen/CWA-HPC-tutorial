# HPC 優化思維指南

> 從程式設計基本概念到效能調校的完整指南

> **🖥️ 本課程使用 Fujitsu A64FX (FX1000) - ARM SVE 平台**  
> 優化重點略有不同於 x86，特別強調：  
> - **ARM SVE 512-bit 向量化** (`-KSVE`)  
> - **HBM2 高頻寬記憶體** 的有效利用  
> - **Fujitsu 編譯器**特有優化選項

---

## 🎯 HPC 程式設計核心思維

在高效能計算中，**正確性是基礎，效能是目標**。本指南將幫助您建立優化思維，寫出既正確又快速的程式。

### 效能優化的黃金法則

1. **先求正確，再求快速** - 錯誤的快程式毫無價值
2. **測量，不要猜測** - 用 profiler 找出真正的瓶頸
3. **優化熱點** - 80% 的時間花在 20% 的程式碼上
4. **了解硬體特性** - CPU cache、GPU 記憶體架構等

---

## 📊 程式設計基本概念

### 1. 時間複雜度 (Time Complexity)

了解演算法的時間複雜度可幫助您選擇正確的實作方式。

| 複雜度 | 範例 | N=1000 時的操作次數 | 評價 |
|-------|------|-------------------|-----|
| O(1) | 陣列索引 `A[i]` | 1 | 優秀 |
| O(log N) | 二分搜尋 | ~10 | 優秀 |
| O(N) | 簡單迴圈 | 1,000 | 良好 |
| O(N log N) | 快速排序 | ~10,000 | 可接受 |
| O(N²) | 雙層迴圈 | 1,000,000 | 需優化 |
| O(N³) | 三層迴圈 | 1,000,000,000 | 避免 |

**實例對比：**

```cpp
// ❌ O(N²) - 慢版本
for (int i = 0; i < n; i++) {
  for (int j = 0; j < n; j++) {
    sum += A[i] * B[j];  // 不必要的雙層迴圈
  }
}

// ✅ O(N) - 快版本
float sumA = 0, sumB = 0;
for (int i = 0; i < n; i++) {
  sumA += A[i];
  sumB += B[i];
}
float result = sumA * sumB;  // 數學上等價
```

---

### 2. 記憶體階層 (Memory Hierarchy)

現代電腦的記憶體分為多個層級，存取速度差異巨大：

```
CPU 暫存器    <---- 最快 (0.5 ns)
    ↓
L1 Cache      <---- 快   (1-2 ns)
    ↓
L2 Cache      <---- 中   (3-10 ns)
    ↓
L3 Cache      <---- 稍慢 (10-20 ns)
    ↓
主記憶體 (RAM) <---- 慢   (50-100 ns)
    ↓
硬碟/SSD      <---- 非常慢 (1,000,000 ns)
```

**關鍵概念**：盡可能讓資料停留在快速記憶體中！

---

## ⚡ HPC 優化技巧

### 1. Cache Locality (資料局部性)

**原理**：充分利用 CPU cache，減少主記憶體存取次數。

#### 1.1 空間局部性 (Spatial Locality)

連續存取記憶體中相鄰的資料。

```fortran
! ❌ 慢版本：列優先存取 (對 Fortran 不友善)
do j = 1, N
  do i = 1, N
    A(i, j) = i + j
  end do
end do

! ✅ 快版本：行優先存取 (Fortran 的記憶體配置方式)
do j = 1, N
  do i = 1, N
    A(i, j) = i + j  ! 這樣寫其實是對的
  end do
end do
```

> ⚠️ **重要**：Fortran 是 **column-major**（行優先），C/C++ 是 **row-major**（列優先）！

```cpp
// C++ 範例
// ❌ 慢版本：跳躍存取
for (int i = 0; i < N; i++) {
  for (int j = 0; j < N; j++) {
    A[j][i] = i + j;  // 跳著讀取
  }
}

// ✅ 快版本：連續存取
for (int i = 0; i < N; i++) {
  for (int j = 0; j < N; j++) {
    A[i][j] = i + j;  // 連續讀取
  }
}
```

**效能差異**：在 N=10000 時，快版本可快 **5-10 倍**！

---

#### 1.2 時間局部性 (Temporal Locality)

重複使用最近存取過的資料。

```cpp
// ❌ 慢版本：重複從記憶體讀取
for (int i = 0; i < n; i++) {
  result[i] = sqrt(x[i]) + sqrt(x[i]) + sqrt(x[i]);
}

// ✅ 快版本：用暫存變數存放
for (int i = 0; i < n; i++) {
  float temp = sqrt(x[i]);  // 只計算一次
  result[i] = temp + temp + temp;
}
```

---

### 2. Loop Optimization (迴圈優化)

#### 2.1 迴圈融合 (Loop Fusion)

```cpp
// ❌ 慢版本：兩次迴圈
for (int i = 0; i < n; i++) {
  A[i] = B[i] + C[i];
}
for (int i = 0; i < n; i++) {
  D[i] = A[i] * 2.0;
}

// ✅ 快版本：合併迴圈
for (int i = 0; i < n; i++) {
  A[i] = B[i] + C[i];
  D[i] = A[i] * 2.0;
}
```

**原因**：減少迴圈控制開銷，提升 cache 命中率。

---

#### 2.2 迴圈展開 (Loop Unrolling)

```cpp
// ❌ 一般版本
for (int i = 0; i < n; i++) {
  sum += A[i];
}

// ✅ 手動展開（處理 4 個元素）
for (int i = 0; i < n - 3; i += 4) {
  sum += A[i] + A[i+1] + A[i+2] + A[i+3];
}
// 處理剩餘元素
for (int i = (n/4)*4; i < n; i++) {
  sum += A[i];
}
```

**效果**：減少迴圈判斷次數，利於編譯器向量化優化。

---

### 3. Memory Alignment (記憶體對齊)

現代 CPU 偏好從對齊的記憶體位址讀取資料（如 16-byte 或 64-byte 邊界）。

```cpp
// C++ 範例：確保陣列對齊
#include <cstdlib>

// ❌ 一般配置（可能未對齊）
float* A = new float[n];

// ✅ 對齊配置（64-byte 對齊，適合 AVX-512）
float* A = (float*)aligned_alloc(64, n * sizeof(float));
// 使用完後記得釋放
free(A);
```

**Fortran 自動對齊**，無需特別處理。

---

### 4. Compiler Optimization Flags (編譯器優化)

善用編譯器優化選項：

#### Fujitsu 編譯器 (A64FX 平台)

| 選項 | 說明 | 加速效果 |
|-----|------|---------|
| `-Kfast` | 激進優化（推薦） | 2-4x |
| `-KSVE` | **ARM SVE 512-bit 向量化** ⭐ | 額外 2-3x (向量運算) |
| `-Kopenmp` | 啟用 OpenMP 多執行緒 | 理想上 48x (A64FX 48核) |
| `-Koptmsg=2` | 顯示優化訊息 | 診斷用 |
| `-Nquickdbg` | 快速除錯（保持部分優化） | 除錯時使用 |

**範例（Fujitsu A64FX）：**

```bash
# Fortran - 基礎優化
frt -Kfast program.f90 -o program

# Fortran - 完整優化（啟用 SVE 向量化）
frt -Kfast -KSVE -Kopenmp program.f90 -o program

# C++ - 完整優化
FCC -Kfast -KSVE -Kopenmp -std=c++11 program.cpp -o program

# 查看向量化報告
frt -Kfast -KSVE -Koptmsg=2 program.f90 -o program
```

#### ARM SVE 向量化關鍵

A64FX 的 **ARM SVE (Scalable Vector Extension)** 是 512-bit 向量指令集，一次可處理 8 個 double 或 16 個 float：

```
一般運算:   A + B = C           (一次 1 個)
ARM SVE:    [A₀...A₇] + [B₀...B₇] = [C₀...C₇]  (一次 8 個)
```

**使用 `-KSVE` 後，編譯器會自動：**
- 將迴圈向量化
- 使用 SVE 指令
- 預期加速 2-3 倍（向量密集運算）

---

#### 對比：x86 平台編譯器（參考）

若在 x86 平台上：

| 選項 | 說明 | 加速效果 |
|-----|------|---------|
| `-O2` | 推薦的安全優化 | 1.5-3x |
| `-O3` | 激進優化（含迴圈向量化） | 2-5x |
| `-march=native` | 針對當前 CPU 優化 (AVX/AVX-512) | 1.2-2x |
| `-ffast-math` | 放寬浮點數精度要求 | 1.1-1.5x |

---

## 🚀 GPU 優化思維

### GPU vs CPU 的關鍵差異

| 特性 | CPU | GPU |
|-----|-----|-----|
| **核心數** | 少（4-64） | 多（數千） |
| **時脈** | 高（3-5 GHz） | 低（1-2 GHz） |
| **適合任務** | 複雜邏輯、分支多 | 大量平行、簡單運算 |
| **記憶體頻寬** | 中 (~50 GB/s) | 高 (~900 GB/s) |

### GPU 優化重點

#### 1. 最大化平行度

```cuda
// ❌ 太少 threads
kernel<<<1, 256>>>(data, n);  // 只有 256 threads

// ✅ 充分利用 GPU
int threads = 256;
int blocks = (n + threads - 1) / threads;
kernel<<<blocks, threads>>>(data, n);  // 數千/數萬 threads
```

---

#### 2. 減少 Host-Device 資料傳輸

**資料傳輸速度 << 運算速度**，盡可能在 GPU 上完成所有運算。

```cuda
// ❌ 慢版本：反覆傳輸
for (int iter = 0; iter < 1000; iter++) {
  cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
  kernel<<<blocks, threads>>>(d_A);
  cudaMemcpy(h_A, d_A, size, cudaMemcpyDeviceToHost);
}

// ✅ 快版本：一次傳輸，多次運算
cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
for (int iter = 0; iter < 1000; iter++) {
  kernel<<<blocks, threads>>>(d_A);
}
cudaMemcpy(h_A, d_A, size, cudaMemcpyDeviceToHost);
```

---

#### 3. Coalesced Memory Access (合併記憶體存取)

GPU 中相鄰 threads 應存取相鄰記憶體位址。

```cuda
__global__ void kernel(float* A, int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  
  // ✅ 好：threads 0,1,2,... 存取 A[0], A[1], A[2]...（連續）
  if (i < n) A[i] = i;
  
  // ❌ 壞：threads 存取不連續記憶體
  // if (i < n) A[i * 1000] = i;  // 跳躍存取
}
```

---

## 📈 效能測量

### 如何驗證優化有效？

#### CPU 程式計時 (C++)

```cpp
#include <chrono>

auto start = std::chrono::high_resolution_clock::now();

// ... 你的程式碼 ...

auto end = std::chrono::high_resolution_clock::now();
std::chrono::duration<double> elapsed = end - start;
std::cout << "Time: " << elapsed.count() << " s\n";
```

#### Fortran 計時

```fortran
real :: start, finish

call cpu_time(start)

! ... 你的程式碼 ...

call cpu_time(finish)
print *, 'Time:', finish - start, 's'
```

#### CUDA 計時

```cuda
cudaEvent_t start, stop;
cudaEventCreate(&start);
cudaEventCreate(&stop);

cudaEventRecord(start);
kernel<<<blocks, threads>>>(data);
cudaEventRecord(stop);

cudaEventSynchronize(stop);
float milliseconds = 0;
cudaEventElapsedTime(&milliseconds, start, stop);
printf("Kernel time: %f ms\n", milliseconds);
```

---

## 🎓 優化流程建議

1. **寫出正確的程式** - 先通過功能測試
2. **測量基準效能** - 記錄原始執行時間
3. **找出瓶頸** - 用 profiler (如 `gprof`, `perf`, `nvprof`)
4. **針對熱點優化** - 只優化佔用時間最多的部分
5. **測量改進效果** - 對比優化前後的時間
6. **驗證正確性** - 確保結果未改變
7. **重複 3-6** - 持續優化直到滿意

---

## 💡 常見優化迷思

| 迷思 | 真相 |
|-----|------|
| "我的程式碼很短，一定很快" | 短不等於快，關鍵在演算法複雜度 |
| "GPU 一定比 CPU 快" | 小資料量時 GPU 反而慢（傳輸成本高） |
| "多執行緒一定更快" | 平行化有開銷，資料相依性也會限制加速 |
| "優化就是加 `-O3`" | 編譯器優化有限，演算法優化更重要 |

---

## 📚 延伸閱讀

- **《Computer Architecture: A Quantitative Approach》** - Hennessy & Patterson
- **CUDA Best Practices Guide**：https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/
- **Compiler Explorer**：https://godbolt.org/ (觀察編譯器優化結果)

---

**記住：優化是一門科學，也是一門藝術。持續學習，不斷實踐！🚀**
