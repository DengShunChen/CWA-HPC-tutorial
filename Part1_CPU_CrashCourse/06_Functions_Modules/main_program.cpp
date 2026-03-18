// 主程式 - 使用 math_functions
// 示範如何引用和使用自訂函數

#include <iostream>
#include <iomanip>
#include <vector>
#include <cmath>
#include "math_functions.h"

int main() {
  std::cout << "=========================================" << std::endl;
  std::cout << "  C++ 函數範例" << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << std::endl;
  
  //-----------------------------------------
  // 1. 測試階乘函數
  //-----------------------------------------
  std::cout << "--- 階乘測試 ---" << std::endl;
  for (int i = 1; i <= 10; i++) {
    int result = factorial(i);
    std::cout << std::setw(2) << i << "! = " 
              << std::setw(10) << result << std::endl;
  }
  std::cout << std::endl;
  
  //-----------------------------------------
  // 2. 測試費氏數列
  //-----------------------------------------
  std::cout << "--- 費氏數列測試 ---" << std::endl;
  for (int i = 0; i <= 15; i++) {
    int result = fibonacci(i);
    std::cout << "F(" << std::setw(2) << i << ") = " 
              << std::setw(8) << result << std::endl;
  }
  std::cout << std::endl;
  
  //-----------------------------------------
  // 3. 測試質數判斷
  //-----------------------------------------
  std::cout << "--- 質數測試 (1-30) ---" << std::endl;
  std::cout << "質數：" << std::endl;
  for (int i = 1; i <= 30; i++) {
    if (is_prime(i)) {
      std::cout << std::setw(3) << i << " ";
    }
  }
  std::cout << std::endl << std::endl;
  
  //-----------------------------------------
  // 4. 測試統計函數
  //-----------------------------------------
  std::cout << "--- 統計量測試 ---" << std::endl;
  
  int n = 100;
  std::vector<double> test_data(n);
  
  // 產生測試資料
  for (int i = 0; i < n; i++) {
    test_data[i] = std::sin(static_cast<double>(i) * 0.1) * 50.0 + 100.0;
  }
  
  // 計算統計量
  double mean, std_dev, min_val, max_val;
  statistics(test_data, mean, std_dev, min_val, max_val);
  
  std::cout << "資料筆數: " << n << std::endl;
  std::cout << std::fixed << std::setprecision(4);
  std::cout << "平均值:   " << std::setw(10) << mean << std::endl;
  std::cout << "標準差:   " << std::setw(10) << std_dev << std::endl;
  std::cout << "最小值:   " << std::setw(10) << min_val << std::endl;
  std::cout << "最大值:   " << std::setw(10) << max_val << std::endl;
  std::cout << std::endl;
  
  std::cout << "=========================================" << std::endl;
  std::cout << "  所有測試完成" << std::endl;
  std::cout << "=========================================" << std::endl;
  
  return 0;
}
