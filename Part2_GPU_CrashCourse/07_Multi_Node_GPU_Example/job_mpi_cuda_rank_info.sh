#!/bin/bash
# 多節點：在本目錄 make 出 mpi_cuda_rank_info，再以 Open MPI mpirun 啟動（PJM hostfile + pjrsh）。
#
# 使用前請依叢集修改 #PJM；並在腳本內或環境中完成 module load（nvhpc、HPC-X 等），使 nvcc、mpirun 可用。
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
export OMPI_MCA_plm_rsh_agent=/bin/pjrsh

HOSTFILE="${ROOT}/hostfile.${PJM_JOBID:?PJM_JOBID missing}"
: "${PJM_O_NODEINF:?請在 PJM 批次內執行（需要 PJM_O_NODEINF）}"

while read -r node; do
  [[ -z "${node// }" ]] && continue
  echo "${node} slots=${PJM_PROC_BY_NODE:-${NProcsPerNode}}"
done < "${PJM_O_NODEINF}" > "${HOSTFILE}"

MPIRUN="$(command -v mpirun)"
if [[ -z "${MPIRUN}" ]]; then
  echo "找不到 mpirun" >&2
  exit 1
fi

"${MPIRUN}" -np "${NProcs}" \
  -npernode "${NProcsPerNode}" \
  -hostfile "${HOSTFILE}" \
  -bind-to none \
  -x PATH \
  -x LD_LIBRARY_PATH \
  "${EXEC}"

nvidia-smi || true
