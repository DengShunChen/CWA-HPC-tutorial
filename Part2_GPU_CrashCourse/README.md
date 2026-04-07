# Part 2: GPU 程式設計速成課程

> 下半年場次 — CUDA GPU 加速（**下午約 3 小時上機**；上午為課程說明，詳見 [`../PROJECT_SUMMARY.md`](../PROJECT_SUMMARY.md)）

---

## 📋 課程目標

讓學員能夠：
1. 理解 GPU 與 CPU 的架構差異
2. 撰寫簡單的 CUDA 程式並在 GPU 上執行
3. 體驗 GPU 加速的威力（性能對比）
4. 認識 GPU 優化的基本概念
5. （選修）以 **OpenACC** 在 Fortran 上做指令式 GPU 加速，並與 CUDA Fortran 對照

---

## ⏱️ 下午上機實作（約 3 小時）

| 時間 | 主題 | 資料夾 | 重點 |
|-----|------|--------|------|
| 30 min | 複習 + GPU 概念 | README.md + [`01_CUDA_Hello/`](01_CUDA_Hello/) | GPU 架構、編譯流程 |
| 45 min | CUDA 核心語法 | [`02_Vector_Add_GPU/`](02_Vector_Add_GPU/) | Kernel、記憶體管理、效能測試 |
| 45 min | **五語言對照** | [`03_Language_Comparison_VectorAdd/`](03_Language_Comparison_VectorAdd/) | **C、C++、Fortran（CPU）** 與 **CUDA C、CUDA Fortran（GPU）** 同題並排 |
| （選修） | **OpenACC Fortran** | [`04_OpenACC_VectorAdd/`](04_OpenACC_VectorAdd/) | `parallel loop`、`async`／`wait`、`routine(seq)`；與 `03` 同題 |
| 60 min | 實戰案例 | [`05_Heat_Diffusion_Demo/`](05_Heat_Diffusion_Demo/) | 熱傳導模擬、CPU vs GPU 對比 |
| （延伸） | Singularity + PyTorch | [`06_Singularity_PyTorch_GPU/`](06_Singularity_PyTorch_GPU/) | `--nv`、容器內 CUDA、與既有 `.sif` 銜接 |

> 下午總時數仍約 3 小時：`04` 可併入課後自修，或壓縮 `02`／`03` 的示範時間帶做；Fortran 背景較弱時可略過 `03` 的 Fortran 軌與整章 `04`。

---

## 🔄 上半年課程重點複習

在進入 GPU 課程前，請確認您已掌握：

### Fortran / C++ 核心概念
- ✅ 變數宣告與基本型態
- ✅ 迴圈 (`for` / `do`)
- ✅ 陣列操作與記憶體配置
- ✅ 計時測量

### 優化思維
- ✅ Cache locality（資料局部性）
- ✅ 編譯器優化選項（`-O2` vs `-O3`）
- ✅ 迴圈優化技巧

> 💡 忘記了？快速複習：[語法對照表](../00_Cheatsheets/syntax_rosetta_stone.md) 和 [優化思維指南](../00_Cheatsheets/optimization_mindset.md)

---

## 📂 章節內容

### [01_CUDA_Hello](01_CUDA_Hello/) - GPU 環境確認

**學習目標**：
- 確認 GPU 可用且 CUDA 環境正常
- 理解 Host (CPU) 與 Device (GPU) 的概念
- 撰寫第一個 CUDA 程式

**檔案**：
- `hello_gpu.cu` - GPU Hello World
- `device_query.cu` - 查詢 GPU 資訊

---

### [02_Vector_Add_GPU](02_Vector_Add_GPU/) - CPU 到 GPU 的轉換

**學習目標**：
- 理解 CUDA Kernel 的撰寫方式
- 學習 Host-Device 記憶體管理
- 測量 GPU 效能並與 CPU 對比

**檔案**：
- `vec_add_gpu.cu` - 向量加法 GPU 版本（含 CUDA 事件計時）
- `README.md` - 詳細說明與優化技巧

> 另附獨立 `benchmark.cu`（吞吐／設定實驗）；CPU／GPU 向量加法主範例見 `vec_add_gpu.cu`。

**重點概念**：
- `cudaMalloc` / `cudaMemcpy`
- Kernel 函式 (`__global__`)
- Thread / Block / Grid 配置

---

