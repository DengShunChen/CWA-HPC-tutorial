# OpenACC Fortran：需 NVIDIA HPC SDK 之 nvfortran（-acc -gpu=）
# 與 05 章向量加法同一 n、單精度，對照「指令式 GPU」與 CUDA Fortran

NVFOR ?= nvfortran
GPUARCH ?= cc70
FFLAGS ?= -O3 -acc -gpu=$(GPUARCH) -Mfree -Mextend

HAVE_NVFC := $(shell command -v $(NVFOR) >/dev/null 2>&1 && echo 1 || echo 0)

BINS :=
ifeq ($(HAVE_NVFC),1)
BINS := vec_add_openacc vec_add_openacc_async vec_add_openacc_routine
endif

.PHONY: all clean info run

all: info $(BINS)

info:
	@echo "HAVE_NVFC=$(HAVE_NVFC) targets=$(BINS)"

vec_add_openacc: vec_add_openacc.f90
	$(NVFOR) $(FFLAGS) vec_add_openacc.f90 -o $@

vec_add_openacc_async: vec_add_openacc_async.f90
	$(NVFOR) $(FFLAGS) vec_add_openacc_async.f90 -o $@

vec_add_openacc_routine: vec_add_openacc_routine.f90
	$(NVFOR) $(FFLAGS) vec_add_openacc_routine.f90 -o $@

run: $(BINS)
	@for x in $(BINS); do echo "=== $$x ==="; ./$$x | head -14; echo; done

clean:
	rm -f vec_add_openacc vec_add_openacc_async vec_add_openacc_routine
