# MPI + CUDA：以 mpicxx 當 host 連結器，才能連到 libmpi
NVCC ?= nvcc
MPICXX ?= mpicxx
CUDAFLAGS ?= -O2

TARGET = mpi_cuda_rank_info
SRC = mpi_cuda_rank_info.cu

.PHONY: all clean run-local info

all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(CUDAFLAGS) -ccbin $(MPICXX) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET)

# 單節點煙霧：兩個 rank 同機時應看到不同 local_rank、可能共用同一張 GPU（dev 依 local_rank%nGpu）
run-local: $(TARGET)
	mpirun -np 2 --oversubscribe ./$(TARGET)

info:
	@echo "NVCC=$(NVCC) MPICXX=$(MPICXX)"
