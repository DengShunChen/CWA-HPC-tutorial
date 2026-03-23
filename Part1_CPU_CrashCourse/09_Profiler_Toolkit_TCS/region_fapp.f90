! region_fapp.f90 — 使用 fapp_start / fapp_stop 以「名稱 + 詳細編號 + 量測級別」
! 標示兩個獨立量測區域（APP / Advanced Performance Profiler）。
! 建置：make region_fapp（需 frt / frtpx 與 -Nfjprof）
!
! 介面：fapp_start(name, number, level) / fapp_stop(name, number, level)
!   name   ─ 字元字串，自訂區域識別名（建置時展成 "name+number" 顯示於報告）
!   number ─ 整數，同一 name 下的流水號（報告中顯示為 "name1"、"name2" 等）
!   level  ─ 整數，量測深度；執行時 fapp -L N 僅啟用 level ≤ N 的區域
!
! 執行（計算節點）：
!   fapp -C -d ./tmp_fapp -L 1 ./region_fapp    （僅外層 level=0 → level ≤ 1 均啟用）
!   fapp -C -d ./tmp_fapp -L 0 ./region_fapp    （僅 level=0 的區域啟用）

program region_fapp
  use kernel_phases
  implicit none
  integer(ik) :: n
  real(8)     :: s1, s2

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

  call resolve_kernel_profile_n(n)

  ! --- 外層區域：涵蓋整個計算（level=0）---
  call fapp_start("main_region", 1, 0)

    ! --- 子區域 A：phase_heavy（level=1）---
    call fapp_start("heavy", 1, 1)
    call phase_heavy(n, s1)
    call fapp_stop("heavy", 1, 1)

    ! --- 子區域 B：phase_light（level=1）---
    call fapp_start("light", 1, 1)
    call phase_light(n, s2)
    call fapp_stop("light", 1, 1)

  call fapp_stop("main_region", 1, 0)

  ! I/O 留在量測區域外（示範「排除 print 開銷」之最佳實務）
  print *, 'checksum_heavy=', s1, ' checksum_light=', s2
end program region_fapp
