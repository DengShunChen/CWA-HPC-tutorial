// 向量加法 - C++ 基礎版本
// 功能：C = A + B (逐元素相加)

#include <iostream>
#include <chrono>
#include <iomanip>

int main() {
  // 變數宣告
  const int n = 10000000;  // 向量長度 (一千萬)
  double* A = new double[n];
  double* B = new double[n];
  double* C = new double[n];
  
  // 初始化陣列
  std::cout << "初始化陣列 A 和 B..." << std::endl;
  for (int i = 0; i < n; i++) {
    A[i] = static_cast<double>(i);
    B[i] = static_cast<double>(i) * 2.0;
  }
  
  // 開始計時
  auto start = std::chrono::high_resolution_clock::now();
  
  // 向量加法：C = A + B
  for (int i = 0; i < n; i++) {
    C[i] = A[i] + B[i];
  }
  
  // 結束計時
  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = end - start;
  
  // 輸出結果
  std::cout << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << "  向量加法完成" << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << "向量長度:    " << n << std::endl;
  std::cout << "執行時間:    " << std::fixed << std::setprecision(6) 
            << elapsed.count() << " 秒" << std::endl;
  std::cout << "前 5 個結果: ";
  for (int i = 0; i < 5; i++) {
    std::cout << C[i] << " ";
  }
  std::cout << std::endl << std::endl;
  
  // 釋放記憶體
  delete[] A;
  delete[] B;
  delete[] C;
  
  return 0;
}
