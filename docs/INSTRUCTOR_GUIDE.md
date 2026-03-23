# ProgramingTutorial 講師教學指南

> 給授課講師與助教的完整教學手冊：分級地圖、授課節奏、評量標準與風險控管

---

## 1. 課程總覽 

| 場次 | 時長 | 主題 | 前置需求 |
|------|------|------|----------|
| **上半年** | 6 小時／日（上午說明 + 下午 CPU 上機） | CPU 程式語言速成 | 無（完全初學者） |
| **下半年** | 6 小時／日（上午說明 + 下午 GPU 上機） | GPU 加速與實戰 | 需完成上半年課程 |

### 1.1 教學理念

本課程採用**範例導向 + 分層任務**設計。每個章節同時服務三種程度的學員，透過 Must / Should / Could 三層任務卡讓不同程度的學員都能有收穫，同時避免初學者被進階內容壓垮。

### 1.2 批次系統定位說明（**PJM 主線**；Slurm／PBS 為對照）

**本教材 Part 1 之範例作業腳本一律為 Fujitsu PJM**（`#PJM`、`pjsub`），與 FX1000 上半年實作一致：

| 批次系統 | 適用章節／範例 | 使用情境 |
|----------|----------------|----------|
| **PJM** | `02_Vector_Add/job_vec_add.sh`、`04_Matrix_Operations/job_matrix.sh`、`09_Profiler_Toolkit_TCS/job_kernel_profile.sh`、`run_all_tests.sh --submit-pjm` | **Fujitsu FX1000 (A64FX)** — 上半年主線 |
| **Slurm** | Part 2 GPU 課程（建議） | GPU 叢集 — 下半年主線 |
| **PBS** | （本 repo **無** PBS 範例腳本） | 若學員環境為 PBS，請以 `00_Cheatsheets/pjm_batch_system.md` 對照表手動改寫 |

教學時：
- **上半年**：只要求學會 **PJM** 提交與查詢（`pjsub`、`pjstat`、`pjwait` 等）；**04 矩陣章**與 **02 向量章**使用**相同** PJM 語法。
- **下半年**：GPU 課程在 **Slurm** 上執行，與 FX1000 的 PJM 做環境區隔。
- PBS／Slurm 與 PJM 的指令對照（選讀）見 `00_Cheatsheets/pjm_batch_system.md`。

---

## 2. 學員分級地圖

### 2.1 三級能力定義

| 等級 | 代號 | 典型背景 | 課前能力 |
|------|------|----------|----------|
| **Beginner（入門）** | B | 研究人員、氣象預報員、資訊科系新生 | 會基本 Linux 指令（`cd`、`ls`、`vi`）、無程式經驗或僅有腳本經驗 |
| **Intermediate（進階）** | I | 有 Python/MATLAB 經驗的研究生、初期 HPC 使用者 | 會迴圈/陣列概念、能讀懂簡單 Fortran/C++ 程式、用過 SSH 登入叢集 |
| **Professional（專業）** | P | HPC 工程師、模式開發者、系統管理員 | 有 Fortran/C++ 實戰經驗、理解 MPI/OpenMP、需要 FX1000 平台特化知識 |

### 2.2 各級學習成果（可驗證產出）

#### Beginner

- 能在 FX1000 上成功編譯 Hello World（Fortran 與 C++）
- 能撰寫並提交 1 個 PJM 作業腳本，正確取回輸出
- 完成向量加法正確性驗證（比對前 5 個元素）
- **產出**：`job_vec_add.sh` 成功執行的輸出截圖或日誌

#### Intermediate

- 能解釋基礎版與優化版的效能差異原因（向量化 / Cache）
- 能對矩陣乘法完成至少 1 項優化策略（迴圈重排 or Blocking）並比較 GFLOPS
- 能獨立完成 `03_Challenge` 向量乘法練習
- **產出**：矩陣乘法優化前後效能比較表（含 GFLOPS 數值與加速比）

#### Professional

