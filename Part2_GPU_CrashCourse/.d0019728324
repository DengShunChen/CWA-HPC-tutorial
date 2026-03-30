#!/usr/bin/env bash
# Part2 GPU 節點自我檢查：nvidia-smi、nvcc、CUDA 範例編譯與執行、（選用）Singularity+PyTorch。
# 使用方式：
#   ① 互動式：進入 GPU shell 後執行本腳本；若 PJM 允許，也可 pjsub ... -j run_part2_gpu.sh
#   ② 批次：pjsub job_run_part2_gpu.sh（輸出寫入 -o 指定之 log）

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
# shellcheck source=/dev/null
source "${HERE}/part2_lmod_bootstrap.sh"

echo "========== Part2 GPU 自我檢查 =========="
echo "host: $(hostname)  date: $(date -Is 2>/dev/null || date)"
echo

echo "---------- nvidia-smi ----------"
if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "FAIL: 找不到 nvidia-smi（可能不在 GPU 節點）" >&2
  exit 1
fi
nvidia-smi
echo

echo "---------- nvcc（必要時自動 module load / 路徑後援）----------"
# PJM 以 -j 腳本啟動時常為「非登入」環境：沒有 module、MODULEPATH 未含 HPC SDK / privatemodules
part2_lmod_bootstrap
part2_try_nvcc_from_sdk_tree() {
  # 不依賴 module：直接找已安裝之 cuda bin（NVIDIA HPC SDK 預設佈局）
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
  echo "FAIL: 找不到 nvcc。" >&2
  echo "    ① export PART2_CUDA_MODULE=nvhpc-hpcx-cuda12/<版次> 後重跑；或登入節點查：module avail 2>&1 | grep -i nvhpc" >&2
  echo "    ② 診斷：command -v module=$(command -v module 2>/dev/null || echo 無) MODULEPATH=${MODULEPATH:-空}" >&2
  exit 1
fi
nvcc --version
echo

# 依 nvidia-smi 的 compute capability 選 -arch（未手動設 CUDAFLAGS 時）
if [[ -z "${CUDAFLAGS:-}" ]]; then
  cap_code="$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d '.')"
  if [[ -n "$cap_code" ]]; then
    export CUDAFLAGS="-O3 -arch=sm_${cap_code}"
    echo "（自動 CUDAFLAGS=$CUDAFLAGS）"
  else
    export CUDAFLAGS="-O3 -arch=sm_70"
    echo "（預設 CUDAFLAGS=$CUDAFLAGS）"
  fi
else
  echo "（使用既有 CUDAFLAGS=$CUDAFLAGS）"
fi
echo

echo "---------- 編譯 Part2（CUDA）----------"
make -C "$HERE/01_CUDA_Hello" all
make -C "$HERE/02_Vector_Add_GPU" all
make -C "$HERE/03_Heat_Diffusion_Demo" heat_gpu
echo "編譯完成"
echo

echo "---------- 01_CUDA_Hello / device_query ----------"
"$HERE/01_CUDA_Hello/device_query" | head -40
echo
echo "---------- 01_CUDA_Hello / hello_gpu ----------"
"$HERE/01_CUDA_Hello/hello_gpu" | head -20
echo

echo "---------- 02_Vector_Add_GPU / vec_add_gpu ----------"
"$HERE/02_Vector_Add_GPU/vec_add_gpu" | head -20
echo
echo "---------- 02_Vector_Add_GPU / benchmark ----------"
"$HERE/02_Vector_Add_GPU/benchmark" | head -20
echo

echo "---------- 03_Heat_Diffusion_Demo / heat_gpu ----------"
"$HERE/03_Heat_Diffusion_Demo/heat_gpu" | head -20
echo

SIF="${SINGULARITY_SIF:-${HOME}/sample/singularity/torch_1.13.1_cuda11.6.sif}"
part2_try_load_singularity_module 2>/dev/null || true
if command -v singularity >/dev/null 2>&1 || command -v apptainer >/dev/null 2>&1; then
  if [[ -f "$SIF" ]]; then
    echo "---------- 04_Singularity_PyTorch_GPU ----------"
    SINGULARITY_SIF="$SIF" bash "$HERE/04_Singularity_PyTorch_GPU/run_singularity_gpu_test.sh" | head -30 || echo "(Singularity 測試非致命失敗，請看上方輸出)"
  else
    echo "（略過 04：無 SIF $SIF）"
  fi
else
  echo "（略過 04：無 singularity / apptainer）"
fi

echo
echo "========== Part2 GPU 檢查結束（成功）=========="
