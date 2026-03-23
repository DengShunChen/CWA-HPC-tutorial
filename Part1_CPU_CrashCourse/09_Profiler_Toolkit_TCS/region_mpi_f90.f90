! MPI Fortran（單檔版）：僅在 rank 0 呼叫 fipp_start / fipp_stop。
! 建置：make region_mpi_f90（需 mpifrt 或 mpifrtpx）
program region_mpi_f90
  use mpi
  implicit none

  integer, parameter :: dp = kind(1.0d0)
  integer :: ierr, rank, nprocs
  integer(kind=8) :: n
  real(dp) :: s1, s2

  interface
    subroutine fipp_start
    end subroutine fipp_start
    subroutine fipp_stop
    end subroutine fipp_stop
  end interface

  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nprocs, ierr)

  call resolve_n(n)

  if (rank == 0) then
    call fipp_start
    call heavy_kernel(n, s1)
    call light_kernel(n, s2)
    call fipp_stop
    write(*,'(A,F20.10,A,F20.10,A,I0)') &
      'rank 0 checksum_heavy=', s1, ' checksum_light=', s2, ' nprocs=', nprocs
  end if

  call MPI_Barrier(MPI_COMM_WORLD, ierr)
  call MPI_Finalize(ierr)

contains

  subroutine resolve_n(out_n)
    integer(kind=8), intent(out) :: out_n
    character(len=64) :: env
    integer :: status
    out_n = 5000000_8
    call get_environment_variable('KERNEL_PROFILE_N', env, status=status)
    if (status == 0) then
      read(env, *, iostat=status) out_n
      if (status /= 0 .or. out_n <= 0_8) out_n = 5000000_8
    end if
  end subroutine resolve_n

  subroutine heavy_kernel(nn, s)
    integer(kind=8), intent(in) :: nn
    real(dp), intent(out) :: s
    integer(kind=8) :: i
    real(dp) :: x
    s = 0.0_dp
    do i = 1_8, nn
      x = dble(i) * 1.0d-7
      s = s + x * x / (1.0d0 + x)
    end do
  end subroutine heavy_kernel

  subroutine light_kernel(nn, s)
    integer(kind=8), intent(in) :: nn
    real(dp), intent(out) :: s
    integer(kind=8) :: i
    s = 0.0_dp
    do i = 1_8, nn
      s = s + dble(i) * 1.0d-8
    end do
  end subroutine light_kernel

end program region_mpi_f90
