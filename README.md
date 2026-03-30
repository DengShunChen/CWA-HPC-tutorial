# HPC 程式設計工作坊教材

> 為完全初學者設計的高效能計算程式入門課程  
> 涵蓋 Fortran、C++ 與 CUDA GPU 加速

> **🖥️ 本教材針對 Fujitsu A64FX (FX1000) 平台優化**  
> - 使用 **Fujitsu frt (Fortran，A64FX 原生)** 與 **FCC (C++)** 編譯器  
> - **Fortran 建置與執行**在 **A64FX 計算節點**（**不**用登入節點 cross **frtpx**）；長時間工作請 **`pjsub`**  
> - 支援 **ARM SVE 512-bit 向量化**

---

## 📚 課程概覽

本教材為**一年兩次**的工作坊；**每次共 6 小時**，**上午**課程說明、**下午**上機實作。

| 場次 | 時長 | 主題 | 目標 |
|-----|------|------|------|
| **上半年** | 6 小時／日 | CPU 程式語言速成（下午上機） | 掌握 Fortran 與 C++ 基礎，能讀懂並修改數值計算程式 |
| **下半年** | 6 小時／日 | GPU 加速與實戰（下午上機） | 理解 CUDA 平行運算，體驗 GPU 加速威力 |

---

## 🗂️ 教材結構

```
ProgramingTutorial/
├── 00_Cheatsheets/           # 快速參考資料
│   ├── syntax_rosetta_stone.md      # 三語言語法對照表
│   ├── compilation_guide.md         # 編譯指令速查
│   ├── optimization_mindset.md      # HPC 優化思維指南
│   ├── debug_and_profiler.md        # FX1000 TCS Debugger／Profiler、`frt`
│   └── profiler_toolkit_tcs.md      # FIPP（fipp／fipppx，第 09 章）
│
├── Part1_CPU_CrashCourse/    # 上半年：CPU 程式語言
│   ├── 00_HPC_Workflow/      # 合規登入、資料流、跨架構套件
│   ├── 01_Hello/             # 環境測試
│   ├── 02_Vector_Add/        # 核心範例（含優化對比）
│   ├── 03_Challenge/         # 練習題
│   ├── 04_Matrix_Operations/
│   ├── 05_File_IO/
│   ├── 06_Functions_Modules/
│   ├── 07_Structures/
│   ├── 08_Debug_Profile/
│   ├── 09_Profiler_Toolkit_TCS/
│   └── 10_Troubleshooting_Clinic/  # 排錯與 Optimization Loop 示範
│
└── Part2_GPU_CrashCourse/    # 下半年：GPU 加速
    ├── 01_CUDA_Hello/        # GPU 環境確認
    ├── 02_Vector_Add_GPU/    # CPU 到 GPU 轉換
    ├── 03_Heat_Diffusion_Demo/  # 實戰：熱傳導模擬
    └── 04_Singularity_PyTorch_GPU/  # Singularity + PyTorch CUDA 測試（延伸）
```

---

## 🎯 教學特色

| 特色 | 說明 |
|-----|------|
| **對比學習** | 同一功能用 Fortran/C++/CUDA 實作，快速掌握差異 |
| **範例導向** | 不教繁瑣語法，直接透過可執行範例學習 |
| **優化思維** | 每個範例提供「慢版」vs「快版」，展示效能差異 |
| **實戰收尾** | 以數值模擬案例整合所學知識 |

---

## 🚀 快速開始

### 上半年課程
1. 參考 [`00_Cheatsheets/`](00_Cheatsheets/) 快速查閱語法
2. 從 [`Part1_CPU_CrashCourse/01_Hello/`](Part1_CPU_CrashCourse/01_Hello/) 開始
3. 重點學習 [`Part1_CPU_CrashCourse/02_Vector_Add/`](Part1_CPU_CrashCourse/02_Vector_Add/) 的優化技巧

### 下半年課程
1. 複習上半年重點（見 `Part2_GPU_CrashCourse/README.md`）
2. 從 [`Part2_GPU_CrashCourse/01_CUDA_Hello/`](Part2_GPU_CrashCourse/01_CUDA_Hello/) 開始
3. 最終挑戰：[`Part2_GPU_CrashCourse/03_Heat_Diffusion_Demo/`](Part2_GPU_CrashCourse/03_Heat_Diffusion_Demo/)

---

## 🔧 環境需求

### 上半年 (CPU 程式語言)
- **CPU 平台**：Fujitsu A64FX (ARM v8.2-A + SVE)
- **Fortran 編譯器**：`frt` (Fujitsu Compiler，A64FX 原生)
- **C++ 編譯器**：`FCC` (Fujitsu C++ Compiler)
- **批次系統**：PJM (Parallels Job Manager)
- **開發環境**：FX1000 上 **A64FX 計算節點** + TCS（`frt`）

### 下半年 (GPU 加速)
- **CUDA Toolkit**：建議 CUDA >= 10.0
- **支援 CUDA 的 GPU**：建議 Compute Capability >= 3.5
- **NVIDIA 驅動程式**：與 CUDA 版本相容

### 先修能力

