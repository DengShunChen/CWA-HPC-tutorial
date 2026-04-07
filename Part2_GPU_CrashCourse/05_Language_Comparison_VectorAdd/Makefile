# 五語言向量加法對照：CPU（C / C++ / Fortran）+ GPU（CUDA C / CUDA Fortran）
# CUDA 目標僅在偵測到 nvcc / nvfortran 時建置（登入節點無 GPU 時仍可 make CPU 三支）

NVCC ?= nvcc
CUDAFLAGS ?= -O3 -arch=sm_70
CC ?= gcc
CFLAGS ?= -O3 -Wall -std=c11
CXX ?= g++
CXXFLAGS ?= -O3 -Wall -std=c++11
FC_CPU ?= gfortran
FFLAGS ?= -O3 -Wall -ffree-line-length-none
GPU_FC ?= nvfortran
# 與貴中心 GPU 相符之 compute capability，例如 V100=cc70、A100=cc80
GPUARCH ?= cc70
FUFLAGS ?= -O3 -cuda -gpu=$(GPUARCH)

HAVE_NVCC := $(shell command -v $(NVCC) >/dev/null 2>&1 && echo 1 || echo 0)
HAVE_NVFC := $(shell command -v $(GPU_FC) >/dev/null 2>&1 && echo 1 || echo 0)

CPU_BINS := vec_add_cpu_c vec_add_cpu_cpp vec_add_cpu_fortran
GPU_BINS :=
ifeq ($(HAVE_NVCC),1)
GPU_BINS += vec_add_cuda_c
endif
ifeq ($(HAVE_NVFC),1)
GPU_BINS += vec_add_cuda_fortran
endif

.PHONY: all clean run_cpu run_gpu info

all: $(CPU_BINS) $(GPU_BINS)

info:
	@echo "HAVE_NVCC=$(HAVE_NVCC) HAVE_NVFC=$(HAVE_NVFC)"
	@echo "targets: $(CPU_BINS) $(GPU_BINS)"

vec_add_cpu_c: vec_add_cpu.c
	$(CC) $(CFLAGS) vec_add_cpu.c -o $@

vec_add_cpu_cpp: vec_add_cpu.cpp
	$(CXX) $(CXXFLAGS) vec_add_cpu.cpp -o $@

vec_add_cpu_fortran: vec_add_cpu.f90
	$(FC_CPU) $(FFLAGS) vec_add_cpu.f90 -o $@

vec_add_cuda_c: vec_add_cuda.cu
	$(NVCC) $(CUDAFLAGS) vec_add_cuda.cu -o $@

vec_add_cuda_fortran: vec_add_cuda_fortran.cuf
	$(GPU_FC) $(FUFLAGS) vec_add_cuda_fortran.cuf -o $@

run_cpu: vec_add_cpu_c vec_add_cpu_cpp vec_add_cpu_fortran
	@echo "=== C ===" && ./vec_add_cpu_c | head -12
	@echo "=== C++ ===" && ./vec_add_cpu_cpp | head -12
	@echo "=== Fortran ===" && ./vec_add_cpu_fortran | head -12

run_gpu:
	@test -x ./vec_add_cuda_c && { echo "=== CUDA C ===" && ./vec_add_cuda_c | head -12; } || echo "(略過 CUDA C：未建置或無執行權)"
	@test -x ./vec_add_cuda_fortran && { echo "=== CUDA Fortran ===" && ./vec_add_cuda_fortran | head -12; } || echo "(略過 CUDA Fortran：未建置，請確認 nvfortran 與 -gpu= 架構)"

clean:
	rm -f $(CPU_BINS) $(GPU_BINS)
