# Singularity 測試非 make 編譯；此目標僅方便講師一鍵觸發（需已於 GPU 節點且 SIF 存在）

.PHONY: test help

help:
	@echo "Singularity + PyTorch GPU："
	@echo "  ./run_singularity_gpu_test.sh"
	@echo "或:  pjsub job_singularity_torch_gpu.sh"

test:
	@chmod +x run_singularity_gpu_test.sh 2>/dev/null || true
	@./run_singularity_gpu_test.sh
