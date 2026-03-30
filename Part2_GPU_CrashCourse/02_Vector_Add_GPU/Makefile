# Makefile

NVCC = nvcc
CUDAFLAGS ?= -O3 -arch=sm_70

.PHONY: all clean

all: vec_add_gpu benchmark

vec_add_gpu: vec_add_gpu.cu
	$(NVCC) $(CUDAFLAGS) vec_add_gpu.cu -o vec_add_gpu

benchmark: benchmark.cu
	$(NVCC) $(CUDAFLAGS) benchmark.cu -o benchmark

clean:
	rm -f vec_add_gpu benchmark
