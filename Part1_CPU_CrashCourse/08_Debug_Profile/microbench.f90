! 小範例：內部副程式 heavy_work 為運算熱點，供 TCS Debugger / TCS Profiler 練習。
program microbench
  implicit none
  integer, parameter :: ik = selected_int_kind(18)
  integer(ik) :: n
  real(8) :: s, t0, t1

  n = 50000000_ik
  call cpu_time(t0)
  call heavy_work(n, s)
  call cpu_time(t1)
  print *, 'checksum=', s, ' time_s=', t1 - t0

contains

  subroutine heavy_work(n, s)
    integer(ik), intent(in) :: n
    real(8), intent(out) :: s
    integer(ik) :: i

    s = 0.0d0
    do i = 0_ik, n - 1_ik
      s = s + dble(mod(i, 997_ik)) * 1.0d-7
    end do
  end subroutine heavy_work

end program microbench
