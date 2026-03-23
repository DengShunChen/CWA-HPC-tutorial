# PJM 批次系統使用指南

> **本教材主線**：Part 1 範例作業腳本一律為 **PJM**（`pjsub`、`#PJM`）。PBS／Slurm 僅在本文「對照表」供其他環境參考。

> Fujitsu A64FX / FX1000 專用批次作業管理系統

---

## 登入節點與計算節點（站臺政策與本教材約定）

| 位置 | 允許／建議行為 |
|------|----------------|
| **登入節點** | 編輯原始碼、準備 PJM 腳本、**`pjsub`** 提交；**Fortran 建置請在計算節點**使用原生 **`frt`**（**不**用登入節點 cross **`frtpx`**）。 |
| **計算節點** | **執行**可執行檔（數值計算、效能測試、**FIPP**／**fapp** 取樣、**`mpiexec`** 等）。此類工作請寫入 PJM 腳本，由 **`pjsub`** 排程執行。 |

**請勿**在登入節點長時間或大量占用 CPU／記憶體執行計算；若貴中心政策僅允許登入節點編譯，則**執行一律以 `pjsub` 為準**。

---

## 開始前兩件事：配額與工作區

在送作業前，先確認配額與儲存位置（站台命令可能不同）：

```bash
quota -s
lfs quota -u "$USER" /IFS
lfs quota -u "$USER" /OFS
```

建議工作區劃分：

- `/IFS`：受安管、常用於原始資料與正式執行環境
- `/OFS`：大容量或共享資料、封存與搬移

大檔搬移建議使用 `tar` + `rsync`（可續傳、可檢查進度）。

---

## 🎯 什麼是 PJM？

**PJM (Parallels Job Manager)** 是 Fujitsu 超級電腦系統的批次作業管理系統，類似於其他 HPC 系統的 SLURM 或 PBS。

---

## 📝 基本 PJM 作業腳本

### 單節點作業（範例：向量加法）

建立 `job_vec_add.sh`：

```bash
#!/bin/bash
#PJM -L "rscgrp=small"           # 資源群組
#PJM -L "node=1"                 # 使用 1 個節點
#PJM -L "elapse=00:10:00"        # 最長執行時間 10 分鐘
#PJM -g <your_group>             # 你的群組名稱（請修改）
#PJM -j                          # 合併標準輸出與標準錯誤

# 載入必要環境（計算節點上執行；由 pjsub 排程）
module load lang/tcsds-1.2.37   # Fujitsu 編譯器（依貴站版本調整）

# FX1000（部分站臺需先掛載 module 目錄）例：
#   module use /package/fx1000/modulefiles/
#   module load tcsds/1.2.40

# 執行程式（於計算節點）
./vec_add_fortran
```

### 提交作業

```bash
# 提交作業
pjsub job_vec_add.sh

# 查看作業狀態
pjstat

# 取消作業
pjdel <job_id>

# 查看輸出
cat job_vec_add.sh.o<job_id>
```

---

## 📊 常用 PJM 指令

| 指令 | 說明 | 範例 |
|-----|------|------|
| `pjsub` | 提交批次作業 | `pjsub job.sh` |
| `pjstat` | 查看作業狀態 | `pjstat` |
| `pjstat -v` | 詳細作業資訊 | `pjstat -v <job_id>` |
| `pjwait` | 等待作業結束 | `pjwait <job_id>` |
| `pjdel` | 取消作業 | `pjdel <job_id>` |
| `pjhist` | 查看歷史作業 | `pjhist` |

---

## 🔄 工作流程（FX1000）

```
1. SSH 至登入節點：編輯程式碼、module load
   ↓
2. 在 **A64FX 計算節點**（或批次工作內）以 **`frt`／`FCC`** 原生編譯 → 產生執行檔
   ↓
3. 撰寫 PJM 腳本（內含計算節點上要跑的指令）
   ↓
4. 登入節點執行 pjsub 提交作業
   ↓
5. pjstat 監控；實際運算在計算節點執行
   ↓
6. 檢視日誌／標準輸出（#PJM -o 等）
```

**Part1 Fortran** 請在 **A64FX 環境**以 **`frt`** 編譯（`module load` TCS 後；登入節點通常無 `frt`）；**執行與量測仍以 `pjsub` 至計算節點為準**。

---

## 📄 完整範例作業腳本

### Fortran 程式作業腳本

