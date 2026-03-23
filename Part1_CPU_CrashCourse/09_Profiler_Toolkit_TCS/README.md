# 09 — Profiler Toolkit（TCS）／Instant Performance Profiler（FIPP）與 Advanced Performance Profiler（APP）

## 定位

本章對應 **Technical Computing Suite（TCS）** 中的效能剖析流程，並以 **Instant Performance Profiler（FIPP／IPP）** 為**實作與範例程式**主軸；與 **Advanced Performance Profiler（APP）**、**CPU Performance Analysis Report（CPAR）** 之關係與 A64FX 指標解讀，見同目錄：

**[`A64FX_Profiler_Reference.md`](A64FX_Profiler_Reference.md)**（**Fujitsu A64FX 處理器效能特性與成本分佈 — 技術參考**）

核心觀念（**診斷隔離**）：

1. 先識別 **高昂運算區域（Expensive Operation Regions）**（IPP／**`fipp`** 抽樣適合做**全域**篩選）；  
2. 再視需要以 **APP**（**`fapp`**／**`fapp_start`**／**`fapp_stop`**）對**區域**做更細量測；  
3. **CPAR** 則提供 **週期核算** 等進階報告（常搭配 Excel 視覺化，依手冊）。

本章範例程式涵蓋：

- 透過 **取樣分析** 掌握整支程式效能趨勢（**`kernel_profile_opt`**）；  
- **`fipp_start`**／**`fipp_stop`** + **`fipp -Sregion`**（**`region_marked`**）；  
- **MPI** 僅單 rank 量測（**`region_mpi`**）；  
- **`fapp_start`**／**`fapp_stop`** 多層區域標記（**`region_fapp`**、**`region_fapp_c`**）；  
- **MPI + FAPP** 僅單 rank 量測（**`region_fapp_mpi_f90`**、**`region_fapp_mpi_c`**）。

**前置**：建議先完成 [`08_Debug_Profile`](../08_Debug_Profile/)（`frt -g`、TCS Debugger 與剖析觀念）。

完整步驟：[`../../00_Cheatsheets/profiler_toolkit_tcs.md`](../../00_Cheatsheets/profiler_toolkit_tcs.md)  
一般除錯／分析觀念：[`../../00_Cheatsheets/debug_and_profiler.md`](../../00_Cheatsheets/debug_and_profiler.md)  
**深度技術對照（IPP／APP／CPAR、`fipp` 選項、OpenMP `@balance`、MPI 訊息長度、FLIB_FASTOMP 等）**：[`A64FX_Profiler_Reference.md`](A64FX_Profiler_Reference.md)

---

## 檔案說明

| 檔案 | 用途 |
|------|------|
| `kernel_phases.f90` | **`module kernel_phases`**（`phase_heavy`／`phase_light`、**`resolve_kernel_profile_n`**） |
| `kernel_profile.f90` | 整程式量測用主程式 → 執行檔 **`kernel_profile_opt`** |
| `region_marked.f90` | **`fipp_start`**／**`fipp_stop`** 區段範例 → **`region_marked`**（**僅 `frt` 可建置**） |
| `region_mpi.f90` | **MPI Fortran**：僅 **rank 0** 進入 FIPP 區段 → **`region_mpi`**（**`make region_mpi`**，需 **`mpifrt`**） |
| `region_mpi_f90.f90` | **MPI Fortran 單檔**：僅 **rank 0** 進入 FIPP 區段 → **`region_mpi_f90`**（**`make region_mpi_f90`**） |
| `region_mpi_c.c` | **MPI C**：僅 **rank 0** 進入 FIPP 區段 → **`region_mpi_c`**（**`make region_mpi_c`**） |
| `region_fapp.f90` | **Fortran** 多層 **`fapp_start`**／**`fapp_stop`** 區域 → **`region_fapp`**（**`make region_fapp`**，需 **`frt`**） |
| `region_fapp.c` | **C** 多層 **`fapp_start`**／**`fapp_stop`** 區域 → **`region_fapp_c`**（**`make region_fapp_c`**，需 **`fcc`**） |
| `region_fapp_mpi_f90.f90` | **MPI Fortran 單檔**：僅 **rank 0** 進入 FAPP 區域 → **`region_fapp_mpi_f90`**（**`make region_fapp_mpi_f90`**） |
| `region_fapp_mpi_c.c` | **MPI C**：僅 **rank 0** 進入 FAPP 區域 → **`region_fapp_mpi_c`**（**`make region_fapp_mpi_c`**） |
| `Makefile` | **`frt`（fx1000）/ `frtpx`（ln23 cross）**：`kernel_profile_opt` + `region_marked`；**`make optmsg`**、**`make test`** |
| `run_tests.sh` | 章節自測（**`make test`**）；可選 **`RUN_FIPP_TEST`／`RUN_FIPPPX_TEST`／`RUN_FAPP_TEST`**（見下） |
| `job_kernel_profile.sh` | PJM 範例：計算節點 **`fipp`** 取樣 |
| [`A64FX_Profiler_Reference.md`](A64FX_Profiler_Reference.md) | **A64FX／IPP／APP／CPAR** 技術參考（與官方手冊對照用） |

