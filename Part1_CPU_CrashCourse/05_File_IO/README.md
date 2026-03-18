# 05_File_IO - 檔案輸入輸出

> 學習讀寫資料檔案的基本技巧

---

## 🎯 學習目標

1. 理解文字檔案 vs 二進位檔案的差異
2. 學習開啟、讀取、寫入、關閉檔案的操作
3. 掌握格式化輸出與錯誤處理
4. 理解檔案 I/O 對效能的影響

---

## 📝 檔案說明

| 檔案 | 說明 |
|------|------|
| `file_io.f90` | Fortran 檔案 I/O 範例 |
| `file_io.cpp` | C++ 檔案 I/O 範例 |
| `sample_input.txt` | 範例輸入資料檔 |

---

## 🚀 快速開始

```bash
# 編譯程式
make all

# 執行程式（會產生輸出檔案）
make run_all

# 查看產生的檔案
ls -lh output_*.txt output_*.bin

# 清除執行檔和輸出檔案
make clean
```

---

## 📖 基本概念

### 文字檔案 vs 二進位檔案

| 特性 | 文字檔案 | 二進位檔案 |
|------|---------|-----------|
| 可讀性 | 人類可讀 | 機器可讀 |
| 檔案大小 | 較大 | 較小 |
| 讀寫速度 | 較慢 | 較快 |
| 精度 | 可能損失 | 完全保留 |
| 跨平台 | 較佳 | 需注意 byte order |
| 適用場景 | 配置檔、日誌 | 大量數值資料 |

---

## 💻 Fortran 檔案 I/O

### 基本語法

```fortran
! 開啟檔案
open(unit=10, file="data.txt", status='replace', action='write')

! 寫入資料
write(10, *) value              ! 自由格式
write(10, '(F10.4)') value      ! 指定格式

! 讀取資料
read(10, *) value               ! 自由格式
read(10, '(F10.4)') value       ! 指定格式

! 關閉檔案
close(10)
```

### OPEN 參數說明

| 參數 | 選項 | 說明 |
|------|------|------|
| `status` | `'old'` | 檔案必須存在 |
|  | `'new'` | 檔案不可存在 |
|  | `'replace'` | 覆蓋現有檔案 |
| `action` | `'read'` | 唯讀 |
|  | `'write'` | 唯寫 |
|  | `'readwrite'` | 讀寫 |
| `form` | `'formatted'` | 文字檔案（預設） |
|  | `'unformatted'` | 二進位檔案 |
| `position` | `'asis'` | 保持位置 |
|  | `'rewind'` | 回到開頭 |
|  | `'append'` | 附加到結尾 |

### 格式化輸出

```fortran
! F10.4 = 總共 10 個字元，小數點後 4 位
write(*, '(F10.4)') 123.456789    ! → "  123.4568"

! I5 = 整數佔 5 個字元
write(*, '(I5)') 42               ! → "   42"

! 組合格式
write(*, '(A, I5, F10.4)') "Result:", 10, 3.14
```

---

## 💻 C++ 檔案 I/O

### 基本語法

```cpp
#include <fstream>

// 寫入文字檔案
std::ofstream outfile("data.txt");
outfile << value << std::endl;
outfile.close();

// 讀取文字檔案
std::ifstream infile("data.txt");
infile >> value;
infile.close();

// 寫入二進位檔案
std::ofstream binfile("data.bin", std::ios::binary);
binfile.write(reinterpret_cast<char*>(&value), sizeof(double));
binfile.close();
```

### 檔案開啟模式

| 模式 | 說明 |
|------|------|
| `std::ios::in` | 讀取模式 |
| `std::ios::out` | 寫入模式（預設會清空檔案） |
| `std::ios::app` | 附加模式（寫入到檔案結尾） |
| `std::ios::binary` | 二進位模式 |
| `std::ios::trunc` | 開啟時清空檔案 |

### 錯誤處理

```cpp
std::ifstream infile("data.txt");
if (!infile.is_open()) {
    std::cerr << "錯誤：無法開啟檔案" << std::endl;
    return 1;
}

// 檢查讀取是否成功
double value;
if (!(infile >> value)) {
    std::cerr << "錯誤：讀取失敗" << std::endl;
}
```

---

## ⚡ 效能考量

### 1. 二進位 vs 文字

**效能差異**：二進位 I/O 可快 5-10 倍

```fortran
! ❌ 慢：文字檔案
write(10, *) large_array  ! 需要轉換成字串

! ✅ 快：二進位檔案
write(20) large_array     ! 直接寫入記憶體內容
```

### 2. 緩衝 (Buffering)

大部分檔案系統會自動緩衝，但可以手動控制：

```cpp
// 關閉同步（提高效能）
std::ios::sync_with_stdio(false);

// 手動 flush（確保資料寫入）
outfile << data << std::flush;
```

### 3. 大檔案讀取策略

```cpp
// ❌ 不好：一次讀取全部（記憶體爆炸）
std::vector<double> all_data;
while (infile >> value) {
    all_data.push_back(value);
}

// ✅ 好：分批處理
const int batch_size = 1000;
std::vector<double> batch(batch_size);
while (infile.read(reinterpret_cast<char*>(batch.data()), 
                    batch_size * sizeof(double))) {
    // 處理這一批資料
    process_batch(batch);
}
```

---

## 🔍 常見錯誤與除錯

### 錯誤 1：忘記關閉檔案

```fortran
! ❌ 錯誤：檔案未關閉可能導致資料遺失
open(10, file="data.txt")
write(10, *) value
! 忘記 close(10)

! ✅ 正確
open(10, file="data.txt")
write(10, *) value
close(10)
```

### 錯誤 2：檔案路徑錯誤

```cpp
// 使用相對路徑時要注意工作目錄
std::ifstream infile("data.txt");          // 當前目錄
std::ifstream infile("./data/data.txt");   // 子目錄
std::ifstream infile("../data.txt");       // 上層目錄
```

### 錯誤 3：忘記檢查錯誤

```fortran
! 檢查開啟是否成功
integer :: ios
open(10, file="data.txt", iostat=ios)
if (ios /= 0) then
    print *, "錯誤：無法開啟檔案"
    stop
end if
```

---

## ✅ 實驗練習

1. **基礎練習**：執行範例程式，檢查產生的檔案
2. **修改練習**：改變資料量（從 100 改為 10,000），測量執行時間
3. **進階練習**：讀取 `sample_input.txt`，計算平均值並輸出

---

## 📚 延伸閱讀

- Fortran: [格式化 I/O 完整指南](https://www.fortran90.org)
- C++: [fstream 參考文件](https://en.cppreference.com/w/cpp/io/basic_fstream)

---

**下一步：前往 [`06_Functions_Modules`](../06_Functions_Modules/) 學習程式碼模組化 🚀**
