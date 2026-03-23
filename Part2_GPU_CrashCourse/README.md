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
- `vec_add_gpu.cu` - 向量加法 GPU 版本
- `benchmark.cu` - CPU vs GPU 效能測試
- `README.md` - 詳細說明與優化技巧

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
- `main_cpu.cpp` - CPU 版本（基準線）
- `main_gpu.cu` - GPU 版本
- `Makefile` - 編譯腳本
- `README.md` - 案例說明

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

# 3. 挑戰實戰案例
cd ../03_Heat_Diffusion_Demo
make run_all
```

---

## 📚 延伸閱讀

- [編譯指令速查](../00_Cheatsheets/compilation_guide.md#-cuda-編譯-nvcc) - CUDA 編譯選項
- [優化思維指南](../00_Cheatsheets/optimization_mindset.md#-gpu-優化思維) - GPU 優化技巧
- **CUDA C Programming Guide**：https://docs.nvidia.com/cuda/cuda-c-programming-guide/

---

**準備好進入 GPU 的平行運算世界了嗎？Let's go! 🚀**