---

## Fortran：`fipp_start`／`fipp_stop` 指定量測區域

Fortran 中直接以**副程式呼叫**即可（無需像 C/C++ 引入 `fipp.h`）。典型寫法（雙迴圈外層多次量測內層）：

```fortran
program example
  implicit none
  integer :: i, j
  interface
    subroutine fipp_start
    end subroutine fipp_start
    subroutine fipp_stop
    end subroutine fipp_stop
  end interface

  do i = 1, 10000
    call fipp_start
    do j = 1, 10000
      ! 欲量測之運算
    end do
    call fipp_stop
  end do
end program example
```

本目錄之 **`region_marked.f90`** 將 **`phase_heavy`**／**`phase_light`** 包在單一區段內，**`print`** 留在區段外，示範「排除 I/O、只量純運算」之編排。

**量測時**須加上 **`-Sregion`**：

```bash
fipp -C -d ./tmp -Sregion ./region_marked
```

---

## MPI Fortran：僅量測單一進程（例如 rank 0）

若**只量測特定進程**，僅在該 rank 呼叫 **`fipp_start`**／**`fipp_stop`**；其他進程不呼叫即可。
同一邏輯亦可套用到 **`fapp_start`**／**`fapp_stop`**（APP）。

### C / C++：僅量測 rank 0（`fipp` / `fapp`）

```c
MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);

if (rank == 0) {
    /* 僅 process 0 開始量測 */
    fipp_start();                  /* Instant Performance Profiler */
    /* fapp_start("foo", 1, 0); */ /* Advanced Performance Profiler */
}

/* ... target region ... */

if (rank == 0) {
    /* 僅 process 0 停止量測 */
    fipp_stop();
    /* fapp_stop("foo", 1, 0); */
}

MPI_Finalize();
```

本目錄 **`region_mpi.f90`** 示意（與下列骨架相同精神）：

```fortran
program main
  use mpi
  implicit none
  integer :: ierr, rank
  interface
    subroutine fipp_start; end subroutine fipp_start
    subroutine fipp_stop; end subroutine fipp_stop
  end interface

  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)

  if (rank == 0) then
    call fipp_start
    ! 僅 rank 0 進入量測區
    call fipp_stop
  end if

  call MPI_Finalize(ierr)
end program main
```

> 對**沒有呼叫到量測常式**的進程（例如 `rank /= 0`），系統不會收集該進程的量測資料。

**量測所有進程**時：在 **`MPI_Init`** 之後、**`MPI_Finalize`** 之前，讓**各 rank 都執行**到 **`fipp_start`** 與 **`fipp_stop`** 即可。

建置與執行：

```bash
make region_mpi
mpiexec -n 4 ./region_mpi    # 實際啟動方式依叢集（PJM／mpiexec）為準
```

### MPI Fortran（單檔）：可直接實作之 rank 0 量測範例

本目錄提供完整可編譯單檔程式 **`region_mpi_f90.f90`**，不依賴其他 module，
可直接示範「只在 `rank == 0` 呼叫 `fipp_start` / `fipp_stop`」。

```bash
make region_mpi_f90
mpiexec -n 4 ./region_mpi_f90
```

### MPI C：可直接實作之 rank 0 量測範例

本目錄提供完整可編譯程式 **`region_mpi_c.c`**，同樣只在 `rank == 0` 呼叫 `fipp_start` / `fipp_stop`。

```bash
make region_mpi_c
mpiexec -n 4 ./region_mpi_c
```

若要以 FIPP 區段模式收資料：

```bash
mkdir -p ./tmp
fipp -C -d ./tmp -Sregion ./region_mpi_c
```

---

