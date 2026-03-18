! 檔案輸入輸出 - Fortran 範例
! 示範文字與二進位檔案的讀寫

program file_io_example
  implicit none
  
  ! 變數宣告
  integer, parameter :: n = 100
  real(8), allocatable :: data(:)
  real(8) :: value
  integer :: i, iostat
  character(len=50) :: filename_txt, filename_bin
  
  print *, "========================================="
  print *, "  Fortran 檔案 I/O 範例"
  print *, "========================================="
  print *
  
  ! 配置記憶體
  allocate(data(n))
  
  ! 產生測試資料
  print *, "產生測試資料..."
  do i = 1, n
    data(i) = sin(real(i, 8) * 0.1d0) * 100.0d0
  end do
  
  !-----------------------------------------
  ! 1. 寫入文字檔案 (Formatted I/O)
  !-----------------------------------------
  filename_txt = "output_data.txt"
  print *, "寫入文字檔案:", trim(filename_txt)
  
  open(unit=10, file=filename_txt, status='replace', action='write')
  
  ! 寫入標題行
  write(10, '(A)') "# Index    Value"
  write(10, '(A)') "# ----------------"
  
  ! 寫入資料（格式化輸出）
  do i = 1, n
    write(10, '(I5, 2X, F12.6)') i, data(i)
  end do
  
  close(10)
  print *, "✓ 文字檔案寫入完成"
  print *
  
  !-----------------------------------------
  ! 2. 寫入二進位檔案 (Unformatted I/O)
  !-----------------------------------------
  filename_bin = "output_data.bin"
  print *, "寫入二進位檔案:", trim(filename_bin)
  
  open(unit=20, file=filename_bin, status='replace', &
       form='unformatted', access='stream')
  
  ! 先寫入陣列大小
  write(20) n
  
  ! 再寫入所有資料（非常快速！）
  write(20) data
  
  close(20)
  print *, "✓ 二進位檔案寫入完成"
  print *
  
  !-----------------------------------------
  ! 3. 讀取文字檔案
  !-----------------------------------------
  print *, "從文字檔案讀取..."
  
  open(unit=10, file=filename_txt, status='old', action='read')
  
  ! 跳過標題行
  read(10, *)
  read(10, *)
  
  ! 讀取前 5 筆資料
  print *, "文字檔案前 5 筆資料："
  do i = 1, 5
    read(10, *, iostat=iostat) value
    if (iostat /= 0) exit
    write(*, '(A, I3, A, F12.6)') "  資料[", i, "] = ", value
  end do
  
  close(10)
  print *
  
  !-----------------------------------------
  ! 4. 讀取二進位檔案
  !-----------------------------------------
  print *, "從二進位檔案讀取..."
  
  ! 清空陣列以驗證讀取
  data = 0.0d0
  
  open(unit=20, file=filename_bin, status='old', &
       form='unformatted', access='stream')
  
  ! 讀取陣列大小
  read(20) i
  print *, "陣列大小:", i
  
  ! 讀取所有資料
  read(20) data
  
  close(20)
  
  print *, "二進位檔案前 5 筆資料："
  do i = 1, 5
    write(*, '(A, I3, A, F12.6)') "  資料[", i, "] = ", data(i)
  end do
  print *
  
  !-----------------------------------------
  ! 5. 附加資料到檔案 (Append)
  !-----------------------------------------
  print *, "附加資料到文字檔案..."
  
  open(unit=10, file=filename_txt, status='old', &
       position='append', action='write')
  
  write(10, '(A)') "# --- 新增資料 ---"
  write(10, '(I5, 2X, F12.6)') 999, 1234.5678d0
  
  close(10)
  print *, "✓ 資料附加完成"
  print *
  
  !-----------------------------------------
  ! 總結
  !-----------------------------------------
  print *, "========================================="
  print *, "  檔案 I/O 操作完成"
  print *, "========================================="
  print *, "產生的檔案："
  print *, "  1. ", trim(filename_txt), " (文字檔案)"
  print *, "  2. ", trim(filename_bin), " (二進位檔案)"
  print *
  
  ! 釋放記憶體
  deallocate(data)
  
end program file_io_example
