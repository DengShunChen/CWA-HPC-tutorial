// 向量加法 — C++（CPU），單精度；計時用 chrono
#include <chrono>
#include <cstdio>
#include <vector>

int main() {
  const int n = 10000000;
  std::vector<float> A(n), B(n), C(n);

  printf("初始化陣列 A 和 B...\n");
  for (int i = 0; i < n; i++) {
    A[i] = static_cast<float>(i);
    B[i] = static_cast<float>(i) * 2.0f;
  }

  auto t0 = std::chrono::high_resolution_clock::now();
  for (int i = 0; i < n; i++)
    C[i] = A[i] + B[i];
  auto t1 = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = t1 - t0;

  printf("\n========================================\n");
  printf("  C++（CPU）向量加法\n");
  printf("========================================\n");
  printf("向量長度:     %d\n", n);
  printf("執行時間:     %.6f 秒\n", elapsed.count());
  printf("前 5 個結果:  %.0f %.0f %.0f %.0f %.0f\n",
         static_cast<double>(C[0]), static_cast<double>(C[1]),
         static_cast<double>(C[2]), static_cast<double>(C[3]),
         static_cast<double>(C[4]));
  printf("\n");
  return 0;
}
