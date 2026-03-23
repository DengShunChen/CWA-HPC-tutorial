# Makefile for Structures Example（Fortran：FX1000 用 frt；登入節點可用 frtpx）

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
TARGETS = particle_fortran particle_cpp

# 預設目標：編譯所有程式
all: $(TARGETS)

# Fortran 版本
particle_fortran: particle_simulation.f90
	$(FC) $(FFLAGS) $< -o $@
	@echo "✓ 編譯完成: $@"

# C++ 版本
particle_cpp: particle_simulation.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo "✓ 編譯完成: $@"

# 執行所有程式
run_all: all
	@echo ""
	@echo "========================================"
	@echo "  執行粒子模擬"
	@echo "========================================"
	@echo ""
	@echo "--- Fortran 版本 ---"
	@./particle_fortran
	@echo ""
	@echo "--- C++ 版本 ---"
	@./particle_cpp

# 清除執行檔
clean:
	rm -f $(TARGETS)
	@echo "✓ 清除完成"

.PHONY: all run_all clean
