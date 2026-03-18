// 粒子模擬 - C++ Struct/Class 範例
// 使用自訂資料結構組織複雜資料

#include <iostream>
#include <iomanip>
#include <vector>
#include <cmath>

// 定義粒子結構 (struct)
struct Particle {
  int id;                    // 粒子編號
  double mass;               // 質量
  double position[3];        // 位置 (x, y, z)
  double velocity[3];        // 速度 (vx, vy, vz)
  double force[3];           // 受力 (fx, fy, fz)
  bool is_active;            // 是否活躍
  
  // 建構子（初始化）
  Particle(int id_val = 0, double mass_val = 1.0) 
    : id(id_val), mass(mass_val), is_active(true) {
    for (int i = 0; i < 3; i++) {
      position[i] = 0.0;
      velocity[i] = 0.0;
      force[i] = 0.0;
    }
  }
  
  // 成員函數：印出粒子資訊
  void print() const {
    std::cout << "粒子 ID:    " << id << std::endl;
    std::cout << "質量:       " << std::fixed << std::setprecision(4) 
              << mass << std::endl;
    std::cout << "位置:       " 
              << std::setw(10) << position[0] << " "
              << std::setw(10) << position[1] << " "
              << std::setw(10) << position[2] << std::endl;
    std::cout << "速度:       " 
              << std::setw(10) << velocity[0] << " "
              << std::setw(10) << velocity[1] << " "
              << std::setw(10) << velocity[2] << std::endl;
    std::cout << "活躍狀態:   " << (is_active ? "是" : "否") << std::endl;
    std::cout << std::endl;
  }
  
  // 成員函數：更新粒子狀態
  void update(double dt) {
    if (!is_active) return;
    
    // 簡單的重力場
    force[2] = -9.8 * mass;
    
    // 更新速度 (v = v + a*dt)
    for (int i = 0; i < 3; i++) {
      velocity[i] += (force[i] / mass) * dt;
    }
    
    // 更新位置 (x = x + v*dt)
    for (int i = 0; i < 3; i++) {
      position[i] += velocity[i] * dt;
    }
    
    // 簡單的邊界條件（地板反彈）
    if (position[2] < 0.0) {
      position[2] = 0.0;
      velocity[2] = -velocity[2] * 0.8;  // 反彈且損失能量
    }
  }
  
  // 成員函數：計算動能
  double kinetic_energy() const {
    double v_squared = velocity[0] * velocity[0] +
                       velocity[1] * velocity[1] +
                       velocity[2] * velocity[2];
    return 0.5 * mass * v_squared;
  }
  
  // 成員函數：計算位能
  double potential_energy() const {
    return mass * 9.8 * position[2];
  }
};

// 計算系統總能量
double compute_total_energy(const std::vector<Particle>& particles) {
  double total = 0.0;
  for (const auto& p : particles) {
    if (p.is_active) {
      total += p.kinetic_energy() + p.potential_energy();
    }
  }
  return total;
}

int main() {
  std::cout << "=========================================" << std::endl;
  std::cout << "  C++ Struct/Class 範例" << std::endl;
  std::cout << "  粒子模擬系統" << std::endl;
  std::cout << "=========================================" << std::endl;
  std::cout << std::endl;
  
  // 建立粒子陣列
  const int n_particles = 10;
  std::vector<Particle> particles;
  
  // 初始化粒子
  std::cout << "初始化 " << n_particles << " 個粒子..." << std::endl;
  for (int i = 0; i < n_particles; i++) {
    Particle p(i+1, 1.0 + i * 0.1);
    
    // 設定初始位置
    p.position[0] = i * 0.5;
    p.position[1] = i * 0.3;
    p.position[2] = i * 0.2;
    
    // 設定初始速度
    p.velocity[0] = std::sin(static_cast<double>(i)) * 2.0;
    p.velocity[1] = std::cos(static_cast<double>(i)) * 2.0;
    p.velocity[2] = 0.0;
    
    particles.push_back(p);
  }
  std::cout << "✓ 初始化完成" << std::endl;
  std::cout << std::endl;
  
  // 顯示前 5 個粒子的資訊
  std::cout << "前 5 個粒子的初始狀態：" << std::endl;
  std::cout << "-------------------------------------------" << std::endl;
  for (int i = 0; i < 5; i++) {
    particles[i].print();
  }
  
  // 簡單的時間步進模擬
  double dt = 0.01;
  std::cout << "執行 100 個時間步進 (dt = " << dt << ")..." << std::endl;
  for (int step = 0; step < 100; step++) {
    for (auto& p : particles) {
      p.update(dt);
    }
  }
  std::cout << "✓ 模擬完成" << std::endl;
  std::cout << std::endl;
  
  // 顯示模擬後的狀態
  std::cout << "粒子 #1 模擬後的狀態：" << std::endl;
  std::cout << "-------------------------------------------" << std::endl;
  particles[0].print();
  
  // 計算系統總能量
  double total_energy = compute_total_energy(particles);
  std::cout << "系統總能量: " << std::fixed << std::setprecision(4) 
            << total_energy << std::endl;
  std::cout << std::endl;
  
  std::cout << "=========================================" << std::endl;
  std::cout << "  模擬完成" << std::endl;
  std::cout << "=========================================" << std::endl;
  
  return 0;
}
