# 04_Matrix_Operations - 矩陣運算與快取優化

> 學習二維陣列操作與快取友善演算法

---

## 🎯 學習目標

1. 理解二維陣列的宣告與記憶體配置
2. 學習矩陣乘法的基本實作
3. **重點**：理解快取局部性對效能的巨大影響
4. 學習迴圈重排序 (Loop Interchange) 與分塊 (Blocking/Tiling) 優化技巧

---

## 📝 檔案說明

| 檔案 | 說明 | 特色 |
|------|------|------|
| `matrix_multiply.f90` | Fortran 基礎版 | i-j-k 迴圈順序 |
| `matrix_multiply.cpp` | C++ 基礎版 | i-j-k 迴圈順序 |
| `matrix_multiply_optimized.f90` | Fortran 優化版 ⚡ | 使用內建 MATMUL |
| `matrix_multiply_optimized.cpp` | C++ 優化版 ⚡ | i-k-j 順序 + Blocking |
| `job_matrix.sh` | **PJM** 批次範例 | `pjsub` 於計算節點執行 `make` 與 `make run_all` |

---

## 🚀 快速開始

```bash
# 編譯所有程式
make all

# 執行效能對比測試
make run_all

# 清除執行檔
make clean
```

### 於 FX1000 上以 PJM 提交（主線）

本章 `job_matrix.sh` 與 [`02_Vector_Add/job_vec_add.sh`](../02_Vector_Add/job_vec_add.sh) 相同，使用 **Fujitsu PJM**（`#PJM` 指令列、`pjsub` 提交）。請將腳本內 `<your_group>` 改為實際群組後，在 **`04_Matrix_Operations` 目錄**執行：

```bash
pjsub job_matrix.sh
```

作業內會 `module load lang/tcsds-1.2.37`、重新 `make` 並執行 `make run_all`；標準輸出／錯誤合併寫入 `matrix_multiply_benchmark.log`（依腳本中 `#PJM -o` 設定）。PJM 指令與錯誤排除見 [`../../00_Cheatsheets/pjm_batch_system.md`](../../00_Cheatsheets/pjm_batch_system.md)。

---

## 📊 矩陣乘法基礎

### 運算定義

矩陣乘法 C = A × B，其中 A, B, C 都是 n×n 矩陣：

```
C[i][j] = Σ(k=0 to n-1) A[i][k] * B[k][j]
```

**運算量**：2n³ 次浮點運算（n³ 次乘法 + n³ 次加法）

---

## 🔍 為什麼矩陣乘法很重要？

矩陣乘法是許多科學計算的核心運算：
- 線性代數求解器
- 深度學習（神經網路訓練）
- 圖形渲染（3D 轉換）
- 物理模擬（有限元素法）

**效能關鍵**：矩陣乘法是**記憶體頻寬受限**的運算，優化重點在於減少記憶體存取次數。

---

## 💡 基礎版本：三層迴圈

### Fortran 實作

```fortran
! i-j-k 順序
do i = 1, n
  do j = 1, n
    sum_val = 0.0d0
    do k = 1, n
      sum_val = sum_val + A(i,k) * B(k,j)
    end do
    C(i,j) = sum_val
  end do
end do
```

### C++ 實作

```cpp
// i-j-k 順序
for (int i = 0; i < n; i++) {
  for (int j = 0; j < n; j++) {
    double sum = 0.0;
    for (int k = 0; k < n; k++) {
      sum += A[i*n + k] * B[k*n + j];
    }
    C[i*n + j] = sum;
  }
}
```

---

## ⚡ 優化技巧詳解

### 1. Fortran：使用內建 MATMUL

```fortran
! ✅ 一行搞定，編譯器會自動優化
C = matmul(A, B)
```

**為什麼快？**
- 編譯器針對 MATMUL 有專門的優化實作
- 自動選擇最佳迴圈順序
- 利用 BLAS (Basic Linear Algebra Subprograms) 函式庫
- 自動應用 SIMD 向量化

---

### 2. C++：迴圈重排序 (Loop Interchange)

```cpp
// ❌ 基礎版：i-j-k 順序
for (int i = 0; i < n; i++) {
  for (int j = 0; j < n; j++) {
    for (int k = 0; k < n; k++) {
      C[i*n + j] += A[i*n + k] * B[k*n + j];
    }
  }
}

// ✅ 優化版：i-k-j 順序
for (int i = 0; i < n; i++) {
  for (int k = 0; k < n; k++) {
    double a_ik = A[i*n + k];  // 重用這個值
    for (int j = 0; j < n; j++) {
      C[i*n + j] += a_ik * B[k*n + j];
    }
  }
}
```

**為什麼 i-k-j 比 i-j-k 快？**

在 C++ 中，陣列是 **row-major**（列優先）儲存：
- `i-k-j` 順序：內層迴圈 (j) 連續存取 `B[k*n + j]` 和 `C[i*n + j]` → **cache friendly**
- `i-j-k` 順序：內層迴圈 (k) 跳躍存取 `B[k*n + j]` → **cache miss 多**

---

### 3. C++：分塊 (Blocking/Tiling)