## Advanced Performance Profiler（APP）— `fapp_start`／`fapp_stop` 多層區域

**APP** 比 IPP 提供更細粒度的指令級成本分析，適合在 IPP 已篩出熱點後深度挖掘。  
介面：`fapp_start(name, number, level)` / `fapp_stop(name, number, level)`  
- **`name`**：字串，自訂區域識別名（報告顯示為 `name+number`）。  
- **`number`**：整數，同一 name 下的流水號。  
- **`level`**：整數，量測深度；執行時 **`fapp -L N`** 僅啟用 `level ≤ N` 的區域。  

> **C/C++ 需引入標頭**：`#include "fj_tool/fapp.h"`（Fortran 則以 `interface` 宣告即可）。  
> **保留名稱警告**：勿使用 `name="all"`, `number=0`（系統保留全程式量測標記）。

### 多層嵌套區域（Fortran 骨架）

```fortran
interface
  subroutine fapp_start(name, number, level)
    character(*), intent(in) :: name
    integer,      intent(in) :: number, level
  end subroutine fapp_start
  subroutine fapp_stop(name, number, level)
    character(*), intent(in) :: name
    integer,      intent(in) :: number, level
  end subroutine fapp_stop
end interface

call fapp_start("outer", 1, 0)   ! 外層區域（level=0）
  call fapp_start("heavy", 1, 1) ! 子區域（level=1）
  ! ... 計算 ...
  call fapp_stop("heavy", 1, 1)
  call fapp_start("light", 1, 1)
  ! ... 計算 ...
  call fapp_stop("light", 1, 1)
call fapp_stop("outer", 1, 0)
```

### 建置（範例程式）

```bash
make region_fapp        # Fortran（frt / frtpx）
make region_fapp_c      # C（fcc / fccpx）
make region_fapp_mpi_f90  # MPI Fortran，僅 rank 0（mpifrt / mpifrtpx）
make region_fapp_mpi_c    # MPI C，僅 rank 0（mpifcc / mpifccpx）
```

### 量測（計算節點）

```bash
mkdir -p ./tmp_fapp
# 啟用 level ≤ 1（外層 + 子區域均量測）
fapp -C -d ./tmp_fapp -L 1 ./region_fapp

# 僅啟用 level ≤ 0（只量外層 outer）
fapp -C -d ./tmp_fapp -L 0 ./region_fapp

# MPI：4 rank，僅 rank 0 有量測資料
mpiexec -n 4 fapp -C -d ./tmp_fapp -L 1 ./region_fapp_mpi_f90
```

> **量測模式 `-H`**：  
> - `-Hmethod=fast`（預設）：硬體驅動，低開銷；  
> - `-Hmethod=normal`：系統級路徑，支援較完整的系統資訊。  
> 詳見 [`A64FX_Profiler_Reference.md`](A64FX_Profiler_Reference.md) §3.2。

---

## Instant Performance Profiler（FIPP）— 建議操作順序（摘要）

1. **（可選）** 區段量測：`fipp_start`／`fipp_stop` + **`fipp -Sregion`**。  
2. **環境**：**`PATH`**、**`LD_LIBRARY_PATH`**；**勿**任意設定 **`FIPP_`**／**`FAPP_`** 等保留變數。  
3. **編譯**：`make`（**`frt`**：**`-Nfjprof`、`-Nline`**；**勿 `strip`**）。  
4. **測量（計算節點）**：`fipp -C -d ./tmp ./kernel_profile_opt` 或 **`fipp -C -d ./tmp -Sregion ./region_marked`**。  
5. **分析**：登入節點 **`fipppx -A -d ./tmp`**。  
6. **深度調校**：**`fapp_start`**／**`fapp_stop`**（Advanced Performance Profiler），見速查表。

---

## 建議上機流程（本範例）

1. **載入 TCS 模組**（例如 `module load lang/tcsds-...`）。  
2. **編譯**：`make clean && make`（**`frt`** 時會多產生 **`region_marked`**）。  
3. **自測**：`make test`（等同 **`bash ./run_tests.sh`**）。  
4. **（FX1000／TCS）FIPP + fipppx + FAPP 一鍵自測**：`make test-profilers`  
   - 等同設定 **`RUN_FIPP_TEST=1`**、**`RUN_FIPPPX_TEST=1`**、**`RUN_FAPP_TEST=1`** 後執行 **`run_tests.sh`**。  
   - **`fipp`**：取樣並檢查輸出目錄有檔案（有 **`region_marked`** 時用 **`-Sregion`**）。  
   - **`fipppx`**：對同一暫存目錄執行 **`fipppx -A -d ...`**。  
   - **`fapp`**：**Advanced Performance Profiler**，腳本以 **`fapp -C -d ... ./kernel_profile_opt`** 驗證可寫入資料（參數若與貴站版本不符，請依 *Profiler User's Guide* 調整 **`run_tests.sh`**）。  
   - 若 PATH 無對應指令，相關項目會 **SKIP**，不影響 **`make test`** 基本通過。  
