# Fujitsu A64FX 處理器效能特性與成本分佈 — 技術參考（Profiler Toolkit）

> 本文件整理 **A64FX** 上 **Fujitsu Profiler** 之概念與實務要點，供 HPC 架構師與軟體開發者對照 **Profiler User's Guide**／站臺文件使用。  
> 與本章範例程式之對應見同目錄 [`README.md`](README.md)。

---

## 1. 診斷隔離與工具鏈定位

在具備 **SVE** 與 **HBM2** 的 A64FX 上，優化戰略核心為 **診斷隔離（Diagnostic Isolation）**：

1. 先識別 **高昂運算區域（Expensive Operation Regions）**；  
2. 再以硬體計數器與報告精確定位流水線停頓或通訊瓶頸。

**Fujitsu Profiler** 提供互補工具鏈：

| 工具 | 英文縮寫 | 角色 |
|------|----------|------|
| **Instant Performance Profiler** | **IPP**（教材中常見指令 **`fipp`**／分析 **`fipppx`**） | 低開銷、**全域**效能趨勢（抽樣） |
| **Advanced Performance Profiler** | **APP**（**`fapp`**／**`fapp_start`**／**`fapp_stop`**） | **區域**、指令級／通訊成本之較精細量測 |
| **CPU Performance Analysis Report** | **CPAR** | 以 **Excel** 等視覺化呈現 **週期核算（Cycle Accounting）** 等 PMU 診斷 |

流程上可視為：**IPP 篩全域熱點 → APP 鎖定區域深挖 → CPAR 做週期層級診斷**（依需求與採集次數累積）。

---

## 2. Instant Performance Profiler（IPP）技術細節

### 2.1 抽樣機制與限制

- IPP 以**固定時間間隔**觸發抽樣。  
- 若程式**總執行時間過短（例如遠小於 1 秒）**，樣本數可能不足，**統計代表性差**，不適合當作嚴格結論依據。  
- **不建議**以極短 **micro-benchmark** 單獨依賴 IPP 做「定論」（本教材 **`KERNEL_PROFILE_N`** 可調整執行長度，即與此相關）。

### 2.2 `fipp` 核心選項（摘錄）

| 選項 | 功能 | 備註 |
|------|------|------|
| **`-C`** | 執行資料量測 | 啟用採集之**必要**選項 |
| **`-d`** *dir* | 資料儲存目錄 | 須為**空目錄**或**不存在**（由工具建立） |
| **`-I`** *項目* | 量測項目 | 例如 **`call`**（呼叫圖）、**`cpupa`**（CPU 特性）、**`mpi`**（MPI 成本）。**`-Icall`** 為啟用 **`-Puserfunc`** 等之前提（依版本／手冊） |
| **`-i`** *間隔* | 抽樣間隔 | 約 **10–3,600,000 ms**（預設常見為 **100 ms**）；過短易增加系統擾動 |
| **`-S`** *範圍* | 量測範圍 | **`all`**：整程式；**`region`**：需搭配程式內 **`fipp_start`**／**`fipp_stop`**（本教材 **`region_marked`** + **`fipp -Sregion`**） |

### 2.3 內聯與成本歸屬（`-M`）

C/C++ 高度優化時，內聯會改變呼叫圖：

| 選項 | 意涵 |
|------|------|
| **`-Mnoinlined`**（常見預設） | 內聯函式成本計入**呼叫者（Caller）** — 利於模組間負載分佈 |
| **`-Minlined`** | 成本歸於**被呼叫者（Callee）** — 利於定位被大量內聯之函式實際開銷 |

---

## 3. Advanced Performance Profiler（APP）與區域量測

### 3.1 `fapp_start`／`fapp_stop`

- 開發者以 **(name, number, level)** 標註區域（語言／介面細節以手冊為準）。  
- **level** 與執行時 **`fapp`** 的 **`-L`** 搭配：僅當 **`-L` ≥ 程式內 level** 時該區域才會啟用量測。

**保留名稱警告**：系統保留 **`name="all"`, `number=0`** 作為全程式量測標記。若使用 **`-Hmethod=fast`**，可能**不支援**量測 **`"all:0"`** 區域；全程式量測需改 **method=normal** 或改用**非保留**之自訂區域名稱（依手冊）。

### 3.2 量測模式（`-H`）

| 模式 | 說明 |
|------|------|
| **method=fast** | 硬體驅動為主，開銷較小，適合**極緊密迴圈** |
| **method=normal** | 經 OS 核心路徑，系統級資訊較完整，精密度與支援面與 fast 不同 |

---

## 4. 核心 CPU 指標（架構師視角）

解讀 A64FX 報告時，宜連同**硬體行為**一起判讀：

- **GFLOPS 與 SVE 遮罩**：報告 GFLOPS 常假設向量**全部活躍**；若實務上 **SVE predication** 導致大量通道被遮罩，可出現「數值高但有效運算少」之**廢止操作**現象，應檢視迴圈與資料對齊以提高向量填充率。  
- **SIMD vs SVE**：需區分傳統固定寬度 SIMD 與 **512-bit SVE**；SVE 比例偏低可能表示編譯器多走非 SVE 路徑。  
- **記憶體吞吐量（GB/s）**：與理論峰值比較；偏低時常見 **非連續／Stride** 存取導致 **HBM2** 頻寬浪費在無效快取行載入。  
- **IPC／GIPS**：**IPC** 偏低常與流水線停頓相關，需搭配週期核算判斷是**資料依賴**或**資源衝突**。

