# ProgramingTutorial 專案摘要

> 最後更新：2026-03-21

---

## 一、專案概述

**ProgramingTutorial** 是一套為**完全初學者**設計的高效能計算（HPC）程式設計入門教材，涵蓋 **Fortran**、**C++** 與 **CUDA GPU** 加速。教材採用**一年兩次**的工作坊：每次**共 6 小時**，**上午**為課程說明、**下午**為上機實作；**上半年**下午實作 **CPU**（Part1）、**下半年**下午實作 **GPU**（Part2）。目標是讓學員能讀懂、修改並優化數值計算程式。

### 單次工作坊節奏（規劃）

| 時段 | 內容 |
|------|------|
| 上午（約 3 小時） | 課程說明：觀念、工具鏈、對應 `00_Cheatsheets/` 與當次實作主題 |
| 下午（約 3 小時） | 上機實作：上半年對應 `Part1_CPU_CrashCourse/`，下半年對應 `Part2_GPU_CrashCourse/` |

### 核心特色

| 特色 | 說明 |
|------|------|
| **對比學習** | 同一功能以 Fortran / C++ / CUDA 三種語言實作，便於快速掌握差異 |
| **範例導向** | 不教繁瑣語法，直接透過可執行範例學習 |
| **優化思維** | 每個範例提供「慢版」vs「快版」，展示效能差異與優化技巧 |
| **實戰收尾** | 以熱傳導數值模擬案例整合所學知識 |

### 目標平台

- **主要**：Fujitsu A64FX (FX1000) — ARM v8.2-A + SVE 512-bit
- **編譯器**：Fujitsu frt (Fortran)、FCC (C++)
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
│   ├── debug_and_profiler.md    # FX1000 TCS Debugger／Profiler、`frt`
│   ├── profiler_toolkit_tcs.md # FIPP（fipp／fipppx）、與第 09 章對應
│   └── pjm_batch_system.md      # PJM 批次系統說明
│
├── Part1_CPU_CrashCourse/        # 上半年下午：CPU 上機實作教材
│   ├── 00_HPC_Workflow/          # 合規登入、資料流、跨架構套件
│   ├── 01_Hello/                # 環境測試
│   ├── 02_Vector_Add/           # 向量運算與優化（核心）
│   ├── 03_Challenge/            # 練習題
│   ├── 04_Matrix_Operations/    # 矩陣運算與快取優化
│   ├── 05_File_IO/              # 檔案 I/O
│   ├── 06_Functions_Modules/    # 函數與模組化
│   ├── 07_Structures/           # 資料結構
│   ├── 08_Debug_Profile/        # TCS Debugger／Profiler（Fortran / frt）
│   ├── 09_Profiler_Toolkit_TCS/ # Instant Performance Profiler（FIPP）／fipp、fipppx
│   └── 10_Troubleshooting_Clinic/ # 排錯實戰、Optimization_Loop_Demo
│
└── Part2_GPU_CrashCourse/        # 下半年下午：GPU 上機實作教材
    ├── 01_CUDA_Hello/           # GPU 環境確認
    ├── 02_Vector_Add_GPU/      # 向量加法 GPU 版
    ├── 03_Language_Comparison_VectorAdd/  # C/C++/Fortran 與 CUDA C/CUDA Fortran 對照
    ├── 04_OpenACC_VectorAdd/    # OpenACC Fortran（與 03 同題）
    ├── 05_Heat_Diffusion_Demo/  # 熱傳導模擬（CPU/GPU 參考實作）
    ├── 06_Singularity_PyTorch_GPU/  # Singularity --nv + PyTorch CUDA 測試
    └── 07_Multi_Node_GPU_Example/   # MPI+CUDA 探測、PJM 多 vnode；可併用 $HOME/sample/GPU_multiNodes
```

---

## 三、技術棧

| 類別 | 技術 | 說明 |
|------|------|------|
| **語言** | Fortran 90 | 數值計算 |
| **語言** | C++11 | 數值計算 |
| **語言** | CUDA C | GPU 平行運算 |
| **語言／指令** | OpenACC（Fortran） | `nvfortran -acc`，與 CUDA Fortran 對照（Part2 `04_OpenACC_VectorAdd`） |
| **編譯器** | Fujitsu frt / FCC | A64FX 平台 |
| **編譯器** | g++（無 FCC 時之 C++） | 僅部分章節之 C++；Fortran 仍 **`frt`** |
| **編譯器** | nvcc | CUDA |
| **建構** | Make | 編譯與建構 |
| **批次** | **PJM**（主線） | 作業管理（`pjsub`、`#PJM`） |
| **除錯／分析** | **TCS Debugger**、**Instant Performance Profiler（FIPP）**、`fipp`／`fipppx`、`frt -g`／`-Nfjprof`／`-Nline` 等 | FX1000 Fortran 除錯與取樣剖析（見 `debug_and_profiler.md`、`profiler_toolkit_tcs.md`） |

---

## 四、主要範例與學習重點

