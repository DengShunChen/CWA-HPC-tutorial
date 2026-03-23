program loop_optimized
  implicit none
  integer, parameter :: dp = kind(1.0d0)
  integer, parameter :: n_default = 1200
  integer, parameter :: reps_default = 18
  integer :: n, reps
  integer :: i, j, it
  real(dp), allocatable :: a(:,:), b(:,:), c(:,:)
  real(dp) :: t0, t1, checksum
  logical, allocatable :: mask(:,:)

  call resolve_inputs(n, reps)
  allocate(a(n,n), b(n,n), c(n,n), mask(n,n))

  do j = 1, n
    do i = 1, n
      a(i,j) = dble(mod(i * 13 + j * 17, 997)) * 1.0d-4
      b(i,j) = dble(mod(i * 19 + j * 23, 991)) * 1.0d-4
      c(i,j) = 0.0d0
      mask(i,j) = .false.
    end do
  end do

  call cpu_time(t0)

  do it = 1, reps
    ! Optimized-1: 預先建 mask，避免核心更新迴圈內分支
    do j = 2, n - 1
      do i = 2, n - 1
        mask(i,j) = (mod(i + j + it, 7) <= 2)
      end do
    end do

    ! Optimized-2: Fortran 友善走訪（i 內層）+ 分支拆分
    do j = 2, n - 1
      do i = 2, n - 1
        if (mask(i,j)) then
          c(i,j) = 0.55d0 * a(i,j) + 0.30d0 * b(i,j-1) + 0.15d0 * a(i,j+1)
        else
          c(i,j) = 0.65d0 * b(i,j) + 0.20d0 * a(i-1,j) + 0.15d0 * b(i+1,j)
        end if
      end do
    end do

    do j = 2, n - 1
      do i = 2, n - 1
        a(i,j) = a(i,j) + 2.0d-3 * c(i,j)
        b(i,j) = b(i,j) - 1.5d-3 * c(i,j)
      end do
    end do
  end do

  call cpu_time(t1)

  checksum = 0.0d0
  do j = 1, n, 7
    do i = 1, n, 7
      checksum = checksum + a(i,j) + b(i,j) + c(i,j)
    end do
  end do

  print '(A,I0,A,I0)', 'n=', n, ' reps=', reps
  print '(A,F20.10,A,F12.6)', 'checksum=', checksum, ' time_s=', t1 - t0

  deallocate(a, b, c, mask)

contains

  subroutine resolve_inputs(out_n, out_reps)
    integer, intent(out) :: out_n, out_reps
    character(len=64) :: env
    integer :: ios, stat

    out_n = n_default
    out_reps = reps_default

    call get_environment_variable('LOOP_DEMO_N', env, status=stat)
    if (stat == 0) then
      read(env, *, iostat=ios) out_n
      if (ios /= 0 .or. out_n < 200) out_n = n_default
    end if

    call get_environment_variable('LOOP_DEMO_REPS', env, status=stat)
    if (stat == 0) then
      read(env, *, iostat=ios) out_reps
      if (ios /= 0 .or. out_reps < 1) out_reps = reps_default
    end if
  end subroutine resolve_inputs

end program loop_optimized