- 能分析 CPU vs GPU 的效能決策（何時該用 GPU、資料搬移成本）
- 能完成 Heat Diffusion 案例的基礎實作（CPU 或 GPU 至少一版）
- 能解釋 ARM SVE 512-bit 與 `-KSVE` 編譯選項的效能影響
- **產出**：Heat Diffusion CPU vs GPU 實測報告，含瓶頸分析與優化建議

### 2.3 現有課綱與能力目標對照（落差分析）

| 章節 | B 入門 | I 進階 | P 專業 | 落差與補強 |
|------|--------|--------|--------|------------|
| 01_Hello | 核心 | 快速帶過 | 跳過 | -- |
| 02_Vector_Add | Must 任務 | Should 任務（解釋優化原理） | Could 任務（SVE 分析） | 需增加 Should/Could 任務說明 |
| 03_Challenge | Must 任務 | Must 任務 | 選做 | 需增加進階挑戰題 |
| 04_Matrix_Operations | 觀摩為主 | 核心 | Should 任務 | 需增加 Blocking 實作引導 |
| 05_File_IO | Must 任務 | 快速帶過 | 跳過 | -- |
| 06_Functions_Modules | 觀摩為主 | Should 任務 | 快速帶過 | -- |
| 07_Structures | 選做 | Should 任務 | 快速帶過 | -- |
| 08_Debug_Profile | Must（TCS Debugger 於 `heavy_work`） | Should（TCS Profiler 熱點） | Could（對照 `-Koptmsg=2`） | 圖形介面需 X11／VNC 時預先演練；不以 GNU 工具為主軸 |
| 09_Profiler_Toolkit_TCS | 延伸自學 | Should（**FIPP**：`fipp`／`fipppx` 完整流程） | Could（`fipp_start`／區段或 **fapp** 進階） | 可併入進階場次；與 08 銜接 |
| 01_CUDA_Hello | 核心 | 快速帶過 | 跳過 | -- |
| 02_Vector_Add_GPU | Must 任務 | Should 任務（分析傳輸成本） | 核心（Kernel 調校） | 需補充 Kernel 調校引導 |
| 03_Heat_Diffusion | 觀摩為主 | Should 任務（MVP 版） | 核心 | 無完整程式碼，需補 MVP 與進階版 |

---

## 3. 授課執行方式

### 3.1 主軸教學模式（混成式）

本課程採用四種教學手法交替運用：

| 手法 | 時機 | 說明 |
|------|------|------|
| **翻轉式微課程** | 課前 | 課前發放 20-30 分鐘預習材料（環境自檢 + Cheatsheet 閱讀），課中時間保留給實作 |
| **Live Coding + Checkpoint** | 課中示範 | 講師每 15-20 分鐘設置一個檢查點，學員必須完成才能繼續 |
| **Pair/Trio Lab** | 課中實作 | B 級與 I/P 級混組（2-3 人），降低卡關時間並提升班級整體節奏 |
| **分層任務卡** | 課中實作 | Must / Should / Could 三層難度，對應不同程度學員 |

### 3.2 分層任務卡（Must / Should / Could）說明

每個實作環節均提供三層任務：

| 層級 | 對應等級 | 要求 | 範例（02_Vector_Add） |
|------|----------|------|----------------------|
| **Must** | B 入門 | 所有學員必須完成 | 編譯 vec_add.f90、提交 PJM job、確認輸出正確 |
| **Should** | I 進階 | 建議完成 | 比較基礎版與優化版的執行時間，解釋差異原因 |
| **Could** | P 專業 | 挑戰題 | 嘗試不同 `-K` 編譯選項組合，記錄向量化報告（`-Koptmsg=2`） |

### 3.3 課前預習材料

課前一週發放給學員：

1. **環境自檢腳本**（見 README.md「課前環境自檢」章節）
2. **Cheatsheet 閱讀**：
   - B 級：`pjm_batch_system.md`（前半段）
   - I 級：`syntax_rosetta_stone.md` + `compilation_guide.md`
   - P 級：`optimization_mindset.md`（全文）
3. **5 分鐘自我評估問卷**（見第 6 節前測）

---

## 4. 上半年課程（Part 1）教學流程

