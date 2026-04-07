# 06：OpenACC Fortran 向量加法

與 [`../05_Language_Comparison_VectorAdd/`](../05_Language_Comparison_VectorAdd/) **同一題目**（n=10⁷、單精度 C = A + B），改以 **OpenACC 指令** 讓 `nvfortran` 產生 GPU kernel，與 **顯式 CUDA Fortran（`.cuf`）** 對照。

---

## 學習目標

- 使用 `!$acc data`、`copyin` / `copyout` 描述 **資料在 host／device 間的搬移**。
- 使用 `!$acc parallel loop` 與 `!$acc kernels` 兩種常見平行化形式。
- 以 `async` / `wait` 建立 **非同步排程** 的基本概念。
- 以 `!$acc routine(seq)` 撰寫 **裝置端可呼叫副程式**（概念上接近 CUDA 的 `__device__`）。

---

## 檔案

| 執行檔（`make` 產生） | 原始碼 | 重點 |
|----------------------|--------|------|
| `vec_add_openacc` | `vec_add_openacc.f90` | `data` + `parallel loop`，最直覺入門 |
| `vec_add_openacc_async` | `vec_add_openacc_async.f90` | `kernels async(1)` + `wait`，預留與其它工作交疊 |
| `vec_add_openacc_routine` | `vec_add_openacc_routine.f90` | 模組內 `routine(seq)`，迴圈內呼叫 `pure` 函式 |

計時使用 `system_clock`（**整段 data 區**含資料進出；若要對照 CUDA 事件只量 kernel，需另用工具如 Nsight／編譯器報告）。

---

## 編譯

```bash
module load nvhpc   # 或貴中心同等模組；需有 nvfortran
export GPUARCH=cc80   # 依 GPU 調整，與 05 章 nvfortran -gpu= 一致
make all
make run
```

無 `nvfortran` 時 `make all` 不產生執行檔（`make info` 顯示 `HAVE_NVFC=0`）。

---

## 與 05 章 CUDA Fortran 的關係（速記）

| 項目 | CUDA Fortran（`.cuf`） | OpenACC（本目錄） |
|------|------------------------|-------------------|
| Kernel 來源 | 自行撰寫 `attributes(global)` | 編譯器由 `!$acc` 區塊產生 |
| 資料 | `device` 陣列、`cudaMemcpy` 等 | `copyin` / `copyout` / `data` |
| 細部執行緒 | `<<<grid, block>>>` | 通常交給編譯器（可用 `num_gangs` 等微調） |

---

## 課堂討論

1. `parallel loop` 與 `kernels` 在編譯器最佳化空間上有何不同？（可試 `-Minfo=accel` 觀察訊息。）
2. 為何 `async` 範例在 `end data` 前要有 `wait`，否則讀取 `c` 可能發生什麼事？
3. `routine(seq)` 與 `routine(vector)`／SIMD 化在何種內層迴圈結構下會用到？

---

## 參考文件

- [OpenACC Specification](https://www.openacc.org/specification)（標準文字）
- [NVIDIA HPC Compilers User Guide](https://docs.nvidia.com/hpc-sdk/compilers/hpc-compilers-user-guide/) — OpenACC、`nvfortran` 選項
