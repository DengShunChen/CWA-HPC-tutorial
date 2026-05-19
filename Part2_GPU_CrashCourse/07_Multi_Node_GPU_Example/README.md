# 07_Multi_Node_GPU_Example — 多節點 GPU（MPI + CUDA）

本目錄提供**可編譯、可送 PJM（TCS）** 的最小範例：**每個 MPI rank** 在所屬計算節點上查 GPU、依 **節點內序號** 呼叫 `cudaSetDevice`，並列印 hostname／裝置名稱。程式也會用 `MPI_Comm_split_type(..., MPI_COMM_TYPE_SHARED, ...)` 建立 **shared-memory communicator**，把 **`node_rank/node_size`** 印出來（通常比只看環境變數更直觀）。

預設還會多做一段「有趣但輕量」的檢查：在 GPU 上跑一個 **saxpy kernel**（量 CUDA event 時間），再把結果拉回 host memory 做一次 **`MPI_Allreduce`**（量 `MPI_Wtime()`），讓你在同一個 job 裡同時看到 **CUDA + MPI** 是否都正常。

---

## 檔案

| 檔案 | 說明 |
|------|------|
| [`mpi_cuda_rank_info.cu`](mpi_cuda_rank_info.cu) | 原始碼（MPI + CUDA runtime） |
| [`Makefile`](Makefile) | `nvcc -ccbin mpicxx` 產生 `mpi_cuda_rank_info` |
| [`job_mpi_cuda_rank_info.sh`](job_mpi_cuda_rank_info.sh) | PJM 批次：自動 `make`、以 PJM allocation 直接啟動 MPI |

---

## 建置

```bash
cd Part2_GPU_CrashCourse/07_Multi_Node_GPU_Example
module load ...   # 貴站：nvhpc / CUDA + HPC-X（Open MPI）等，使 nvcc、mpicxx、mpirun 可用
make
```

- **`MPICXX`**：預設 `mpicxx`，可覆寫 `make MPICXX=/path/to/mpicxx`。
- **`NVCC`**、`**CUDAFLAGS**`：與其他 Part2 章節相同慣例。
- **`CUDA_ARCH` / `CUDA_GENCODE`**：`Makefile` 預設針對 **A100（`sm_80`）** 產生 code/PTX；若卡種不同請覆寫，例如 `make CUDA_ARCH=90`。

---

## 單節點煙霧（互動 GPU shell）

```bash
./run_test_07.sh              # 自動 module／SDK 路徑探測後 make + mpirun（須 nvidia-smi 有 GPU）
RUN_TEST_07_COMPILE_ONLY=1 ./run_test_07.sh   # 只測編譯（登入節點可用）
# 或手動：
make run-local    # mpirun -np 2 --oversubscribe ./mpi_cuda_rank_info
```

> 在**無 GPU** 或 **driver 與 CUDA runtime 版本不匹配**的節點上，`cudaGetDeviceCount` 可能為 0 並導致程式 `MPI_Abort`；請與 `nvidia-smi`、`nvcc` 所連結之 runtime 一併排查。

同一台機器上兩個 rank 的 **local_rank** 會是 0 與 1；若僅一張 GPU，兩者會輪流 `cudaSetDevice(0)`（仍可比對輸出格式）。

---

## 調整「額外測試」強度（環境變數）

> 這些變數只影響 `mpi_cuda_rank_info` 內建的額外段落；預設值偏保守，避免不小心在超大 `n` 下做 CPU-side `MPI_Allreduce` 把 job 打爆。

- **`MCRI_EXTRA`**：`1`（預設）開啟額外段落；設 `0` 關閉，回到「只印裝置資訊」。
- **`MCRI_N`**：向量長度（`float` 個數；預設 `262144`，約 1MiB）。
- **`MCRI_REPEATS`**：kernel 重複次數（預設 `50`）。
- **`MCRI_A`**：saxpy 的純量 `a`（預設 `2.0`）。

範例（在 PJM 腳本 `mpiexec` 前 `export` 即可）：

```bash
export MCRI_N=$((1<<20))
export MCRI_REPEATS=10
```

---

## 多節點送件（PJM）

1. 編輯 [`job_mpi_cuda_rank_info.sh`](job_mpi_cuda_rank_info.sh) 頂端 **`#PJM`**，使資源與 **`Nodes` / `NProcs` / `NProcsPerNode`** 一致（`NProcs` 須整除 `Nodes`）。
2. 在腳本內或站臺預設環境完成 **module**（與建置相同）。
3. 於本目錄：

```bash
pjsub job_mpi_cuda_rank_info.sh
```

腳本會：

- 檢查 **`PJM_O_NODEINF`** 是否存在（確保是在 PJM 批次內執行），並做簡單的一致性檢查（PJM 配到的 nodes vs `Nodes`）。
- 以 **`mpiexec`**（找不到則用 `mpirun`）在 **PJM allocation** 下直接執行 **`-np`**，最後 **`nvidia-smi`**（非致命）。

已編譯時可 **`export SKIP_MAKE=1`** 略過 `make`。

---

## 與 `ru`／`rg` 或 `rscunit`／`rscgrp`

部分站台 `#PJM` 寫 **`-L ru=` / `-L rg=`**，另一些寫 **`rscunit=` / `rscgrp=`**；請依貴中心手冊擇一，並與互動式 `pjsub` 參數對齊（見 [`00_Cheatsheets/pjm_batch_system.md`](../../00_Cheatsheets/pjm_batch_system.md)）。

---

## 家目錄延伸：`$HOME/sample/GPU_multiNodes/`

若你已有 **pi-cuda、大規模 procs、自訂 module 堆疊** 等，可繼續使用 **`$HOME/sample/GPU_multiNodes/`**（例如 `run_gpu.sh`）。本章節範例與該目錄**獨立**；進階實驗可將本目錄程式路徑替換為該處之 `CMD`，或將本章節的 **PJM allocation + launcher** 方式整合進你的自訂腳本。

---

## 常見問題

| 狀況 | 方向 |
|------|------|
| 連結階段找不到 MPI | 確認 `-ccbin $(MPICXX)` 指向的 `mpicxx` 與 `mpirun` 同一套 Open MPI／HPC-X |
| `the provided PTX was compiled with an unsupported toolchain` | **CUDA toolkit（`nvcc`）太新、GPU driver 太舊**（或 module 混到不相容組合）。對齊 `nvidia-smi` 顯示的 **CUDA Version** 與 `nvcc --version`；必要時換較舊的 CUDA module，或升級/換到匹配的 GPU 節點 driver |
| 多 rank 全用 GPU0 | 先看輸出的 **`node_rank/node_size`**；多卡時本範例用 **`node_rank % nGpu`**（並把環境變數的 `local_rank` 一併印出來方便對照） |
| `PJM_O_NODEINF` 不存在 | 必須在 **PJM 啟動的批次腳本**內執行，勿在登入節點裸跑該腳本 |

---

## 延伸閱讀

- [`../README.md`](../README.md) — Part2 總覽  
- [`../../00_Cheatsheets/pjm_batch_system.md`](../../00_Cheatsheets/pjm_batch_system.md) — PJM、GPU 互動式
