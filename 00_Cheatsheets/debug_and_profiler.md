# FX1000／TCS — Debug 與 Profiler 速查（Fortran 主軸）

> **本課程以 PRIMEHPC FX1000 上之 Technical Computing Suite（TCS）為準**，使用 **Fujitsu Fortran 編譯器 `frt`** 與 **TCS Debugger**、**TCS Profiler**。**不**以 GNU `gdb`／`perf`／Valgrind 作為教學主線。  
> 實際選單、啟動指令與專案檔格式請以**貴中心安裝之 TCS 版本**所附手冊為準（常見關鍵字：*Technical Computing Suite*、*TCS Debugger*、*TCS Profiler*、*Profiler User's Guide*）。

---

## 1. 角色分工（觀念）

| 工具 | 典型用途 |
|------|----------|
| **TCS Debugger** | 中斷點、單步、檢視變數與呼叫堆疊；搭配 `-g` 與（選用）執行時檢查選項 |
| **TCS Profiler** | 觀察時間／事件分布、熱點常式；搭配可分析之編譯產物（通常需除錯資訊與適當最佳化） |
| **`frt` 編譯選項** | 產生除錯用符號、邊界檢查、優化與優化訊息（與「先量測再優化」流程銜接） |

---

## 2. Fortran 編譯（`frt`）— 與除錯／分析相關

以下與 [`compilation_guide.md`](compilation_guide.md) 一致，為本節實作**必備**基礎。

```bash
# 除錯／執行時邊界檢查（教學用「慢但安全」；含陣列下標等，見 Fujitsu 手冊 -Haefosux）
frt -g -Haefosux microbench.f90 -o microbench_dbg

# 效能分析用：最佳化 + 除錯符號（實際旗標依 TCS Profiler 手冊微調）
frt -g -Kfast -KSVE -Koptmsg=2 microbench.f90 -o microbench_opt
```

| 選項 | 說明 |
|------|------|
| `-g` | 產生除錯資訊，供 **TCS Debugger**／**TCS Profiler** 對應原始碼 |
| `-Haefosux` | 編譯／執行期詳細檢查（含陣列形狀與下標、介面引數等；教學示範用）。舊文件常寫 `-Hx,CHECK_SUBSCRIPT`，部分 TCS 版本會報 `Invalid suboption for -H`，請改此選項 |
| `-Kfast`、`-KSVE` | 一般最佳化與 SVE 向量化（與 Part1 其他章節一致） |
| `-Koptmsg=2` | 輸出優化訊息，輔助理解「編譯器做了什麼」 |
| `-Nquickdbg` | 在除錯時維持部分最佳化（依需求選用，見編譯器手冊） |

---

## 3. TCS Debugger（流程概念）

1. 以 **`frt -g ...`**（必要時加 **`-Haefosux`**）完成連結，產生可除錯執行檔。  
2. 依站臺程序啟動 **TCS Debugger**，載入執行檔與（若需要）原始碼路徑。  
3. 在熱點副程式（例如本教材 `microbench.f90` 內之 `heavy_work`）設**中斷點**，執行並**單步**、檢視變數。  
4. 對 **`buggy_bounds`** 一類越界範例：可觀察執行時檢查如何攔截錯誤（與未開檢查時行為對照）。

> **注意**：平行程式（MPI／OpenMP）除錯時，程序更複雜；本教材僅示範**序列 Fortran**。並行除錯器之**死鎖調查**與 **`fjdbg_summary`** 見下節與 [`Part1_CPU_CrashCourse/08_Debug_Profile/README.md`](../Part1_CPU_CrashCourse/08_Debug_Profile/README.md)。

### 3.1 並行偵錯：死鎖調查（`mpiexec`）與 `fjdbg_summary`（速查）

**並行應用程式偵錯器**含異常終止調查、死鎖調查、GDB 命令檔控制等；另以 **`fjdbg_summary`** 對調查輸出做回溯**重複排除**與格式化。

**死鎖調查**須在 **`mpiexec`** 上**同時**指定（僅其一會錯誤退出）：