### 4.0 單日節奏（6 小時）

- **上午（約 180 分鐘）**：課程說明 — HPC 與本日目標、工具鏈（frt／FCC／Make）、優化思維與 Cheatsheets 導讀、PJM 主線說明；**FX1000 TCS Debugger／TCS Profiler 與 `frt -g` 角色**（見 `00_Cheatsheets/debug_and_profiler.md`，**不以 GNU gdb／perf 為主軸**）；預告下午實作節奏與 Checkpoint。
- **下午（約 180 分鐘）**：上機實作 — 建議時程見 **4.1**（下列表格以**下午**為 0:00 起算）。

### 4.1 建議時程 — 下午上機（180 分鐘，對齊 CWA 課綱）

| 時間 | 分鐘 | 主題 | 資料夾／文件 | 教學重點 | 任務層級 |
|------|------|------|-------------|----------|----------|
| 14:00-14:40 | 40 | 實務演練（一）：合規登入、互動式資源、資料處理 | `00_HPC_Workflow`、`01_Hello`、`00_Cheatsheets/pjm_batch_system.md` | 先 `pjsub --interact` 再操作；示範 Quota、/IFS / /OFS 工作目錄、tar+rsync 流程 | Must: 成功進入互動節點並完成一次資料搬移 |
| 14:40-15:30 | 50 | 實務演練（二）：A64FX 原生編譯與 Optimization Loop | `02_Vector_Add`、`03_Challenge`、`08_Debug_Profile` | `frt`/`FCC` 編譯、`-Kfast` + `-Koptmsg=2` 判讀、TCS Profiler（fapp/fipp）熱點觀察 | Must + Should |
| 15:30-15:45 | 15 | **休息 + 問題蒐集** | -- | 助教整理紅/黃旗問題，準備批次派送段落 | -- |
| 15:45-16:30 | 45 | 實務演練（三）：PJM 批次派送與監控防護 | `04_Matrix_Operations/job_matrix.sh`、`00_Cheatsheets/pjm_batch_system.md` | 撰寫/修改 `#PJM`、`pjsub` 提交、`pjstat`/`pjwait` 監控、`pjdel` 安全中止 | Must: 完成提交流程；Could: 演練無窮迴圈中止 |
| 16:30-17:00 | 30 | Q&A + Troubleshooting | `10_Troubleshooting_Clinic`、`08_Debug_Profile`、`09_Profiler_Toolkit_TCS`、Cheatsheets | PJM 錯誤碼、OOM、Crash/Core dump、求援流程與錄影回放；可用 `Optimization_Loop_Demo` 示範完整優化閉環 | -- |

**重要時間保護**：`05_File_IO`、`06_Functions_Modules`、`07_Structures` 為自學補充。`09_Profiler_Toolkit_TCS` 定位為 Q&A 延伸或第二次進階場次，與 `08_Debug_Profile` 銜接。`10_Troubleshooting_Clinic/Optimization_Loop_Demo` 可在 16:30-17:00 直接示範「profiling → analysis → optimize → verify → reprofiling」。

### 4.2 關鍵教學點

1. **01_Hello**：確認 **`frt`**（Fortran 必備）、**`FCC`** 或 **`g++`**（C++）可用
2. **02_Vector_Add**：務必展示優化前後效能差異，用「為什麼快」帶出 Cache 與 SIMD 概念
3. **03_Challenge**：留足時間讓學員動手，卡關超過 5 分鐘才提供提示
4. **04_Matrix_Operations**：用圖解說明 Column-major vs Row-major 在記憶體中的差異（本節奏若時間緊，以「跑通優化版 + 一張效能對照表」為優先）
5. **08_Debug_Profile**：**Fortran + `frt`**；除錯用 **`microbench_dbg`**（`-g`、`-Hx,CHECK_SUBSCRIPT`），分析用 **`microbench_opt`**（`-g -Kfast -KSVE -Koptmsg=2`）；**TCS Debugger** 以 `heavy_work` 中斷點為主，**TCS Profiler** 對 `microbench_opt` 取樣；`buggy_bounds` 僅示範越界與執行時檢查，勿在批次腳本中當預期成功之 job
6. **10_Troubleshooting_Clinic**：若時間允許，直接跑 `Optimization_Loop_Demo/run_optimization_loop.sh`，讓學員看到完整工程閉環：`profiling -> analysis -> identify -> optimize -> verify -> reprofiling`，並以 `loop_reports/summary.txt` 做驗收

