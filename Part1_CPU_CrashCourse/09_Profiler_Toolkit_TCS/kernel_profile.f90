! 整程式量測用進入點（無 fipp 區段標記）；模組見 kernel_phases.f90
program kernel_profile
  use kernel_phases
  implicit none
  integer(ik) :: n
  real(8) :: s_heavy, s_stream, s_branch, s_light
  real(8) :: t0, t1, th0, th1, ts0, ts1, tb0, tb1, tl0, tl1

  call resolve_kernel_profile_n(n)
  call cpu_time(t0)
  call cpu_time(th0)
  call phase_heavy(n, s_heavy)
  call cpu_time(th1)

  call cpu_time(ts0)
  call phase_stream(n, s_stream)
  call cpu_time(ts1)

  call cpu_time(tb0)
  call phase_branch(n, s_branch)
  call cpu_time(tb1)

  call cpu_time(tl0)
  call phase_light(n, s_light)
  call cpu_time(tl1)
  call cpu_time(t1)
  print *, 'checksum_heavy=', s_heavy, ' checksum_stream=', s_stream, &
           ' checksum_branch=', s_branch, ' checksum_light=', s_light, &
           ' time_s=', t1 - t0
  print *, 'phase_time_heavy_s=', th1 - th0, ' phase_time_stream_s=', ts1 - ts0, &
           ' phase_time_branch_s=', tb1 - tb0, ' phase_time_light_s=', tl1 - tl0
end program kernel_profile
