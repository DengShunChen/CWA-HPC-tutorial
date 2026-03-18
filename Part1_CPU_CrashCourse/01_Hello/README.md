# 01_Hello - 環境測試

> 確認編譯環境正常運作

---

## 🎯 目標

- 測試 Fortran 與 C++ 編譯器
- 熟悉編輯-編譯-執行的流程
- 理解最基本的程式結構

---

## 📝 檔案說明

- `hello.f90` - Fortran 版本
- `hello.cpp` - C++ 版本
- `Makefile` - 自動化編譯腳本

---

## 🚀 快速開始

### 方法一：使用 Makefile（推薦）

```bash
# 編譯並執行所有程式
make all

# 清除執行檔
make clean
```

### 方法二：手動編譯

#### Fortran
```bash
# 編譯
gfortran -O2 -Wall hello.f90 -o hello_fortran

# 執行
./hello_fortran
```

#### C++
```bash
# 編譯
g++ -O2 -Wall -std=c++11 hello.cpp -o hello_cpp

# 執行
./hello_cpp
```

---

## 📖 程式結構說明

### Fortran 版本

```fortran
program hello_world       ! 程式開始
  implicit none           ! 關閉隱式宣告（好習慣！）
  
  print *, "訊息"         ! 輸出到螢幕
  
end program hello_world   ! 程式結束
```

### C++ 版本

```cpp
#include <iostream>       // 引入輸入輸出函式庫

int main() {              // 主程式入口
  std::cout << "訊息" << std::endl;  // 輸出到螢幕
  
  return 0;               // 回傳 0 表示成功
}
```

---

## 🔍 常見問題

### Q: 編譯時出現 "command not found"
**A**: 編譯器未安裝或不在系統路徑中。請聯絡系統管理員安裝 `gfortran` 或 `g++`。

### Q: 為什麼 Fortran 需要 `implicit none`？
**A**: Fortran 預設會根據變數名稱自動推斷型態（如 `i` 開頭是整數），這容易導致錯誤。`implicit none` 強制明確宣告所有變數，是現代 Fortran 的最佳實踐。

### Q: `std::endl` 和 `\n` 有什麼差別？
**A**: `std::endl` 會輸出換行並清空緩衝區（flush），`\n` 只輸出換行。在效能敏感的程式中，`\n` 較快。

---

## ✅ 檢查點

完成以下事項後，即可進入下一章節：

- [ ] 成功編譯 Fortran 程式
- [ ] 成功編譯 C++ 程式
- [ ] 兩個程式都能正常執行並顯示訊息
- [ ] 理解基本程式結構

---

**恭喜完成第一步！接下來進入 [`02_Vector_Add`](../02_Vector_Add/) 學習陣列操作 🚀**
