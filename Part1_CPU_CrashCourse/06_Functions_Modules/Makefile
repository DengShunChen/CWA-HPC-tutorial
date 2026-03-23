# Makefile for Functions/Modules Example（Fortran：FX1000 用 frt；登入節點可用 frtpx）

ifneq ($(shell which frt 2>/dev/null),)
FC = frt
else ifneq ($(shell which frtpx 2>/dev/null),)
FC = frtpx
else
$(error 未找到 frt / frtpx。請先 module load TCS 環境。)
endif
FFLAGS = -Kfast

ifeq ($(shell which FCC 2>/dev/null),)
CXX = g++
CXXFLAGS = -O2 -Wall -std=c++11
else
CXX = FCC
CXXFLAGS = -Kfast -std=c++11
endif

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
