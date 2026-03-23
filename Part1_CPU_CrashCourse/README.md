# Part 1: CPU 程式語言速成課程

> 上半年場次 — Fortran 與 C++ 基礎（**下午約 3 小時上機**；上午為課程說明，詳見 [`../PROJECT_SUMMARY.md`](../PROJECT_SUMMARY.md)）

---

## 📋 課程目標

讓完全初學者能夠：
1. 編譯並執行簡單的 Fortran 與 C++ 程式
2. 理解基本的陣列操作與記憶體管理
3. 認識效能優化的基本概念
4. 能修改現有程式碼完成簡單任務
5. （入門）使用除錯與效能分析工具協助找錯與找熱點

---

## ⏱️ 時程安排（對齊 CWA FX1000 新進使用者課綱）

### 下午上機實作（14:00–17:00，約 3 小時）

| 時間 | 實作主題 | 對應教材 | 產出／檢核 |
|-----|---------|---------|------------|
| 14:00-14:40 | 實務演練（一）：合規登入、環境建立、資料操作 | [`00_HPC_Workflow/`](00_HPC_Workflow/)、[`01_Hello/`](01_Hello/)、[`../00_Cheatsheets/pjm_batch_system.md`](../00_Cheatsheets/pjm_batch_system.md) | 完成 SSH 金鑰與 Quota 檢查、`pjsub --interact`、`/IFS`/`/OFS` + `tar` + `rsync`、跨架構套件準備 |
| 14:40-15:30 | 實務演練（二）：A64FX 原生編譯與 Optimization Loop | [`02_Vector_Add/`](02_Vector_Add/)、[`03_Challenge/`](03_Challenge/)、[`08_Debug_Profile/`](08_Debug_Profile/) | 以 `frt`（或站臺允許下 `frtpx`）完成編譯、讀懂 `-Koptmsg=2`、至少完成 1 次 profiler 觀察 |
| 15:45-16:30 | 實務演練（三）：PJM 批次派送、監控與安全中止 | [`04_Matrix_Operations/`](04_Matrix_Operations/)、[`../00_Cheatsheets/pjm_batch_system.md`](../00_Cheatsheets/pjm_batch_system.md) | 成功 `pjsub` + `pjstat`/`pjwait` 監控，並演練 `pjdel`；理解 MPI/OMP 與綁定概念 |
| 16:30-17:00 | Q&A + Troubleshooting | [`10_Troubleshooting_Clinic/`](10_Troubleshooting_Clinic/)、[`08_Debug_Profile/`](08_Debug_Profile/)、[`09_Profiler_Toolkit_TCS/`](09_Profiler_Toolkit_TCS/) | 可判讀 Code 28/29、walltime、OOM、Crash/Core dump，並描述求援路徑 |

### 進階選修（自學或延伸課程）

| 主題 | 資料夾 | 重點 |
|------|--------|------|
| 函數與模組化 | [`06_Functions_Modules/`](06_Functions_Modules/) | 程式碼組織、多檔案編譯 |
| 資料結構 | [`07_Structures/`](07_Structures/) | Derived Types、Struct/Class |
| Instant Performance Profiler（FIPP） | [`09_Profiler_Toolkit_TCS/`](09_Profiler_Toolkit_TCS/) | `fipp`／`fipppx`、`-Nfjprof`／`-Nline`、雙階段熱點 |
| 進階故障排除 | [`10_Troubleshooting_Clinic/`](10_Troubleshooting_Clinic/) | PJM 錯誤、OOM、Core dump、求援資訊包 |

> 以上時程已對齊你提供的 CWA 全日課綱。若站臺政策要求「登入節點僅編輯／提交」，請將長時間執行統一放在互動或批次計算節點進行。**Profiler Toolkit** 深入可在 Q&A 延伸，或另開進階場次 [`09_Profiler_Toolkit_TCS/`](09_Profiler_Toolkit_TCS/)。

### 兩種學習順序（避免 confusion）

| 路徑 | 順序 | 適用情境 |
|------|------|----------|
| **依資料夾編號 01→09** | 01 → 02 → 03 → **04** → 05 → 06 → 07 → **08** → **09** | 自學、`run_all_tests.sh` 預設測試順序；概念上為「語法與優化」→「矩陣／I／O／模組／結構」→「除錯與取樣剖析」→「FIPP 深入」。 |
| **約 3 小時工作坊**（上表） | **00/01**（合規登入與互動資源）→ **02/03**（Optimization Loop）→ **08**（分析）→ **04**（批次派送）→ **10**（Troubleshooting）→ **09**（Q&A 延伸） | 對齊 CWA 14:00–17:00 節奏：先建立合規操作與資料流，再進入編譯優化、排程監控與故障排查。 |

