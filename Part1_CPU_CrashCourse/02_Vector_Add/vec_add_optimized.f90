! 向量加法 - Fortran 優化版本 ⚡
! 優化技巧：
! 1. 使用編譯器優化選項 (-O3)
! 2. 利用 Fortran 內建的陣列運算
! 3. 改善 cache locality

program vector_add_optimized
  implicit none
  
  ! 變數宣告
  integer, parameter :: n = 10000000   ! 向量長度
  real(8), allocatable :: A(:), B(:), C(:)
  integer :: i
  real :: start_time, end_time
  
  ! 配置記憶體
  allocate(A(n), B(n), C(n))
  
  ! 初始化陣列
  print *, "初始化陣列 A 和 B (優化版)..."
  ! 優化：使用 Fortran 陣列語法
  A = [(real(i, 8), i=1, n)]
  B = A * 2.0d0
  
  ! 開始計時
  call cpu_time(start_time)
  
  ! 向量加法：使用 Fortran 內建陣列運算
  ! 這樣寫可讓編譯器自動向量化優化
  C = A + B
  
  ! 結束計時
  call cpu_time(end_time)
  
  ! 輸出結果
  print *
  print *, "========================================="
  print *, "  向量加法完成 (優化版 ⚡)"
  print *, "========================================="
  print *, "向量長度:    ", n
  print *, "執行時間:    ", end_time - start_time, " 秒"
  print *, "前 5 個結果: ", C(1:5)
  print *, ""
  print *, "💡 優化技巧："
  print *, "   - 使用 Fortran 內建陣列運算"
  print *, "   - 編譯時加上 -O3 -march=native"
  print *
  
  ! 釋放記憶體
  deallocate(A, B, C)
  
end program vector_add_optimized
