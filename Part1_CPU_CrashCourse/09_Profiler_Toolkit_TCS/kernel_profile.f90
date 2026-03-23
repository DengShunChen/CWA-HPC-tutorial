! 整程式量測用進入點（無 fipp 區段標記）；模組見 kernel_phases.f90
program kernel_profile
  use kernel_phases
  implicit none
  integer(ik) :: n
  real(8) :: s1, s2, t0, t1

  call resolve_kernel_profile_n(n)
  call cpu_time(t0)
  call phase_heavy(n, s1)
  call phase_light(n, s2)
  call cpu_time(t1)
  print *, 'checksum_heavy=', s1, ' checksum_light=', s2, ' time_s=', t1 - t0
end program kernel_profile