### 4.3 Checkpoint 驗證標準（對齊 14:00–17:00）

| Checkpoint | 時間點 | 驗證方式 | 通過標準 |
|------------|--------|----------|----------|
| CP1 | 14:40 | 互動式資源取得 | 成功 `pjsub --interact` 並進入計算節點 shell |
| CP2 | 15:10 | 原生編譯與優化訊息 | 成功以 `frt`/`FCC` 編譯，並可指出 `-Koptmsg=2` 至少一則關鍵訊息 |
| CP3 | 15:30 | Optimization Loop | 完成「分析→調整→重編譯→驗證」至少 1 次迭代（可用 vec_add/challenge） |
| CP4 | 16:15 | 批次派送與監控 | 成功 `pjsub` 後以 `pjstat`/`pjwait` 追蹤；可示範 `pjdel` 中止 |
| CP5 | 16:50 | 排錯/優化口頭驗證 | 能描述至少一個實際錯誤（PJM/OOM/Crash）與排查步驟；或完成 `Optimization_Loop_Demo` 一輪並說出 speedup |

### 4.4 常見學員問題

| 問題 | 建議回答 |
|------|----------|
| Fortran 和 C++ 該學哪個？ | 兩者都學基礎，HPC 領域兩者皆常見；氣象模式多用 Fortran，新專案常用 C++ |
| 優化真的有必要嗎？ | 是，HPC 程式常跑數天，2x 優化可省一半時間與數百萬元計算成本 |
| 編譯失敗？ | 查 `00_Cheatsheets/compilation_guide.md`；最常見原因是忘記 `module load` |
| PJM 作業卡住？ | 查 `00_Cheatsheets/pjm_batch_system.md` 的「錯誤排除速查」章節 |
| TCS Debugger／Profiler 無法啟動？ | 查 TCS／站臺手冊與 `module load`；圖形介面需登入節點或 VNC；**不以** GNU `gdb`／`perf` 替代正式教學目標 |

---

## 5. 下半年課程（Part 2）教學流程

### 5.0 單日節奏（6 小時）

- **上午（約 180 分鐘）**：課程說明 — GPU 程式模型、CUDA 工具鏈（nvcc）、記憶體／效能觀念、熱傳導案例架構與分層任務說明；預告下午上機。
- **下午（約 180 分鐘）**：上機實作 — 建議時程見 **5.1**（下列表格以**下午**為 0:00 起算）。

### 5.1 建議時程 — 下午上機（180 分鐘）

| 時間 | 分鐘 | 主題 | 資料夾 | 教學重點 | 任務層級 |
|------|------|------|--------|----------|----------|
| 0:00-0:20 | 20 | 複習 + GPU 概念 | README | 上半年重點回顧、CPU vs GPU 架構、Host/Device 模型 | -- |
| 0:20-0:35 | 15 | CUDA Hello | 01_CUDA_Hello | `nvidia-smi`、`device_query`、kernel 語法 | Must: device_query 成功 |
| 0:35-1:05 | 30 | 向量加法 GPU 示範 | 02_Vector_Add_GPU | Live Coding：cudaMalloc、cudaMemcpy、kernel launch | 講師示範 |
| 1:05-1:30 | 25 | 第一輪實作 | 02_Vector_Add_GPU | 學員動手：編譯、執行、記錄 Kernel 時間 | Must + Should |
| 1:30-1:40 | 10 | **休息 + 問題蒐集** | -- | 助教收集紅/黃旗問題 | -- |
| 1:40-2:20 | 40 | 熱傳導模擬 | 03_Heat_Diffusion_Demo | CPU 版 MVP 實作 / GPU 版框架講解 | Must: MVP / Should: GPU 版 |
| 2:20-2:40 | 20 | 效能對比實作 | 02 + 03 | CPU vs GPU 執行時間比較 | Could: 不同 grid size 測試 |
| 2:40-2:55 | 15 | 成果分享 | -- | 每組展示 CPU vs GPU 效能比較 | -- |
| 2:55-3:00 | 5 | 收斂 + 後測 | -- | 課程總結、後測、回饋表 | -- |

