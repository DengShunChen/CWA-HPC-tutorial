! 主程式 - 使用 math_module
! 示範如何引用和使用模組中的函數

program main_program
  ! 引用模組（可選擇性地只匯入特定函數）
  use math_module, only: factorial, fibonacci, is_prime, statistics
  implicit none
  
  ! 變數宣告
  integer :: i, n
  integer :: fact_result, fib_result
  logical :: prime_result
  real(8), allocatable :: test_data(:)
  real(8) :: mean, std_dev, min_val, max_val
  
  print *, "========================================="
  print *, "  Fortran 模組範例"
  print *, "========================================="
  print *
  
  !-----------------------------------------
  ! 1. 測試階乘函數
  !-----------------------------------------
  print *, "--- 階乘測試 ---"
  do i = 1, 10
    fact_result = factorial(i)
    write(*, '(I2, A, I10)') i, "! = ", fact_result
  end do
  print *
  
  !-----------------------------------------
  ! 2. 測試費氏數列
  !-----------------------------------------
  print *, "--- 費氏數列測試 ---"
  do i = 0, 15
    fib_result = fibonacci(i)
    write(*, '(A, I2, A, I8)') "F(", i, ") = ", fib_result
  end do
  print *
  
  !-----------------------------------------
  ! 3. 測試質數判斷
  !-----------------------------------------
  print *, "--- 質數測試 (1-30) ---"
  print *, "質數："
  do i = 1, 30
    prime_result = is_prime(i)
    if (prime_result) then
      write(*, '(I3, A)', advance='no') i, " "
    end if
  end do
  print *
  print *
  
  !-----------------------------------------
  ! 4. 測試統計函數
  !-----------------------------------------
  print *, "--- 統計量測試 ---"
  
  n = 100
  allocate(test_data(n))
  
  ! 產生測試資料
  do i = 1, n
    test_data(i) = sin(real(i, 8) * 0.1d0) * 50.0d0 + 100.0d0
  end do
  
  ! 計算統計量
  call statistics(test_data, n, mean, std_dev, min_val, max_val)
  
  print *, "資料筆數: ", n
  write(*, '(A, F10.4)') "平均值:   ", mean
  write(*, '(A, F10.4)') "標準差:   ", std_dev
  write(*, '(A, F10.4)') "最小值:   ", min_val
  write(*, '(A, F10.4)') "最大值:   ", max_val
  print *
  
  ! 釋放記憶體
  deallocate(test_data)
  
  print *, "========================================="
  print *, "  所有測試完成"
  print *, "========================================="
  
end program main_program
