// 數學函數實作檔 - C++ Implementation
// 實作函數邏輯

#include "math_functions.h"
#include <cmath>
#include <algorithm>

// 計算階乘 n!
int factorial(int n) {
  int result = 1;
  for (int i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

// 計算費氏數列第 n 項
int fibonacci(int n) {
  if (n <= 1) {
    return n;
  }
  
  int a = 0, b = 1;
  for (int i = 2; i <= n; i++) {
    int temp = a + b;
    a = b;
    b = temp;
  }
  return b;
}

// 判斷是否為質數
bool is_prime(int n) {
  if (n < 2) {
    return false;
  }
  
  if (n == 2) {
    return true;
  }
  
  if (n % 2 == 0) {
    return false;
  }
  
  for (int i = 3; i <= static_cast<int>(std::sqrt(n)) + 1; i += 2) {
    if (n % i == 0) {
      return false;
    }
  }
  
  return true;
}

// 計算陣列的基本統計量
void statistics(const std::vector<double>& data, 
                double& mean, 
                double& std_dev, 
                double& min_val, 
                double& max_val) {
  int n = data.size();
  
  // 計算平均值
  double sum = 0.0;
  for (const auto& value : data) {
    sum += value;
  }
  mean = sum / n;
  
  // 計算標準差
  double sum_sq = 0.0;
  for (const auto& value : data) {
    sum_sq += (value - mean) * (value - mean);
  }
  std_dev = std::sqrt(sum_sq / n);
  
  // 找最小值和最大值
  min_val = *std::min_element(data.begin(), data.end());
  max_val = *std::max_element(data.begin(), data.end());
}