同一章節內容不因順序而改變；若你依編號自學，可無視工作坊插隊，**08 仍建議在 09 之前**（09 README 已標示前置為 08）。

---

## 📂 章節內容

### [00_HPC_Workflow](00_HPC_Workflow/) - 合規登入、資料流與跨架構安裝

**學習目標**：
- 以 SSH 金鑰登入並完成 Quota 配額檢查
- 先 `pjsub --interact` 取得計算資源後再操作
- 建立 `/IFS`、`/OFS` 工作目錄，練習 `tar` + `rsync`
- 於可連外節點準備 `aarch64` 套件（`CONDA_SUBDIR`／`pip download --platform`）

**檔案**：
- `README.md` - 14:00-14:40 實作步驟與 Checkpoint

---

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

### [08_Debug_Profile](08_Debug_Profile/) - TCS Debugger／Profiler（入門，Fortran）

**學習目標**：
- 以 **`frt -g`**（與課程所需之檢查／最佳化選項）編譯 Fortran
- 使用 **TCS Debugger** 於副程式（如 `heavy_work`）設中斷點並檢視變數
- 使用 **TCS Profiler** 分析 `microbench_opt` 之熱點（**不以 GNU gdb／perf 為教學主軸**）
- 認識 **並行應用程式偵錯器**：異常終止／死鎖調查／GDB 命令檔；死鎖調查時 **`mpiexec` 必須同時**使用 **`-fjdbg-dlock`** 與 **`-fjdbg-out-dir`**；以 **`fjdbg_summary`** 整理 **`signal`**／**`deadlock`** 等輸出目錄

**檔案**：
- `microbench.f90` — 熱點副程式 `heavy_work`
- `buggy_bounds.f90` — 陣列越界範例（搭配 `-Hx,CHECK_SUBSCRIPT`）
- `README.md` — 上機步驟、**MPI 死鎖調查選項**與 **`fjdbg_summary`**；速查表請見 [`../00_Cheatsheets/debug_and_profiler.md`](../00_Cheatsheets/debug_and_profiler.md)

---

### [09_Profiler_Toolkit_TCS](09_Profiler_Toolkit_TCS/) — Instant Performance Profiler（FIPP）

**學習目標**：
- 在 **FX1000** 上以 **`frt`**（A64FX 原生）編譯可供 **FIPP（IPP）** 量測之執行檔（**`-Nfjprof`、`-Nline`**，並可併用 **`-g`、`-Kfast`、`-KSVE`、`-Koptmsg=2`**）
- 於**計算節點**使用 **`fipp -C -d ...`** 取樣，於**登入節點**使用 **`fipppx -A -d ...`** 產出分析
- 解讀報告中 **`phase_heavy`**／**`phase_stream`**／**`phase_branch`**／**`phase_light`** 之時間占比，並與 **`-Koptmsg=2`** 對照
- （延伸）理解 **IPP／APP／CPAR** 分工、**`fipp`** 關鍵選項（**`-I`、`-i`、`-S`、`-M`**）、**A64FX** 指標（GFLOPS／SVE／HBM）、**CPAR 週期核算**與 **OpenMP `FLIB_FASTOMP`** 等（見 **`A64FX_Profiler_Reference.md`**）

**檔案**：
- `kernel_phases.f90`、`kernel_profile.f90` — 整程式量測
- `region_marked.f90` — **`fipp_start`**／**`fipp_stop`** + **`-Sregion`**（**`frt`** + FIPP 連結）
- `region_mpi.f90` — MPI Fortran 僅 rank 0 量測（**`make region_mpi`**）
- `run_tests.sh`／**`make test`** — 章節自測
- `README.md` — FIPP 步驟；速查表請見 [`../00_Cheatsheets/profiler_toolkit_tcs.md`](../00_Cheatsheets/profiler_toolkit_tcs.md)
- **`A64FX_Profiler_Reference.md`** — A64FX／**IPP／APP／CPAR** 技術參考（與 *Profiler User's Guide* 對照）

---

### [10_Troubleshooting_Clinic](10_Troubleshooting_Clinic/) — Q&A 實戰排錯

**學習目標**：
- 判讀 PJM 常見失敗（含 Code 28/29、walltime）
- 進行 OOM 排查，並以調整 MPI ranks 降低單行程記憶體壓力
- 產出並讀取 core dump（Segmentation Fault 首輪定位）
- 整理可提交給 CWA / Fujitsu 的最小求援資訊包

**檔案**：
- `README.md` - 16:30-17:00 Q&A 實作流程
- `Optimization_Loop_Demo/` - 完整軟體優化循環案例（profiling → analysis → identify → optimize → verify → reprofiling）

---

## 🎓 學習建議

### 課前準備
1. 確認 Fujitsu 編譯器可用：**ln23 可見 `frtpx`（cross）**、**fx1000 計算節點可見 `frt`（原生）**；Part1 Fortran **完整執行測試**請在 `frt` 環境進行
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

