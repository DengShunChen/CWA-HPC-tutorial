# 2D 熱傳導：CPU / GPU 對照
# 若 GPU 架構不同，請將 sm_70 改為貴機的 compute capability（見 nvidia-smi / device_query）

NVCC = nvcc
CUDAFLAGS ?= -O3 -arch=sm_70
CXX = g++
CXXFLAGS = -O3 -std=c++11

.PHONY: all clean run_all run_cpu run_gpu

all: heat_cpu heat_gpu

heat_cpu: main_cpu.cpp
	$(CXX) $(CXXFLAGS) main_cpu.cpp -o heat_cpu

heat_gpu: main_gpu.cu
	$(NVCC) $(CUDAFLAGS) main_gpu.cu -o heat_gpu

run_cpu: heat_cpu
	./heat_cpu

run_gpu: heat_gpu
	./heat_gpu

run_all: all
	@echo "=== CPU ==="
	./heat_cpu
	@echo ""
	@echo "=== GPU ==="
	./heat_gpu

clean:
	rm -f heat_cpu heat_gpu
