# Makefile for File I/O Example（Fortran：FX1000 用 frt；登入節點可用 frtpx）

ifneq ($(shell which frt 2>/dev/null),)
FC = frt
else ifneq ($(shell which frtpx 2>/dev/null),)
FC = frtpx
else
$(error 未找到 frt / frtpx。請先 module load TCS 環境。)
endif
FFLAGS = -Kfast

ifeq ($(shell which FCC 2>/dev/null),)
CXX = g++
CXXFLAGS = -O2 -Wall -std=c++11
else
CXX = FCC
CXXFLAGS = -Kfast -std=c++11
endif

# 目標執行檔
TARGETS = file_io_fortran file_io_cpp

# 預設目標：編譯所有程式
all: $(TARGETS)

# Fortran 版本
file_io_fortran: file_io.f90
	$(FC) $(FFLAGS) $< -o $@
	@echo "✓ 編譯完成: $@"

# C++ 版本
file_io_cpp: file_io.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo "✓ 編譯完成: $@"

# 執行所有程式
run_all: all
	@echo ""
	@echo "========================================"
	@echo "  執行 File I/O 範例"
	@echo "========================================"
	@echo ""
	@echo "--- Fortran 版本 ---"
	@./file_io_fortran
	@echo ""
	@echo "--- C++ 版本 ---"
	@./file_io_cpp

# 清除執行檔和產生的資料檔
clean:
	rm -f $(TARGETS)
	rm -f output_data.txt output_data.bin
	rm -f output_data_cpp.txt output_data_cpp.bin
	@echo "✓ 清除完成"

.PHONY: all run_all clean
