! 矩陣乘法 - Fortran 優化版本
! 功能：C = A * B (矩陣乘法)
! 優化技巧：使用內建 MATMUL 函數（編譯器會自動優化）

program matrix_multiply_optimized
  implicit none
  
  ! 變數宣告
  integer, parameter :: n = 512   ! 矩陣維度 (n x n)
  real(8), allocatable :: A(:,:), B(:,:), C(:,:)
  integer :: i, j
  real :: start_time, end_time
  
  print *, "========================================="
  print *, "  矩陣乘法 - 優化版本 ⚡"
  print *, "========================================="
  print *, "矩陣大小: ", n, "x", n
  print *, "優化技巧: 使用內建 MATMUL 函數"
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
  
  ! 開始計時
  call cpu_time(start_time)
  
  ! ✅ 矩陣乘法：使用內建函數（編譯器會自動優化）
  ! MATMUL 會自動選擇最佳的迴圈順序和分塊策略
  C = matmul(A, B)
  
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
  
end program matrix_multiply_optimized
