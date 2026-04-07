# HPC 編譯指令速查表

> 快速參考：Fortran、C++ 與 CUDA 的常用編譯指令

> **⚠️ 本課程使用 Fujitsu A64FX (FX1000) 平台**  
> **Fortran** 使用 **原生 `frt`**（在 **A64FX 計算節點**或互動計算節點上編譯與執行；**不**採 x86 登入節點之 cross **`frtpx`**）。**C++** 為 **`FCC`** 或登入節點 **`g++`**（依章節 Makefile）。長時間計算與量測請 **`pjsub`** 至計算節點。  
> **Part1 各章 `Makefile` 之 Fortran 使用 `frt`**；下文若出現 **GNU `gfortran`**，僅作一般語法／選項對照，**非**本教材預設建置路徑。

---

## 🖥️ 平台架構說明

| 項目 | 說明 |
|-----|------|
| **CPU** | Fujitsu A64FX (ARM v8.2-A + SVE) |
| **向量寬度** | 512-bit (ARM SVE) |
| **記憶體** | HBM2 高頻寬記憶體 |
| **批次系統** | PJM (Parallels Job Manager)；**執行可執行檔請 `pjsub`** |
| **編譯** | **A64FX 計算節點**上以原生 **`frt`／`FCC`** 產出執行檔（`module load` TCS） |
| **執行** | **計算節點**（由 PJM 排程） |

---

## 🔧 Fortran 編譯 (Fujitsu frt，FX1000 原生)

### 基本編譯

```bash
# 編譯單一檔案
frt hello.f90 -o hello

# 執行（透過 PJM）
pjsub job_script.sh
```

### 常用編譯選項

```bash
# 開啟優化 (建議使用 -Kfast)
frt -Kfast program.f90 -o program

# 啟用 ARM SVE 向量化 (512-bit)
frt -Kfast -KSVE program.f90 -o program

# 除錯模式 (加入除錯符號 + Fujitsu 執行期檢查，含陣列下標等：-Haefosux)
frt -g -Haefosux program.f90 -o program_debug

# 完整優化 + OpenMP
frt -Kfast -KSVE -Kopenmp program.f90 -o program
```

### Fujitsu 編譯器優化選項

| 選項 | 說明 | 適用時機 |
|-----|------|---------|
| `-Kfast` | 激進優化（推薦） | 生產版本 |
| `-KSVE` | 啟用 ARM SVE 512-bit 向量化 | 向量運算密集程式 |
| `-Kopenmp` | 啟用 OpenMP 多執行緒 | 平行化程式 |
| `-Koptmsg=2` | 顯示優化訊息 | 檢視編譯器優化 |
| `-Nquickdbg` | 快速除錯優化 | 除錯時保持部分優化 |

### 優化報告

```bash
# 顯示向量化報告
frt -Kfast -KSVE -Koptmsg=2 program.f90 -o program

# Instant Performance Profiler（FIPP）量測用（詳見 profiler_toolkit_tcs.md）
# -Nfjprof：連結 Profiler 函式庫；-Nline 或 -ffj-line：行號／迴圈對應（勿對執行檔 strip）
frt -g -Kfast -KSVE -Koptmsg=2 -Nfjprof -Nline program.f90 -o program_fipp
```

---

## 🔧 C++ 編譯 (Fujitsu FCC)

### 基本編譯

```bash
# 編譯單一檔案
FCC hello.cpp -o hello

# 執行（透過 PJM）
pjsub job_script.sh
```

### 常用編譯選項

```bash
# 指定 C++ 標準 (建議 C++11 或以上)
FCC -std=c++11 program.cpp -o program

# 開啟優化
FCC -Kfast -std=c++11 program.cpp -o program

# 啟用 ARM SVE 向量化
FCC -Kfast -KSVE -std=c++11 program.cpp -o program

# 除錯模式
FCC -g -std=c++11 program.cpp -o program_debug

# 高度優化 + OpenMP
FCC -Kfast -KSVE -Kopenmp -std=c++11 program.cpp -o program
```

### Fujitsu 編譯器優化選項

| 選項 | 說明 |
|-----|------|
| `-Kfast` | 激進優化（等同 gcc -O3） |
| `-KSVE` | 啟用 ARM SVE 512-bit 向量化 |
| `-Kopenmp` | 啟用 OpenMP |
| `-Koptmsg=2` | 顯示優化訊息 |
| `-std=c++11` | C++11 標準（推薦） |

---

## 🚀 CUDA 編譯 (nvcc)

### 基本編譯

```bash
# 編譯 CUDA 程式
nvcc hello.cu -o hello

# 執行
./hello
```

### 常用編譯選項

```bash
# 指定 GPU 架構 (Compute Capability)
nvcc -arch=sm_60 kernel.cu -o kernel   # Pascal (GTX 10xx, Tesla P100)
nvcc -arch=sm_70 kernel.cu -o kernel   # Volta (V100)
nvcc -arch=sm_75 kernel.cu -o kernel   # Turing (RTX 20xx, T4)
nvcc -arch=sm_80 kernel.cu -o kernel   # Ampere (A100, RTX 30xx)

# 開啟優化
nvcc -O2 kernel.cu -o kernel

# 除錯模式
nvcc -g -G kernel.cu -o kernel_debug
# -g: host 程式碼除錯資訊
# -G: device 程式碼除錯資訊

# 顯示詳細編譯資訊
nvcc --ptxas-options=-v kernel.cu -o kernel
```

