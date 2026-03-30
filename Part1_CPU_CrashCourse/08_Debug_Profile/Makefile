# Fortran：FX1000 用原生 frt；登入節點可用 frtpx（TCS）

ifneq ($(shell which frt 2>/dev/null),)
FC = frt
else ifneq ($(shell which frtpx 2>/dev/null),)
FC = frtpx
else
$(error 未找到 frt / frtpx。請先 module load TCS 環境。)
endif
# 執行期／編譯期檢查（含陣列下標）：Fujitsu 手冊為 -Haefosux。舊寫法 -Hx,CHECK_SUBSCRIPT 在 tcsds 1.2.x 常出現 Invalid suboption for -H。
FFLAGS_DBG = -g -Haefosux -O0
FFLAGS_OPT = -g -Kfast -KSVE -Koptmsg=2

.PHONY: all clean run_opt

all: microbench_dbg microbench_opt buggy_bounds
	@echo "✓ 已建立 microbench_dbg / microbench_opt / buggy_bounds（Fortran / frt）"

microbench_dbg: microbench.f90
	$(FC) $(FFLAGS_DBG) microbench.f90 -o microbench_dbg

microbench_opt: microbench.f90
	$(FC) $(FFLAGS_OPT) microbench.f90 -o microbench_opt

buggy_bounds: buggy_bounds.f90
	$(FC) $(FFLAGS_DBG) buggy_bounds.f90 -o buggy_bounds

run_opt: microbench_opt
	./microbench_opt

clean:
	rm -f microbench_dbg microbench_opt buggy_bounds *.o *.mod
