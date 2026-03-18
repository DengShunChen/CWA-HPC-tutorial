# ProgramingTutorial 技術架構

> 專案架構、編譯流程與技術設計說明

---

## 1. 整體架構

```
┌─────────────────────────────────────────────────────────────────┐
│                     ProgramingTutorial                            │
├─────────────────────────────────────────────────────────────────┤
│  00_Cheatsheets          │  參考資料層（語法、編譯、優化、批次）   │
├─────────────────────────────────────────────────────────────────┤
│  Part1_CPU_CrashCourse   │  CPU 課程層（Fortran + C++）           │
│  Part2_GPU_CrashCourse   │  GPU 課程層（CUDA）                    │
├─────────────────────────────────────────────────────────────────┤
│  Makefile                │  建構層（頂層 + 各章節 Makefile）       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 編譯架構

### 2.1 頂層 Makefile 依賴關係

```
make all
  ├── make part1
  │     ├── Part1/01_Hello/make all
  │     └── Part1/02_Vector_Add/make all
  └── make part2
        ├── Part2/01_CUDA_Hello/make all
        └── Part2/02_Vector_Add_GPU/make all
```

### 2.2 各章節編譯模式

| 章節 | 輸入 | 輸出 | 編譯器 |
|------|------|------|--------|
| 01_Hello | hello.f90, hello.cpp | hello_f, hello_cpp | frtpx, FCC 或 gfortran, g++ |
| 02_Vector_Add | vec_add*.f90, vec_add*.cpp | vec_add_f, vec_add_cpp, ... | 同上 |
| 04_Matrix_Operations | matrix_multiply*.f90, *.cpp | matrix_multiply_f, ... | gfortran, g++ |
| 01_CUDA_Hello | hello_gpu.cu, device_query.cu | hello_gpu, device_query | nvcc |
| 02_Vector_Add_GPU | vec_add_gpu.cu | vec_add_gpu | nvcc |

### 2.3 編譯器選項（Fujitsu A64FX）

- **Fortran**：`frtpx -KSVE -O3` — 啟用 SVE 512-bit 向量化
- **C++**：`FCC -KSVE -O3` — 同上
- **CUDA**：`nvcc -O3` — 標準優化

---

## 3. 程式碼組織模式

### 3.1 每章節標準結構

```
NN_ChapterName/
├── README.md           # 學習目標、檔案說明、範例解析
├── Makefile            # 編譯腳本
├── *.f90               # Fortran 原始碼（若有）
├── *.cpp               # C++ 原始碼（若有）
├── *.cu                # CUDA 原始碼（若有）
└── job_*.sh            # 批次作業腳本（若有）
```

### 3.2 範例命名慣例

| 類型 | 命名 | 範例 |
|------|------|------|
| 基礎版 | `*_basic` 或無後綴 | vec_add.f90 |
| 優化版 | `*_optimized` | vec_add_optimized.f90 |
| GPU 版 | `*_gpu` 或 `*_cuda` | vec_add_gpu.cu |

---

## 4. 平台與環境

### 4.1 目標平台

| 平台 | 用途 | 編譯器 |
|------|------|--------|
| Fujitsu A64FX (FX1000) | 主要教學平台 | frtpx, FCC |
| x86 (一般 PC) | 部分章節、本地開發 | gfortran, g++ |
| NVIDIA GPU | GPU 課程 | nvcc |

### 4.2 模組載入（PJM 腳本）

```bash
module load lang/tcsds-1.2.37   # Fujitsu 編譯器模組
```

### 4.3 批次系統

- **PJM**：`job_vec_add.sh` — 向量加法
- **PBS**：`job_matrix.sh` — 矩陣乘法（04 章節）

---

## 5. 優化技術對照

| 層級 | 技術 | 適用章節 |
|------|------|----------|
| CPU 迴圈 | 迴圈展開、向量化 | 02_Vector_Add |
| CPU 快取 | Loop interchange、Blocking | 04_Matrix_Operations |
| 編譯器 | -O2, -O3, -KSVE | 全章節 |
| GPU | Kernel 設計、記憶體管理 | 02_Vector_Add_GPU |

---

## 6. 相依性

- **無套件管理**：無 `package.json`、`requirements.txt`、`Cargo.toml`
- **外部依賴**：僅需編譯器與 Make
- **CUDA**：需 NVIDIA 驅動與 CUDA Toolkit

---

## 7. 擴充建議

1. **頂層 Makefile**：可納入 03–07 章節以統一編譯
2. **03_Heat_Diffusion_Demo**：補齊 `main_cpu.cpp`、`main_gpu.cu` 實作
3. **批次系統**：統一使用 PJM 或 PBS，避免混用