---

## 5. 成本分佈（Cost Distribution）與 `@balance`

**OpenMP 負載平衡**相關指標 **@balance**（概念式）：

- 公式型態：**(@cost2 − 平均值) / 平均值 × 100%**（細節以報告與手冊為準）。  
- 計算時常**排除執行緒屏障**之 @cost2，以**純計算分配**是否均勻為主。若絕對值過大（例如超過 **±100%**），表示嚴重**負載傾斜**。

### 編譯器產生之程序命名（節錄）

| 語言／模式 | 情境 | 名稱模式（示意） |
|------------|------|------------------|
| Fortran／Trad | 自動平行化 | `proc._PRL_num_` |
| Fortran／Trad | OpenMP | `proc._OMP_num_` |
| C++／Clang Mode | OpenMP | `proc.omp_outlined._debug__num` |
| C++／Trad | TASK | `proc._TSK_num_` |

---

## 6. MPI 通訊成本與訊息長度（節錄）

- 報告常區分 **等待時間** 與**實際傳輸**；細節行可能以**括號與縮排**呈現 **MPI_STARTALL** 等持久通訊之多請求。  
- 訊息長度常見以 **0–4K／4K–64K／64K–1024K／1024K+** 等區間做直方圖，用以診斷**小訊息過多**或 **Rendezvous** 切換等問題。

**訊息長度計算（Byte）概念表（核對 Tofu 負載時參考）**：

| MPI 函數 | 長度邏輯（概念） |
|----------|------------------|
| **BCAST（Root）** | 元素數 × 型別大小 × **2** |
| **BCAST（非 Root）** | 元素數 × 型別大小 |
| **GATHER（Root）** | (發送元素×大小) + (總進程數×接收元素×大小) |
| **ALLTOALL** | (總進程數×發送元素×大小) + (總進程數×接收元素×大小) |
| **REDUCE_SCATTER** | (總發送元素×大小) + (接收元素×大小) |

（實務請以應用程式實際參數與手冊公式為準。）

---

## 7. CPU Performance Analysis Report（CPAR）

- **等級**：常見如 **Single／Brief／Standard／Detail**（依版本）。  
- **累積量測**：可在既有採集上**增量**補齊 PMU 事件以升級報告等級（例如手冊所述補 **pa12–pa17** 等以邁向 **Detail**）。  
- **週期核算（Cycle Accounting）**：將時間拆解為多類週期（Brief 約 **9** 類、Standard／Detail 可達 **20** 類），例如：  
  - **Floating-point Pipeline Stall**  
  - **L1／L2 Cache Wait**  
  - **Hardware Prefetch** 相關指標等  

---

## 8. 實務注意事項與環境配置

### 8.1 編譯與符號

| 項目 | 說明 |
|------|------|
| **Trad Mode（Fortran）** | 剖析相關常需 **`-Nfjprof`**（與本教材 `Makefile` 一致方向） |
| **Clang Mode（C/C++）** | 可能需 **`-ffj-fjprof`**（依專案與手冊） |
| **行級成本** | 需 **`-g`** 且 **`-Nline`** 或 **`-ffj-line`**，否則難有完整 **line cost** |
| **strip** | **禁止**對執行檔 **`strip`**，否則易出現大量 **`__?unknown`**，分析失效 |

### 8.2 執行環境（OpenMP 與 Profiler）

| 變數／議題 | 說明 |
|------------|------|
| **`FLIB_FASTOMP=TRUE`** | 量測 **OpenMP** 行為時，執行時**建議設定**；未設定可能導致執行緒相關資訊**嚴重失真**（依手冊） |
| **記憶體** | 每執行緒預設工作空間（手冊常載約 **3000KB** 量級）— 大規模並行時需估算**節點內總量** |

### 8.3 與本章範例的對應

| 教材檔案／指令 | 對應本參考之概念 |
|----------------|------------------|
| **`fipp -C -d`** | §2.2 IPP 採集 |
| **`fipp -Sregion`** + **`region_marked.f90`** | §2.2 **`-S region`** |
| **`fipp -Icall,cpupa`** | §2.2 **`-I`** |
| **`fapp`**／**`fapp_start`／`fapp_stop`** | §3 APP（進階，需另依手冊調編譯與執行參數） |
| **`KERNEL_PROFILE_N`**／**`kernel_n_default`** | §2.1 執行時間過短不利 IPP 統計 |
| **PJM／計算節點執行** | 與登入節點政策一致：量測應在**計算節點**執行 |

---

## 9. 結語

透過 **IPP** 做全域篩選、**APP** 做區域隔離、**CPAR** 做週期層級診斷，可建立 A64FX 上較完整之效能工程流程。細節仍以 **Fujitsu Profiler User's Guide** 與貴中心 **TCS** 版本為準。

---

## 10. 參考連結（教材內）

- [`README.md`](README.md) — 本章範例與上機步驟  
- [`../../00_Cheatsheets/profiler_toolkit_tcs.md`](../../00_Cheatsheets/profiler_toolkit_tcs.md) — 速查與指令流程  
- [Profiler User's Guide（PDF 索引）](https://software.fujitsu.com/jp/manual/manualindex/p22000026e.html) — 官方文件入口（請對齊站臺 **tcsds** 版本）
