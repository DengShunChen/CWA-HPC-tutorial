/* 向量加法 — C（CPU），單精度；與本目錄其他語言同一演算法以便對照 */
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static double monotonic_sec(void) {
  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0)
    return -1.0;
  return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

int main(void) {
  const int n = 10000000;
  const size_t bytes = (size_t)n * sizeof(float);
  float *A = (float *)malloc(bytes);
  float *B = (float *)malloc(bytes);
  float *C = (float *)malloc(bytes);
  if (!A || !B || !C) {
    fprintf(stderr, "malloc failed\n");
    return 1;
  }

  printf("初始化陣列 A 和 B...\n");
  for (int i = 0; i < n; i++) {
    A[i] = (float)i;
    B[i] = (float)i * 2.0f;
  }

  double t0 = monotonic_sec();
  for (int i = 0; i < n; i++)
    C[i] = A[i] + B[i];
  double t1 = monotonic_sec();

  printf("\n========================================\n");
  printf("  C（CPU）向量加法\n");
  printf("========================================\n");
  printf("向量長度:     %d\n", n);
  printf("執行時間:     %.6f 秒\n", t1 - t0);
  printf("前 5 個結果:  %.0f %.0f %.0f %.0f %.0f\n",
         (double)C[0], (double)C[1], (double)C[2], (double)C[3], (double)C[4]);
  printf("\n");

  free(A);
  free(B);
  free(C);
  return 0;
}
