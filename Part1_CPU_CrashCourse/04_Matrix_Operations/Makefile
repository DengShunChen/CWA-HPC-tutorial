# Makefile for Matrix Operations Example（Fortran：FX1000 用 frt；登入節點可用 frtpx）

ifneq ($(shell which frt 2>/dev/null),)
FC = frt
else ifneq ($(shell which frtpx 2>/dev/null),)
FC = frtpx
else
$(error 未找到 frt / frtpx。請先 module load TCS 環境。)
endif

ifeq ($(shell which FCC 2>/dev/null),)
CXX = g++
CXXFLAGS_BASIC = -O2 -Wall -std=c++11
CXXFLAGS_OPT = -O3 -march=native -funroll-loops -std=c++11
else
CXX = FCC
CXXFLAGS_BASIC = -Kfast -std=c++11
CXXFLAGS_OPT = -Kfast -KSVE -Koptmsg=2 -std=c++11
endif

FFLAGS_BASIC = -Kfast
FFLAGS_OPT = -Kfast -KSVE -Koptmsg=2

# 目標執行檔
TARGETS = matrix_multiply_fortran \
          matrix_multiply_cpp \
          matrix_multiply_optimized_fortran \
          matrix_multiply_optimized_cpp

# 預設目標：編譯所有程式（FX1000 上請以 PJM 提交：pjsub job_matrix.sh）
all: $(TARGETS)
	@echo "✓ 全部編譯完成。於叢集上可 pjsub job_matrix.sh（請先修改腳本內群組）。"

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
