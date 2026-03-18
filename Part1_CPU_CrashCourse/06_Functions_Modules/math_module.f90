! 數學函數模組 - Fortran Module
! 示範如何組織可重用的函數

module math_module
  implicit none
  
  ! 設定模組為私有，僅匯出指定的函數
  private
  public :: factorial, fibonacci, is_prime, statistics
  
contains

  ! 計算階乘 n!
  function factorial(n) result(result_val)
    integer, intent(in) :: n
    integer :: result_val
    integer :: i
    
    result_val = 1
    do i = 2, n
      result_val = result_val * i
    end do
  end function factorial
  
  ! 計算費氏數列第 n 項
  function fibonacci(n) result(result_val)
    integer, intent(in) :: n
    integer :: result_val
    integer :: a, b, temp, i
    
    if (n <= 1) then
      result_val = n
      return
    end if
    
    a = 0
    b = 1
    do i = 2, n
      temp = a + b
      a = b
      b = temp
    end do
    result_val = b
  end function fibonacci
  
  ! 判斷是否為質數
  function is_prime(n) result(result_val)
    integer, intent(in) :: n
    logical :: result_val
    integer :: i
    
    if (n < 2) then
      result_val = .false.
      return
    end if
    
    if (n == 2) then
      result_val = .true.
      return
    end if
   if (mod(n, 2) == 0) then
      result_val = .false.
      return
    end if
    
    do i = 3, int(sqrt(real(n))) + 1, 2
      if (mod(n, i) == 0) then
        result_val = .false.
        return
      end if
    end do
    
    result_val = .true.
  end function is_prime
  
  ! 計算陣列的基本統計量
  subroutine statistics(data, n, mean, std_dev, min_val, max_val)
    integer, intent(in) :: n
    real(8), intent(in) :: data(n)
    real(8), intent(out) :: mean, std_dev, min_val, max_val
    real(8) :: sum_val, sum_sq
    integer :: i
    
    ! 計算平均值
    sum_val = 0.0d0
    do i = 1, n
      sum_val = sum_val + data(i)
    end do
    mean = sum_val / real(n, 8)
    
    ! 計算標準差
    sum_sq = 0.0d0
    do i = 1, n
      sum_sq = sum_sq + (data(i) - mean)**2
    end do
    std_dev = sqrt(sum_sq / real(n, 8))
    
    ! 找最小值和最大值
    min_val = data(1)
    max_val = data(1)
    do i = 2, n
      if (data(i) < min_val) min_val = data(i)
      if (data(i) > max_val) max_val = data(i)
    end do
    
  end subroutine statistics

end module math_module