### 5.2 關鍵教學點

1. **01_CUDA_Hello**：先跑 `nvidia-smi` 與 `device_query` 確認 GPU 可用
2. **02_Vector_Add_GPU**：對照 Part1 的 CPU 版 vec_add，強調 Host/Device 資料傳輸成本
3. **03_Heat_Diffusion_Demo**：依學員程度選擇 MVP 或進階版（見該章節 README）

### 5.3 Checkpoint 驗證標準

| Checkpoint | 時間點 | 驗證方式 | 通過標準 |
|------------|--------|----------|----------|
| CP1 | 0:35 | device_query 輸出 | 能看到 GPU 名稱與記憶體大小 |
| CP2 | 1:30 | vec_add_gpu 輸出 | 前 5 個結果正確（0, 3, 6, 9, 12）且 Kernel 時間 < 0.01 秒 |
| CP3 | 2:20 | Heat Diffusion | B: 理解框架 / I: MVP 可編譯 / P: CPU+GPU 皆可執行 |
| CP4 | 2:40 | 效能比較 | 能說出 GPU 加速倍數或解釋為何特定情境 CPU 更快 |

### 5.4 常見學員誤區

| 誤區 | 糾正 |
|------|------|
| "GPU 一定比 CPU 快" | 資料傳輸有成本，小資料量或低平行度時 CPU 可能更快 |
| "寫 CUDA 很難" | 基本概念與 C 語言接近，從 vec_add 開始即可上手 |
| "優化隨便做就好" | GPU 優化重點與 CPU 不同，需理解 Coalesced Access 與佔用率 |

---

## 6. 評量與結訓標準

### 6.1 前測（課前或課堂前 10 分鐘）

前測用於分組依據與教學節奏調整，不計分。

**Part 1 前測題目（10 題，預估 10 分鐘）：**

| # | 題目 | 考察能力 | 對應等級 |
|---|------|----------|----------|
| 1 | `ls -la` 指令的功能是什麼？ | Linux 基礎 | B |
| 2 | 如何在終端機切換到 `/home/user/work` 目錄？ | Linux 基礎 | B |
| 3 | `gcc -o hello hello.c` 指令中 `-o` 的用途？ | 編譯概念 | B |
| 4 | 什麼是「編譯」？與「直譯」的差別？ | 程式基礎 | B |
| 5 | Fortran 的 `do i = 1, 10` 等同 C++ 的哪段程式碼？ | 語法對照 | I |
| 6 | 什麼是「快取（Cache）」？為什麼它能加速程式？ | 記憶體概念 | I |
| 7 | Fortran 陣列是 Column-major 還是 Row-major？ | 記憶體佈局 | I |
| 8 | 什麼是 SIMD？ARM SVE 的向量寬度是多少？ | 向量化概念 | P |
| 9 | 解釋 `#PJM -L "node=1"` 這行的意思 | 批次系統 | I |
| 10 | 什麼情況下 Loop Blocking 能有效提升效能？ | 優化策略 | P |

**分級參考**：0-4 題正確 → B 級、5-7 題 → I 級、8-10 題 → P 級

**Part 2 前測題目（10 題，預估 10 分鐘）：**

