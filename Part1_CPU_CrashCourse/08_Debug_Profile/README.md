# 08 — TCS Debugger 與 TCS Profiler 入門（FX1000／Fortran）

## 學習目標

- 以 **Fujitsu `frt`** 編譯 Fortran，並使用 **`-g`** 與（選用）**`-Haefosux`** 產生可供 **TCS Debugger** 使用的執行檔（執行期檢查含陣列下標等；舊寫法 `-Hx,CHECK_SUBSCRIPT` 在部分 TCS 版本會失敗）。  
- 在 **TCS Debugger** 中於副程式（如 `heavy_work`）設中斷點、單步執行、檢視變數。  
- 以 **TCS Profiler** 分析 **`microbench_opt`** 這類最佳化執行檔之熱點，並與 **`-Koptmsg=2`** 編譯訊息對照（**Profiler Toolkit 深入操作**見 [`../09_Profiler_Toolkit_TCS/README.md`](../09_Profiler_Toolkit_TCS/README.md)）。  
- （MPI／平行程式）認識 **並行應用程式偵錯器（Debugger for Parallel Applications）** 之**死鎖調查**與 **`mpiexec` 執行選項**、**`fjdbg_summary`** 之用途與限制。  
- **不**使用 GNU `gdb`／`perf`／Valgrind 作為本教材主軸。

速查表：[`../../00_Cheatsheets/debug_and_profiler.md`](../../00_Cheatsheets/debug_and_profiler.md)

---

## 檔案說明

| 檔案 | 用途 |
|------|------|
| `microbench.f90` | 內含熱點副程式 `heavy_work`，分別編譯為 `microbench_dbg`／`microbench_opt` |
| `buggy_bounds.f90` | 陣列越界範例；搭配 **`-Haefosux`** 示範執行時檢查 |
| `Makefile` | 僅 **`frt`**（無則 **`make` 失敗**） |

---

## 上機流程（建議 20 分鐘）

### 1. 載入 TCS／編譯環境

依貴中心規範（例如 `module load lang/tcsds-...`），確認 **`frt`** 可用。

### 2. 編譯

```bash
make clean && make
```

### 3. TCS Debugger

1. 以 **`microbench_dbg`**（含 `-g`、建議含 **`-Haefosux`**）為標的。  
2. 依 **TCS Debugger** 手冊建立工作階段，載入執行檔。  
3. 於副程式 **`heavy_work`** 設中斷點，執行並單步，檢視區域變數 `i`、`s`。

### 4. TCS Profiler

1. 以 **`microbench_opt`**（`-g -Kfast -KSVE -Koptmsg=2`）為分析對象。  
2. 依 **TCS Profiler** 手冊執行取樣或事件分析，檢視耗時最高之程序／區段。

### 5. 邊界檢查示範（選修）

```bash
./buggy_bounds
```

若已以 **`-Haefosux`** 連結，預期於越界存取時由執行時檢查攔截（實際訊息依編譯器版本而定）。

---

## 任務分級（Must / Should / Could）

| 層級 | 任務 |
|------|------|
| **Must** | 於 FX1000 上以 `frt` 完成編譯，並於 **TCS Debugger** 中在 `heavy_work` 至少命中一次中斷點 |
| **Should** | 使用 **TCS Profiler** 執行 `microbench_opt`，於報告中指出主要熱點程序名稱 |
| **Could** | 對照 **`-Koptmsg=2`** 輸出與 Profiler 結果，寫一句話說明「編譯器優化」與「量測熱點」之關聯 |

---

## 並行應用程式偵錯器（Parallel Application Debugger）— 概念與工具

本節補充 **Fujitsu／TCS 並行應用程式偵錯器**之**三大核心調查與控制功能**，以及輔助用的 **重複排除（Duplication Removal）**。實際啟動方式、授權與版本請以**貴站手冊**為準。

### 三大核心功能

| 功能 | 說明 |
|------|------|
| **1. 異常終止調查（Abnormal Termination）** | 程式因異常終止而收到特定信號時，自動蒐集回溯（backtraces）、特定框架之區域／引數變數、信號位址附近之反組譯、暫存器與記憶體對應（memory map）等。 |
| **2. 死鎖調查（Deadlock）** | 判斷是否發生死鎖並協助找原因；程式無法結束或失去回應時，蒐集**所有工作行程**之執行資訊（含回溯、變數與 memory map 等）。**啟動方式見下文 `mpiexec` 兩項必備選項。** |
| **3. 命令檔除錯控制（Command Files）** | 使用含 **GDB 命令**之命令檔，於提交工作時套用，可依行程屬性彈性除錯，甚至僅針對**單一行程**。 |

### 輔助：重複排除（`fjdbg_summary`）

