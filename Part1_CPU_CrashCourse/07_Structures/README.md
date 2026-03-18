# 07_Structures - 資料結構

> 學習自訂資料型態來組織複雜資料

---

## 🎯 學習目標

1. 理解 Fortran 的 Derived Types
2. 學習 C++ 的 Struct 和 Class
3. 掌握結構化資料的記憶體佈局
4. 理解物件導向程式設計的基礎

---

## 📝 檔案說明

| 檔案 | 說明 |
|------|------|
| `particle_simulation.f90` | Fortran 粒子模擬（使用 Derived Types） |
| `particle_simulation.cpp` | C++ 粒子模擬（使用 Struct/Class） |

---

## 🚀 快速開始

```bash
# 編譯程式
make all

# 執行程式
make run_all

# 清除執行檔
make clean
```

---

## 💻 Fortran Derived Types

### 定義結構

```fortran
type :: Particle
  integer :: id
  real(8) :: mass
  real(8) :: position(3)
  real(8) :: velocity(3)
end type Particle
```

### 使用結構

```fortran
! 宣告變數
type(Particle) :: p1
type(Particle), allocatable :: particles(:)

! 初始化
p1%id = 1
p1%mass = 1.5d0
p1%position = [0.0d0, 0.0d0, 0.0d0]

! 陣列配置
allocate(particles(100))
particles(1)%id = 1
```

### 帶建構子的型態

```fortran
type :: Point
  real(8) :: x, y, z
contains
  procedure :: distance => point_distance
end type Point

! 成員函數
function point_distance(this, other) result(dist)
  class(Point), intent(in) :: this, other
  real(8) :: dist
  dist = sqrt((this%x - other%x)**2 + &
              (this%y - other%y)**2 + &
              (this%z - other%z)**2)
end function point_distance
```

---

## 💻 C++ Struct 和 Class

### Struct（簡單資料容器）

```cpp
struct Particle {
  int id;
  double mass;
  double position[3];
  double velocity[3];
};

// 使用
Particle p1;
p1.id = 1;
p1.mass = 1.5;
```

### Class（帶成員函數）

```cpp
class Particle {
public:
  // 建構子
  Particle(int id_val, double mass_val) 
    : id(id_val), mass(mass_val) {}
  
  // 成員函數
  double kinetic_energy() const {
    return 0.5 * mass * v_squared;
  }
  
private:
  int id;
  double mass;
  double position[3];
};

// 使用
Particle p1(1, 1.5);
double ke = p1.kinetic_energy();
```

---

## 🔍 重要概念

### 1. 記憶體佈局

**結構在記憶體中是連續的**：

```
Particle 結構:
┌─────────┬─────────┬──────────────┬──────────────┐
│   id    │  mass   │ position[3]  │ velocity[3]  │
│ 4 bytes │ 8 bytes │   24 bytes   │   24 bytes   │
└─────────┴─────────┴──────────────┴──────────────┘

總大小: ~60 bytes (可能因 padding 而略有不同)
```

### 2. AoS vs SoA

**Array of Structures (AoS)**：
```cpp
struct Particle {
  double x, y, z;
  double vx, vy, vz;
};
Particle particles[1000];  // 常見做法
```

**Structure of Arrays (SoA)**：
```cpp
struct Particles {
  double x[1000];
  double y[1000];
  double z[1000];
  double vx[1000];
  double vy[1000];
  double vz[1000];
};  // 對 SIMD 更友善
```

### 3. Padding 和對齊

編譯器可能插入 padding 以對齊記憶體：

```cpp
struct Example1 {
  char a;      // 1 byte
  int b;       // 4 bytes
  char c;      // 1 byte
};  // 實際大小可能是 12 bytes（不是 6）

struct Example2 {
  char a;      // 1 byte
  char c;      // 1 byte
  int b;       // 4 bytes
};  // 實際大小: 8 bytes（更緊湊）
```

---

## ⚡ 效能考量

### 1. Cache 友善性

```fortran
! ❌ 不良：跳躍存取
do i = 1, n
  result = result + particles(i)%mass
end do

! ✅ 較好：考慮使用 SoA
! 可以連續存取所有質量值
```

### 2. 小型結構 vs 大型結構

```cpp
// ✅ 好：小型結構可以直接傳值
struct Vec3 {
  double x, y, z;
};
Vec3 add(Vec3 a, Vec3 b) { ... }  // 傳值 OK

// ❌ 不好：大型結構應該傳引用
struct BigData {
  double data[10000];
};
void process(const BigData& data) { ... }  // 傳引用
```

---

## 📚 Struct vs Class (C++)

| 特性 | Struct | Class |
|------|--------|-------|
| 預設存取權限 | `public` | `private` |
| 常用場景 | 純資料容器 | 帶邏輯的物件 |
| 成員函數 | 可以有 | 可以有 |

**慣例**：
- 如果只是儲存資料 → 用 `struct`
- 如果有複雜邏輯 → 用 `class`

---

## ✅ 實驗練習

1. **基礎練習**：執行範例程式，觀察粒子模擬
2. **修改練習**：新增一個 `color` 欄位到 Particle 結構
3. **進階練習**：修改為 SoA 佈局，測量效能差異

---

## 🔧 常見錯誤

### Fortran

```fortran
! ❌ 錯誤：忘記百分號
particles(1).mass = 1.0d0  ! 錯誤語法

! ✅ 正確
particles(1)%mass = 1.0d0
```

### C++

```cpp
// ❌ 錯誤：忘記初始化
Particle p;  // 成員值未定義！

// ✅ 正確：使用建構子
Particle p(1, 1.0);
```

---

## 📖 延伸閱讀

- [資料導向設計 (Data-Oriented Design)](https://www.dataorienteddesign.com/dodbook/)
- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/)

---

**恭喜！您已完成 Part1_CPU_CrashCourse 的所有範例 🎉**

**下一步：進入 [Part2_GPU_CUDA](../../Part2_GPU_CUDA/) 學習 GPU 程式設計 🚀**
