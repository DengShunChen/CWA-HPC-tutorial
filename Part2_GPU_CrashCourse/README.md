# Part 2: GPU 程式設計速成課程

> 下半年場次 — CUDA GPU 加速（**下午約 3 小時上機**；上午為課程說明，詳見 [`../PROJECT_SUMMARY.md`](../PROJECT_SUMMARY.md)）

---

## 📋 課程目標

讓學員能夠：
1. 理解 GPU 與 CPU 的架構差異
2. 撰寫簡單的 CUDA 程式並在 GPU 上執行
3. 體驗 GPU 加速的威力（性能對比）
4. 認識 GPU 優化的基本概念

---

## ⏱️ 下午上機實作（約 3 小時）

| 時間 | 主題 | 資料夾 | 重點 |
|-----|------|--------|------|
| 30 min | 複習 + GPU 概念 | README.md + [`01_CUDA_Hello/`](01_CUDA_Hello/) | GPU 架構、編譯流程 |
| 90 min | CUDA 核心語法 | [`02_Vector_Add_GPU/`](02_Vector_Add_GPU/) | Kernel、記憶體管理、效能測試 |
| 60 min | 實戰案例 | [`03_Heat_Diffusion_Demo/`](03_Heat_Diffusion_Demo/) | 熱傳導模擬、CPU vs GPU 對比 |
| （延伸） | Singularity + PyTorch | [`04_Singularity_PyTorch_GPU/`](04_Singularity_PyTorch_GPU/) | `--nv`、容器內 CUDA、與既有 `.sif` 銜接 |

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

> 本節未另附獨立 `benchmark.cu`；CPU／GPU 對照與計時概念見 `vec_add_gpu.cu` 與 README 內文。

**重點概念**：
- `cudaMalloc` / `cudaMemcpy`
- Kernel 函式 (`__global__`)
- Thread / Block / Grid 配置

---

### [03_Heat_Diffusion_Demo](03_Heat_Diffusion_Demo/) - 熱傳導模擬（實戰）

**學習目標**：
- 應用所學知識到實際問題
- 觀察 GPU 在數值模擬中的加速效果

**檔案**：
- `README.md` - 分層任務（Must／Should／Could）與 **CPU／GPU 實作框架**（範例程式在 README 的 fenced code 區塊內）

> 本目錄**未**附可立即 `make` 的 `main_cpu.cpp`、`main_gpu.cu` 或 `Makefile`；學員依 README 建立檔案後再以 `g++`／`nvcc` 編譯（與 [`../PROJECT_SUMMARY.md`](../PROJECT_SUMMARY.md)「尚無完整可編譯程式碼」之說明一致）。

---

### [04_Singularity_PyTorch_GPU](04_Singularity_PyTorch_GPU/) - Singularity 容器 + PyTorch GPU（延伸）

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

---

## 💡 學習建議

### 課前準備
1. 複習上半年課程的向量加法程式
2. 確認 GPU 環境可用（`nvidia-smi`）
3. 瀏覽 [CUDA 語法](../00_Cheatsheets/syntax_rosetta_stone.md#-cuda-特有語法)

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

```bash
# 1. 確認環境
cd 01_CUDA_Hello
make

# 2. 學習核心語法
cd ../02_Vector_Add_GPU
make
./vec_add_gpu

# 3. 熱傳導實戰（依 README 自建原始碼後編譯）
cd ../03_Heat_Diffusion_Demo
make run_all

# 4. （延伸）Singularity + PyTorch GPU
cd ../04_Singularity_PyTorch_GPU
chmod +x run_singularity_gpu_test.sh
./run_singularity_gpu_test.sh
```

---

## 📚 延伸閱讀

- [編譯指令速查](../00_Cheatsheets/compilation_guide.md#-cuda-編譯-nvcc) - CUDA 編譯選項
- [優化思維指南](../00_Cheatsheets/optimization_mindset.md#-gpu-優化思維) - GPU 優化技巧
- **CUDA C Programming Guide**：https://docs.nvidia.com/cuda/cuda-c-programming-guide/

---

**準備好進入 GPU 的平行運算世界了嗎？Let's go! 🚀**