```bash
#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:15:00"
#PJM -g <your_group>
#PJM -j
#PJM -o vec_add_output.log

# 載入環境
module load lang/tcsds-1.2.37

# 顯示執行資訊
echo "========================================="
echo "  作業開始"
echo "========================================="
echo "節點: $(hostname)"
echo "時間: $(date)"
echo

# 執行程式
echo ">>> 執行 Fortran 向量加法..."
./vec_add_fortran
echo

# 執行優化版本
echo ">>> 執行 Fortran 優化版本..."
./vec_add_optimized_fortran
echo

echo "========================================="
echo "  作業完成"
echo "========================================="
```

### C++ 程式作業腳本

```bash
#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:15:00"
#PJM -g <your_group>
#PJM -j
#PJM -o vec_add_cpp_output.log

# 載入環境
module load lang/tcsds-1.2.37

# 顯示執行資訊
echo "========================================="
echo "  C++ 向量加法作業"
echo "========================================="

# 執行基礎版本
echo ">>> 基礎版本:"
./vec_add_cpp

# 執行優化版本
echo ">>> 優化版本:"
./vec_add_optimized_cpp

echo "作業完成: $(date)"
```

---

## ⚙️ 資源配置選項

### 基本資源選項

| PJM 參數 | 說明 | 範例 |
|---------|------|------|
| `-L "rscgrp=<group>"` | 資源群組 | `rscgrp=small` |
| `-L "node=<N>"` | 節點數量 | `node=1` |
| `-L "elapse=HH:MM:SS"` | 最長執行時間 | `elapse=00:30:00` |
| `-g <group>` | 使用者群組 | `-g ga00` |
| `-j` | 合併 stdout/stderr | `-j` |
| `-o <file>` | 輸出檔案 | `-o output.log` |

### 進階選項（OpenMP）

```bash
#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:10:00"
#PJM --mpi "proc=1"              # MPI 程序數
#PJM --omp "thread=48"           # OpenMP 執行緒數 (A64FX 有 48 核心)

export OMP_NUM_THREADS=48

./my_openmp_program
```

---

## 💡 使用技巧

### 1. 互動式測試（不建議用於生產）

```bash
# 申請互動式節點（方便除錯）
pjsub --interact -L "node=1" -L "elapse=00:30:00" -g <group>
```

### 2. 批次提交多個作業

```bash
# 建立提交腳本
for i in {1..10}; do
  sed "s/INPUT/$i/g" template.sh > job_$i.sh
  pjsub job_$i.sh
done
```

### 3. 等待作業完成

```bash
# 監控直到作業完成
while pjstat | grep -q <job_id>; do
  sleep 5
done
echo "作業已完成！"
```

---

## 🐛 常見問題

### Q: 如何知道我的群組名稱？
**A**: 詢問系統管理員，或查看 `~/.bashrc` 中的設定。

### Q: 作業一直卡在 QUEUED 狀態？
**A**: 可能是：
- 資源不足（等待其他作業完成）
- 執行時間超過群組限制
- 節點數量超過可用資源

### Q: 如何查看作業輸出？
**A**: 預設輸出檔案為 `<script_name>.o<job_id>`，使用 `cat` 或 `less` 查看。

---

## 🔧 錯誤排除速查

課堂上最常遇到的問題與對應解法：

### 提交階段錯誤

| 錯誤訊息 / 現象 | 原因 | 解法 |
|-----------------|------|------|
| `pjsub: command not found` | 不在 login node 上，或 PATH 未設定 | 確認已 SSH 到正確的 login node |
| `PJM 0020 error` | `-g <your_group>` 中群組名稱錯誤 | 向管理員確認群組名，修改腳本中的 `<your_group>` |
| `PJM 0040 error` | 指定的 `rscgrp` 不存在 | 用 `pjstat --rsc` 查看可用資源群組 |
| `PJM 0050 error` | 請求的節點數超過限制 | 確認 `node=1`（教學用途一個節點即可） |
| `Permission denied` | 腳本沒有執行權限或目錄無寫入權 | `chmod +x job_*.sh`；確認家目錄配額未滿 |
| `Code 28`（站台常見） | 資源參數與群組權限或策略不符 | 先用最小腳本測試；檢查 `-g`、`rscgrp`、`node`、`proc/thread` 組合 |
| `Code 29`（站台常見） | 作業屬性衝突或站台限制觸發 | 移除非必要選項後重提；逐項加回並用 `pjstat -v` 比對 |

### 執行階段錯誤

| 錯誤訊息 / 現象 | 原因 | 解法 |
|-----------------|------|------|
| `./vec_add_fortran: No such file` | 執行檔不存在（未編譯） | 先執行 `make all` 再提交 |
| `./vec_add_fortran: cannot execute binary` | 在 x86 上執行 ARM 執行檔 | 必須透過 PJM 提交到 A64FX 節點執行 |
| `module: command not found` | module 環境未初始化 | 在腳本開頭加 `source /etc/profile.d/modules.sh` |
| `Segmentation fault` | 陣列越界或記憶體不足 | 用 `-g` 重新編譯除錯版；檢查陣列索引 |
| 輸出檔案為空 | 程式執行失敗或路徑錯誤 | 加 `-j` 合併 stderr，查看錯誤訊息 |