5. **`make optmsg`** → `optmsg_fujitsu.log`（對照編譯器訊息）。
6. **計算節點**：

   ```bash
   mkdir -p ./tmp
   fipp -C -d ./tmp ./kernel_profile_opt
   # 區段量測：
   fipp -C -d ./tmp -Sregion ./region_marked
   ```

7. **登入節點**：`fipppx -A -d ./tmp`

---

## 預期行為（健全性檢查）

| 項目 | 說明 |
|------|------|
| **正確性** | `./kernel_profile_opt` 與 **`./region_marked`** 之 **checksum** 應與參考一致（見 **`run_tests.sh`**） |
| **時間分布** | **`phase_heavy`** 應顯著重於 **`phase_light`** |
| **符號** | 未 **`strip`**；已加 **`-Nline`**（或 **`-ffj-line`**） |

---

## 實作上須注意

- **Makefile 會優先用 `frt`，否則退回 `frtpx`**；無任一編譯器時 **`make` 會失敗**，請先 **`module load`** 正確之 TCS 環境。  
- **`./tmp`** 等量測目錄勿提交版控。  
- **`KERNEL_PROFILE_N`（環境變數）**：未設定時迭代長度為模組內 **`kernel_n_default`**（約 5×10⁷），適合**計算節點**剖析。FX1000 上**正式流程**為：登入節點僅 **`make` 編譯**，執行與 **FIPP／fapp** 取樣請 **`pjsub`**（見 **`job_kernel_profile.sh`**），並在該腳本中 **`unset KERNEL_PROFILE_N`** 以使用完整負載。**`run_tests.sh`／`make test-profilers` 預設將 `KERNEL_PROFILE_N=5000000`**，僅供站臺允許之極短自測；與「登入節點只編譯、執行靠 `pjsub`」之政策並存時，請以站臺規範為準。

---

## 任務分級（Must / Should / Could）

| 層級 | 任務 |
|------|------|
| **Must** | **`frt`** 建置並完成 **`fipp` + `fipppx`** 一輪；能說明 **`phase_heavy`** 為主要熱點 |
| **Should** | 使用 **`region_marked`** 與 **`-Sregion`**，對照整程式量測之差異 |
| **Could** | 建置 **`region_mpi`**，示範僅 rank 0 量測；或調整 **`KERNEL_PROFILE_N`**／**`kernel_n_default`** 做負載實驗 |
| **Could+** | 建置 **`region_fapp`**，以 **`fapp_start`**／**`fapp_stop`** 做多層 APP 量測，對比 IPP 全域分析與 APP 指令級分析之差異 |
---

## 注意事項

- 詳細參數以 **Profiler User's Guide** 與貴站文件為準。  
- **`fapp_*`** 屬 **Advanced Performance Profiler（APP）**，介面 **(name, number, level)**；**C/C++ 需引入 `fj_tool/fapp.h`**；Fortran 以 `interface` 宣告即可。執行時以 **`fapp -L N`** 控制啟用深度；方法選項（**`-Hmethod=fast/normal`**）與保留名稱等見 [`A64FX_Profiler_Reference.md`](A64FX_Profiler_Reference.md) §3。  
- 量測 **OpenMP** 時，執行環境請依手冊設定 **`FLIB_FASTOMP=TRUE`**（見參考手冊 §8.2）。  
- **IPP** 抽樣在**總執行時間過短**時樣本不足；請適當調整 **`KERNEL_PROFILE_N`** 或 **`kernel_n_default`**，使程式運行足夠長（參考 §2.1）。  
- 本目錄新增 **`region_fapp.f90`**、**`region_fapp.c`**、**`region_fapp_mpi_f90.f90`**、**`region_fapp_mpi_c.c`**：示範與 FIPP 區段相同的「單 rank 量測」概念在 APP 層面之實作，以及多層巢狀 **level** 控制。
