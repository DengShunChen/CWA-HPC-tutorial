! 練習題：向量乘法 - Fortran
! 功能：C(i) = A(i) * B(i)，並測量執行時間

program vector_multiply
  implicit none

  integer, parameter :: n = 10000000
  real(8), allocatable :: A(:), B(:), C(:)
  integer :: i
  real :: start_time, end_time

  allocate(A(n), B(n), C(n))

  print *, "初始化陣列 A 和 B..."
  do i = 1, n
    A(i) = real(i, 8)
    B(i) = real(i, 8) * 2.0d0
  end do

  call cpu_time(start_time)

  do i = 1, n
    C(i) = A(i) * B(i)
  end do

  call cpu_time(end_time)

  print *
  print *, "====================================="
  print *, "  向量乘法完成"
  print *, "====================================="
  print *, "向量長度:    ", n
  print *, "執行時間:    ", end_time - start_time, " 秒"
  print *, "前 5 個結果: ", C(1:5)
  print *

  deallocate(A, B, C)

end program vector_multiply