| 程度 | 先修要求 |
|------|----------|
| **Beginner** | 會基本 Linux 指令（`cd`、`ls`、`vi` 或 `nano`）、能用 SSH 登入遠端主機 |
| **Intermediate** | 理解迴圈/陣列概念、能讀懂簡單 Fortran 或 C++ 程式 |
| **Professional** | 有 Fortran/C++ 實戰經驗、理解 MPI/OpenMP 概念 |

### 課前環境自檢

請在**上課前一天**完成以下檢查，確認環境正常：

```bash
# === Step 1: 登入 FX1000 ===
ssh <your_account>@<fx1000_login_node>

# === Step 2: 載入編譯器模組 ===
module load lang/tcsds-1.2.37
echo "Module loaded: OK"

# === Step 3: 檢查 Fujitsu 編譯器 ===
frt --version && echo "frt: OK" || echo "frt: FAILED"
FCC --version && echo "FCC: OK" || echo "FCC: FAILED"

# === Step 4: 檢查 PJM 系統 ===
pjstat && echo "PJM: OK" || echo "PJM: FAILED"

# === Step 5: 檢查教材 ===
cd ~/CWA-HPC-tutorial   # 或教材所在路徑
ls Part1_CPU_CrashCourse/ Part2_GPU_CrashCourse/ 00_Cheatsheets/
echo "教材目錄: OK"

# === Step 6: 測試編譯（Part 1） ===
cd Part1_CPU_CrashCourse/01_Hello
make clean && make all && echo "Part1 編譯: OK"

# === Step 7: 檢查 CUDA（僅下半年課程） ===
nvcc --version && echo "CUDA: OK" || echo "CUDA: NOT AVAILABLE (下半年課程需要)"
```

**自檢結果判讀**：

| 結果 | 意義 | 處理 |
|------|------|------|
| 全部 OK | 環境正常，可直接上課 | 無需動作 |
| frt/FCC FAILED | 編譯器不可用 | 聯繫系統管理員；Part1 Fortran 需 **`frt`**（A64FX + `module load`） |
| PJM FAILED | 批次系統不可用 | 聯繫系統管理員；可先在本地測試 |
| CUDA NOT AVAILABLE | GPU 環境未安裝 | 僅影響下半年課程，上半年不需要 |

### 快速環境檢查（簡版）

```bash
# 檢查 Fujitsu 編譯器
frt --version
FCC --version

# 檢查 PJM 系統
pjstat --version

# 檢查 CUDA (GPU 課程)
nvcc --version
```

---

## 📖 學習路徑建議

本教材適用從初學者到專業 HPC 工程師的不同程度學員。詳細分級說明請參考 [docs/INSTRUCTOR_GUIDE.md](docs/INSTRUCTOR_GUIDE.md)。

### Beginner（入門）：無程式經驗或僅有腳本經驗
1. 課前完成「環境自檢」（見下方）
2. 閱讀 `00_Cheatsheets/pjm_batch_system.md` 前半段
3. 從 `01_Hello` 開始，每個 Checkpoint 確實通過再往下
4. 重點完成 `02_Vector_Add` 的 Must 任務（編譯 + 提交 + 驗證）

### Intermediate（進階）：有 Python/MATLAB 經驗
- 課前閱讀 `syntax_rosetta_stone.md` + `compilation_guide.md`
- 重點學習各章節的優化技巧（Should 任務）
- 完成 `03_Challenge` 與 `04_Matrix_Operations` 效能比較

### Professional（專業）：有 Fortran/C++ 實戰經驗
- 課前閱讀 `optimization_mindset.md` 全文
- 關注 ARM SVE 512-bit 與 `-KSVE` 編譯選項的效能影響
- 挑戰 [`Part2_GPU_CrashCourse/03_Heat_Diffusion_Demo/`](Part2_GPU_CrashCourse/03_Heat_Diffusion_Demo/) 的完整 CPU + GPU 實作（Could 任務；依該章 README 自建原始碼）

---

## 💡 教材使用提示

- 📋 **語法不確定？** → 查閱 `00_Cheatsheets/syntax_rosetta_stone.md`
- 🔧 **編譯失敗？** → 參考 `00_Cheatsheets/compilation_guide.md`
- ⚡ **如何優化？** → 閱讀 `00_Cheatsheets/optimization_mindset.md`
- 📦 **如何提交作業？** → 查看 `00_Cheatsheets/pjm_batch_system.md`
- 🤔 **看不懂程式碼？** → 每個資料夾的 `README.md` 都有詳細說明

### Fujitsu A64FX 平台特別注意

1. **編譯**：在 **A64FX 計算節點**使用 **`frt`／`FCC`** 原生編譯（勿在登入節點長時間跑計算）。
2. **執行**：在 FX1000 上應以 **`pjsub`** 將工作送交**計算節點**執行；與正式效能／FIPP 量測一致。
3. **優化關鍵**：使用 **`-KSVE`** 啟用 ARM SVE 512-bit 向量化。
4. **模組載入**：於 PJM 腳本內 **`module load`**（版本依貴站，例如 `lang/tcsds-…`）。

---

## 📁 專案文件

| 文件 | 說明 |
|------|------|
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | 專案摘要、結構、技術棧 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 技術架構與編譯設計 |
| [docs/INSTRUCTOR_GUIDE.md](docs/INSTRUCTOR_GUIDE.md) | 講師教學指南 |

---

## 📬 聯絡與回饋

如有任何問題或建議，歡迎聯繫講師。

---

**Good luck and happy coding! 🚀**
