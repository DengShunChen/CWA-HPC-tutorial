// 練習題：向量乘法 - C++
// 功能：C[i] = A[i] * B[i]，並測量執行時間

#include <chrono>
#include <iomanip>
#include <iostream>

int main() {
  const int n = 10000000;
  double *A = new double[n];
  double *B = new double[n];
  double *C = new double[n];

  std::cout << "初始化陣列 A 和 B..." << std::endl;
  for (int i = 0; i < n; i++) {
    A[i] = static_cast<double>(i);
    B[i] = static_cast<double>(i) * 2.0;
  }

  auto start = std::chrono::high_resolution_clock::now();

  for (int i = 0; i < n; i++) {
    C[i] = A[i] * B[i];
  }

  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = end - start;

  std::cout << std::endl;
  std::cout << "=====================================" << std::endl;
  std::cout << "  向量乘法完成" << std::endl;
  std::cout << "=====================================" << std::endl;
  std::cout << "向量長度:    " << n << std::endl;
  std::cout << "執行時間:    " << std::fixed << std::setprecision(6)
            << elapsed.count() << " 秒" << std::endl;
  std::cout << "前 5 個結果: ";
  for (int i = 0; i < 5; i++) {
    std::cout << C[i] << " ";
  }
  std::cout << std::endl << std::endl;

  delete[] A;
  delete[] B;
  delete[] C;

  return 0;
}