### 佇列與資源問題

| 現象 | 原因 | 解法 |
|------|------|------|
| 作業一直 QUEUED | 佇列滿或資源不足 | `pjstat -v <job_id>` 查看估計等待時間 |
| 作業 RUNNING 但很久沒完成 | 程式進入無窮迴圈或 I/O 卡住 | `pjdel <job_id>` 取消後檢查程式邏輯 |
| 作業被系統提前結束 | 可能超過 `elapse`（walltime） | 延長 `#PJM -L "elapse=..."`，並先用小資料量估算時間 |
| 輸出亂碼 | 編碼不一致 | 確認 terminal 使用 UTF-8 編碼 |
| 同樣程式在 x86 正常但 A64FX 失敗 | 平台差異（int 大小、對齊） | 檢查是否使用了平台相依的假設 |

### 快速除錯流程

```
1. 確認腳本語法
   → 檢查 #PJM 開頭的每一行，注意引號與空格
   
2. 確認執行檔存在
   → ls -la ./vec_add_fortran
   
3. 確認模組已載入
   → module list  (應看到 lang/tcsds-1.2.37)
   
4. 小規模測試
   → 先用 --interact 互動模式測試
   → pjsub --interact -L "node=1" -L "elapse=00:10:00" -g <group>
   
5. 查看完整錯誤輸出
   → 加上 #PJM -j 合併 stdout/stderr
   → cat <script>.o<job_id>
```

---

## ⚠️ 三大批次系統對照：PJM / PBS / Slurm

氣象署同時擁有 FX1000（PJM）與 GPU 叢集（Slurm）等環境。**本教材 Part 1 之範例作業腳本皆為 PJM**；PBS／Slurm 僅供對照。三者是**不同的批次系統，指令不可互通**。以下為完整對照：

### 指令對照表

| 功能 | PJM (FX1000) | PBS (一般叢集) | Slurm (GPU 叢集) |
|------|-------------|----------------|-------------------|
| 提交作業 | `pjsub job.sh` | `qsub job.sh` | `sbatch job.sh` |
| 查看狀態 | `pjstat` | `qstat` | `squeue` |
| 查看自己的作業 | `pjstat` | `qstat -u $USER` | `squeue -u $USER` |
| 詳細資訊 | `pjstat -v <id>` | `qstat -f <id>` | `scontrol show job <id>` |
| 取消作業 | `pjdel <id>` | `qdel <id>` | `scancel <id>` |
| 查看歷史 | `pjhist` | `qstat -H` | `sacct` |
| 互動式作業 | `pjsub --interact ...` | `qsub -I ...` | `srun --pty bash` |
| 查看可用資源 | `pjstat --rsc` | `pbsnodes -a` | `sinfo` |
| 查看佇列/分區 | `pjstat --rsc` | `qstat -Q` | `sinfo -s` |

### 腳本語法對照

| 功能 | PJM | PBS | Slurm |
|------|-----|-----|-------|
| 指令前綴 | `#PJM` | `#PBS` | `#SBATCH` |
| 作業名稱 | `#PJM -N "name"` | `#PBS -N name` | `#SBATCH -J name` |
| 節點數 | `#PJM -L "node=1"` | `#PBS -l select=1` | `#SBATCH -N 1` |
| 執行時間 | `#PJM -L "elapse=01:00:00"` | `#PBS -l walltime=01:00:00` | `#SBATCH -t 01:00:00` |
| 使用者群組 | `#PJM -g <group>` | `#PBS -W group_list=<group>` | `#SBATCH -A <account>` |
| 佇列/分區 | `#PJM -L "rscgrp=small"` | `#PBS -q workq` | `#SBATCH -p gpu` |
| 合併輸出 | `#PJM -j` | `#PBS -j oe` | `#SBATCH -o %j.out` |
| 輸出檔案 | `#PJM -o output.log` | `#PBS -o output.log` | `#SBATCH -o output.log` |
| GPU 資源 | （不適用） | `#PBS -l ngpus=1` | `#SBATCH --gres=gpu:1` |
| 工作目錄 | 自動為提交目錄 | 需 `cd $PBS_O_WORKDIR` | 自動為提交目錄 |

### Slurm GPU 作業腳本範例

以下為在氣象署 GPU 叢集上提交 CUDA 程式的典型腳本：

