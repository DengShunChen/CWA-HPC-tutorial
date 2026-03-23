! 雙階段運算負載（module 程序）：便於 TCS Profiler／FIPP 報告中顯示符號。
! 預期：phase_heavy 迴圈次數遠多於 phase_light，主要時間應落在 phase_heavy。
!
! 環境變數 KERNEL_PROFILE_N（可選）：覆寫迭代長度 n，供登入節點／CI 快速自測。
! 未設定時預設 kernel_n_default（約 5e7，適合計算節點上量測）。
module kernel_phases
  implicit none
  private
  public :: ik, kernel_n_default, resolve_kernel_profile_n, phase_heavy, phase_light

  integer, parameter :: ik = selected_int_kind(18)
  integer(ik), parameter :: kernel_n_default = 50000000_ik

contains

  subroutine resolve_kernel_profile_n(n)
    integer(ik), intent(out) :: n
    character(len=128) :: buf
    integer :: stat, ios
    integer(8) :: nt

    n = kernel_n_default
    call get_environment_variable('KERNEL_PROFILE_N', buf, status=stat)
    if (stat /= 0) return
    buf = adjustl(buf)
    if (len_trim(buf) == 0) return
    read (buf, *, iostat=ios) nt
    if (ios /= 0) return
    if (nt < 1_8) return
    n = int(nt, kind=ik)
  end subroutine resolve_kernel_profile_n


  subroutine phase_heavy(n, s)
    integer(ik), intent(in) :: n
    real(8), intent(out) :: s
    integer(ik) :: i

    s = 0.0d0
    do i = 0_ik, n - 1_ik
      s = s + dble(mod(i, 997_ik)) * 1.0d-7
    end do
  end subroutine phase_heavy

  subroutine phase_light(n, s)
    integer(ik), intent(in) :: n
    real(8), intent(out) :: s
    integer(ik) :: i
    integer(ik) :: m

    m = max(1_ik, n / 20_ik)
    s = 0.0d0
    do i = 0_ik, m - 1_ik
      s = s + dble(mod(i, 13_ik)) * 1.0d-6
    end do
  end subroutine phase_light

end module kernel_phases