```cpp
const int block_size = 64;  // 配合 CPU cache 大小

// 將矩陣分成小塊處理
for (int ii = 0; ii < n; ii += block_size) {
  for (int kk = 0; kk < n; kk += block_size) {
    for (int jj = 0; jj < n; jj += block_size) {
      
      // 在每個小塊內執行矩陣乘法
      for (int i = ii; i < min(ii+block_size, n); i++) {
        for (int k = kk; k < min(kk+block_size, n); k++) {
          for (int j = jj; j < min(jj+block_size, n); j++) {
            C[i*n + j] += A[i*n + k] * B[k*n + j];
          }
        }
      }
      
    }
  }
}
```

**為什麼分塊有效？**
- 小塊矩陣可以完全放入 L1/L2 cache
- 減少從主記憶體讀取的次數
- 提高資料重用率 (Data Reuse)

---

## 🧠 快取局部性原理

### Cache 階層

```
CPU 核心
  ↕ 
L1 Cache (~32 KB, 1-2 cycles)
  ↕
L2 Cache (~256 KB, 10-20 cycles)
  ↕
L3 Cache (~8 MB, 40-60 cycles)
  ↕
主記憶體 (~GB, 200+ cycles)
```

### 記憶體存取模式

**不良模式 (i-j-k 在 C++)**：
```
存取 B[0][j], B[1][j], B[2][j], ...
每次跳過 n 個元素 → 許多 cache miss
```

**良好模式 (i-k-j 在 C++)**：
```
存取 B[k][0], B[k][1], B[k][2], ...
連續存取 → cache prefetching 有效
```

---

## 📈 預期效能差異

在典型的現代 CPU 上（如 Intel Xeon），n=512 的矩陣乘法：

```
Fortran 基礎版 (i-j-k):     0.8-1.2 秒  (~0.3 GFLOPS)
Fortran 優化版 (MATMUL):    0.03-0.05 秒 (~8-15 GFLOPS) ⚡ 快 20-30 倍
C++ 基礎版 (i-j-k):         0.8-1.0 秒  (~0.4 GFLOPS)
C++ 優化版 (blocking):      0.1-0.2 秒  (~2-4 GFLOPS) ⚡ 快 5-8 倍
```

> ⚠️ 實際數字會因 CPU 型號、cache 大小、編譯器版本而異

---

## 🔬 延伸實驗

### 實驗 1：不同矩陣大小

修改程式中的 `n` 值，測試不同大小：

```fortran
integer, parameter :: n = 128   ! 小矩陣
integer, parameter :: n = 512   ! 中矩陣
integer, parameter :: n = 1024  ! 大矩陣
```

**觀察**：小矩陣可能看不出差異，大矩陣差異會更明顯

---

### 實驗 2：不同迴圈順序

在基礎版本中，將 i-j-k 改為其他順序：
- i-k-j
- j-i-k
- j-k-i
- k-i-j
- k-j-i

**問題**：哪個順序最快？為什麼？

---

### 實驗 3：調整 Blocking 大小

在 C++ 優化版中，嘗試不同的 `block_size`：

```cpp
const int block_size = 16;   // 太小
const int block_size = 64;   // 適中（推薦）
const int block_size = 256;  // 太大
```

**提示**：理想的 block_size 應該讓 3 個小塊矩陣可以同時放入 L1 cache

---

## 💻 Fortran vs C++ 記憶體佈局差異

### Fortran：Column-Major（列優先）

```fortran
real(8) :: A(3,3)
! 記憶體中的順序：A(1,1), A(2,1), A(3,1), A(1,2), A(2,2), ...
! 最內層索引（第一個）變化最快
```

**最佳迴圈順序**：外層 j，內層 i

---

### C++：Row-Major（行優先）

```cpp
double A[3][3];
// 記憶體中的順序：A[0][0], A[0][1], A[0][2], A[1][0], A[1][1], ...
// 最右側索引（第二個）變化最快
```

**最佳迴圈順序**：外層 i，內層 j

---

## 📚 重要概念總結

| 概念 | 說明 | 影響 |
|------|------|------|
| **Cache Locality** | 資料在記憶體中的連續性 | 2-30 倍效能差異 |
| **Loop Interchange** | 調整迴圈順序 | 提高 cache hit rate |
| **Blocking/Tiling** | 將大問題分成小塊 | 提高資料重用率 |
| **SIMD** | 單指令多資料 | 編譯器自動優化 |
| **FLOPS** | 每秒浮點運算次數 | 效能指標 |

---

## ✅ 檢查清單

完成後，確認你已經理解：

- [ ] 矩陣乘法的三層迴圈實作
- [ ] Fortran 的 column-major vs C++ 的 row-major
- [ ] 為什麼迴圈順序會影響效能
- [ ] Cache 階層與記憶體存取時間
- [ ] 什麼是 Blocking/Tiling
- [ ] 如何測量 GFLOPS

---

## 📖 延伸閱讀

- [優化思維指南](../../00_Cheatsheets/optimization_mindset.md) - 系統性優化方法
- [編譯指令速查表](../../00_Cheatsheets/compilation_guide.md) - 編譯器優化選項
- 外部資源：
  - *What Every Programmer Should Know About Memory* - Ulrich Drepper
  - *Computer Architecture: A Quantitative Approach* - Hennessy & Patterson

---

**下一步：前往 [`05_File_IO`](../05_File_IO/) 學習檔案讀寫操作 🚀**
