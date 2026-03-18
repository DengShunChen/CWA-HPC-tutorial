// 數學函數標頭檔 - C++ Header
// 宣告函數介面

#ifndef MATH_FUNCTIONS_H
#define MATH_FUNCTIONS_H

#include <vector>

// 計算階乘 n!
int factorial(int n);

// 計算費氏數列第 n 項
int fibonacci(int n);

// 判斷是否為質數
bool is_prime(int n);

// 計算陣列的基本統計量
void statistics(const std::vector<double>& data, 
                double& mean, 
                double& std_dev, 
                double& min_val, 
                double& max_val);

#endif // MATH_FUNCTIONS_H
