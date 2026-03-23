! MPI Fortran：僅在 rank 0 呼叫 fipp_start / fipp_stop（其他進程不進入量測區）。
! 建置：make region_mpi（需 mpifrt 與 MPI 環境）
program region_mpi
  use mpi
  use kernel_phases
  implicit none
  integer :: ierr, rank, nprocs
  integer(ik) :: n
  real(8) :: s1, s2

  interface
    subroutine fipp_start
    end subroutine fipp_start
    subroutine fipp_stop
    end subroutine fipp_stop
  end interface

  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nprocs, ierr)

  call resolve_kernel_profile_n(n)

  if (rank == 0) then
    call fipp_start
    call phase_heavy(n, s1)
    call phase_light(n, s2)
    call fipp_stop
    print *, 'rank 0 checksum_heavy=', s1, ' checksum_light=', s2, ' nprocs=', nprocs
  end if

  call MPI_Barrier(MPI_COMM_WORLD, ierr)
  call MPI_Finalize(ierr)
end program region_mpi
