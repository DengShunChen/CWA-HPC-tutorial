# Makefile for 03_Challenge - 向量乘法練習題 (Fujitsu A64FX)

FC = frtpx
CXX = FCC

FFLAGS = -Kfast
CXXFLAGS = -Kfast -std=c++11

.PHONY: all clean fortran cpp

all: fortran cpp
	@echo "✓ 編譯完成。請完成程式碼實作後，使用 PJM 提交執行。"

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
