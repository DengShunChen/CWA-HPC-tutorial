# 03：C / C++ / Fortran / CUDA C / CUDA Fortran 向量加法對照

同一題目：**長度 n=10⁷ 的單精度向量相加 C = A + B**，用五種寫法並排對照語法與執行模型差異。

---

## 學習目標

- 看出 **CPU 語言**（C、C++、Fortran）在迴圈、索引、計時上的差異。
- 對照 **CUDA C** 與 **CUDA Fortran**：kernel 標記、啟動設定、裝置記憶體、事件計時。
- 理解 **Fortran 1-based 索引** 在 host 與 **CUDA Fortran device 內建維度**（同樣常為 1-based）的寫法。
- （銜接）對照 **OpenACC** 指令式寫法：見 [`../04_OpenACC_VectorAdd/`](../04_OpenACC_VectorAdd/)。

---

## 檔案一覽

| 檔案 | 說明 |
|------|------|
| `vec_add_cpu.c` | C，`clock_gettime(CLOCK_MONOTONIC)` 計時 |
| `vec_add_cpu.cpp` | C++11，`std::chrono::high_resolution_clock` |
| `vec_add_cpu.f90` | Fortran，`cpu_time` |
| `vec_add_cuda.cu` | CUDA C，`__global__`、`cudaMalloc` / `cudaMemcpy`、`cudaEvent` |
| `vec_add_cuda_fortran.cuf` | CUDA Fortran（`nvfortran`），`attributes(global)`、`allocate(..., device)`、`cudafor` |

> 與上半年 Part1 `02_Vector_Add` 的差異：Part1 CPU 範例多用 **雙精度**；本節一律 **float**，與 `../02_Vector_Add_GPU/vec_add_gpu.cu` 一致，GPU 數字才可公平對照。

---

## 概念對照表（精簡）

| 面向 | C / C++ | Fortran（CPU） | CUDA C | CUDA Fortran |
|------|---------|----------------|--------|----------------|
| 陣列索引 | 0 … n−1 | 1 … n | kernel 內 0 … n−1 | kernel 內常配合 1 … n（`threadIdx%x` 等由 1 起） |
| 平行單位 | 無（序列迴圈） | 無 | thread / block / grid | 同左，語法為 `<<<blocks, threads>>>` |
| 裝置記憶體 | — | — | `cudaMalloc` | `allocate(..., device)` 或 `cudaMalloc` |
| Kernel | — | — | `__global__ void` | `attributes(global) subroutine` |
| 裝置計時 | — | — | `cudaEvent` | `type(cudaEvent)` + `cudaEventElapsedTime` |

**重點**：CUDA C 與 CUDA Fortran 編譯後皆為 **PTX / SASS**，效能特性相近；差在 **語法與與 Fortran 專案整合**（大量舊碼為 Fortran 時，CUDA Fortran 可減少 C 介面層）。

| 面向 | CUDA Fortran（本節） | OpenACC Fortran（延伸） |
|------|----------------------|-------------------------|
| 風格 | **顯式** kernel、`<<< >>>`、裝置指標／`device` 陣列 | **指令**（`!$acc kernels` / `parallel loop` 等）由編譯器產生 kernel |
| 編譯 | `nvfortran -cuda` | 通常 `nvfortran -acc -gpu=...`（同屬 NVIDIA HPC SDK） |
| 適用 | 要精細控制 thread、與 CUDA C 混編 | 快速移植既有 Fortran 迴圈、漸進式加速 |

**OpenACC 實作**：本倉庫 [`../04_OpenACC_VectorAdd/`](../04_OpenACC_VectorAdd/)（`parallel loop`、`kernels` + `async`、`routine(seq)` 三則）。

---

## 編譯

```bash
# CPU 三支（只需 gcc / g++ / gfortran）
make vec_add_cpu_c vec_add_cpu_cpp vec_add_cpu_fortran

# GPU：需 module 載入含 nvcc、nvfortran 之環境（如 NVIDIA HPC SDK）
export CUDAFLAGS="-O3 -arch=sm_80"    # 依 nvidia-smi 之 compute capability
export GPUARCH=cc80                   # nvfortran -gpu=...
make all
make info                             # 顯示是否偵測到 nvcc / nvfortran
```

若中心 Fortran CPU 編譯器為 Fujitsu `frt`（A64FX）而非 gfortran，可在 **CPU 節點**用 `frt` 編譯 `vec_add_cpu.f90`；**GPU 節點**上本節預設仍以 `gfortran` 產出 CPU 對照執行檔（x86 + NVIDIA 常見組合）。

---

## 執行

```bash
./vec_add_cpu_c
./vec_add_cpu_cpp
./vec_add_cpu_fortran
./vec_add_cuda_c
./vec_add_cuda_fortran
# 或
make run_cpu
make run_gpu    # 需已成功建置 GPU 執行檔
```

---

## 課堂討論題（建議）

1. 為何 GPU kernel 時間遠小於 **端到端**時間？（若加上 H2D/D2H 複製會如何？）
2. CUDA Fortran 的 `i <= n` 與 CUDA C 的 `i < n` 差一個邊界，與 **索引起點**有何關係？
3. 何時值得用 CUDA Fortran 而非 CUDA C + `iso_c_binding` 包一層？
4. 同樣用 `nvfortran`，**OpenACC** 與 **CUDA Fortran** 在維護成本與可控程度上各犧牲／換到什麼？（對照 [`../04_OpenACC_VectorAdd/`](../04_OpenACC_VectorAdd/) 三則範例。）

---

## 參考

- [CUDA Fortran Programming Guide](https://docs.nvidia.com/hpc-sdk/cuda-fortran-cuda-interfaces/index.html)（NVIDIA HPC SDK 文件）
- 本倉庫 `../04_OpenACC_VectorAdd/README.md`、`../02_Vector_Add_GPU/README.md`、`../../00_Cheatsheets/compilation_guide.md`
