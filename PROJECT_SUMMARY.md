# ProgramingTutorial 專案摘要

> 最後更新：2025-03-18

---

## 一、專案概述

**ProgramingTutorial** 是一套為**完全初學者**設計的高效能計算（HPC）程式設計入門教材，涵蓋 **Fortran**、**C++** 與 **CUDA GPU** 加速。教材採用年度系列工作坊形式，分兩次上課（各 3 小時），目標是讓學員能讀懂、修改並優化數值計算程式。

### 核心特色

| 特色 | 說明 |
|------|------|
| **對比學習** | 同一功能以 Fortran / C++ / CUDA 三種語言實作，便於快速掌握差異 |
| **範例導向** | 不教繁瑣語法，直接透過可執行範例學習 |
| **優化思維** | 每個範例提供「慢版」vs「快版」，展示效能差異與優化技巧 |
| **實戰收尾** | 以熱傳導數值模擬案例整合所學知識 |

### 目標平台

- **主要**：Fujitsu A64FX (FX1000) — ARM v8.2-A + SVE 512-bit
- **編譯器**：Fujitsu frtpx (Fortran)、FCC (C++)
- **批次系統**：PJM (Parallels Job Manager)
- **GPU**：NVIDIA CUDA（下半年課程）

---

## 二、專案結構

```
ProgramingTutorial/
├── README.md                    # 專案主說明、快速開始
├── PROJECT_SUMMARY.md           # 本檔案：專案摘要
├── Makefile                     # 頂層編譯腳本
│
├── 00_Cheatsheets/              # 快速參考
│   ├── syntax_rosetta_stone.md  # Fortran/C++/CUDA 語法對照
│   ├── compilation_guide.md     # 編譯指令速查
│   ├── optimization_mindset.md  # HPC 優化思維
│   └── pjm_batch_system.md      # PJM 批次系統說明
│
├── Part1_CPU_CrashCourse/        # 上半年：CPU 程式語言（3 小時）
│   ├── 01_Hello/                # 環境測試
│   ├── 02_Vector_Add/           # 向量運算與優化（核心）
│   ├── 03_Challenge/            # 練習題
│   ├── 04_Matrix_Operations/    # 矩陣運算與快取優化
│   ├── 05_File_IO/              # 檔案 I/O
│   ├── 06_Functions_Modules/    # 函數與模組化
│   └── 07_Structures/           # 資料結構
│
└── Part2_GPU_CrashCourse/        # 下半年：GPU 加速（3 小時）
    ├── 01_CUDA_Hello/           # GPU 環境確認
    ├── 02_Vector_Add_GPU/      # 向量加法 GPU 版
    └── 03_Heat_Diffusion_Demo/  # 熱傳導模擬（實戰框架）
```

---

## 三、技術棧

| 類別 | 技術 | 說明 |
|------|------|------|
| **語言** | Fortran 90 | 數值計算 |
| **語言** | C++11 | 數值計算 |
| **語言** | CUDA C | GPU 平行運算 |
| **編譯器** | Fujitsu frtpx / FCC | A64FX 平台 |
| **編譯器** | gfortran / g++ | x86 平台（部分章節） |
| **編譯器** | nvcc | CUDA |
| **建構** | Make | 編譯與建構 |
| **批次** | PJM / PBS | 作業管理 |

---

## 四、主要範例與學習重點

| 章節 | 範例 | 學習重點 |
|------|------|----------|
| 02_Vector_Add | 向量加法 | 迴圈展開、陣列運算、SIMD 向量化 |
| 04_Matrix_Operations | 矩陣乘法 | 快取局部性、迴圈重排序、Blocking |
| 02_Vector_Add_GPU | GPU 向量加法 | CUDA kernel、Host-Device 記憶體、效能測試 |
| 03_Heat_Diffusion_Demo | 熱傳導模擬 | 2D 有限差分法、CPU vs GPU 對比 |

---

## 五、建構與執行

### 頂層 Makefile 目標

```bash
make all     # 編譯所有教材
make part1   # 只編譯 Part 1 (01_Hello, 02_Vector_Add)
make part2   # 只編譯 Part 2 (01_CUDA_Hello, 02_Vector_Add_GPU)
make clean   # 清除執行檔
make help    # 顯示說明
```

**注意**：頂層 Makefile 僅編譯部分章節。`03_Challenge`、`04_Matrix_Operations`、`05_File_IO`、`06_Functions_Modules`、`07_Structures` 需進入各章節目錄執行 `make`。

### 批次作業

- `Part1_CPU_CrashCourse/02_Vector_Add/job_vec_add.sh` — PJM
- `Part1_CPU_CrashCourse/04_Matrix_Operations/job_matrix.sh` — PBS

---

## 六、文件索引

| 文件 | 用途 |
|------|------|
| [README.md](README.md) | 專案說明、快速開始、環境需求、課前環境自檢、先修清單 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 技術架構與設計 |
| [docs/INSTRUCTOR_GUIDE.md](docs/INSTRUCTOR_GUIDE.md) | 講師與助教完整手冊：分級地圖、授課節奏、評量標準、風險控管 |
| [00_Cheatsheets/](00_Cheatsheets/) | 語法、編譯、優化、批次系統速查（含 PJM 錯誤排除） |

---

## 七、已知限制與注意事項

1. **03_Heat_Diffusion_Demo**：提供分層任務框架（Must/Should/Could），尚無完整可編譯程式碼
2. **平台差異**：主目標為 Fujitsu A64FX，部分章節（04-07）使用 gfortran/g++ 適用 x86
3. **批次系統**：`job_vec_add.sh` 使用 PJM（FX1000 主線），`job_matrix.sh` 使用 PBS（x86 輔助）。教學時以 PJM 為主，詳見 `docs/INSTRUCTOR_GUIDE.md` 第 1.2 節

---

**Good luck and happy coding! 🚀**
