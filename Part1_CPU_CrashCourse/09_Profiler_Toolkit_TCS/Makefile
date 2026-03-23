# Fortran：FX1000 用原生 frt；登入節點可用 frtpx（FIPP：-Nfjprof、-Nline）

ifneq ($(shell which frt 2>/dev/null),)
FC = frt
else ifneq ($(shell which frtpx 2>/dev/null),)
FC = frtpx
else
FC =
endif
FFLAGS_OPT = -g -Kfast -KSVE -Koptmsg=2 -Nfjprof -Nline
FIPP_TARGETS = region_marked

ifneq ($(shell which mpifrt 2>/dev/null),)
  MPIFC = mpifrt
else ifneq ($(shell which mpifrtpx 2>/dev/null),)
  MPIFC = mpifrtpx
endif

ifneq ($(shell which mpifcc 2>/dev/null),)
  MPICC = mpifcc
else ifneq ($(shell which mpifccpx 2>/dev/null),)
  MPICC = mpifccpx
else ifneq ($(shell which mpicc 2>/dev/null),)
  MPICC = mpicc
endif

# Fujitsu MPI C 編譯器可用時啟用 FIPP／FAPP 連結；其他 MPI C 編譯器保守使用一般除錯優化。
ifneq ($(findstring mpifcc,$(MPICC)),)
  CFLAGS_MPI = -g -Kfast -Nfjprof -Nline
else ifneq ($(findstring mpifccpx,$(MPICC)),)
  CFLAGS_MPI = -g -Kfast -Nfjprof -Nline
else
  CFLAGS_MPI = -O2 -g
endif

# Fujitsu C 編譯器（非 MPI）：用於 region_fapp_c。
ifneq ($(shell which fcc 2>/dev/null),)
  CC_FJ = fcc
else ifneq ($(shell which fccpx 2>/dev/null),)
  CC_FJ = fccpx
else
  CC_FJ =
endif
CFLAGS_FJ = -g -Kfast -Nfjprof -Nline

.PHONY: all clean run help optmsg test test-profilers \
        region_mpi region_mpi_c region_mpi_f90 \
        region_fapp region_fapp_c region_fapp_mpi_f90 region_fapp_mpi_c

all: kernel_profile_opt $(FIPP_TARGETS)
	@echo "✓ kernel_profile_opt"
	@if [ -n "$(FIPP_TARGETS)" ]; then echo "✓ region_marked（fipp_start／fipp_stop，搭配 -Sregion）"; fi

kernel_profile_opt: kernel_phases.f90 kernel_profile.f90
	@test -n "$(FC)" || { echo "需要 frt / frtpx（請先 module load TCS 環境）"; exit 1; }
	$(FC) $(FFLAGS_OPT) kernel_phases.f90 kernel_profile.f90 -o kernel_profile_opt

region_marked: kernel_phases.f90 region_marked.f90
	@test -n "$(FC)" || { echo "需要 frt / frtpx（請先 module load TCS 環境）"; exit 1; }
	$(FC) $(FFLAGS_OPT) kernel_phases.f90 region_marked.f90 -o region_marked

region_mpi: kernel_phases.f90 region_mpi.f90
	@test -n "$(MPIFC)" || { echo "需要 mpifrt / mpifrtpx"; exit 1; }
	$(MPIFC) $(FFLAGS_OPT) kernel_phases.f90 region_mpi.f90 -o region_mpi
	@echo "✓ region_mpi（MPI + 僅 rank0 FIPP 區段）"

region_mpi_f90: region_mpi_f90.f90
	@test -n "$(MPIFC)" || { echo "需要 mpifrt / mpifrtpx"; exit 1; }
	$(MPIFC) $(FFLAGS_OPT) region_mpi_f90.f90 -o region_mpi_f90
	@echo "✓ region_mpi_f90（MPI Fortran 單檔 + 僅 rank0 FIPP 區段）"

region_mpi_c: region_mpi_c.c
	@test -n "$(MPICC)" || { echo "需要 mpifcc / mpifccpx / mpicc"; exit 1; }
	$(MPICC) $(CFLAGS_MPI) region_mpi_c.c -o region_mpi_c
	@echo "✓ region_mpi_c（MPI C + 僅 rank0 FIPP 區段）"

