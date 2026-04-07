# 07_Multi_Node_GPU_Example — 多節點 GPU 作業（PJM + MPI）

本章**不複製**你站上專用之模組路徑與可執行檔路徑；**完整可跑流程**請以家目錄下範例為準：

**`$HOME/sample/GPU_multiNodes/`**

（與 Part2 `06` 使用 `$HOME/sample/singularity/` 銜接容器映像同一思路：教材說明概念與 PJM 模式，實際 binary／module 留在 sample。）

---

## 該目錄裡有什麼（摘要）

| 檔案 | 用途 |
|------|------|
| `run_gpu.sh` | **多 vnode** GPU 作業：`vnode`、`gpu`、`--mpi proc`、`PJM_O_NODEINF` 產生 hostfile、`mpirun` + `OMPI_MCA_plm_rsh_agent=/bin/pjrsh` |
| `run.sh` | 多節點 **CPU/MPI** 探測（`pwd` 等）；同樣 hostfile 模式 |
| `submit_gpu.sh` | 單 vnode 快速送件／`nvidia-smi` 煙霧 |
| `sample_code/` | 例如 `mpi_openacc_example.f90`、HPL 相關範例（Fortran 原始碼） |
| `pi-cuda`、`pi-mpi` | 目錄內既有 binary（來源可能在他處，如 `run_gpu.sh` 內之 `CMD` 路徑） |

**送件前請自行對齊**：`Nodes`（腳本變數）＝ `#PJM -L vnode=`；`NProcs`＝ `#PJM --mpi proc=`；`NProcsPerNode = NProcs / Nodes` 與 `-npernode` 一致。

---

## PJM 資源行（你環境常見寫法）

`GPU_multiNodes/run_gpu.sh` 類似結構：

```bash
#PJM -L rscunit=rscunit_pg01
#PJM -L rscgrp=gpu-rd-large
#PJM -L vnode=2
#PJM -L vnode-core=32
#PJM -L gpu=1
#PJM --mpi proc=64
#PJM -L elapse=0:10:00
#PJM -j
```

> 部分文件或互動式範例寫成 `-L ru=...`、`-L rg=...`；**與 `rscunit`／`rscgrp` 是否同義依貴中心手冊為準**（見 [`00_Cheatsheets/pjm_batch_system.md`](../../00_Cheatsheets/pjm_batch_system.md)）。

---

## Hostfile + Open MPI（重點）

1. **`PJM_O_NODEINF`**：PJM 提供的節點列表；迴圈寫入 `hostfile`，每行 `hostname slots=<每節點 slot 數>`（你範例用 `PJM_PROC_BY_NODE`）。
2. **`export OMPI_MCA_plm_rsh_agent=/bin/pjrsh`**：在 Fujitsu PJM 環境下讓 `mpirun` 用 **`pjrsh`** 啟動遠端程序（與登入節點上一般 `ssh` 不同）。
3. **`mpirun -np $NProcs -npernode $NProcsPerNode -hostfile ... -x PATH -x LD_LIBRARY_PATH <CMD>`**：把環境帶到各 rank；**CUDA 程式**需保證每 rank 綁到正確 GPU（多卡節點時依 `OMPI_COMM_WORLD_LOCAL_RANK` 等設定 `cudaSetDevice`，見下）。

---

## 多卡／多節點時的 GPU 綁定（概念）

- **每節點 1 卡、每節點數個 MPI rank**：通常每 rank `cudaSetDevice(local_rank % num_gpus)`，或每節點只跑 1 GPU 1 rank（最簡教學）。
- **每節點多卡**：必須避免多 process 預設都搶 `device 0`；請在程式內或啟動腳本設定 `CUDA_VISIBLE_DEVICES`／`local_rank`。

本 repo 之 `01`–`06` 以**單節點**為主；**多節點實作與 timing** 請以 `$HOME/sample/GPU_multiNodes` 與貴中心手冊為主。

---

## 本目錄之模板腳本

[`job_multi_node_gpu_template.sh`](job_multi_node_gpu_template.sh) 為**去個人化**的 PJM 骨架：`CMD`、`module`、資源數字請依你的 `GPU_multiNodes` 或叢集政策修改後再 `pjsub`。

---

## 延伸閱讀

- [`../README.md`](../README.md) — Part2 總覽  
- [`../../00_Cheatsheets/pjm_batch_system.md`](../../00_Cheatsheets/pjm_batch_system.md) — PJM、`vnode`、`--mpi proc`、GPU 互動式範例
