# Profiler Toolkit（TCS）速查 — FX1000／Fortran

> 對應教材：`Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/`。  
> **Profiler Toolkit** 指 Technical Computing Suite（TCS）中**用於效能剖析**之工具集合；其中 **Instant Performance Profiler（FIPP／IPP）** 以**取樣分析（sampling analysis）**掌握整體效能趨勢，找出**昂貴運算區域（expensive operation region）**，通常**無需大幅修改程式碼**。實際指令與選項以貴站 TCS 版本手冊為準。

**延伸閱讀（A64FX／IPP／APP／CPAR 技術對照）**：[`../Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/A64FX_Profiler_Reference.md`](../Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/A64FX_Profiler_Reference.md)

---

## 1. 與第 08 章的關係

| 章節 | 重點 |
|------|------|
| **08_Debug_Profile** | TCS Debugger 入門；`frt -g` 與剖析觀念 |
| **09（本章）** | **Instant Performance Profiler（FIPP）** 等工具之**編譯、測量、報告**流程 |

---

## 2. Instant Performance Profiler（FIPP）— 程式調校標準步驟

### 2.1 目的（為何用 FIPP）

透過**取樣分析**掌握整支程式的效能趨勢，找出耗時集中的**昂貴運算區域**；多數情境下**不必**為了量測而大幅改寫程式。

### 2.2 （可選）測量區域：`fipp_start`／`fipp_stop`

- **預設**：FIPP 測量**整支程式**。  
- **僅量測某區段**（例如排除 I/O、只量純運算）：在量測起點／終點呼叫 **`fipp_start`** 與 **`fipp_stop`**，並在執行 **`fipp`** 時加上 **`-Sregion`**（依手冊）。

**Fortran**（直接當副程式呼叫；可宣告 `interface` 區塊）：

```fortran
do i = 1, 10000
  call fipp_start
  ! 內層迴圈或熱點運算
  call fipp_stop
end do
```

**C／C++**：`#include "fj_tool/fipp.h"`，於區段前後呼叫 **`fipp_start()`**／**`fipp_stop()`**。

**MPI Fortran（僅量測單一進程，例如 rank 0）**：

```fortran
call MPI_Init(ierr)
call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
if (rank == 0) call fipp_start
! … 共同或分支運算 …
if (rank == 0) call fipp_stop
call MPI_Finalize(ierr)
```

**量測所有進程**：在 **`MPI_Init`** 之後、**`MPI_Finalize`** 之前，讓各進程皆執行 **`fipp_start`**／**`fipp_stop`**。

教材範例：`Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/region_marked.f90`、`region_mpi.f90`。

### 2.3 設定環境變數

- 編譯與執行前，依站臺說明設定 **`PATH`**、**`LD_LIBRARY_PATH`** 等，使能找到工具安裝路徑。  
- **請勿**自行任意設定以 **`FIPP_`**、**`FAPP_`** 等開頭之**系統保留**環境變數（除非手冊明確要求）。

### 2.4 編譯程式（Fujitsu 編譯器）

使用 **`frt`**、**`fccpx`**、**`FCCpx`**、**`mpifrt`** 等（依專案為準）。

| 重點 | 說明 |
|------|------|
| **`-Nfjprof`** | 連結 Profiler 相關函式庫；多數情境下編譯時**預設會啟用**（仍建議對照手冊確認）。 |
| **`-Nline` 或 `-ffj-line`** | **強烈建議**至少擇一，以利 Profiler 對應**原始碼行數**與**迴圈成本**。 |
| **勿 `strip`** | 編譯產物**請勿**再執行 **`strip`**，否則符號被剝除會導致量測／對應原始碼失準。 |
| **其餘** | 與本教材一致時可併用 **`-g`**、**`-Kfast`**、**`-KSVE`**、**`-Koptmsg=2`** 等（見下節與 `09` 之 `Makefile`）。 |

### 2.5 測量效能資料（`fipp`，建議於計算節點）

在**運算節點**上以 **`fipp`** 執行程式並收集資料；必須指定 **`-C`**（測量資料）與 **`-d`**（儲存目錄）。

```bash
# 基本測量（整程式）
mkdir -p ./tmp
fipp -C -d ./tmp ./a.out
```

已使用 **`fipp_start`**／**`fipp_stop`** 標示區段時，加上 **`-Sregion`**：

```bash
fipp -C -d ./tmp -Sregion ./region_marked
```

同時需要 **Call Graph** 與 **CPU 效能特徵**時，可加上 **`-I`**：

```bash
fipp -C -d ./tmp -Icall,cpupa ./a.out
```

（`09` 範例：**`./kernel_profile_opt`**、**`./region_marked`**。）

### MPI：只量測特定 rank（例如 process 0）

在 MPI 程式中，若只想收集特定進程資料，請用 `rank` 條件包覆量測常式；沒有呼叫到常式的進程不會被記錄。此邏輯同時適用 **`fipp_*`** 與 **`fapp_*`**。

```c
MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
if (rank == 0) {
  fipp_start();                  /* or fapp_start("foo", 1, 0) */
}
/* ... target region ... */
if (rank == 0) {
  fipp_stop();                   /* or fapp_stop("foo", 1, 0) */
}
MPI_Finalize();
```