# --- FAPP 範例（Advanced Performance Profiler）---
region_fapp: kernel_phases.f90 region_fapp.f90
	@test -n "$(FC)" || { echo "需要 frt / frtpx（請先 module load TCS 環境）"; exit 1; }
	$(FC) $(FFLAGS_OPT) kernel_phases.f90 region_fapp.f90 -o region_fapp
	@echo "✓ region_fapp（fapp_start／fapp_stop 多層區域，Fortran）"

region_fapp_c: region_fapp.c
	@test -n "$(CC_FJ)" || { echo "需要 fcc / fccpx（請先 module load TCS 環境）"; exit 1; }
	$(CC_FJ) $(CFLAGS_FJ) region_fapp.c -o region_fapp_c
	@echo "✓ region_fapp_c（fapp_start／fapp_stop 多層區域，C）"

region_fapp_mpi_f90: region_fapp_mpi_f90.f90
	@test -n "$(MPIFC)" || { echo "需要 mpifrt / mpifrtpx"; exit 1; }
	$(MPIFC) $(FFLAGS_OPT) region_fapp_mpi_f90.f90 -o region_fapp_mpi_f90
	@echo "✓ region_fapp_mpi_f90（MPI Fortran 單檔 + 僅 rank0 FAPP 區段）"

region_fapp_mpi_c: region_fapp_mpi_c.c
	@test -n "$(MPICC)" || { echo "需要 mpifcc / mpifccpx / mpicc"; exit 1; }
	$(MPICC) $(CFLAGS_MPI) region_fapp_mpi_c.c -o region_fapp_mpi_c
	@echo "✓ region_fapp_mpi_c（MPI C + 僅 rank0 FAPP 區段）"

run: kernel_profile_opt
	./kernel_profile_opt

optmsg: clean kernel_phases.f90 kernel_profile.f90
	@test -n "$(FC)" || { echo "需要 frt / frtpx（請先 module load TCS 環境）"; exit 1; }
	@$(FC) $(FFLAGS_OPT) kernel_phases.f90 kernel_profile.f90 -o kernel_profile_opt 2> optmsg_fujitsu.log || \
	  { echo "若編譯失敗，請檢查 frt / frtpx 與模組環境"; exit 1; }
	@echo "✓ 已寫入 optmsg_fujitsu.log"
	@ls -la optmsg_fujitsu.log

test:
	bash ./run_tests.sh

# 於 FX1000／TCS 環境：一併驗證 fipp、fipppx、fapp（工具須在 PATH）
test-profilers:
	RUN_FIPP_TEST=1 RUN_FIPPPX_TEST=1 RUN_FAPP_TEST=1 bash ./run_tests.sh

help:
	@echo "make / make all       — kernel_profile_opt 與 region_marked（frt 或 frtpx）"
	@echo "--- FIPP 區段（Instant Performance Profiler）---"
	@echo "make region_mpi       — 需 mpifrt 或 mpifrtpx：MPI + rank0 之 fipp 區段"
	@echo "make region_mpi_f90   — 需 mpifrt 或 mpifrtpx：MPI Fortran 單檔 rank0 量測"
	@echo "make region_mpi_c     — 需 mpifcc/mpifccpx/mpicc：MPI C + rank0 之 fipp 區段"
	@echo "fipp 區段量測：fipp -C -d ./tmp -Sregion ./region_marked"
	@echo "--- FAPP 區域（Advanced Performance Profiler）---"
	@echo "make region_fapp      — Fortran 多層 fapp_start/stop（需 frt / frtpx）"
	@echo "make region_fapp_c    — C 多層 fapp_start/stop（需 fcc / fccpx）"
	@echo "make region_fapp_mpi_f90 — MPI Fortran 單檔 rank0 fapp 區域"
	@echo "make region_fapp_mpi_c   — MPI C rank0 fapp 區域"
	@echo "fapp 量測：fapp -C -d ./tmp_fapp -L 1 ./region_fapp"
	@echo "---"
	@echo "make run / test       — 執行主程式／章節自測"
	@echo "make test-profilers   — fipp + fipppx + fapp 自測（需 TCS 工具）"
	@echo "make optmsg           — 優化訊息 → optmsg_fujitsu.log"
	@echo "make clean"

clean:
	rm -f kernel_profile_opt region_marked \
	      region_mpi region_mpi_f90 region_mpi_c \
	      region_fapp region_fapp_c region_fapp_mpi_f90 region_fapp_mpi_c \
	      optmsg_fujitsu.log *.o *.mod