| 章節 | 範例 | 學習重點 |
|------|------|----------|
| 02_Vector_Add | 向量加法 | 迴圈展開、陣列運算、SIMD 向量化 |
| 04_Matrix_Operations | 矩陣乘法 | 快取局部性、迴圈重排序、Blocking |
| 08_Debug_Profile | Fortran 熱點 + 越界範例 | **`frt`**、**TCS Debugger**、**TCS Profiler**、**`-Haefosux`**（執行期檢查；舊寫法 `-Hx,CHECK_SUBSCRIPT` 易與新版 TCS 不相容） |
| 09_Profiler_Toolkit_TCS | `phase_heavy`／`phase_light` | **FIPP**：`fipp`／`fipppx`、`-Nfjprof`／`-Nline`、與 `-Koptmsg=2` 對照 |
| 02_Vector_Add_GPU | GPU 向量加法 | CUDA kernel、Host-Device 記憶體、效能測試 |
| 03_Language_Comparison_VectorAdd | 五語言向量加 | C / C++ / Fortran（CPU）與 CUDA C / CUDA Fortran |
| 04_OpenACC_VectorAdd | OpenACC 向量加 | `!$acc data`、`parallel loop`、`async`／`routine(seq)` |
| 05_Heat_Diffusion_Demo | 熱傳導模擬 | 2D 有限差分法、CPU vs GPU 對比 |
| 06_Singularity_PyTorch_GPU | PyTorch in Singularity | `--nv`、與 `torch_1.13.1_cuda11.6.sif` 銜接、PJM 批次範例 |
| 07_Multi_Node_GPU_Example | 多節點 GPU + MPI | `mpi_cuda_rank_info.cu`、`job_mpi_cuda_rank_info.sh`；進階見 `$HOME/sample/GPU_multiNodes/` |

---

## 五、建構與執行

### 頂層 Makefile 目標

```bash
make all     # 編譯所有教材
make part1   # 只編譯 Part 1 (01_Hello, 02_Vector_Add)
make part2   # 只編譯 Part 2（CUDA Hello、Vector GPU、05 對照、06 OpenACC、Heat Diffusion）
make clean   # 清除執行檔
make help    # 顯示說明
```

**注意**：頂層 Makefile 僅編譯部分章節。`03_Challenge`、`04_Matrix_Operations`、`05_File_IO`、`06_Functions_Modules`、`07_Structures`、`08_Debug_Profile`、`09_Profiler_Toolkit_TCS` 需進入各章節目錄執行 `make`。

**Part1**：各章 `make` 產生之執行檔與 `*.mod`／`*.o` 不納入 Git（見 `Part1_CPU_CrashCourse/.gitignore`）；clone 後請於所需章節目錄 `make`，或至少執行根目錄 `make part1`（僅涵蓋 01、02）。

**Part2**：執行檔不納入 Git（見 `Part2_GPU_CrashCourse/.gitignore`），clone 後請 `make part2`。登入節點若無 `nvcc`，`make part2` 仍會完成 `05`（CPU 三支）與 `03/heat_cpu`，CUDA 目標略過；GPU 節點載入 CUDA／nvhpc 後再編譯即可。GPU 節點一鍵檢查：`Part2_GPU_CrashCourse/run_part2_tests.sh`（登入節點送件：`export PJM_GROUP=… && ./run_part2_tests.sh --submit-pjm`，對齊 Part1 `run_all_tests.sh --submit-pjm`）。

### 批次作業

- `Part1_CPU_CrashCourse/02_Vector_Add/job_vec_add.sh` — **PJM**
- `Part1_CPU_CrashCourse/04_Matrix_Operations/job_matrix.sh` — **PJM**
- `Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/job_kernel_profile.sh` — **PJM**（選用，**`fipp -C -d ...`** 取樣）
- `Part2_GPU_CrashCourse/run_part2_tests.sh --submit-pjm` — **PJM**（GPU 資源；亦可手寫 `pjsub job_run_part2_gpu.sh`）

---

## 六、文件索引

| 文件 | 用途 |
|------|------|
| [README.md](README.md) | 專案說明、快速開始、環境需求、課前環境自檢、先修清單 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 技術架構與設計 |
| [docs/INSTRUCTOR_GUIDE.md](docs/INSTRUCTOR_GUIDE.md) | 講師與助教完整手冊：分級地圖、授課節奏、評量標準、風險控管 |
| [00_Cheatsheets/](00_Cheatsheets/) | 語法、編譯、優化、除錯／profiler、批次系統速查（含 PJM 錯誤排除） |

---

## 七、已知限制與注意事項

1. **05_Heat_Diffusion_Demo**：README 仍保留分層任務說明；同目錄已提供可編譯之 `main_cpu.cpp`、`main_gpu.cu`（`make` / `make run_all`）
2. **平台差異**：主目標為 Fujitsu A64FX；Part1 **Fortran** 一律 **`frt`**，C++ 可 **FCC** 或 **g++**
3. **批次系統**：Part 1 範例作業腳本（`job_vec_add.sh`、`job_matrix.sh`、`job_kernel_profile.sh` 等）皆為 **PJM**；PBS／Slurm 僅見 Cheatsheet 對照表。詳見 `docs/INSTRUCTOR_GUIDE.md` 第 1.2 節
4. **TCS Debugger／FIPP**：`fipp`／`fipppx` 與 **`-Nline`** 等選項依 TCS 版本而異；請以貴中心手冊為準（第 09 章為 **Instant Performance Profiler** 流程概念）

---

**Good luck and happy coding! 🚀**
