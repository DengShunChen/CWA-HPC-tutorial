# 10 / Optimization Loop Demo
# Fortran only (FX1000 / TCS): 需要 frt 或 frtpx

ifneq ($(shell which frt 2>/dev/null),)
FC = frt
else ifneq ($(shell which frtpx 2>/dev/null),)
FC = frtpx
else
FC =
endif

FFLAGS_BASE = -g -Koptmsg=2 -Nfjprof -Nline
FFLAGS_OPT  = -g -Kfast -KSVE -Koptmsg=2 -Nfjprof -Nline

.PHONY: all clean baseline optimized

all: baseline optimized

baseline: loop_baseline.f90
	@test -n "$(FC)" || { echo "需要 frt / frtpx（請先 module load TCS 環境）"; exit 1; }
	$(FC) $(FFLAGS_BASE) loop_baseline.f90 -o loop_baseline

optimized: loop_optimized.f90
	@test -n "$(FC)" || { echo "需要 frt / frtpx（請先 module load TCS 環境）"; exit 1; }
	$(FC) $(FFLAGS_OPT) loop_optimized.f90 -o loop_optimized

clean:
	rm -f loop_baseline loop_optimized optmsg_baseline.log optmsg_optimized.log
