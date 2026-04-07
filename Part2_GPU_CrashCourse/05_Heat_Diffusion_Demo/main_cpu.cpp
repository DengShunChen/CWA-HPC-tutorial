// 2D 熱傳導 — CPU 參考實作（有限差分、顯式 Euler）
// 與 main_gpu.cu 使用相同參數與索引：列優先 T[i * NY + j]

#include <chrono>
#include <cmath>
#include <cstring>
#include <iostream>

int main() {
  const int NX = 512;
  const int NY = 512;
  const int STEPS = 1000;
  const float alpha = 0.1f;
  const float dx = 1.0f;
  const size_t n = static_cast<size_t>(NX) * static_cast<size_t>(NY);
  const size_t bytes = n * sizeof(float);

  float *T_old = new float[n];
  float *T_new = new float[n];

  std::memset(T_old, 0, bytes);
  std::memset(T_new, 0, bytes);

  for (int i = NX / 2 - 50; i < NX / 2 + 50; ++i)
    for (int j = NY / 2 - 50; j < NY / 2 + 50; ++j)
      T_old[static_cast<size_t>(i) * NY + j] = 100.0f;

  float max_init = 0.f;
  for (size_t k = 0; k < n; ++k)
    max_init = fmaxf(max_init, T_old[k]);

  auto t0 = std::chrono::high_resolution_clock::now();

  for (int step = 0; step < STEPS; ++step) {
    std::memset(T_new, 0, bytes);
    for (int i = 1; i < NX - 1; ++i) {
      for (int j = 1; j < NY - 1; ++j) {
        const size_t idx = static_cast<size_t>(i) * NY + j;
        const float laplacian =
            (T_old[idx + NY] + T_old[idx - NY] + T_old[idx + 1] + T_old[idx - 1] -
             4.0f * T_old[idx]) /
            (dx * dx);
        T_new[idx] = T_old[idx] + alpha * laplacian;
      }
    }
    float *tmp = T_old;
    T_old = T_new;
    T_new = tmp;
  }

  auto t1 = std::chrono::high_resolution_clock::now();
  const double sec =
      std::chrono::duration<double>(t1 - t0).count();

  float max_final = 0.f;
  for (size_t k = 0; k < n; ++k)
    max_final = fmaxf(max_final, T_old[k]);

  std::cout << "========================================\n";
  std::cout << "  2D 熱傳導 — CPU\n";
  std::cout << "========================================\n";
  std::cout << "網格:        " << NX << " x " << NY << "\n";
  std::cout << "時間步數:    " << STEPS << "\n";
  std::cout << "初始最高溫:  " << max_init << "\n";
  std::cout << "最終最高溫:  " << max_final << "\n";
  std::cout << "CPU 時間:    " << sec << " 秒\n";

  delete[] T_old;
  delete[] T_new;
  return 0;
}