### FX1000（本課程主線）

- **計算節點（A64FX）**：使用 **`frt`／`FCC`**（**原生** Fortran／C++）**編譯並執行**；**不**在登入節點長時間跑計算（可於登入節點編輯與送 `pjsub`）。
- **計算節點**：以 **`pjsub`** 提交 PJM 作業後執行可執行檔（向量／矩陣範例、**FIPP** 等）。詳見 [`../00_Cheatsheets/pjm_batch_system.md`](../00_Cheatsheets/pjm_batch_system.md)。

### 本機／離線

- **Fortran**：教材 **Makefile 要求 `frt`**（於 **A64FX 計算節點** **`module load`** TCS 後取得）；登入節點通常**無** `frt`，請用 **`pjsub`** 或互動計算節點。
- **C++**：多數章節在無 **FCC** 時可退回 **`g++`**（C++11）。
- **Make**、**文字編輯器**：與一般開發相同。

### 快速測試環境

```bash
frt --version      # Part1 Fortran 必備（須在 A64FX 環境）
g++ --version      # 無 FCC 時編譯 C++ 範例
make --version
```

### 一鍵自動測試（`run_all_tests.sh`）

在 `Part1_CPU_CrashCourse` 目錄下會依序對 **01–09** 各章執行 `make clean && make`，並**執行**對應程式（含 Fortran），**不略過任何步驟**。第 **10** 章屬 Q&A/Troubleshooting 與 Optimization Loop 實作，請依章節腳本另行執行。結束時若任一步失敗，腳本以非零 exit code 結束。

**`run_all_tests.sh`** 須在具 **`frt`** 的 **A64FX** 環境執行（互動計算節點或 **`./run_all_tests.sh --submit-pjm`** 送批次至計算節點）。登入節點若無 `frt`，腳本會在前置檢查**直接中止（exit 3）**並提示改至計算節點。

```bash
cd Part1_CPU_CrashCourse
chmod +x run_all_tests.sh
./run_all_tests.sh
./run_all_tests.sh --report part1_autotest_report.txt   # 另存紀錄（含環境快照）
# 詳細編譯／執行輸出（檔案較大，供檢查用）：
./run_all_tests.sh --report part1_test_report_$(date +%Y%m%d_%H%M%S).txt --verbose
```

在具 **PJM／pjsub** 的登入節點上，可將同一套測試送到計算節點（請先將 `PJM_GROUP` 改為您的資源群組；其餘 `#PJM` 選項可依站台調整 `PJM_RSCGRP`、`PJM_ELAPSE` 等）：

```bash
export PJM_GROUP=您的群組
# FX1000 常見（與互動環境一致；`--submit-pjm` 產生之 job 內建預設亦同）：
export PJM_MODULE_USE=/package/fx1000/modulefiles/
export PJM_MODULE=tcsds/1.2.40
# 若貴站無需 `module use`，可設：  export PJM_MODULE_USE=0
# 互動編譯前亦可：  module use /package/fx1000/modulefiles/ && module load tcsds/1.2.40
export PJM_ELAPSE=01:30:00
./run_all_tests.sh --submit-pjm
```

若系統有 `pjwait`，腳本會嘗試等待工作結束；否則請以 `pjstat` 或 PJM 日誌（預設 `part1_autotest.log`）查結果。計算節點上的測試摘要會寫入 `part1_autotest_report.txt`（與腳本同目錄）。不需要 Fujitsu module 時可設 `PJM_MODULE=0`。

- **完整 Part1 基礎章節（01–09）於計算節點之結果**：請查看 **`part1_autotest.log`**（標準輸出合併）與 **`part1_autotest_report.txt`**（時間戳 PASS／FAIL 摘要）。若快照顯示 **`frt: 未找到`**，請在 **A64FX** 環境載入貴站 **`module load`**（例：`module use …` + **`tcsds/1.2.40`**）。

### 僅測試 PJM 是否正常（煙霧測試）

`pjm_smoke_test.sh` 會在**計算節點**印出 `hostname`、時間與架構（預期 **`aarch64`**）。請先將腳本內 **`#PJM -g <your_group>`** 改為您的群組，再於本目錄執行：

```bash
chmod +x pjm_smoke_test.sh
pjsub pjm_smoke_test.sh
# 檢視輸出（檔名依 #PJM -o）
cat pjm_smoke_test.log
```

或一行置換群組後提交（`$(id -gn)` 為目前登入之預設群組，未必符合貴站要求）：

```bash
sed "s/<your_group>/$(id -gn)/" pjm_smoke_test.sh > /tmp/pjm_smoke_run.sh && pjsub /tmp/pjm_smoke_run.sh
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