| # | 題目 | 考察能力 | 對應等級 |
|---|------|----------|----------|
| 1 | CPU 與 GPU 架構的主要差異？ | 硬體概念 | B |
| 2 | 什麼是 Host？什麼是 Device？ | CUDA 基礎 | B |
| 3 | `cudaMalloc` 在哪裡配置記憶體？ | CUDA 記憶體 | B |
| 4 | `__global__` 關鍵字的用途？ | Kernel 語法 | I |
| 5 | `<<<blocks, threads>>>` 語法代表什麼？ | 執行配置 | I |
| 6 | 為什麼需要 `cudaDeviceSynchronize()`？ | 同步概念 | I |
| 7 | 在什麼情境下 GPU 反而比 CPU 慢？ | 效能分析 | I |
| 8 | 什麼是 Coalesced Memory Access？ | GPU 優化 | P |
| 9 | 如何計算 CUDA kernel 所需的 block 數量？ | 索引計算 | I |
| 10 | Roofline Model 的兩個軸分別代表什麼？ | 效能模型 | P |

### 6.2 課中檢核（Checkpoint）

每個 Checkpoint 有明確的可驗證輸出（見 4.3 與 5.3 節）。

**進度追蹤方式**：紅黃綠旗幟系統

| 顏色 | 意義 | 學員動作 | 助教動作 |
|------|------|----------|----------|
| 🟢 綠 | 已完成當前 Checkpoint | 舉綠旗或在共享文件標記 | 可協助鄰近紅旗學員 |
| 🟡 黃 | 卡住超過 5 分鐘 | 舉黃旗 | 優先前往協助 |
| 🔴 紅 | 完全無法進行 | 舉紅旗 | 立即前往，必要時切換備援方案 |

### 6.3 後測（課堂最後 5 分鐘或課後線上填寫）

後測以實作為主，題目與前測呼應但使用不同規模資料：

**Part 1 後測：**

1. 請提交一份 PJM 作業，執行 vec_add_optimized 並附上輸出日誌
2. 比較向量加法基礎版與優化版的執行時間，計算加速比（Speedup）
3. （I/P 級）請解釋為什麼優化版比較快（50 字以內）

**Part 2 後測：**

1. 請執行 vec_add_gpu 並記錄 Kernel 時間
2. 如果向量長度從 1000 萬改為 100，GPU 版會比 CPU 版快嗎？為什麼？
3. （I/P 級）請描述一個適合用 GPU 加速的計算情境，並說明原因

### 6.4 結訓門檻

| 等級 | 結訓標準 | 證明方式 |
|------|----------|----------|
| **Beginner** | 可獨立提交 PJM 作業並取回正確輸出 | CP1 + CP2 通過 |
| **Intermediate** | 可提出至少一項有效優化並量化成果 | CP3 + CP4 通過 + 後測第 2-3 題 |
| **Professional** | 可解釋 CPU/GPU 選型理由與瓶頸來源 | 全部 CP 通過 + 後測完整作答 |

---

## 7. 助教手冊

### 7.1 助教角色與職責

| 角色 | 人數建議 | 負責區域 |
|------|----------|----------|
| **主助教** | 1 人 | 協助講師控制節奏、蒐集問題、管理紅黃綠旗 |
| **區域助教** | 每 10-15 位學員 1 人 | 固定座位區巡迴、即時排除編譯/提交問題 |

### 7.2 助教課前準備清單

- [ ] 確認個人帳號可登入 FX1000 並成功編譯所有範例
- [ ] 在自己的帳號下跑過一次完整流程（Hello → Vector_Add → Challenge）
- [ ] 閱讀本指南 2-6 節，理解分級地圖與評量標準
- [ ] 準備常見錯誤排除筆記（見 7.4 節）
- [ ] 確認紅黃綠旗幟或替代工具（便利貼、線上表單）已備妥
- [ ] 課前 30 分鐘到場，協助學員環境設定

### 7.3 助教課中流程

| 時段 | 助教動作 |
|------|----------|
| 開場（0-20 分） | 協助學員登入、發放前測、處理帳號問題 |
| 示範（20-40 分） | 站在後方觀察學員螢幕，記錄落後者 |
| 實作（40-90 分） | 分區巡迴，每 3 分鐘掃一次紅黃旗，優先處理紅旗 |
| 休息（90-100 分） | 向主助教匯報問題統計，準備下半場 |
| 實作（100-150 分） | 同上；注意 Should/Could 任務也需要引導 |
| 分享（150-170 分） | 協助學員投影、紀錄各組成果 |
| 收尾（170-180 分） | 收回後測、發放回饋表、協助關閉環境 |

