# Makefile for Hello World examples (Fujitsu A64FX)

FC = frtpx
CXX = FCC

FFLAGS = -Kfast
CXXFLAGS = -Kfast -std=c++11

.PHONY: all clean fortran cpp

all: fortran cpp
	@echo "✓ 編譯完成。請使用 PJM 提交執行。"

fortran: hello_fortran
	@echo "Fortran 程式已編譯"

cpp: hello_cpp
	@echo "C++ 程式已編譯"

hello_fortran: hello.f90
	$(FC) $(FFLAGS) hello.f90 -o hello_fortran

hello_cpp: hello.cpp
	$(CXX) $(CXXFLAGS) hello.cpp -o hello_cpp

clean:
	rm -f hello_fortran hello_cpp *.o *.mod
