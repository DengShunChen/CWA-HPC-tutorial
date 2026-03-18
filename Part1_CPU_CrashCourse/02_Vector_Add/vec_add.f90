! 向量加法 - Fortran 基礎版本
! 功能：C = A + B (逐元素相加)

program vector_add
  implicit none
  
  ! 變數宣告
  integer, parameter :: n = 10000000   ! 向量長度 (一千萬)
  real(8), allocatable :: A(:), B(:), C(:)  ! 動態陣列
  integer :: i
  real :: start_time, end_time
  
  ! 配置記憶體
  allocate(A(n), B(n), C(n))
  
  ! 初始化陣列
  print *, "初始化陣列 A 和 B..."
  do i = 1, n
    A(i) = real(i, 8)
    B(i) = real(i, 8) * 2.0d0
  end do
  
  ! 開始計時
  call cpu_time(start_time)
  
  ! 向量加法：C = A + B
  do i = 1, n
    C(i) = A(i) + B(i)
  end do
  
  ! 結束計時
  call cpu_time(end_time)
  
  ! 輸出結果
  print *
  print *, "========================================="
  print *, "  向量加法完成"
  print *, "========================================="
  print *, "向量長度:    ", n
  print *, "執行時間:    ", end_time - start_time, " 秒"
  print *, "前 5 個結果: ", C(1:5)
  print *
  
  ! 釋放記憶體
  deallocate(A, B, C)
  
end program vector_add
