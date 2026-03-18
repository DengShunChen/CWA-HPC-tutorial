// 矩陣乘法 - C++ 基礎版本
// 功能：C = A * B (矩陣乘法)
// 使用標準的三層迴圈 (i-j-k 順序)

#include <iostream>
#include <chrono>
#include <iomanip>

int main() {
  // 變數宣告
  const int n = 512;  // 矩陣維度 (n x n)
  
  std::cout << "=========================================" << std::endl;
  std::cout << "  矩陣乘法 - 基礎版本" << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << "矩陣大小: " << n << " x " << n << std::endl;
  std::cout << std::endl;
  
  // 配置記憶體 (使用一維陣列模擬二維，row-major)
  double* A = new double[n * n];
  double* B = new double[n * n];
  double* C = new double[n * n];
  
  // 初始化矩陣
  std::cout << "初始化矩陣 A 和 B..." << std::endl;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      A[i*n + j] = static_cast<double>(i + j) / static_cast<double>(n);
      B[i*n + j] = static_cast<double>(i - j) / static_cast<double>(n);
    }
  }
  
  // 初始化結果矩陣為零
  for (int i = 0; i < n * n; i++) {
    C[i] = 0.0;
  }
  
  // 開始計時
  auto start = std::chrono::high_resolution_clock::now();
  
  // 矩陣乘法：C = A * B
  // 標準三層迴圈 (i-j-k 順序)
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      double sum = 0.0;
      for (int k = 0; k < n; k++) {
        sum += A[i*n + k] * B[k*n + j];
      }
      C[i*n + j] = sum;
    }
  }
  
  // 結束計時
  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = end - start;
  
  // 輸出結果
  std::cout << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << "  計算完成" << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << "執行時間:    " << std::fixed << std::setprecision(6) 
            << elapsed.count() << " 秒" << std::endl;
  
  double gflops = (2.0 * n * n * n) / (elapsed.count() * 1.0e9);
  std::cout << "GFLOPS:      " << std::fixed << std::setprecision(3) 
            << gflops << std::endl;
  std::cout << std::endl;
  
  std::cout << "結果矩陣 C 的部分元素：" << std::endl;
  std::cout << "C(1,1)   = " << C[0] << std::endl;
  std::cout << "C(1,2)   = " << C[1] << std::endl;
  std::cout << "C(n,n)   = " << C[n*n - 1] << std::endl;
  std::cout << std::endl;
  
  // 釋放記憶體
  delete[] A;
  delete[] B;
  delete[] C;
  
  return 0;
}
