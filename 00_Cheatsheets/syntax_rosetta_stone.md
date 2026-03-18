# HPC 三語言語法對照表 (Rosetta Stone)

> 快速對照 Fortran、C++ 與 CUDA 的核心語法

本對照表只列出 HPC 數值計算最常用的語法，不涵蓋完整語言特性。

---

## 📝 程式結構

| Fortran 90 | C++ | CUDA | 說明 |
|-----------|-----|------|------|
| `program main` ... `end program` | `int main() { ... }` | `int main() { ... }` | 主程式入口 |
| `! 註解` | `// 註解` 或 `/* 註解 */` | `// 註解` | 單行註解 |
| `implicit none` | (不需要) | (不需要) | 關閉隱式宣告 |

---

## 🔢 變數與資料型態

| 描述 | Fortran 90 | C++ | CUDA |
|-----|-----------|-----|------|
| **整數** | `integer :: n` | `int n;` | `int n;` |
| **單精度浮點數** | `real :: x` | `float x;` | `float x;` |
| **雙精度浮點數** | `real(8) :: x`<br>或 `double precision :: x` | `double x;` | `double x;` |
| **宣告並賦值** | `integer :: n = 10` | `int n = 10;` | `int n = 10;` |
| **常數** | `integer, parameter :: N = 100` | `const int N = 100;` | `const int N = 100;` |

---

## 🔁 控制流程

### If 條件判斷

```fortran
! Fortran
if (x > 0) then
  print *, "Positive"
else if (x < 0) then
  print *, "Negative"
else
  print *, "Zero"
end if
```

```cpp
// C++ / CUDA
if (x > 0) {
  std::cout << "Positive" << std::endl;
} else if (x < 0) {
  std::cout << "Negative" << std::endl;
} else {
  std::cout << "Zero" << std::endl;
}
```

### For 迴圈

```fortran
! Fortran
do i = 1, 10
  print *, i
end do
```

```cpp
// C++ / CUDA
for (int i = 1; i <= 10; i++) {
  std::cout << i << std::endl;
}
```

> ⚠️ **重要差異**：Fortran 陣列索引從 1 開始，C++/CUDA 從 0 開始！

---

## 📊 陣列操作

### 靜態陣列宣告

```fortran
! Fortran
real :: A(100)        ! 索引 1~100
real :: B(10, 20)     ! 10x20 矩陣
```

```cpp
// C++
float A[100];         // 索引 0~99
float B[10][20];      // 10x20 矩陣
```

```cuda
// CUDA (device code)
float A[100];
```

### 動態陣列配置

```fortran
! Fortran
real, allocatable :: A(:)
allocate(A(n))
! ... 使用 A
deallocate(A)
```

```cpp
// C++ (傳統方式)
float* A = new float[n];
// ... 使用 A
delete[] A;

// C++ (現代方式)
std::vector<float> A(n);
```

```cuda
// CUDA (device 記憶體)
float* d_A;
cudaMalloc(&d_A, n * sizeof(float));
// ... 使用 d_A
cudaFree(d_A);
```

### 陣列賦值與運算

```fortran
! Fortran (支援整體陣列運算)
A = 0.0              ! 全部設為 0
B = A + C            ! 逐元素相加
```

```cpp
// C++ (需要迴圈)
for (int i = 0; i < n; i++) {
  A[i] = 0.0f;
  B[i] = A[i] + C[i];
}
```

---

## 🧮 數學函式

| 功能 | Fortran 90 | C++ | CUDA |
|-----|-----------|-----|------|
| **平方根** | `sqrt(x)` | `std::sqrt(x)` 或 `sqrtf(x)` | `sqrtf(x)` (單精度)<br>`sqrt(x)` (雙精度) |
| **指數函數** | `exp(x)` | `std::exp(x)` | `expf(x)` / `exp(x)` |
| **對數** | `log(x)` | `std::log(x)` | `logf(x)` / `log(x)` |
| **三角函數** | `sin(x)`, `cos(x)` | `std::sin(x)` | `sinf(x)`, `cosf(x)` |
| **絕對值** | `abs(x)` (整數)<br>`dabs(x)` (浮點數) | `std::abs(x)` | `fabsf(x)` / `fabs(x)` |

> 💡 CUDA 建議使用單精度版本 (`sinf`, `cosf`, `sqrtf`) 以獲得更好效能。

---

## 🖨️ 輸入輸出

### 標準輸出

```fortran
! Fortran
print *, "Hello, HPC!"
print *, "x =", x
```

```cpp
// C++
#include <iostream>
std::cout << "Hello, HPC!" << std::endl;
std::cout << "x = " << x << std::endl;
```

```cuda
// CUDA (host code 同 C++)
printf("Hello from GPU! x = %f\n", x);  // device code 也可用 printf
```

---

## ⚡ CUDA 特有語法

### Kernel 函式定義

```cuda
__global__ void vectorAdd(float* A, float* B, float* C, int n) {
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n) {
    C[i] = A[i] + B[i];
  }
}
```

### Kernel 呼叫

```cuda
int threadsPerBlock = 256;
int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;
vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, n);
```

### 記憶體搬移

```cuda
// Host → Device
cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);

// Device → Host
cudaMemcpy(h_A, d_A, size, cudaMemcpyDeviceToHost);
```

---

## 🔍 快速查找索引

- **變數宣告** → [變數與資料型態](#-變數與資料型態)
- **迴圈** → [控制流程](#-控制流程)
- **陣列** → [陣列操作](#-陣列操作)
- **數學計算** → [數學函式](#-數學函式)
- **GPU 程式** → [CUDA 特有語法](#-cuda-特有語法)

---

## 📚 延伸閱讀

- **Fortran 官方文件**：https://fortran-lang.org/
- **C++ Reference**：https://en.cppreference.com/
- **CUDA C Programming Guide**：https://docs.nvidia.com/cuda/cuda-c-programming-guide/

---

**提示**：隨時回到本對照表查閱語法！🚀
