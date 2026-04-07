! 向量加法 — Fortran（CPU），單精度；索引 1..n
program vec_add_cpu_fortran
  implicit none
  integer, parameter :: n = 10000000
  real, allocatable :: A(:), B(:), C(:)
  integer :: i
  real :: t0, t1

  allocate(A(n), B(n), C(n))

  print *, "初始化陣列 A 和 B..."
  do i = 1, n
    A(i) = real(i)
    B(i) = real(i) * 2.0
  end do

  call cpu_time(t0)
  do i = 1, n
    C(i) = A(i) + B(i)
  end do
  call cpu_time(t1)

  print *
  print *, "========================================="
  print *, "  Fortran（CPU）向量加法"
  print *, "========================================="
  print *, "向量長度:    ", n
  print *, "執行時間:    ", t1 - t0, " 秒"
  print *, "前 5 個結果: ", C(1:5)
  print *

  deallocate(A, B, C)
end program vec_add_cpu_fortran
