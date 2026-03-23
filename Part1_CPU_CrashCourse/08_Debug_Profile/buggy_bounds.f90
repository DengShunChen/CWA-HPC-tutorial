! 刻意示範：迴圈越界讀取陣列。若以 -Hx,CHECK_SUBSCRIPT 編譯，執行時應被檢查攔截。
! 自動化測試不會執行本程式（非零結束／錯誤結束）。
program buggy_bounds
  implicit none
  integer :: a(4)
  integer :: i, s

  a = (/ 1, 2, 3, 4 /)
  s = 0
  do i = 1, 5
    s = s + a(i)
  end do
  print *, s
end program buggy_bounds
