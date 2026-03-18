# Makefile for Matrix Operations Example
# 使用方法：make all 編譯所有程式

# 編譯器設定
FC = gfortran
CXX = g++

# 編譯選項
FFLAGS_BASIC = -O2 -Wall
FFLAGS_OPT = -O3 -march=native -funroll-loops
CXXFLAGS_BASIC = -O2 -Wall -std=c++11
CXXFLAGS_OPT = -O3 -march=native -funroll-loops -std=c++11

# 目標執行檔
TARGETS = matrix_multiply_fortran \
          matrix_multiply_cpp \
          matrix_multiply_optimized_fortran \
          matrix_multiply_optimized_cpp

# 預設目標：編譯所有程式
all: $(TARGETS)

# Fortran 基礎版本
matrix_multiply_fortran: matrix_multiply.f90
	$(FC) $(FFLAGS_BASIC) $< -o $@
	@echo "✓ 編譯完成: $@"

# C++ 基礎版本
matrix_multiply_cpp: matrix_multiply.cpp
	$(CXX) $(CXXFLAGS_BASIC) $< -o $@
	@echo "✓ 編譯完成: $@"

# Fortran 優化版本
matrix_multiply_optimized_fortran: matrix_multiply_optimized.f90
	$(FC) $(FFLAGS_OPT) $< -o $@
	@echo "✓ 編譯完成: $@ (優化版)"

# C++ 優化版本
matrix_multiply_optimized_cpp: matrix_multiply_optimized.cpp
	$(CXX) $(CXXFLAGS_OPT) $< -o $@
	@echo "✓ 編譯完成: $@ (優化版)"

# 執行所有程式並比較效能
run_all: all
	@echo ""
	@echo "========================================"
	@echo "  效能測試：基礎版 vs 優化版"
	@echo "========================================"
	@echo ""
	@echo "--- Fortran 基礎版本 ---"
	@./matrix_multiply_fortran
	@echo "--- Fortran 優化版本 ---"
	@./matrix_multiply_optimized_fortran
	@echo "--- C++ 基礎版本 ---"
	@./matrix_multiply_cpp
	@echo "--- C++ 優化版本 ---"
	@./matrix_multiply_optimized_cpp

# 清除執行檔
clean:
	rm -f $(TARGETS)
	@echo "✓ 清除完成"

.PHONY: all run_all clean
