# Makefile for Functions/Modules Example

# 編譯器設定
FC = gfortran
CXX = g++

# 編譯選項
FFLAGS = -O2 -Wall
CXXFLAGS = -O2 -Wall -std=c++11

# 目標執行檔
TARGETS = main_fortran main_cpp

# 預設目標：編譯所有程式
all: $(TARGETS)

# Fortran 版本（需要先編譯模組）
math_module.mod: math_module.f90
	$(FC) $(FFLAGS) -c $<
	@echo "✓ 模組編譯完成: math_module"

main_fortran: main_program.f90 math_module.mod
	$(FC) $(FFLAGS) math_module.o main_program.f90 -o $@
	@echo "✓ 編譯完成: $@"

# C++ 版本（需要先編譯函數庫）
math_functions.o: math_functions.cpp math_functions.h
	$(CXX) $(CXXFLAGS) -c math_functions.cpp
	@echo "✓ 函數庫編譯完成: math_functions.o"

main_cpp: main_program.cpp math_functions.o
	$(CXX) $(CXXFLAGS) main_program.cpp math_functions.o -o $@
	@echo "✓ 編譯完成: $@"

# 執行所有程式
run_all: all
	@echo ""
	@echo "========================================"
	@echo "  執行 Functions/Modules 範例"
	@echo "========================================"
	@echo ""
	@echo "--- Fortran 版本 ---"
	@./main_fortran
	@echo ""
	@echo "--- C++ 版本 ---"
	@./main_cpp

# 清除執行檔和中間檔
clean:
	rm -f $(TARGETS)
	rm -f *.o *.mod
	@echo "✓ 清除完成"

.PHONY: all run_all clean
