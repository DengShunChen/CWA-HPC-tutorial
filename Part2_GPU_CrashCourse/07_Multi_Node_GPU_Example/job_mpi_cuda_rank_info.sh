#!/bin/bash
# 多節點（TCS / PJM）：在本目錄 make 出 mpi_cuda_rank_info，再由 PJM 配置之 MPI launcher 啟動。
#
# 使用前請依叢集修改 #PJM；本腳本會嘗試在 PJM 計算節點環境下初始化 Lmod，並自動載入常見 CUDA/MPI 模組。
#
#   cd Part2_GPU_CrashCourse/07_Multi_Node_GPU_Example
#   pjsub job_mpi_cuda_rank_info.sh
#
# 與腳本內變數一致：Nodes == vnode，NProcs == --mpi proc，且 NProcs % Nodes == 0。
#
#PJM -N p2-mpi-cuda-info
#PJM -j
#PJM -o p2_mpi_cuda_rank_info.%j.out
#PJM -L ru=rscunit_pg01
#PJM -L rg=gpu-rd-large
#PJM -L gpu=1
#PJM -L vnode=2
#PJM -L vnode-core=4
#PJM -L vnode-mem=32Gi
#PJM -L elapse=0:15:00
#PJM --mpi proc=4
#PJM --sparam wait-time=600
#
# 若貴站使用 rscunit=/rscgrp= 寫法，請改寫 #PJM 並維持資源語意一致。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$ROOT"

Nodes=2
NProcs=4
if (( NProcs % Nodes != 0 )); then
  echo "錯誤：NProcs=${NProcs} 須整除 Nodes=${Nodes}" >&2
  exit 1
fi
NProcsPerNode=$((NProcs / Nodes))

# --- batch 環境 module 初始化與自動載入（沿用 run_test_07.sh 的策略） ---
# shellcheck source=/dev/null
source "${ROOT}/../part2_lmod_bootstrap.sh"
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
  echo "FAIL: 找不到 nvcc。請確認 CUDA/nvhpc 模組或設定 PART2_CUDA_MODULE。" >&2
  exit 1
fi

if ! command -v mpiexec >/dev/null 2>&1 && ! command -v mpirun >/dev/null 2>&1 && command -v module >/dev/null 2>&1; then
  for m in hpcx hpcx-mt openmpi4 openmpi gnu9/openmpi mpi; do
    module load "$m" 2>/dev/null || continue
    (command -v mpiexec >/dev/null 2>&1 || command -v mpirun >/dev/null 2>&1) && break
  done
fi

if ! command -v mpicxx >/dev/null 2>&1 && (command -v mpiexec >/dev/null 2>&1 || command -v mpirun >/dev/null 2>&1) && command -v module >/dev/null 2>&1; then
  for m in hpcx openmpi4 openmpi gnu9/openmpi; do
    module load "$m" 2>/dev/null || continue
    command -v mpicxx >/dev/null 2>&1 && break
  done
fi

if ! command -v mpicxx >/dev/null 2>&1; then
  echo "FAIL: 找不到 mpicxx（連結 MPI 需要）。請 module load 與 mpiexec/mpirun 對應的 MPI。" >&2
  exit 1
fi

# 編譯（若已預先編好可設 SKIP_MAKE=1）
if [[ "${SKIP_MAKE:-0}" != 1 ]]; then
  make -s all || make all
fi

EXEC="${ROOT}/mpi_cuda_rank_info"
if [[ ! -x "$EXEC" ]]; then
  echo "找不到 $EXEC（請確認 nvcc、mpicxx 與 module）" >&2
  exit 1
fi

export LANG=C

: "${PJM_JOBID:?PJM_JOBID missing}"
: "${PJM_O_NODEINF:?請在 PJM 批次內執行（需要 PJM_O_NODEINF）}"

# 以 PJM 實際節點數做一致性檢查（避免只改了 #PJM header 或只改了腳本變數）
PJM_NODES="$(grep -cve '^[[:space:]]*$' "${PJM_O_NODEINF}" || true)"
if [[ -n "${PJM_NODES}" && "${PJM_NODES}" != 0 && "${PJM_NODES}" != "${Nodes}" ]]; then
  echo "警告：PJM 配到 ${PJM_NODES} nodes，但腳本 Nodes=${Nodes}；請確保 #PJM -L vnode 與 Nodes 一致。" >&2
fi

# TCS/PJM 環境通常會提供可直接使用 allocation 的 launcher；不強制 hostfile 或 pjrsh。
LAUNCHER="$(command -v mpiexec || true)"
if [[ -z "${LAUNCHER}" ]]; then
  LAUNCHER="$(command -v mpirun || true)"
fi
if [[ -z "${LAUNCHER}" ]]; then
  echo "找不到 mpiexec/mpirun（請確認已 module load 正確的 MPI）" >&2
  exit 1
fi

"${LAUNCHER}" -np "${NProcs}" \
  -x PATH \
  -x LD_LIBRARY_PATH \
  "${EXEC}"

nvidia-smi || true
