// 檔案輸入輸出 - C++ 範例
// 示範文字與二進位檔案的讀寫

#include <iostream>
#include <fstream>
#include <iomanip>
#include <cmath>
#include <vector>

int main() {
  // 變數宣告
  const int n = 100;
  std::vector<double> data(n);
  
  std::cout << "=========================================" << std::endl;
  std::cout << "  C++ 檔案 I/O 範例" << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << std::endl;
  
  // 產生測試資料
  std::cout << "產生測試資料..." << std::endl;
  for (int i = 0; i < n; i++) {
    data[i] = std::sin(static_cast<double>(i) * 0.1) * 100.0;
  }
  
  //-----------------------------------------
  // 1. 寫入文字檔案 (Text Mode)
  //-----------------------------------------
  std::string filename_txt = "output_data_cpp.txt";
  std::cout << "寫入文字檔案: " << filename_txt << std::endl;
  
  std::ofstream outfile_txt(filename_txt);
  if (!outfile_txt.is_open()) {
    std::cerr << "錯誤：無法開啟檔案 " << filename_txt << std::endl;
    return 1;
  }
  
  // 寫入標題行
  outfile_txt << "# Index    Value" << std::endl;
  outfile_txt << "# ----------------" << std::endl;
  
  // 寫入資料（格式化輸出）
  for (int i = 0; i < n; i++) {
    outfile_txt << std::setw(5) << i+1 << "  " 
                << std::fixed << std::setprecision(6) 
                << data[i] << std::endl;
  }
  
  outfile_txt.close();
  std::cout << "✓ 文字檔案寫入完成" << std::endl;
  std::cout << std::endl;
  
  //-----------------------------------------
  // 2. 寫入二進位檔案 (Binary Mode)
  //-----------------------------------------
  std::string filename_bin = "output_data_cpp.bin";
  std::cout << "寫入二進位檔案: " << filename_bin << std::endl;
  
  std::ofstream outfile_bin(filename_bin, std::ios::binary);
  if (!outfile_bin.is_open()) {
    std::cerr << "錯誤：無法開啟檔案 " << filename_bin << std::endl;
    return 1;
  }
  
  // 先寫入陣列大小
  outfile_bin.write(reinterpret_cast<const char*>(&n), sizeof(int));
  
  // 再寫入所有資料（非常快速！）
  outfile_bin.write(reinterpret_cast<const char*>(data.data()), 
                    n * sizeof(double));
  
  outfile_bin.close();
  std::cout << "✓ 二進位檔案寫入完成" << std::endl;
  std::cout << std::endl;
  
  //-----------------------------------------
  // 3. 讀取文字檔案
  //-----------------------------------------
  std::cout << "從文字檔案讀取..." << std::endl;
  
  std::ifstream infile_txt(filename_txt);
  if (!infile_txt.is_open()) {
    std::cerr << "錯誤：無法開啟檔案 " << filename_txt << std::endl;
    return 1;
  }
  
  // 跳過標題行
  std::string line;
  std::getline(infile_txt, line);
  std::getline(infile_txt, line);
  
  // 讀取前 5 筆資料
  std::cout << "文字檔案前 5 筆資料：" << std::endl;
  for (int i = 0; i < 5; i++) {
    int idx;
    double value;
    if (infile_txt >> idx >> value) {
      std::cout << "  資料[" << std::setw(3) << i+1 << "] = " 
                << std::fixed << std::setprecision(6) << value << std::endl;
    }
  }
  
  infile_txt.close();
  std::cout << std::endl;
  
  //-----------------------------------------
  // 4. 讀取二進位檔案
  //-----------------------------------------
  std::cout << "從二進位檔案讀取..." << std::endl;
  
  // 清空陣列以驗證讀取
  std::fill(data.begin(), data.end(), 0.0);
  
  std::ifstream infile_bin(filename_bin, std::ios::binary);
  if (!infile_bin.is_open()) {
    std::cerr << "錯誤：無法開啟檔案 " << filename_bin << std::endl;
    return 1;
  }
  
  // 讀取陣列大小
  int size_read;
  infile_bin.read(reinterpret_cast<char*>(&size_read), sizeof(int));
  std::cout << "陣列大小: " << size_read << std::endl;
  
  // 讀取所有資料
  infile_bin.read(reinterpret_cast<char*>(data.data()), 
                  size_read * sizeof(double));
  
  infile_bin.close();
  
  std::cout << "二進位檔案前 5 筆資料：" << std::endl;
  for (int i = 0; i < 5; i++) {
    std::cout << "  資料[" << std::setw(3) << i+1 << "] = " 
              << std::fixed << std::setprecision(6) << data[i] << std::endl;
  }
  std::cout << std::endl;
  
  //-----------------------------------------
  // 5. 附加資料到檔案 (Append)
  //-----------------------------------------
  std::cout << "附加資料到文字檔案..." << std::endl;
  
  std::ofstream appendfile(filename_txt, std::ios::app);
  if (!appendfile.is_open()) {
    std::cerr << "錯誤：無法開啟檔案 " << filename_txt << std::endl;
    return 1;
  }
  
  appendfile << "# --- 新增資料 ---" << std::endl;
  appendfile << std::setw(5) << 999 << "  " 
             << std::fixed << std::setprecision(4) 
             << 1234.5678 << std::endl;
  
  appendfile.close();
  std::cout << "✓ 資料附加完成" << std::endl;
  std::cout << std::endl;
  
  //-----------------------------------------
  // 總結
  //-----------------------------------------
  std::cout << "=========================================" << std::endl;
  std::cout << "  檔案 I/O 操作完成" << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << "產生的檔案：" << std::endl;
  std::cout << "  1. " << filename_txt << " (文字檔案)" << std::endl;
  std::cout << "  2. " << filename_bin << " (二進位檔案)" << std::endl;
  std::cout << std::endl;
  
  return 0;
}
