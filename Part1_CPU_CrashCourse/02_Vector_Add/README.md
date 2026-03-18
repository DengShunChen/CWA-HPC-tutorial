# 02_Vector_Add - 向量運算與優化

> 核心教學內容：陣列操作與效能優化

---

## 🎯 學習目標

1. 理解動態陣列的配置與釋放
2. 學習基本的向量運算
3. **重點**：透過「基礎版」vs「優化版」理解效能優化技巧
4. 學會使用計時器測量程式效能

---

## 📝 檔案說明

| 檔案 | 說明 | 編譯選項 |
|------|------|---------|
| `vec_add.f90` | Fortran 基礎版 | `-O2` |
| `vec_add.cpp` | C++ 基礎版 | `-O2` |
| `vec_add_optimized.f90` | Fortran 優化版 ⚡ | `-O3 -march=native` |
| `vec_add_optimized.cpp` | C++ 優化版 ⚡ | `-O3 -march=native` |

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

---

## 📊 程式碼解析

### 基礎版本邏輯

#### Fortran (`vec_add.f90`)

```fortran
! 1. 配置記憶體
allocate(A(n), B(n), C(n))

! 2. 初始化（使用迴圈）
do i = 1, n
  A(i) = real(i, 8)
  B(i) = real(i, 8) * 2.0d0
end do

! 3. 向量加法（使用迴圈）
do i = 1, n
  C(i) = A(i) + B(i)
end do
```

#### C++ (`vec_add.cpp`)

```cpp
// 1. 配置記憶體
double* A = new double[n];

// 2. 初始化（使用迴圈）
for (int i = 0; i < n; i++) {
  A[i] = static_cast<double>(i);
}

// 3. 向量加法（使用迴圈）
for (int i = 0; i < n; i++) {
  C[i] = A[i] + B[i];
}
```

---

### 優化版本技巧

#### Fortran 優化 (`vec_add_optimized.f90`)

**核心技巧**：利用 Fortran 內建的陣列運算

```fortran
! ❌ 基礎版：手動迴圈
do i = 1, n
  C(i) = A(i) + B(i)
end do

! ✅ 優化版：陣列運算（編譯器自動向量化）
C = A + B
```

**優勢**：
- 程式碼更簡潔
- 編譯器可自動應用 SIMD（單指令多資料）優化
- 減少迴圈控制開銷

---

#### C++ 優化 (`vec_add_optimized.cpp`)

**核心技巧**：手動迴圈展開 (Loop Unrolling)

```cpp
// ❌ 基礎版：一次處理一個元素
for (int i = 0; i < n; i++) {
  C[i] = A[i] + B[i];
}

// ✅ 優化版：一次處理四個元素
for (i = 0; i < n - 3; i += 4) {
  C[i]   = A[i]   + B[i];
  C[i+1] = A[i+1] + B[i+1];
  C[i+2] = A[i+2] + B[i+2];
  C[i+3] = A[i+3] + B[i+3];
}
```

**優勢**：
- 減少迴圈判斷次數（從 n 次減少到 n/4 次）
- 增加指令層級平行性 (ILP)
- 編譯器更容易應用向量化優化

---

## ⚡ 編譯器優化選項對比

| 選項 | 說明 | 預期加速 |
|-----|------|---------|
| `-O2` | 標準優化（基礎版使用） | 1.5-2x |
| `-O3` | 激進優化（含自動向量化） | 2-4x |
| `-march=native` | 針對當前 CPU 指令集優化 | 額外 1.2-1.5x |
| `-ffast-math` | 放寬浮點數精度標準 | 額外 1.1-1.3x |

---

## 📈 預期效能差異

在典型的現代 CPU 上（如 Intel Xeon 或 AMD EPYC），預期效能對比：

```
Fortran 基礎版:     0.050 秒
Fortran 優化版:     0.015 秒  (快 3.3 倍 ⚡)

C++ 基礎版:         0.055 秒
C++ 優化版:         0.020 秒  (快 2.8 倍 ⚡)
```

> ⚠️ 實際數字會因 CPU 型號、記憶體頻寬等因素而異。

---

## 🔍 優化原理深入解析

### 1. SIMD 向量化

現代 CPU 支援 SIMD 指令（如 AVX、AVX-512），可同時處理多個資料：

```
一般指令:  A + B = C   (一次一個)
AVX-512:   [A₀ A₁ ... A₇] + [B₀ B₁ ... B₇] = [C₀ C₁ ... C₇]  (一次 8 個)
```

**編譯器優化關鍵**：
- `-O3` 啟用自動向量化
- `-march=native` 使用當前 CPU 的最新 SIMD 指令集

---

### 2. Cache Friendly Access

向量加法是 **記憶體頻寬受限** 的運算：

```
時間 = 讀取 A + 讀取 B + 寫入 C + 運算
     = 大    + 大    + 大    + 小
```

**優化重點**：
- 連續存取記憶體（利用 cache line prefetching）
- 減少不必要的記憶體搬移

---

## 💡 延伸思考

### Q1: 為什麼不是所有程式都用 `-O3`？

**A**: `-O3` 可能導致：
- 編譯時間變長
- 程式碼體積變大（影響 instruction cache）
- 極少數情況下產生數值精度問題

在開發階段建議用 `-O2`，最終版本再用 `-O3`。

---

### Q2: Fortran 的陣列運算速度一定比手動迴圈快嗎？

**A**: 通常是，但不保證。關鍵在於：
- 編譯器的優化能力
- 陣列大小（太小的陣列看不出差異）
- CPU 的 SIMD 支援

**最佳實踐**：總是測量！

---

## ✅ 實驗練習

1. **基礎練習**：運行 `make run_all`，觀察四個版本的效能差異

2. **進階練習**：修改向量長度 `n`，測試不同資料量的效能表現
   ```bash
   # 小資料量 (10^4)
   # 中資料量 (10^6)
   # 大資料量 (10^8)
   ```

3. **編譯器實驗**：嘗試不同優化組合
   ```bash
   gfortran -O2 vec_add.f90 -o test1
   gfortran -O3 vec_add.f90 -o test2
   gfortran -O3 -march=native vec_add.f90 -o test3
   ```

---

## 📚 延伸閱讀

- [HPC 優化思維指南](../../00_Cheatsheets/optimization_mindset.md) - 完整的優化技巧
- [編譯指令速查表](../../00_Cheatsheets/compilation_guide.md) - 編譯器選項說明

---

**下一步：完成 [`03_Challenge`](../03_Challenge/) 練習題，實踐所學知識！🚀**