### 7.4 常見錯誤排除速查（助教專用）

| 錯誤現象 | 原因 | 解法 |
|----------|------|------|
| `frt: command not found` | 未載入模組 | **FX1000 常見**：`module use /package/fx1000/modulefiles/` 後 `module load tcsds/1.2.40`；其他站臺可能是 `module load lang/tcsds-1.2.37` |
| `FCC: command not found` | 同上 | 同上（與 TCS 同模組） |
| `pjsub: command not found` | 不在計算節點上或 PATH 未設定 | 確認登入正確的 login node |
| `PJM 0020 error` | 群組名稱錯誤 | 將 `<your_group>` 改為實際群組名 |
| `PJM 0040 error` | 資源群組不存在 | 確認 `rscgrp=small` 在該系統可用 |
| 作業卡在 QUEUED | 資源不足或排隊中 | `pjstat -v <job_id>` 查看原因；考慮用 `--interact` |
| `Segmentation fault` | 陣列越界或未配置記憶體 | 用 `-g` 編譯除錯版；檢查陣列索引 |
| `nvcc: command not found` | CUDA 未安裝或 PATH 未設定 | `module load cuda` 或確認 CUDA 路徑 |
| `no CUDA-capable device` | GPU 不可用 | 切換至有 GPU 的節點；或改用純 CPU 模式 |
| Makefile 編譯失敗 | 編譯器不匹配 | Part1 Fortran 需 **`frt`**；C++ 為 **FCC** 或 **g++**；確認 **`module load`** 與 **PATH** |
| `sbatch: error: invalid partition` | Slurm 分區名錯誤 | `sinfo` 查看可用分區，修改 `-p` 參數 |
| `sbatch: error: Invalid account` | Slurm 帳號錯誤 | `sacctmgr show assoc user=$USER` 查看可用帳號 |
| Slurm 作業 PD (PENDING) 很久 | GPU 資源排隊中 | `squeue -j <id>` 查看 REASON；考慮減少 GPU 數量 |

### 7.5 備援方案決策樹

```
FX1000 可用？
├─ 是 → 正常流程（frt + PJM）
└─ 否 → 備援
         ├─ 僅 C++／CUDA 可嘗試本機 g++／nvcc；Fortran 教材須 **A64FX** 上 **`frt`** 或講師示範
         └─ GPU 可用？
             ├─ 是 → 正常 CUDA 流程
             └─ 否 → 僅講解 CUDA 概念與程式碼，不實際執行
```

---

## 8. 平台風險控管清單

### 8.1 課前風險檢查（開課前 3 天）

| # | 檢查項目 | 負責人 | 狀態 |
|---|----------|--------|------|
| 1 | FX1000 系統正常運作，login node 可 SSH 登入 | 系統管理員 | [ ] |
| 2 | 所有學員帳號已建立，群組名稱正確 | 系統管理員 | [ ] |
| 3 | TCS 可載入（例：`module use /package/fx1000/modulefiles/` + `module load tcsds/1.2.40`）且 **`frt`** 在 PATH | 講師/助教 | [ ] |
| 4 | PJM 佇列可正常提交，`rscgrp=small` 可用 | 講師/助教 | [ ] |
| 5 | 教材已 clone 到共用目錄或各學員家目錄 | 助教 | [ ] |
| 6 | `make all` 在 FX1000 上編譯成功 | 助教 | [ ] |
| 7 | GPU 節點（若有）`nvidia-smi` 正常 | 助教 | [ ] |
| 8 | 網路穩定、投影設備正常 | 現場負責人 | [ ] |
| 9 | 備援方案已驗證（預編譯執行檔、線上編譯器或講師示範） | 講師 | [ ] |

### 8.2 課中風險應對

