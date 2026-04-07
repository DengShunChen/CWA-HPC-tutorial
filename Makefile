# HPC Programming Workshop - ProgramingTutorial

# 頂層 Makefile：統一管理所有教材編譯

.PHONY: all clean help part1 part2

all:
	@echo "========================================="
	@echo "  HPC 程式設計工作坊 - 編譯所有教材"
	@echo "========================================="
	@echo
	@$(MAKE) part1
	@echo
	@$(MAKE) part2

part1:
	@echo ">>> 編譯 Part 1: CPU 程式語言課程"
	@cd Part1_CPU_CrashCourse/01_Hello && $(MAKE) all
	@cd Part1_CPU_CrashCourse/02_Vector_Add && $(MAKE) all
	@echo "✓ Part 1 編譯完成"

part2:
	@echo ">>> 編譯 Part 2: GPU 程式設計課程"
	@cd Part2_GPU_CrashCourse/01_CUDA_Hello && $(MAKE) all
	@cd Part2_GPU_CrashCourse/02_Vector_Add_GPU && $(MAKE) all
	@cd Part2_GPU_CrashCourse/05_Language_Comparison_VectorAdd && $(MAKE) all
	@cd Part2_GPU_CrashCourse/06_OpenACC_VectorAdd && $(MAKE) all
	@cd Part2_GPU_CrashCourse/03_Heat_Diffusion_Demo && $(MAKE) all
	@echo "✓ Part 2 編譯完成"

clean:
	@echo "清理所有執行檔..."
	@cd Part1_CPU_CrashCourse/01_Hello && $(MAKE) clean
	@cd Part1_CPU_CrashCourse/02_Vector_Add && $(MAKE) clean
	@cd Part2_GPU_CrashCourse/01_CUDA_Hello && $(MAKE) clean
	@cd Part2_GPU_CrashCourse/02_Vector_Add_GPU && $(MAKE) clean
	@cd Part2_GPU_CrashCourse/05_Language_Comparison_VectorAdd && $(MAKE) clean
	@cd Part2_GPU_CrashCourse/06_OpenACC_VectorAdd && $(MAKE) clean
	@cd Part2_GPU_CrashCourse/03_Heat_Diffusion_Demo && $(MAKE) clean
	@echo "✓ 清理完成"

help:
	@echo "========================================="
	@echo "  HPC 程式設計工作坊 - Makefile 使用說明"
	@echo "========================================="
	@echo ""
	@echo "可用指令："
	@echo "  make all    - 編譯所有教材程式"
	@echo "  make part1  - 只編譯 Part 1 (CPU 課程)"
	@echo "  make part2  - 只編譯 Part 2 (GPU 課程)"
	@echo "  make clean  - 清除所有執行檔"
	@echo "  make help   - 顯示此說明"
	@echo ""
	@echo "範例："
	@echo "  make part1  # 編譯上半年課程"
	@echo "  make clean  # 清理"
	@echo ""
