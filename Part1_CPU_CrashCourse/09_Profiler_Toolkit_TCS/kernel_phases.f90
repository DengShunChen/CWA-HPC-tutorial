! 多階段運算負載（module 程序）：便於 TCS Profiler／FIPP 報告中顯示多種瓶頸。
! 預期：
!   - phase_heavy   : 計算密集（高 FLOPs、易向量化）
!   - phase_stream  : 記憶體頻寬/資料搬移較敏感
!   - phase_branch  : 分支與混合整數/浮點路徑
!   - phase_light   : 輕量基準段（對照用）
!
! 環境變數 KERNEL_PROFILE_N（可選）：覆寫迭代長度 n，供登入節點／CI 快速自測。
! 未設定時預設 kernel_n_default（較大，適合計算節點上量測）。
module kernel_phases
  implicit none
  private
  public :: ik, kernel_n_default, resolve_kernel_profile_n
  public :: phase_heavy, phase_stream, phase_branch, phase_light

  integer, parameter :: ik = selected_int_kind(18)
  integer(ik), parameter :: kernel_n_default = 120000000_ik

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

  subroutine phase_stream(n, s)
    integer(ik), intent(in) :: n
    real(8), intent(out) :: s
    integer(ik) :: m, i
    integer :: sweep
    real(8), allocatable :: a(:), b(:), c(:)

    m = max(200000_ik, n / 8_ik)
    allocate(a(m), b(m), c(m))

    do i = 1_ik, m
      a(i) = dble(mod(i, 251_ik)) * 1.0d-5
      b(i) = dble(mod(i, 127_ik)) * 2.0d-5
      c(i) = 0.0d0
    end do

    do sweep = 1, 4
      do i = 2_ik, m - 1_ik
        c(i) = 0.25d0 * a(i - 1_ik) + 0.5d0 * b(i) + 0.25d0 * a(i + 1_ik)
      end do
      do i = 2_ik, m - 1_ik
        a(i) = a(i) + 1.0d-3 * c(i)
        b(i) = b(i) - 5.0d-4 * c(i)
      end do
    end do

    s = 0.0d0
    do i = 1_ik, m, 16_ik
      s = s + a(i) + b(i) + c(i)
    end do

    deallocate(a, b, c)
  end subroutine phase_stream

  subroutine phase_branch(n, s)
    integer(ik), intent(in) :: n
    real(8), intent(out) :: s
    integer(ik) :: m, i
    integer(ik) :: r
    real(8) :: x

    m = max(500000_ik, n / 4_ik)
    s = 0.0d0

    do i = 1_ik, m
      r = mod(i, 11_ik)
      x = dble(mod(i, 4093_ik)) * 1.0d-6
      if (r <= 2_ik) then
        s = s + x * x + 3.0d-7
      else if (r <= 6_ik) then
        s = s + x / (1.0d0 + x) + 1.0d-7
      else
        s = s + (x * (2.0d0 - x)) * 0.5d0
      end if
    end do
  end subroutine phase_branch

end module kernel_phases