### CUDA Fortran（`nvfortran`，NVIDIA HPC SDK）

```bash
# 單檔 CUDA Fortran（副檔名 .cuf 常見）
nvfortran -O3 -cuda -gpu=cc70 vec_add_cuda_fortran.cuf -o vec_add_cuda_fortran

# -gpu= 請改為與節點 GPU 相符之 compute capability（如 cc80、cc90）
```

與 **CUDA C** 可混編、連結同一專案；教學用完整對照見 `Part2_GPU_CrashCourse/05_Language_Comparison_VectorAdd/`。

### OpenACC Fortran（`nvfortran`，指令式 GPU）

```bash
# 典型：由編譯器依 !$acc 區塊產生 GPU kernel
nvfortran -O3 -acc -gpu=cc70 program.f90 -o program_acc
```

可編譯範例：`Part2_GPU_CrashCourse/06_OpenACC_VectorAdd/`（`make all`）。

### 查詢 GPU Compute Capability

```bash
# 使用 CUDA 範例程式查詢
/usr/local/cuda/extras/demo_suite/deviceQuery

# 或在程式中查詢
cudaDeviceProp prop;
cudaGetDeviceProperties(&prop, 0);
printf("Compute Capability: %d.%d\n", prop.major, prop.minor);
```

---

## 📦 使用 Makefile 統一編譯

### 簡單範例

```makefile
# Makefile
FC = gfortran
CXX = g++
NVCC = nvcc

FFLAGS = -O2 -Wall
CXXFLAGS = -O2 -Wall -std=c++11
CUDAFLAGS = -O2 -arch=sm_70

all: fortran_prog cpp_prog cuda_prog

fortran_prog: program.f90
	$(FC) $(FFLAGS) program.f90 -o fortran_prog

cpp_prog: program.cpp
	$(CXX) $(CXXFLAGS) program.cpp -o cpp_prog

cuda_prog: kernel.cu
	$(NVCC) $(CUDAFLAGS) kernel.cu -o cuda_prog

clean:
	rm -f fortran_prog cpp_prog cuda_prog
```

使用方式：
```bash
make            # 編譯所有程式
make clean      # 清除執行檔
```

---

## ⚡ 效能優化編譯技巧

### Fortran（GNU 參考；Part1 請用 `frt -Kfast`／`-KSVE` 等）

```bash
# 向量化優化報告
gfortran -O3 -fopt-info-vec program.f90 -o program

# 針對當前 CPU 優化
gfortran -O3 -march=native program.f90 -o program

# OpenMP 平行化
gfortran -O2 -fopenmp program.f90 -o program
```

### C++

```bash
# 向量化優化
g++ -O3 -march=native -ftree-vectorize program.cpp -o program

# 顯示優化報告
g++ -O3 -fopt-info-vec program.cpp -o program

# OpenMP 平行化
g++ -O2 -fopenmp program.cpp -o program
```

### CUDA

```bash
# 最大化暫存器使用
nvcc -O3 --maxrregcount=64 kernel.cu -o kernel

# 啟用多個 GPU 架構支援
nvcc -gencode arch=compute_60,code=sm_60 \
     -gencode arch=compute_70,code=sm_70 \
     -gencode arch=compute_75,code=sm_75 \
     kernel.cu -o kernel
```

---

## 🐛 常見編譯錯誤與解決方法

### Fortran

| 錯誤訊息 | 可能原因 | 解決方法 |
|---------|---------|---------|
| `implicit none` 相關 | 變數未宣告 | 加上變數宣告 |
| `Rank mismatch` | 陣列維度不符 | 檢查陣列宣告與使用 |
| `Segmentation fault` | 陣列越界或堆疊溢位 | 用 `-fcheck=bounds` 除錯 |

### C++

| 錯誤訊息 | 可能原因 | 解決方法 |
|---------|---------|---------|
| `undefined reference` | 缺少函式實作或連結錯誤 | 檢查是否所有 `.cpp` 都有編譯 |
| `std::` 相關錯誤 | 未 include 正確標頭檔 | 加上 `#include <iostream>` 等 |

### CUDA

| 錯誤訊息 | 可能原因 | 解決方法 |
|---------|---------|---------|
| `no kernel image available` | GPU 架構不符 | 用 `-arch=sm_XX` 指定正確版本 |
| `out of memory` | GPU 記憶體不足 | 減少資料量或改用分批處理 |
| `invalid device function` | 嘗試在 host 呼叫 device 函式 | 檢查 `__host__` / `__device__` 標記 |

---

## 💡 實用技巧

### 快速測試編譯是否成功

```bash
# Fortran
gfortran -fsyntax-only program.f90   # 只檢查語法，不產生執行檔

# C++
g++ -fsyntax-only program.cpp
```

### 查看編譯器版本

```bash
gfortran --version
g++ --version
nvcc --version
```

### 清理暫存檔

```bash
rm -f *.o *.mod *.exe a.out
```

---

**隨時參考本指令表加速開發流程！⚡**