| 風險 | 影響 | 應對 |
|------|------|------|
| FX1000 當機 | 全班無法編譯/提交 | 切換至 x86 備援；講師用預錄影片展示 FX1000 輸出 |
| PJM 佇列滿載 | 作業等待時間過長 | 使用 `--interact` 互動式節點；或先講解下一章節 |
| 學員帳號鎖定 | 個別學員無法操作 | 助教提供臨時共用帳號；或與鄰座 Pair |
| 編譯器版本不一致 | 輸出結果與教材不同 | 事先固定 module 版本；在 Makefile 指定完整路徑 |
| 課程進度落後 | 後段章節被壓縮 | 砍掉 04 以後章節，保護 01-03 核心內容 |
| 初學者心理受挫 | 學員想放棄 | 強調「會用 > 會寫」，降低 Must 任務門檻 |

### 8.3 環境快照建議

為確保上課當天編譯行為一致，建議在課前 3 天：

1. 固定 module 版本：依貴站寫入（FX1000 例：`module use /package/fx1000/modulefiles/` + `tcsds/1.2.40`；或 `lang/tcsds-1.2.37`）；`Part1` 之 **`run_all_tests.sh --submit-pjm`** 預設已對齊 FX1000（見 `PJM_MODULE_USE`／`PJM_MODULE`）
2. 預編譯所有範例，將執行檔保存在 `_prebuilt/` 目錄作為備援
3. 記錄每個範例的預期輸出，供 Checkpoint 驗證時比對

---

## 9. 課前檢查清單（總整理）

### 9.1 環境

- [ ] **`frt`** 與 **`FCC`**（或 **`g++`**）已可執行；Part1 Fortran **`make` 依賴 `frt`**
- [ ] CUDA 環境可用（`nvcc`、`nvidia-smi`）（Part 2）
- [ ] PJM 可提交作業（`pjsub`、`pjstat` 指令可用）
- [ ] 學員帳號可登入、有足夠磁碟配額
- [ ] 教室網路、投影、麥克風正常

### 9.2 教材

- [ ] 教材已 `git clone` 到各學員帳號或共用目錄
- [ ] `make all` 成功編譯（Part 1 + Part 2）
- [ ] 各章節 README 可正常閱讀
- [ ] `00_Cheatsheets/` 可快速查閱（建議列印紙本備用）

### 9.3 教學工具

- [ ] 前測問卷已印刷或建立線上版本
- [ ] 紅黃綠旗幟或便利貼已備妥
- [ ] 助教已完成一次完整演練
- [ ] 備援方案已驗證

---

## 10. 參考文件速查

| 情境 | 文件 |
|------|------|
| 語法不確定 | `00_Cheatsheets/syntax_rosetta_stone.md` |
| 編譯失敗 | `00_Cheatsheets/compilation_guide.md` |
| 優化原理 | `00_Cheatsheets/optimization_mindset.md` |
| 提交作業 | `00_Cheatsheets/pjm_batch_system.md` |
| 專案總覽 | `PROJECT_SUMMARY.md` |
| 技術架構 | `docs/ARCHITECTURE.md` |

---

## 11. 課後建議

1. 請學員完成 `03_Challenge` 並回傳或分享
2. 鼓勵閱讀 `optimization_mindset.md` 深化理解
3. 收集學員回饋問卷，重點收集：
   - 課程節奏是否適當？
   - 哪個章節最有收穫？哪個最困難？
   - 助教協助是否及時？
4. 課後一週內寄出補充資料（含各章節 README 連結與延伸閱讀）
5. 建立學員交流群組（如 Teams/Slack），方便課後提問

---

## 12. 執行時程建議（課前兩週）

| 時間 | 任務 | 負責人 |
|------|------|--------|
| D-14 | 確認開課日期、教室、學員名單 | 講師 |
| D-14 | 發放課前預習材料與環境自檢腳本 | 講師 |
| D-10 | 收回前測問卷，初步分組 | 助教 |
| D-7 | 完成風險檢查清單（第 8.1 節） | 講師 + 助教 |
| D-5 | 助教完整演練一次 | 助教 |
| D-3 | 環境快照：固定 module 版本、預編譯 | 助教 |
| D-1 | 最終環境確認、教材印刷、設備測試 | 全體 |
| D-Day | 提前 30 分鐘到場，協助學員入座與登入 | 全體 |