### [03_Language_Comparison_VectorAdd](03_Language_Comparison_VectorAdd/) - C / C++ / Fortran 與 CUDA C / CUDA Fortran 對照

**學習目標**：

- 同一向量加法題，對照 **C、C++、Fortran**（序列 CPU）與 **CUDA C、CUDA Fortran**（GPU）。
- 理解 **索引起點**、**kernel 語法**、**裝置記憶體配置** 在兩種 CUDA 語言中的對應。
- 認識 **NVIDIA HPC SDK** 之 `nvfortran` 與 `.cuf` 在教學／Legacy Fortran 專案中的角色。

**檔案**：見該目錄 `README.md`；`make all` 會依環境自動建置（無 `nvcc`／`nvfortran` 時仍可得三支 CPU 執行檔）。

---

### [04_OpenACC_VectorAdd](04_OpenACC_VectorAdd/) - OpenACC Fortran（與 03 同題）

**學習目標**：

- 以 `!$acc data`、`copyin`／`copyout` 與 `parallel loop`（或 `kernels`）將向量加法 offload 到 GPU。
- 試作 `async`／`wait` 與 `!$acc routine(seq)`，對照 CUDA Fortran 的顯式 kernel。

**檔案**：`vec_add_openacc.f90`、`vec_add_openacc_async.f90`、`vec_add_openacc_routine.f90`、`Makefile`；需 `nvfortran -acc`（見該目錄 `README.md`）。

---

### [05_Heat_Diffusion_Demo](05_Heat_Diffusion_Demo/) - 熱傳導模擬（實戰）

**學習目標**：
- 應用所學知識到實際問題
- 觀察 GPU 在數值模擬中的加速效果

**檔案**：`README.md`（分層任務 Must／Should／Could）、`Makefile`、`main_cpu.cpp`、`main_gpu.cu`；`make run_all` 可跑 CPU／GPU 對照。

---

### [06_Singularity_PyTorch_GPU](06_Singularity_PyTorch_GPU/) - Singularity 容器 + PyTorch GPU（延伸）

**學習目標**：

- 使用 `singularity exec --nv`（或 Apptainer 同等指令）掛載主機 NVIDIA 驅動
- 在 **PyTorch 1.13.1 / CUDA 11.6** 映像內驗證 `torch.cuda.is_available()`
- 與中心既有 **`$HOME/sample/singularity/torch_1.13.1_cuda11.6.sif`**（及同內容之 `.def`）銜接

**檔案**：

- `torch_1.13.1_cuda11.6.def` - 與範例路徑之定義檔一致，可重建 SIF
- `test_cuda_torch.py` - GPU 煙霧測試
- `run_singularity_gpu_test.sh` - 一鍵執行（`SINGULARITY_SIF` 可覆寫預設路徑）
- `job_singularity_torch_gpu.sh` - PJM 批次範例

---

## 🎯 GPU vs CPU 核心差異

| 特性 | CPU | GPU |
|-----|-----|-----|
| **設計目標** | 低延遲、複雜邏輯 | 高吞吐量、簡單運算 |
| **核心數** | 少（4-64 核） | 多（數千核心） |
| **時脈** | 高（3-5 GHz） | 較低（1-2 GHz） |
| **記憶體頻寬** | ~50 GB/s | ~900 GB/s |
| **適合任務** | 分支多、不規則存取 | 高度平行、規則運算 |

**結論**：GPU 不是萬能，但對於大量平行運算（如向量運算、矩陣乘法、數值模擬）有巨大優勢！

---

## 🔧 環境需求

### 必要軟體
- **CUDA Toolkit**：建議 CUDA >= 10.0
- **GPU**：支援 CUDA 的 NVIDIA GPU（Compute Capability >= 3.5）
- **驅動程式**：與 CUDA 版本相容的 NVIDIA 驅動

### 取得 GPU 節點（PJM 互動式）

登入節點通常**沒有** GPU 或無法穩定編譯／執行 CUDA，請先以 PJM 申請 **GPU 互動式作業** 再進行 Part 2 實作。寫法與 CPU 章節的 `rscgrp=small` 可能不同；完整選項說明見 [`00_Cheatsheets/pjm_batch_system.md`](../00_Cheatsheets/pjm_batch_system.md) 內 **「GPU 互動式」** 小節。

### 環境測試

```bash
# 查看 CUDA 版本
nvcc --version

# 查看 GPU 資訊
nvidia-smi

# 測試編譯
cd 01_CUDA_Hello
make
```

