! 矩陣乘法 - Fortran 基礎版本
! 功能：C = A * B (矩陣乘法)
! 使用標準的三層迴圈 (i-j-k 順序)

program matrix_multiply
  implicit none
  
  ! 變數宣告
  integer, parameter :: n = 512   ! 矩陣維度 (n x n)
  real(8), allocatable :: A(:,:), B(:,:), C(:,:)
  integer :: i, j, k
  real :: start_time, end_time
  real(8) :: sum_val
  
  print *, "========================================="
  print *, "  矩陣乘法 - 基礎版本"
  print *, "========================================="
  print *, "矩陣大小: ", n, "x", n
  print *
  
  ! 配置記憶體
  allocate(A(n,n), B(n,n), C(n,n))
  
  ! 初始化矩陣
  print *, "初始化矩陣 A 和 B..."
  do j = 1, n
    do i = 1, n
      A(i,j) = real(i + j, 8) / real(n, 8)
      B(i,j) = real(i - j, 8) / real(n, 8)
    end do
  end do
  
  ! 初始化結果矩陣為零
  C = 0.0d0
  
  ! 開始計時
  call cpu_time(start_time)
  
  ! 矩陣乘法：C = A * B
  ! 標準三層迴圈 (i-j-k 順序)
  ! ⚠️ 注意：這個順序在 Fortran 中不是最優的！
  do i = 1, n
    do j = 1, n
      sum_val = 0.0d0
      do k = 1, n
        sum_val = sum_val + A(i,k) * B(k,j)
      end do
      C(i,j) = sum_val
    end do
  end do
  
  ! 結束計時
  call cpu_time(end_time)
  
  ! 輸出結果
  print *
  print *, "========================================="
  print *, "  計算完成"
  print *, "========================================="
  print *, "執行時間:    ", end_time - start_time, " 秒"
  print *, "GFLOPS:      ", (2.0d0 * n**3) / ((end_time - start_time) * 1.0d9)
  print *
  print *, "結果矩陣 C 的部分元素："
  print *, "C(1,1)   = ", C(1,1)
  print *, "C(1,2)   = ", C(1,2)
  print *, "C(n,n)   = ", C(n,n)
  print *
  
  ! 釋放記憶體
  deallocate(A, B, C)
  
end program matrix_multiply
