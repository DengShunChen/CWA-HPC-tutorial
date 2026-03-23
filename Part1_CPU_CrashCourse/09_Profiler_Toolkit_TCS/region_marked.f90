! 使用 fipp_start / fipp_stop 標示「僅量測此區段」（搭配 fipp -Sregion）。
! 需以 Fujitsu frt 並連結 FIPP（-Nfjprof）。
program region_marked
  use kernel_phases
  implicit none
  integer(ik) :: n
  real(8) :: s_heavy, s_stream, s_branch, s_light

  interface
    subroutine fipp_start
    end subroutine fipp_start
    subroutine fipp_stop
    end subroutine fipp_stop
  end interface

  call resolve_kernel_profile_n(n)

  ! I／O 留在區段外時，量測結果不包含 print 開銷（教學示範）
  call fipp_start
  call phase_heavy(n, s_heavy)
  call phase_stream(n, s_stream)
  call phase_branch(n, s_branch)
  call phase_light(n, s_light)
  call fipp_stop

  print *, 'checksum_heavy=', s_heavy, ' checksum_stream=', s_stream, &
           ' checksum_branch=', s_branch, ' checksum_light=', s_light
end program region_marked