### 在 GPU 計算節點（CN）或 PJM 批次執行（比照 Part1）

登入節點通常無 GPU；**已取得 GPU 互動／批次資源後**（見上節與 [`pjm_batch_system.md`](../00_Cheatsheets/pjm_batch_system.md)）：

```bash
cd Part2_GPU_CrashCourse

# 方式 A：已在 GPU CN／互動 shell（nvidia-smi 可用）
./run_part2_tests.sh
./run_part2_tests.sh --report part2_autotest_report.txt   # 另存一份報告

# 方式 B：仍在登入節點，由腳本產生 GPU 用 #PJM 並 pjsub（與 Part1 run_all_tests.sh --submit-pjm 同概念）
export PJM_GROUP=你的群組   # 必填；亦可視站臺改 PART2_PJM_* 資源變數
./run_part2_tests.sh --submit-pjm
# 日誌檔預設 part2_gpu_autotest.log（可用 PART2_PJM_LOG 覆寫）
```

- **手寫批次**：`pjsub job_run_part2_gpu.sh`（內容為 `exec bash run_part2_gpu.sh`，與方式 A 最終行為相同）。
- **CUDA 模組**：若自動偵測不到 `nvcc`，可 `export PART2_CUDA_MODULE=nvhpc-hpcx-cuda12/…` 再跑；送批次時此變數會一併寫入產生之工作腳本。

---

## 💡 學習建議

### 課前準備
1. 複習上半年課程的向量加法程式
2. 確認 GPU 環境可用（`nvidia-smi`）
3. 瀏覽 [CUDA 語法](../00_Cheatsheets/syntax_rosetta_stone.md#-cuda-特有語法)、[CUDA Fortran 小節](../00_Cheatsheets/syntax_rosetta_stone.md#-cuda-fortran-nvfortran-與-cuda-c-對照)、[OpenACC Fortran 小節](../00_Cheatsheets/syntax_rosetta_stone.md#-openacc-fortran-指令式)

### 上課方式
1. **對比思維** - 把每個 CUDA 程式和對應的 CPU 版本對照
2. **理解原理** - 搞懂 Host/Device、Thread/Block概念
3. **動手實作** - 每個範例都親自編譯執行
4. **觀察效能** - 用計時器體驗 GPU 加速

### 常見誤區
- ❌ "GPU 一定比 CPU 快" → 資料傳輸有成本！
- ❌ "寫 CUDA 很難" → 基本概念其實很簡單
- ❌ "優化隨便做就好" → GPU 優化和 CPU 不同

---

## 🚀 快速開始

> **注意**：Part2 執行檔由 `make` 產生，**不在 Git 內**；clone 後請在 `Part2_GPU_CrashCourse/` 各子目錄或專案根目錄執行 `make part2`（無 `nvcc` 時仍會編出 `03` CPU 與 `05` 之 `heat_cpu`）。

```bash
# 1. 確認環境
cd 01_CUDA_Hello
make

# 2. 學習核心語法
cd ../02_Vector_Add_GPU
make
./vec_add_gpu

# 3. 五語言向量加法對照（GPU 編譯器可選）
cd ../03_Language_Comparison_VectorAdd
make all
make run_cpu
make run_gpu

# 4. OpenACC Fortran（需 nvfortran -acc）
cd ../04_OpenACC_VectorAdd
make all
make run

# 5. 熱傳導實戰
cd ../05_Heat_Diffusion_Demo
make run_all

# 6. （延伸）Singularity + PyTorch GPU
cd ../06_Singularity_PyTorch_GPU
chmod +x run_singularity_gpu_test.sh
./run_singularity_gpu_test.sh
```

---

## 📚 延伸閱讀

- [編譯指令速查](../00_Cheatsheets/compilation_guide.md#-cuda-編譯-nvcc) - CUDA 編譯選項
- [優化思維指南](../00_Cheatsheets/optimization_mindset.md#-gpu-優化思維) - GPU 優化技巧
- **CUDA C Programming Guide**：https://docs.nvidia.com/cuda/cuda-c-programming-guide/
- **OpenACC**：[`04_OpenACC_VectorAdd`](04_OpenACC_VectorAdd/)（本倉庫內建範例）；[OpenACC 規格](https://www.openacc.org/specification)

---

**準備好進入 GPU 的平行運算世界了嗎？Let's go! 🚀**