| 選項 | 用途 |
|------|------|
| `-fjdbg-dlock` | 啟用死鎖調查 |
| `-fjdbg-out-dir output-dir` | 結果目錄（可自動建立；既有目錄下不可有名為 `deadlock` 的**檔案**；若有 `deadlock/` 子目錄則須**空**） |

範例：`mpiexec -fjdbg-dlock -fjdbg-out-dir "/fefs/log" -n 4 ./a.out`

**`fjdbg_summary`**：`fjdbg_summary [ -h \| -v ] [ -n ] [ -a ] [ -b ] [ -r rankspec ] [ -p outrank ] input-dir`  
`input-dir` 通常為 **`signal`** 或 **`deadlock`**（或 spawn 相關目錄）。**`-a`** 與 **`-n`** 互斥（並存時以 **`-n`** 為準）。詳見 **08** README。

---

## 4. TCS Profiler（流程概念）

1. 使用與分析目標相符之編譯選項（通常為 **`-g` + 最佳化**，例如 `-Kfast -KSVE`），產生 `microbench_opt` 這類執行檔。  
2. 依 **TCS Profiler** 手冊建立分析工作階段，指定執行檔與參數，於計算節點或互動環境中執行。  
3. 檢視報告中**耗時比例高**之程序／區段，對照 `-Koptmsg=2` 之編譯器訊息與原始碼。  
4. 「先量測再優化」：先由 Profiler 確認瓶頸，再調演算法或編譯選項。

**Profiler Toolkit／Instant Performance Profiler（FIPP）**：見 [`profiler_toolkit_tcs.md`](profiler_toolkit_tcs.md)（**`fipp`**／**`fipppx`**、`-Nfjprof`、`-Nline` 等）與教材 `Part1_CPU_CrashCourse/09_Profiler_Toolkit_TCS/`。

---

## 5. 與本機／GNU 工具之關係

- **正式課程與評量**以 **FX1000 + TCS + `frt`** 為準。  
- 若學員未在 FX1000 上以 **`frt`** 建置並操作 TCS Debugger／Profiler，**不**視為已涵蓋本教材之除錯／剖析實作；請於叢集上補齊。

---

## 6. Q&A 常見故障：OOM 與 Core dump

### 6.1 OOM（Out Of Memory）快速處置

常見徵兆：作業 log 出現 `Killed`、`out of memory`、或程式在大資料規模下突然中止。

建議排查順序：

1. 先縮小資料規模確認可重現性  
2. 降低 MPI ranks（每 rank 可用記憶體上升）  
3. 固定總核心數後，嘗試不同 `proc x thread` 組合  
4. 重新觀察執行時間與記憶體峰值

> 在 A64FX 單節點上，過多 ranks 常導致每行程記憶體不足；先減少 ranks 通常是最快的止血法。

### 6.2 Core dump（Segmentation Fault）最小流程

```bash
ulimit -c unlimited
./your_program
gdb ./your_program core
(gdb) bt
(gdb) frame 0
(gdb) info locals
```

若站台採集中式 core 管理，可使用 `coredumpctl list` 查詢。  
本課主軸仍為 TCS 工具；此流程用於 Q&A 現場的第一時間定位。

---

## 7. 延伸閱讀

- [`compilation_guide.md`](compilation_guide.md) — `frt` 完整選項  
- [`optimization_mindset.md`](optimization_mindset.md) — 先量測再優化  
- [`../Part1_CPU_CrashCourse/08_Debug_Profile/README.md`](../Part1_CPU_CrashCourse/08_Debug_Profile/README.md) — TCS Debugger／Profiler、**死鎖調查**、`fjdbg_summary`  
- [`../Part1_CPU_CrashCourse/10_Troubleshooting_Clinic/README.md`](../Part1_CPU_CrashCourse/10_Troubleshooting_Clinic/README.md) — PJM 失敗、OOM、Core dump、求援流程  
- 站臺提供之 **TCS／PRIMEHPC 使用者手冊**（Debugger／Profiler／並行偵錯專章）
