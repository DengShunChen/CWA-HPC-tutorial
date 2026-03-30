# Makefile for CUDA Hello World

NVCC = nvcc
CUDAFLAGS ?= -O2

.PHONY: all clean run

all: hello_gpu device_query

hello_gpu: hello_gpu.cu
	$(NVCC) $(CUDAFLAGS) hello_gpu.cu -o hello_gpu

device_query: device_query.cu
	$(NVCC) $(CUDAFLAGS) device_query.cu -o device_query

run: all
	@echo "=== 查詢 GPU 裝置資訊 ==="
	@./device_query
	@echo
	@echo "=== 執行 CUDA Hello World ==="
	@./hello_gpu

clean:
	rm -f hello_gpu device_query
