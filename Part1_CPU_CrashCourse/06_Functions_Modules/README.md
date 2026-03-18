# 06_Functions_Modules - 函數與模組化

> 學習程式碼組織與可重用性

---

## 🎯 學習目標

1. 理解 Fortran 的模組 (Module) 系統
2. 學習 C++ 的標頭檔 / 原始檔分離
3. 掌握多檔案專案的編譯方式
4. 理解程式碼封裝與介面設計

---

## 📝 檔案說明

### Fortran 版本

| 檔案 | 說明 |
|------|------|
| `math_module.f90` | 數學函數模組（可重用） |
| `main_program.f90` | 主程式（使用模組） |

### C++ 版本

| 檔案 | 說明 |
|------|------|
| `math_functions.h` | 標頭檔（函數宣告） |
| `math_functions.cpp` | 實作檔（函數定義） |
| `main_program.cpp` | 主程式（使用函數） |

---

## 🚀 快速開始

```bash
# 編譯程式（注意編譯順序很重要！）
make all

# 執行程式
make run_all

# 清除執行檔和中間檔
make clean
```

---

## 💻 Fortran 模組系統

### 模組定義

```fortran
module my_module
  implicit none
  
  ! 預設私有，只匯出指定項目
  private
  public :: my_function, my_subroutine
  
contains

  function my_function(x) result(y)
    real(8), intent(in) :: x
    real(8) :: y
    y = x * 2.0d0
  end function my_function
  
  subroutine my_subroutine(a, b)
    real(8), intent(in) :: a
    real(8), intent(out) :: b
    b = a + 1.0d0
  end subroutine my_subroutine

end module my_module
```

### 使用模組

```fortran
program main
  ! 匯入整個模組
  use my_module
  
  ! 或只匯入特定項目（推薦）
  use my_module, only: my_function
  
  ! 使用模組中的函數
  result = my_function(3.14d0)
end program main
```

### 編譯順序

```bash
# 1. 先編譯模組（會產生 .mod 檔）
gfortran -c math_module.f90

# 2. 再編譯主程式（需要 .mod 檔）
gfortran math_module.o main_program.f90 -o main
```

---

## 💻 C++ 標頭檔系統

### 標頭檔 (.h)

只包含宣告，不包含實作：

```cpp
#ifndef MATH_FUNCTIONS_H  // 避免重複引入
#define MATH_FUNCTIONS_H

// 函數宣告
int factorial(int n);
double compute_average(const std::vector<double>& data);

#endif
```

### 實作檔 (.cpp)

包含函數的實際程式碼：

```cpp
#include "math_functions.h"

int factorial(int n) {
  int result = 1;
  for (int i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}
```

### 使用函數

```cpp
#include "math_functions.h"

int main() {
  int result = factorial(5);
  return 0;
}
```

### 編譯順序

```bash
# 1. 編譯函數庫為目的檔
g++ -c math_functions.cpp -o math_functions.o

# 2. 連結主程式和函數庫
g++ main_program.cpp math_functions.o -o main
```

---

## 🔍 重要概念

### 1. Intent 屬性（Fortran）

| Intent | 說明 | 使用時機 |
|--------|------|---------|
| `intent(in)` | 唯讀，不可修改 | 輸入參數 |
| `intent(out)` | 唯寫，必須賦值 | 輸出結果 |
| `intent(inout)` | 可讀可寫 | 修改參數 |

```fortran
subroutine example(input, output, modify)
  real(8), intent(in) :: input      ! 不可改變
  real(8), intent(out) :: output    ! 必須賦值
  real(8), intent(inout) :: modify  ! 可以修改
  
  output = input * 2.0d0
  modify = modify + 1.0d0
end subroutine example
```

### 2. 函數 vs 子程序

**Fortran Function**：回傳單一值

```fortran
function square(x) result(y)
  real(8), intent(in) :: x
  real(8) :: y
  y = x * x
end function square
```

**Fortran Subroutine**：可回傳多個值

```fortran
subroutine calculate(a, b, sum, product)
  real(8), intent(in) :: a, b
  real(8), intent(out) :: sum, product
  sum = a + b
  product = a * b
end subroutine calculate
```

### 3. Include Guards（C++）

避免標頭檔被重複引入：

```cpp
// 方法一：傳統 preprocessor guards
#ifndef MY_HEADER_H
#define MY_HEADER_H
// ... 內容 ...
#endif

// 方法二：現代方式（不是所有編譯器都支援）
#pragma once
```

---

## 📚 程式碼組織最佳實踐

### Fortran 建議

1. **一個模組一個檔案**
2. **使用 `only` 明確匯入**：`use module_name, only: func1, func2`
3. **設定 private/public**：預設私有，明確匯出
4. **使用 intent 屬性**：明確參數用途

### C++ 建議

1. **標頭檔只放宣告**：不要放實作（除了 inline/template）
2. **使用 include guards**
3. **用 const reference 傳遞大物件**：`const std::vector<double>&`
4. **分離介面與實作**：.h 和 .cpp 分開

---

## ⚡ 為什麼要模組化？

### 優點

1. **可重用性**：同一個函數可以在多個程式中使用
2. **可維護性**：修改只需在一處進行
3. **可測試性**：可以獨立測試每個模組
4. **團隊合作**：不同人可以開發不同模組
5. **編譯效率**：只需重新編譯修改的部分

### 範例

```
專案結構：
├── math_module.f90      (數學函數)
├── io_module.f90        (檔案 I/O)
├── physics_module.f90   (物理計算)
└── main_program.f90     (主程式)

每個模組獨立開發和測試
主程式只需專注於邏輯流程
```

---

## ✅ 實驗練習

1. **基礎練習**：執行範例程式，觀察模組/函數如何被使用
2. **修改練習**：在模組中新增一個計算平方根的函數
3. **進階練習**：創建一個新模組 `string_utils`，包含字串處理函數

---

## 🔧 常見錯誤

### Fortran

```fortran
! ❌ 錯誤：忘記宣告 intent
subroutine bad_example(x, y)
  real(8) :: x, y  ! 不明確

! ✅ 正確
subroutine good_example(x, y)
  real(8), intent(in) :: x
  real(8), intent(out) :: y
```

### C++

```cpp
// ❌ 錯誤：在 .h 中實作（會導致重複定義）
// math_functions.h
int factorial(int n) {
  return n <= 1 ? 1 : n * factorial(n-1);
}

// ✅ 正確：在 .cpp 中實作
// math_functions.cpp
int factorial(int n) {
  return n <= 1 ? 1 : n * factorial(n-1);
}
```

---

**下一步：前往 [`07_Structures`](../07_Structures/) 學習自訂資料型態 🚀**