```fortran
call mpi_init(ierr)
call mpi_comm_rank(mpi_comm_world, rank, ierr)
if (rank == 0) then
  call fipp_start
  ! call fapp_start("foo", 1, 0)
end if
! ... target region ...
if (rank == 0) then
  call fipp_stop
  ! call fapp_stop("foo", 1, 0)
end if
call mpi_finalize(ierr)
```

**`fipp` 選項摘錄**（完整表見 [`A64FX_Profiler_Reference.md`](../Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/A64FX_Profiler_Reference.md) §2.2）：

| 選項 | 作用 |
|------|------|
| `-C` | 執行資料量測（必備） |
| `-d` *dir* | 資料目錄（空或不存在） |
| `-I` | 如 `call`、`cpupa`、`mpi` |
| `-i` | 抽樣間隔（預設約 100 ms 量級，過短易擾動） |
| `-S` | `all` 或 `region`（搭配 `fipp_start`／`fipp_stop`） |
| `-M` | 內聯成本歸屬：`Mnoinlined`／`Minlined`（C/C++ 為主） |

### 2.6 輸出與分析（`fipppx` 或 `fipp`）

測量完成後：

| 節點 | 指令 | 說明 |
|------|------|------|
| **登入節點** | **`fipppx`** | 例：`fipppx -A -d ./tmp`（**`-A`**：分析；**`-d`**：測量資料目錄） |
| **運算節點** | 繼續使用 **`fipp`** | 依手冊指定分析輸出 |

可用 **`-I`** 篩選資訊類型（例如 **`call`**、**`cpupa`**、**`mpi`**、**`src`** 等），並以 **`-t`** 指定輸出格式：**`text`**、**`csv`**、**`xml`**。

### 2.7 報告裡要看什麼

可檢視（依工具版本與選項）：

- **統計時間資訊**
- **CPU 效能特徵**
- **成本資訊**（程序／迴圈／程式行等層級之成本分布）
- **Call Graph**

據此找出**耗時最長**之區塊後，再決定是否進入**更細之 Advanced Performance Profiler**（見 2.8）。

### 2.8 後續深度調校（Advanced Performance Profiler）

若需更細之 **MPI 通訊成本**與 **CPU Performance Analysis Report（CPAR）** 等，下一步可在鎖定之區塊加入 **`fapp_start`**／**`fapp_stop`**（參數 **name／number／level** 與 **`-L`**、**`-Hmethod`** 等），**重新編譯**後依 **APP** 手續量測（與 IPP 之 **`fipp_*`** 分屬不同層級）。詳見 [`A64FX_Profiler_Reference.md`](../Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/A64FX_Profiler_Reference.md) §3–§7。

**OpenMP 注意**：量測執行緒行為時，執行時建議 **`export FLIB_FASTOMP=TRUE`**（依 *Profiler User's Guide*）。

---

## 3. 與本教材 `09` Makefile 的對應（`frt`）

在 **`frt`** 路徑下，`09` 預設約等同：

```bash
frt -g -Kfast -KSVE -Koptmsg=2 -Nfjprof -Nline kernel_phases.f90 kernel_profile.f90 -o kernel_profile_opt
```

教材 **`09` 之 Makefile 僅使用 `frt`**（含 **`-Nfjprof`／`-Nline`**）；請在 **A64FX 計算節點**載入 TCS 模組後再 **`make`**。

**自動化自測（教材 `09`）**：`make test` 僅驗證編譯與 checksum；在已載入 TCS 之環境可執行 **`make test-profilers`**，會嘗試 **`fipp`**、**`fipppx -A`**、**`fapp`**（詳見 `09_Profiler_Toolkit_TCS/run_tests.sh` 與 README）。本機若無上述指令會顯示 SKIP。

---

## 4. 解讀時常見問題

| 現象 | 可能原因 |
|------|----------|
| 報告幾乎全在單一函式 | 負載集中；或內聯／優化導致符號合併 |
| 無法對應行號 | 未加 **`-Nline`**／**`-ffj-line`**，或執行過 **`strip`** |
| 與 `cpu_time` 粗估差異大 | 取樣誤差、快取狀態、暖機次數 |

---

## 5. 官方文件：從哪裡查？

| 文件 | 說明 |
|------|------|
| [**Profiler User's Guide**（PDF）](https://www.r-ccs.riken.jp/fugaku/docs/manual/en/lang/tool/j2ul-2568-01enz0.pdf) | FIPP／`fipp`／`fipppx` 等（依版本） |
| [Fortran User's Guide](https://www.r-ccs.riken.jp/fugaku/docs/manual/en/lang/j2ul-2558-01enz0.pdf) | `-Nfjprof`、`-Nline` 等編譯選項 |
| [Fujitsu Software Manuals 索引](https://software.fujitsu.com/jp/manual/manualindex/p22000026e.html) | 與貴站 **tcsds** 版本對齊 |

---

## 6. 延伸閱讀（本教材內）

- [`debug_and_profiler.md`](debug_and_profiler.md) — TCS Debugger／整體觀念  
- [`compilation_guide.md`](compilation_guide.md) — `frt` 常用選項  
- `Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/README.md` — 範例程式與 PJM／`fipp` 指令範例  
- `Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/run_profile_workflow.sh` — 一鍵工作流（FIPP/FIPPPX/FAPP）  
- `Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/PROFILE_REVIEW_TEMPLATE.md` — 課堂判讀模板
