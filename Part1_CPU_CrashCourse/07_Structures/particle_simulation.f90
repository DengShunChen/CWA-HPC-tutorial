! 粒子模擬 - Fortran Derived Types 範例
! 使用自訂資料型態組織複雜資料

program particle_simulation
  implicit none
  
  ! 定義粒子資料型態（Derived Type）
  type :: Particle
    integer :: id                 ! 粒子編號
    real(8) :: mass              ! 質量
    real(8) :: position(3)       ! 位置 (x, y, z)
    real(8) :: velocity(3)       ! 速度 (vx, vy, vz)
    real(8) :: force(3)          ! 受力 (fx, fy, fz)
    logical :: is_active         ! 是否活躍
  end type Particle
  
  ! 變數宣告
  integer, parameter :: n_particles = 10
  type(Particle), allocatable :: particles(:)
  integer :: i
  real(8) :: dt, total_energy
  
  print *, "========================================="
  print *, "  Fortran Derived Types 範例"
  print *, "  粒子模擬系統"
  print *, "========================================="
  print *
  
  ! 配置粒子陣列
  allocate(particles(n_particles))
  
  ! 初始化粒子
  print *, "初始化", n_particles, "個粒子..."
  do i = 1, n_particles
    particles(i)%id = i
    particles(i)%mass = 1.0d0 + real(i, 8) * 0.1d0
    
    ! 隨機位置
    particles(i)%position(1) = real(i, 8) * 0.5d0
    particles(i)%position(2) = real(i, 8) * 0.3d0
    particles(i)%position(3) = real(i, 8) * 0.2d0
    
    ! 初始速度
    particles(i)%velocity(1) = sin(real(i, 8)) * 2.0d0
    particles(i)%velocity(2) = cos(real(i, 8)) * 2.0d0
    particles(i)%velocity(3) = 0.0d0
    
    ! 初始受力為零
    particles(i)%force = 0.0d0
    
    ! 所有粒子都活躍
    particles(i)%is_active = .true.
  end do
  print *, "✓ 初始化完成"
  print *
  
  ! 顯示前 5 個粒子的資訊
  print *, "前 5 個粒子的初始狀態："
  print *, "-------------------------------------------"
  do i = 1, 5
    call print_particle(particles(i))
  end do
  print *
  
  ! 簡單的時間步進模擬
  dt = 0.01d0
  print *, "執行 100 個時間步進 (dt =", dt, ")..."
  do i = 1, 100
    call update_particles(particles, n_particles, dt)
  end do
  print *, "✓ 模擬完成"
  print *
  
  ! 顯示模擬後的狀態
  print *, "粒子 #1 模擬後的狀態："
  print *, "-------------------------------------------"
  call print_particle(particles(1))
  print *
  
  ! 計算系統總能量
  total_energy = compute_total_energy(particles, n_particles)
  write(*, '(A, F12.4)') "系統總能量: ", total_energy
  print *
  
  ! 釋放記憶體
  deallocate(particles)
  
  print *, "========================================="
  print *, "  模擬完成"
  print *, "========================================="
  
contains

  ! 印出粒子資訊
  subroutine print_particle(p)
    type(Particle), intent(in) :: p
    
    write(*, '(A, I3)') "粒子 ID:    ", p%id
    write(*, '(A, F8.4)') "質量:       ", p%mass
    write(*, '(A, 3F10.4)') "位置:       ", p%position
    write(*, '(A, 3F10.4)') "速度:       ", p%velocity
    write(*, '(A, L2)') "活躍狀態:   ", p%is_active
    print *
  end subroutine print_particle
  
  ! 更新粒子狀態
  subroutine update_particles(particles, n, dt)
    type(Particle), intent(inout) :: particles(:)
    integer, intent(in) :: n
    real(8), intent(in) :: dt
    integer :: i
    
    do i = 1, n
      if (particles(i)%is_active) then
        ! 簡單的重力場
        particles(i)%force(3) = -9.8d0 * particles(i)%mass
        
        ! 更新速度 (v = v + a*dt)
        particles(i)%velocity = particles(i)%velocity + &
                                (particles(i)%force / particles(i)%mass) * dt
        
        ! 更新位置 (x = x + v*dt)
        particles(i)%position = particles(i)%position + &
                                particles(i)%velocity * dt
        
        ! 簡單的邊界條件
        if (particles(i)%position(3) < 0.0d0) then
          particles(i)%position(3) = 0.0d0
          particles(i)%velocity(3) = -particles(i)%velocity(3) * 0.8d0  ! 反彈
        end if
      end if
    end do
  end subroutine update_particles
  
  ! 計算系統總能量
  function compute_total_energy(particles, n) result(energy)
    type(Particle), intent(in) :: particles(:)
    integer, intent(in) :: n
    real(8) :: energy
    integer :: i
    real(8) :: ke, pe, v_squared
    
    energy = 0.0d0
    do i = 1, n
      if (particles(i)%is_active) then
        ! 動能 = 0.5 * m * v^2
        v_squared = dot_product(particles(i)%velocity, particles(i)%velocity)
        ke = 0.5d0 * particles(i)%mass * v_squared
        
        ! 位能 = m * g * h
        pe = particles(i)%mass * 9.8d0 * particles(i)%position(3)
        
        energy = energy + ke + pe
      end if
    end do
  end function compute_total_energy

end program particle_simulation
