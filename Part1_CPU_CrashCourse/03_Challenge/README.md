# 03_Challenge - 練習題

> 動手實作：將向量加法改為向量乘法

---

## 🎯 任務目標

將 `02_Vector_Add` 的向量加法程式改為**向量乘法**，並測量效能。

**運算目標**：
```
C[i] = A[i] * B[i]  (逐元素相乘)
```

---

## 📝 檔案說明

- `multiply.f90` - Fortran 練習題骨架（待完成）
- `multiply.cpp` - C++ 練習題骨架（待完成）
- `solution/` - 參考解答（課後公布）

---

## 📋 實作步驟

### 1. 複製並修改

```bash
# 方法一：從頭開始（推薦給初學者）
# 參考 multiply.f90 / multiply.cpp 中的 TODO 提示

# 方法二：複製加法程式後修改（進階）
cp ../02_Vector_Add/vec_add.f90 multiply.f90
# 修改：將所有 A(i) + B(i) 改為 A(i) * B(i)
```

### 2. 必要元素

你的程式必須包含：

- [ ] 變數宣告（向量長度 n = 10,000,000）
- [ ] 動態記憶體配置
- [ ] 陣列初始化
- [ ] **向量乘法運算**
- [ ] 計時功能
- [ ] 結果輸出
- [ ] 記憶體釋放

### 3. 編譯與執行

```bash
# 使用 Makefile（推薦，需 Fujitsu 編譯器）
make all

# 或手動編譯（Fujitsu A64FX）
frt -Kfast multiply.f90 -o multiply_fortran
FCC -Kfast -std=c++11 multiply.cpp -o multiply_cpp

# 無 FCC 時 C++ 可用 g++（Fortran 仍須 frt）
g++ -O2 -std=c++11 multiply.cpp -o multiply_cpp
```

---

## 🌟 進階挑戰（選做）

完成基礎版本後，嘗試以下挑戰：

### 挑戰1：優化版本

創建 `multiply_optimized.f90` / `multiply_optimized.cpp`，應用優化技巧：

- **Fortran**：使用陣列運算 `C = A * B`
- **C++**：手動迴圈展開
- **編譯選項**：`-O3 -march=native`

### 挑戰2：效能比較

測量並比較：
- 基礎版 vs 優化版
- 乘法 vs 加法（哪個比較快？為什麼？）

### 挑戰3：其他運算

嘗試實作：
- 向量減法 `C = A - B`
- 向量除法 `C = A / B`（注意除以零！）
- 複合運算 `C = A * B + A`

---

## 💡 提示

### Fortran 計時

```fortran
real :: start_time, end_time

call cpu_time(start_time)
! ... 你的程式碼 ...
call cpu_time(end_time)

print *, "執行時間:", end_time - start_time, "秒"
```

### C++ 計時

```cpp
#include <chrono>

auto start = std::chrono::high_resolution_clock::now();
// ... 你的程式碼 ...
auto end = std::chrono::high_resolution_clock::now();

std::chrono::duration<double> elapsed = end - start;
std::cout << "執行時間: " << elapsed.count() << " 秒" << std::endl;
```

---

## ✅ 檢查清單

完成後，確認以下事項：

- [ ] 程式能成功編譯
- [ ] 程式能正常執行
- [ ] 輸出包含執行時間
- [ ] 輸出前 5 個結果以供驗證
- [ ] 記憶體正確釋放（無 memory leak）
- [ ] 試著理解為什麼結果是這樣

---

## 🎓 學習重點

透過這個練習，你應該能夠：

1. **獨立修改程式碼** - 不只是複製貼上
2. **理解陣列操作** - 動態配置、存取、釋放
3. **測量效能** - 知道程式需要多少時間
4. **驗證正確性** - 檢查輸出是否合理

---

## 📚 需要幫助？

- 語法不確定 → 查閱 [`00_Cheatsheets/syntax_rosetta_stone.md`](../../00_Cheatsheets/syntax_rosetta_stone.md)
- 編譯錯誤 → 參考 [`00_Cheatsheets/compilation_guide.md`](../../00_Cheatsheets/compilation_guide.md)
- 想學優化 → 閱讀 [`00_Cheatsheets/optimization_mindset.md`](../../00_Cheatsheets/optimization_mindset.md)

---

**祝你順利完成練習！記得：錯誤是學習的一部分 💪**

---

**下一步（擇一）**

- **依資料夾編號自學**：進入 [`04_Matrix_Operations`](../04_Matrix_Operations/)（二維陣列與快取）。  
- **依「約 3 小時工作坊」時程**：接 [`08_Debug_Profile`](../08_Debug_Profile/)（TCS Debugger／Profiler 入門），之後再回頭 [`04_Matrix_Operations`](../04_Matrix_Operations/) — 詳見本目錄 [`README.md`](../README.md)「兩種學習順序」。