```bash
#!/bin/bash
#SBATCH -J vec_add_gpu            # 作業名稱
#SBATCH -p gpu                    # GPU 分區（依實際環境修改）
#SBATCH -N 1                      # 1 個節點
#SBATCH --gres=gpu:1              # 申請 1 張 GPU
#SBATCH -c 4                      # 4 個 CPU 核心
#SBATCH -t 00:10:00               # 最長 10 分鐘
#SBATCH -A <your_account>         # 帳號/專案（請修改）
#SBATCH -o vec_add_gpu_%j.out     # 輸出檔（%j 會替換為 job ID）
#SBATCH -e vec_add_gpu_%j.err     # 錯誤檔

# 載入 CUDA 環境
module load cuda

# 顯示 GPU 資訊
nvidia-smi
echo ""

# 執行程式
echo ">>> 執行 GPU 向量加法..."
./vec_add_gpu

echo "作業完成: $(date)"
```

提交方式：

```bash
# 編譯
nvcc -O3 -arch=sm_70 vec_add_gpu.cu -o vec_add_gpu

# 提交
sbatch job_gpu.sh

# 查看狀態
squeue -u $USER

# 取消
scancel <job_id>

# 查看輸出
cat vec_add_gpu_<job_id>.out
```

### Slurm 常用指令速查

| 指令 | 說明 | 範例 |
|------|------|------|
| `sbatch` | 提交批次作業 | `sbatch job.sh` |
| `squeue` | 查看作業佇列 | `squeue -u $USER` |
| `scancel` | 取消作業 | `scancel 12345` |
| `sinfo` | 查看節點/分區狀態 | `sinfo -N -l` |
| `sacct` | 查看歷史作業 | `sacct --format=JobID,JobName,Elapsed,State` |
| `srun` | 互動式執行 | `srun --gres=gpu:1 --pty bash` |
| `scontrol` | 查看作業詳情 | `scontrol show job 12345` |

### Slurm GPU 專用選項

| 參數 | 說明 | 範例 |
|------|------|------|
| `--gres=gpu:N` | 申請 N 張 GPU | `--gres=gpu:2` |
| `--gres=gpu:v100:1` | 指定 GPU 型號 | `--gres=gpu:a100:1` |
| `-p gpu` | 指定 GPU 分區 | `-p gpu`（依環境而異） |
| `--mem=32G` | 申請 CPU 記憶體 | `--mem=64G` |
| `--cpus-per-task=4` | 每任務 CPU 核心數 | `-c 8` |
| `--ntasks-per-node=1` | 每節點任務數 | 搭配 MPI 使用 |

### Slurm 常見錯誤排除

| 錯誤訊息 / 現象 | 原因 | 解法 |
|-----------------|------|------|
| `sbatch: error: Batch job submission failed: Invalid account` | 帳號/專案名錯誤 | 用 `sacctmgr show assoc user=$USER` 查看可用帳號 |
| `sbatch: error: invalid partition` | 分區名稱錯誤 | 用 `sinfo` 查看可用分區 |
| 作業狀態 `PD` (PENDING) | 排隊中或資源不足 | `squeue -j <id>` 的 REASON 欄位會顯示原因 |
| `CUDA error: no CUDA-capable device` | 未申請 GPU 或驅動問題 | 確認有 `--gres=gpu:1`；用 `nvidia-smi` 檢查 |
| `srun: error: Unable to allocate resources` | 互動式資源不足 | 改用 `sbatch` 批次提交，或選擇較小資源 |

### 本教材各章節使用的批次系統

| 章節 | 批次系統 | 平台 | 說明 |
|------|----------|------|------|
| `02_Vector_Add/job_vec_add.sh` | **PJM** | FX1000 (A64FX) | 教學主線 |
| `04_Matrix_Operations/job_matrix.sh` | **PJM** | FX1000 (A64FX) | 與 02 章相同 `#PJM` 語法 |
| `09_Profiler_Toolkit_TCS/job_kernel_profile.sh` | **PJM** | FX1000（選用） | FIPP 取樣 |
| `run_all_tests.sh --submit-pjm` | **PJM** | FX1000 | Part 1 一鍵測試 |
| Part 2 GPU 課程 | **Slurm**（建議） | GPU 叢集 | 下半年課程 |

教學時請以 **PJM 為主線**（上半年 CPU 課程），下半年 GPU 課程可視環境選用 Slurm。

---

## 📚 延伸閱讀

- Fujitsu PRIMEHPC FX1000 使用手冊
- PJM 官方文件
- [Slurm 官方文件](https://slurm.schedmd.com/documentation.html)
- [Slurm Quick Start Guide](https://slurm.schedmd.com/quickstart.html)

---

**熟悉批次系統是在 HPC 上開發的關鍵！**
