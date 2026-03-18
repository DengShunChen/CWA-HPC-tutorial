# Part 1: CPU 程式語言速成課程

> 上半年場次（3 小時） - Fortran 與 C++ 基礎

---

## 📋 課程目標

讓完全初學者能夠：
1. 編譯並執行簡單的 Fortran 與 C++ 程式
2. 理解基本的陣列操作與記憶體管理
3. 認識效能優化的基本概念
4. 能修改現有程式碼完成簡單任務

---

## ⏱️ 時程安排 (擴充版)

### 核心課程 (3 小時)

| 時間 | 主題 | 資料夾 | 重點 |
|-----|------|--------|------|
| 20 min | HPC Hello World | [`01_Hello/`](01_Hello/) | 環境測試、編譯流程 |
| 50 min | 向量運算與優化 | [`02_Vector_Add/`](02_Vector_Add/) | 陣列操作、效能對比 |
| 40 min | 動手練習 | [`03_Challenge/`](03_Challenge/) | 修改程式、獨立實作 |
| 50 min | 矩陣運算與快取 | [`04_Matrix_Operations/`](04_Matrix_Operations/) | 2D 陣列、快取優化 |
| 30 min | 檔案 I/O | [`05_File_IO/`](05_File_IO/) | 資料讀寫 |
| 30 min | 自由練習時間 | 各章節 | 複習與提問 |

### 進階選修（自學或延伸課程）

| 主題 | 資料夾 | 重點 |
|------|--------|------|
| 函數與模組化 | [`06_Functions_Modules/`](06_Functions_Modules/) | 程式碼組織、多檔案編譯 |
| 資料結構 | [`07_Structures/`](07_Structures/) | Derived Types、Struct/Class |

---

## 📂 章節內容

### [01_Hello](01_Hello/) - 環境測試

**學習目標**：
- 確認 Fortran 與 C++ 編譯器可正常運作
- 熟悉基本的編輯-編譯-執行流程

**檔案**：
- `hello.f90` - Fortran Hello World
- `hello.cpp` - C++ Hello World
- `Makefile` - 統一編譯腳本

---

### [02_Vector_Add](02_Vector_Add/) - 向量運算（核心教學）

**學習目標**：
- 理解陣列宣告與記憶體配置
- 學習基本的迴圈與陣列操作
- **重點**：對比「慢版」與「快版」程式，理解優化技巧

**檔案**：
- `vec_add.f90` - Fortran 基礎版本
- `vec_add.cpp` - C++ 基礎版本
- `vec_add_optimized.f90` - Fortran 優化版本⚡
- `vec_add_optimized.cpp` - C++ 優化版本⚡
- `README.md` - 程式碼詳細說明與優化解析

**重點概念**：
- Cache locality（資料局部性）
- 編譯器優化選項
- 計時測量

---

### [03_Challenge](03_Challenge/) - 練習題

**學習目標**：
- 獨立修改程式碼
- 應用所學的優化技巧

**任務**：
將向量加法 (`C = A + B`) 改為向量乘法 (`C = A * B`)，並測量效能。

---

### [04_Matrix_Operations](04_Matrix_Operations/) - 矩陣運算與快取優化

**學習目標**：
- 理解二維陣列的宣告與操作
- 學習快取友善的演算法設計
- **重點**：理解迴圈順序對效能的巨大影響

**檔案**：
- `matrix_multiply.f90` / `matrix_multiply.cpp` - 基礎版本
- `matrix_multiply_optimized.f90` / `matrix_multiply_optimized.cpp` - 優化版本⚡
- `README.md` - 快取局部性與 Blocking 技巧詳解

**重點概念**：
- Cache locality（快取局部性）
- Loop interchange（迴圈重排序）
- Blocking/Tiling（分塊技術）
- Row-major vs Column-major 記憶體佈局

---

### [05_File_IO](05_File_IO/) - 檔案輸入輸出

**學習目標**：
- 學習讀寫文字與二進位檔案
- 理解檔案 I/O 的效能考量
- 掌握錯誤處理技巧

**檔案**：
- `file_io.f90` / `file_io.cpp` - 檔案讀寫範例
- `sample_input.txt` - 範例資料檔

**重點概念**：
- 文字檔案 vs 二進位檔案
- 緩衝 (Buffering)
- 格式化輸出

---

### [06_Functions_Modules](06_Functions_Modules/) - 函數與模組化

**學習目標**：
- 學習 Fortran 模組系統
- 理解 C++ 標頭檔/原始檔分離
- 掌握多檔案專案編譯

**檔案**：
- Fortran: `math_module.f90` + `main_program.f90`
- C++: `math_functions.h` + `math_functions.cpp` + `main_program.cpp`

**重點概念**：
- 程式碼重用性
- 編譯相依性
- 介面設計

---

### [07_Structures](07_Structures/) - 資料結構

**學習目標**：
- 理解 Fortran Derived Types
- 學習 C++ Struct/Class
- 掌握結構化資料組織

**檔案**：
- `particle_simulation.f90` / `particle_simulation.cpp` - 粒子模擬範例

**重點概念**：
- 自訂資料型態
- 記憶體佈局
- AoS vs SoA（Array of Structures vs Structure of Arrays）

---

## 🎓 學習建議

### 課前準備
1. 確認編譯器已安裝（`gfortran`, `g++`）
2. 複習 [`00_Cheatsheets/syntax_rosetta_stone.md`](../00_Cheatsheets/syntax_rosetta_stone.md)

### 上課方式
1. **不要死記語法** - 隨時查閱語法對照表
2. **動手實作** - 每個範例都親自編譯執行
3. **思考為什麼** - 理解優化背後的原理
4. **提問** - 不懂就問！

### 課後複習
1. 完成 `03_Challenge` 練習題
2. 閱讀 [`00_Cheatsheets/optimization_mindset.md`](../00_Cheatsheets/optimization_mindset.md)
3. 嘗試修改範例程式，觀察效能變化

---

## 🔧 環境需求

- **Fortran 編譯器**：`gfortran` (GCC >= 7.0)
- **C++ 編譯器**：`g++` (支援 C++11)
- **Make 工具**：`make`
-文字編輯器**：vim, emacs, nano, VSCode 等

### 快速測試環境

```bash
# 測試 Fortran 編譯器
gfortran --version

# 測試 C++ 編譯器
g++ --version

# 測試 Make
make --version
```

---

## 💡 常見問題

### Q: Fortran 和 C++ 該學哪一個？
**A**: 兩者各有優勢。Fortran 在數值計算領域歷史悠久，許多氣象/流體模式用 Fortran 撰寫；C++ 則更通用，生態系統更豐富。建議兩者都有基本認識。

### Q: 為什麼要學這麼「古老」的語言？
**A**: Fortran 與 C++ 在 HPC 領域仍是主流，許多大型科學計算程式庫（如 BLAS, LAPACK）都用這些語言撰寫。Python 等高階語言底層也常呼叫 Fortran/C++ 函式庫。

### Q: 優化真的有必要嗎？
**A**: 在 HPC 中絕對必要！一個程式可能需要跑數天甚至數週，若能優化 2 倍效能，就能節省一半的時間與運算資源成本。

---

**準備好了嗎？讓我們開始！🚀**
