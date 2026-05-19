# MPI + CUDA：以 mpicxx 當 host 連結器，才能連到 libmpi
NVCC ?= nvcc
MPICXX ?= mpicxx
CUDAFLAGS ?= -O2

# 預設鎖 A100（sm_80）。若你要跑其他卡種，請覆寫，例如：
#   make CUDA_ARCH=90   # H100
#   make CUDA_ARCH=86   # A40 / A30 等
CUDA_ARCH ?= 80
CUDA_GENCODE ?= -gencode arch=compute_$(CUDA_ARCH),code=sm_$(CUDA_ARCH) -gencode arch=compute_$(CUDA_ARCH),code=compute_$(CUDA_ARCH)

TARGET = mpi_cuda_rank_info
SRC = mpi_cuda_rank_info.cu

.PHONY: all clean run-local info

all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(CUDAFLAGS) $(CUDA_GENCODE) -ccbin $(MPICXX) -std=c++11 $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET)

# 單節點煙霧：兩個 rank 同機時應看到不同 local_rank、可能共用同一張 GPU（dev 依 local_rank%nGpu）
run-local: $(TARGET)
	mpirun -np 2 --oversubscribe ./$(TARGET)

info:
	@echo "NVCC=$(NVCC) MPICXX=$(MPICXX) CUDA_ARCH=$(CUDA_ARCH)"
