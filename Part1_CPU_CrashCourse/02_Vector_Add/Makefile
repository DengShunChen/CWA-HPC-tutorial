# Makefile for Vector Addition Examples (Fujitsu A64FX)

# 編譯器設定
FC = frtpx        # Fujitsu Fortran 編譯器
CXX = FCC         # Fujitsu C++ 編譯器

# 基礎版本：使用 -Kfast
FFLAGS_BASIC = -Kfast
CXXFLAGS_BASIC = -Kfast -std=c++11

# 優化版本：使用 -Kfast + ARM SVE 向量化
FFLAGS_OPT = -Kfast -KSVE -Koptmsg=2
CXXFLAGS_OPT = -Kfast -KSVE -Koptmsg=2 -std=c++11

.PHONY: all clean run_all fortran cpp optimized

all: vec_add_fortran vec_add_cpp vec_add_optimized_fortran vec_add_optimized_cpp
	@echo "✓ 所有程式編譯完成"
	@echo "請使用 'pjsub job_script.sh' 提交到 FX1000 執行"

# 基礎版本
vec_add_fortran: vec_add.f90
	$(FC) $(FFLAGS_BASIC) vec_add.f90 -o vec_add_fortran

vec_add_cpp: vec_add.cpp
	$(CXX) $(CXXFLAGS_BASIC) vec_add.cpp -o vec_add_cpp

# 優化版本
vec_add_optimized_fortran: vec_add_optimized.f90
	$(FC) $(FFLAGS_OPT) vec_add_optimized.f90 -o vec_add_optimized_fortran

vec_add_optimized_cpp: vec_add_optimized.cpp
	$(CXX) $(CXXFLAGS_OPT) vec_add_optimized.cpp -o vec_add_optimized_cpp

# 執行所有程式並比較效能（需透過 PJM 提交）
run_all: all
	@echo "========================================="
	@echo "  ⚠️  請使用 PJM 批次系統執行程式"
	@echo "========================================="
	@echo "範例："
	@echo "  pjsub job_vec_add.sh"
	@echo ""
	@echo "或建立 job_vec_add.sh 包含："
	@echo "  #!/bin/bash"
	@echo "  #PJM -L \"rscgrp=small\""
	@echo "  #PJM -L \"node=1\""
	@echo "  #PJM -L \"elapse=00:10:00\""
	@echo "  #PJM -g <your_group>"
	@echo "  module load lang/tcsds-1.2.37"
	@echo "  ./vec_add_fortran"
	@echo "  ./vec_add_optimized_fortran"

clean:
	rm -f vec_add_fortran vec_add_cpp vec_add_optimized_fortran vec_add_optimized_cpp *.o *.mod
