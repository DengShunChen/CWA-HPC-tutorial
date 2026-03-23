! region_fapp_mpi_f90.f90 — MPI Fortran（單檔版）
! 僅在 rank 0 呼叫 fapp_start / fapp_stop，其他進程不進入量測區。
! 建置：make region_fapp_mpi_f90（需 mpifrt / mpifrtpx 與 -Nfjprof）
!
! 重點：對沒有呼叫量測常式的進程，系統不會收集其資料。
! 若需量測所有 rank：讓各 rank 均執行到 fapp_start / fapp_stop。

program region_fapp_mpi_f90
  use mpi
  implicit none

  integer, parameter :: dp = kind(1.0d0)
  integer :: ierr, rank, nprocs
  integer(kind=8) :: n
  real(dp) :: s1, s2

  interface
    subroutine fapp_start(name, number, level)
      character(*), intent(in) :: name
      integer,      intent(in) :: number, level
    end subroutine fapp_start
    subroutine fapp_stop(name, number, level)
      character(*), intent(in) :: name
      integer,      intent(in) :: number, level
    end subroutine fapp_stop
  end interface

  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nprocs, ierr)

  call resolve_n(n)

  if (rank == 0) then
    ! --- 僅量測 rank 0 ---
    call fapp_start("mpi_outer", 1, 0)

      call fapp_start("mpi_heavy", 1, 1)
      call heavy_kernel(n, s1)
      call fapp_stop("mpi_heavy", 1, 1)

      call fapp_start("mpi_light", 1, 1)
      call light_kernel(n, s2)
      call fapp_stop("mpi_light", 1, 1)

    call fapp_stop("mpi_outer", 1, 0)

    write(*, '(A,F20.10,A,F20.10,A,I0)') &
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
    integer(kind=8), intent(in)  :: nn
    real(dp),        intent(out) :: s
    integer(kind=8) :: i
    real(dp) :: x
    s = 0.0_dp
    do i = 1_8, nn
      x = dble(i) * 1.0d-7
      s = s + x * x / (1.0d0 + x)
    end do
  end subroutine heavy_kernel

  subroutine light_kernel(nn, s)
    integer(kind=8), intent(in)  :: nn
    real(dp),        intent(out) :: s
    integer(kind=8) :: i
    s = 0.0_dp
    do i = 1_8, nn
      s = s + dble(i) * 1.0d-8
    end do
  end subroutine light_kernel

end program region_fapp_mpi_f90
