! 向量加法 — OpenACC Fortran（非同步排程）
! 示範 async / wait：在更大型程式中可把計算與後續 host 工作交疊（此處仍為單一迴圈示範）
program vec_add_openacc_async
  implicit none
  integer, parameter :: n = 10000000
  real, allocatable :: a(:), b(:), c(:)
  integer :: i
  integer :: t0, t1, rate

  allocate(a(n), b(n), c(n))

  print *, "初始化陣列 A、B..."
  do i = 1, n
    a(i) = real(i)
    b(i) = real(i) * 2.0
  end do

  call system_clock(count=t0, count_rate=rate)

  !$acc data copyin(a, b) copyout(c)
  !$acc kernels async(1)
  do i = 1, n
    c(i) = a(i) + b(i)
  end do
  !$acc end kernels
  !$acc wait
  !$acc end data

  call system_clock(count=t1, count_rate=rate)

  print *
  print *, "========================================="
  print *, "  OpenACC Fortran（kernels + async + wait）"
  print *, "========================================="
  print *, "向量長度:    ", n
  print *, "區段時間(秒):", real(t1 - t0) / real(rate)
  print *, "前 5 個結果: ", c(1:5)
  print *

  deallocate(a, b, c)
end program vec_add_openacc_async
