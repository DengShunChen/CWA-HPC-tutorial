# Makefile for Hello World examples（Fortran：FX1000 用 frt；登入節點可用 frtpx）

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