異常終止與死鎖調查會產生大量輸出；**`fjdbg_summary`** 可對結果目錄做**回溯重複排除**與**格式化**，提升可讀性（詳見下方專節）。

---

## 死鎖調查：`mpiexec` 執行選項（Runtime Options）

使用**死鎖調查**時，必須在執行 **`mpiexec`** 時**同時**加上下列**兩個**選項（可單連字號 `-` 或雙連字號 `--` 開頭）。**僅指定其中一個**時，程式會輸出錯誤並終止。

| 選項 | 作用 |
|------|------|
| **`-fjdbg-dlock`**（或 `--fjdbg-dlock`） | 啟用死鎖調查。 |
| **`-fjdbg-out-dir output-dir`**（或 `--fjdbg-out-dir output-dir`） | 指定調查結果檔案之儲存目錄；`output-dir` 可為**絕對或相對路徑**。 |

**目錄注意事項：**

- 若目錄不存在，系統會**自動建立**。  
- 若目錄已存在，其下**不得**已有名為 **`deadlock` 的檔案**。  
- 若已存在名為 **`deadlock` 的子目錄**，該子目錄**必須為空**，否則會在 **rank 0** 輸出錯誤並終止。

**執行範例：**

```bash
mpiexec -fjdbg-dlock -fjdbg-out-dir "/fefs/log" -n 4 ./a.out
```

> 本資料夾之 **`microbench.f90`** 為序列程式；死鎖調查需搭配 **MPI** 執行檔與站臺規定之 `mpiexec`。教學上請先確認手冊與叢集政策後再於計算節點實作。

---

## `fjdbg_summary`：重複排除與格式化

對**異常終止**或**死鎖調查**產生之結果目錄，可用 **`fjdbg_summary`** 執行**重複排除**（合併重複回溯並格式化資訊），便於閱讀。

**基本語法：**

```text
fjdbg_summary [ -h | -v ] [ -n ] [ -a ] [ -b ] [ -r rankspec ] [ -p outrank ] input-dir
```

| 項目 | 說明 |
|------|------|
| **`input-dir`（必填）** | 要處理之目錄（相對或絕對路徑）。通常為調查產生之 **`signal`** 或 **`deadlock`** 目錄（動態 spawn 時可能為 **`spawn-number`** 目錄）。 |
| **（無額外選項）** | 預設以**函數名稱**為鍵，對**所有 rank** 做回溯重複排除並格式化輸出。 |
| **`-a`** | 以**函數名稱 + 回溯位址（address）**為鍵做重複排除。**不可**與 **`-n`** 同時生效（若同時指定，以 **`-n`** 為準）。 |
| **`-n`** | **不做**回溯重複排除，僅格式化各類資訊。 |
| **`-b`** | 預設若物件檔缺符號會停止輸出回溯；加上後即使無符號仍輸出回溯至最後。 |
| **`-r rankspec`** | 限制輸出之 rank，例如 `-r 1`、`-r 1-10`、`-r 1,4-6,8`；未指定則輸出全部。 |
| **`-p outrank`** | 指定輸出特定框架之區域／引數變數值的 rank；未指定則預設全部。 |
| **`-h` / `-v`** | 用法／版本資訊。 |

**範例：**

```bash
fjdbg_summary -a -r 1-10 ./dbg_result/signal
```

讀取 `./dbg_result/signal`，擷取 rank 1–10，並以函數名稱與位址為鍵排除重複回溯。

**標準輸出內容順序（處理後）：**

1. 回溯、特定框架之區域變數與引數  
2. 偵測到信號位置前後之程式碼反組譯  
3. 暫存器內容  
4. 記憶體對應（Memory Map）

---

## 注意事項

- **`buggy_bounds`** 用於示範錯誤行為；自動化測試**不執行**該程式，僅編譯。  
- 圖形化 Debugger／Profiler 若需 **X11／VNC**，請依叢集政策設定。  
- 啟動指令與專案檔格式請以**貴站 TCS 文件**為準，本 README 僅提供流程概念。  
- **`mpiexec -fjdbg-*`** 與 **`fjdbg_summary`** 之行為與錯誤訊息以**實際安裝之偵錯器版本**為準；路徑、配額與 **`deadlock`** 目錄限制請於上機前確認。

---

## 下一步（與 Part1 其他章的銜接）

| 情境 | 建議 |
|------|------|
| **依編號 01→09 自學** | 接 [`09_Profiler_Toolkit_TCS`](../09_Profiler_Toolkit_TCS/)（Instant Performance Profiler／`fipp`；與本章 TCS Profiler 互補，見 09 開頭「定位」）。 |
| **依工作坊時程**（03 之後先上本章） | 回到主線：[`04_Matrix_Operations`](../04_Matrix_Operations/) → [`05_File_IO`](../05_File_IO/) → …；完整對照見 [`../README.md`](../README.md)「兩種學習順序」。 |
