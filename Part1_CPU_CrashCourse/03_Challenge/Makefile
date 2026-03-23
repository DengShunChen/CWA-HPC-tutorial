# Makefile for 03_Challenge - 向量乘法練習題（Fortran：FX1000 用 frt；登入節點可用 frtpx）

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

.PHONY: all clean fortran cpp

all: fortran cpp
	@echo "✓ 編譯完成。本機可執行 ./multiply_fortran、./multiply_cpp；叢集上可用 PJM 提交批次工作。"

fortran: multiply_fortran
	@echo "Fortran 練習題已編譯"

cpp: multiply_cpp
	@echo "C++ 練習題已編譯"

multiply_fortran: multiply.f90
	$(FC) $(FFLAGS) multiply.f90 -o multiply_fortran

multiply_cpp: multiply.cpp
	$(CXX) $(CXXFLAGS) multiply.cpp -o multiply_cpp

clean:
	rm -f multiply_fortran multiply_cpp *.o *.mod
