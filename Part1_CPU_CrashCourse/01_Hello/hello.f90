! Fortran Hello World 程式
! 這是最簡單的 Fortran 程式，用來測試編譯環境

program hello_world
  implicit none   ! 關閉隱式宣告，強制所有變數必須宣告
  
  ! 輸出訊息到標準輸出
  print *, "========================================="
  print *, "  歡迎來到 HPC 程式設計工作坊！"
  print *, "  這是您的第一個 Fortran 程式"
  print *, "========================================="
  print *
  print *, "Fortran 編譯器運作正常 ✓"
  
end program hello_world
