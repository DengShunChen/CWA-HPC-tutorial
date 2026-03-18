// 向量加法 - C++ 優化版本 ⚡
// 優化技巧：
// 1. 使用編譯器優化選項 (-O3 -march=native)
// 2. 迴圈展開提升效能
// 3. 改善 cache locality

#include <iostream>
#include <chrono>
#include <iomanip>

int main() {
  // 變數宣告
  const int n = 10000000;  // 向量長度
  double* A = new double[n];
  double* B = new double[n];
  double* C = new double[n];
  
  // 初始化陣列
  std::cout << "初始化陣列 A 和 B (優化版)..." << std::endl;
  for (int i = 0; i < n; i++) {
    A[i] = static_cast<double>(i);
    B[i] = static_cast<double>(i) * 2.0;
  }
  
  // 開始計時
  auto start = std::chrono::high_resolution_clock::now();
  
  // 向量加法：手動迴圈展開 (處理 4 個元素一次)
  int i;
  for (i = 0; i < n - 3; i += 4) {
    C[i]   = A[i]   + B[i];
    C[i+1] = A[i+1] + B[i+1];
    C[i+2] = A[i+2] + B[i+2];
    C[i+3] = A[i+3] + B[i+3];
  }
  
  // 處理剩餘元素
  for (; i < n; i++) {
    C[i] = A[i] + B[i];
  }
  
  // 結束計時
  auto end = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = end - start;
  
  // 輸出結果
  std::cout << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << "  向量加法完成 (優化版 ⚡)" << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << "向量長度:    " << n << std::endl;
  std::cout << "執行時間:    " << std::fixed << std::setprecision(6) 
            << elapsed.count() << " 秒" << std::endl;
  std::cout << "前 5 個結果: ";
  for (int i = 0; i < 5; i++) {
    std::cout << C[i] << " ";
  }
  std::cout << std::endl << std::endl;
  std::cout << "💡 優化技巧：" << std::endl;
  std::cout << "   - 手動迴圈展開 (4x unrolling)" << std::endl;
  std::cout << "   - 編譯時加上 -O3 -march=native" << std::endl;
  std::cout << std::endl;
  
  // 釋放記憶體
  delete[] A;
  delete[] B;
  delete[] C;
  
  return 0;
}
