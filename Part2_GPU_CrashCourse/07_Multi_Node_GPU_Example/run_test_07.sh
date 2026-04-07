#!/usr/bin/env bash
# 在 GPU 計算節點上測試 07：嘗試載入 CUDA + MPI（與 run_part2_gpu 類似），make 後 mpirun -np 2。
#   cd Part2_GPU_CrashCourse/07_Multi_Node_GPU_Example && ./run_test_07.sh
#
# 僅編譯、不跑 mpirun：  RUN_TEST_07_COMPILE_ONLY=1 ./run_test_07.sh
# 略過 GPU 預檢（不建議）：RUN_TEST_07_SKIP_GPU_CHECK=1 ./run_test_07.sh
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
# shellcheck source=/dev/null
source "${HERE}/../part2_lmod_bootstrap.sh"
part2_lmod_bootstrap

part2_try_nvcc_from_sdk_tree() {
  shopt -s nullglob
  local c
  for c in \
    /opt/nvidia/hpc_sdk/Linux_x86_64/*/cuda/bin/nvcc \
    /opt/nvidia/hpc_sdk/Linux_x86_64/cuda/*/bin/nvcc \
    /package/x86_64/nvidia/hpc_sdk/Linux_x86_64/*/cuda/bin/nvcc; do
    if [[ -x "$c" ]]; then
      export PATH="${c%/*}:$PATH"
      shopt -u nullglob
      return 0
    fi
  done
  shopt -u nullglob
  return 1
}

if ! command -v nvcc >/dev/null 2>&1 && command -v module >/dev/null 2>&1; then
  if [[ -n "${PART2_CUDA_MODULE:-}" ]]; then
    module load "${PART2_CUDA_MODULE}" 2>/dev/null || true
  fi
  if ! command -v nvcc >/dev/null 2>&1; then
    for m in \
      nvhpc-hpcx-cuda12/25.3 \
      nvhpc-hpcx-cuda12/24.11 \
      nvhpc-hpcx-cuda12/24.9 \
      nvhpc-hpcx-cuda12/24.3 \
      nvhpc/25.3 \
      nvhpc/24.11 \
      nvhpc/24.9 \
      nvhpc/24.3 \
      nvhpc-hpcx-cuda11/24.9 \
      nvhpc-hpcx-cuda11/24.3 \
      cuda cuda/12.2 cuda/12.1 cuda/11.8 CUDA/12.2 CUDA/12.1 nvhpc; do
      module load "$m" 2>/dev/null || continue
      command -v nvcc >/dev/null 2>&1 && break
    done
  fi
fi
if ! command -v nvcc >/dev/null 2>&1; then
  part2_try_nvcc_from_sdk_tree || true
fi

if ! command -v nvcc >/dev/null 2>&1; then
  echo "FAIL: 找不到 nvcc。請在 GPU 節點執行，或 export PART2_CUDA_MODULE=…" >&2
  exit 1
fi

if ! command -v mpirun >/dev/null 2>&1 && command -v module >/dev/null 2>&1; then
  for m in hpcx hpcx-mt openmpi4 openmpi gnu9/openmpi mpi; do
    module load "$m" 2>/dev/null || continue
    command -v mpirun >/dev/null 2>&1 && break
  done
fi

if ! command -v mpicxx >/dev/null 2>&1 && command -v mpirun >/dev/null 2>&1; then
  # 有些站臺只有 mpicc，OpenMPI 的 mpicxx 常與 mpirun 同模組
  for m in hpcx openmpi4 openmpi gnu9/openmpi; do
    module load "$m" 2>/dev/null || continue
    command -v mpicxx >/dev/null 2>&1 && break
  done
fi

if ! command -v mpicxx >/dev/null 2>&1; then
  echo "FAIL: 找不到 mpicxx（連結 MPI 需要）。請 module load hpcx 或與叢集 OpenMPI 對應之模組。" >&2
  exit 1
fi
if ! command -v mpirun >/dev/null 2>&1; then
  echo "FAIL: 找不到 mpirun。" >&2
  exit 1
fi

echo ">>> nvcc: $(command -v nvcc)"
echo ">>> mpicxx: $(command -v mpicxx)"
echo ">>> mpirun: $(command -v mpirun)"
make clean
make all

if [[ "${RUN_TEST_07_COMPILE_ONLY:-0}" = 1 ]]; then
  echo ">>> RUN_TEST_07_COMPILE_ONLY=1 — 略過 nvidia-smi 預檢與 mpirun"
  echo ">>> run_test_07.sh OK（僅編譯）"
  exit 0
fi

if [[ "${RUN_TEST_07_SKIP_GPU_CHECK:-0}" != 1 ]] && ! nvidia-smi -L >/dev/null 2>&1; then
  echo "FAIL: nvidia-smi 無可用 GPU（請在 GPU 計算節點／互動資源內執行本腳本）。" >&2
  echo "    若僅需驗證編譯：RUN_TEST_07_COMPILE_ONLY=1 $0" >&2
  exit 2
fi

echo ">>> mpirun -np 2 --oversubscribe ./mpi_cuda_rank_info"
mpirun -np 2 --oversubscribe ./mpi_cuda_rank_info
echo ">>> run_test_07.sh OK"
