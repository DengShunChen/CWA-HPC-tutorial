#!/bin/bash
# 多節點 GPU + MPI 之 PJM 模板（概念對齊 $HOME/sample/GPU_multiNodes/run_gpu.sh）。
# 使用前請：① 改 #PJM 資源；② module load 改成貴站路徑；③ 設定 EXEC 為你的 CUDA/MPI 可執行檔。
#
# 提交：在**本目錄**或複製到 GPU_multiNodes 後執行
#   pjsub job_multi_node_gpu_template.sh
#
#PJM -N mn-gpu-mpi
#PJM -j
#PJM -o mn_gpu_mpi.%j.out
#PJM -L rscunit=rscunit_pg01
#PJM -L rscgrp=gpu-rd-large
#PJM -L vnode=2
#PJM -L vnode-core=8
#PJM -L vnode-mem=64Gi
#PJM -L gpu=1
#PJM -L elapse=0:30:00
#PJM --mpi proc=16
#PJM --sparam wait-time=600

set -euo pipefail

# 與 #PJM 一致（請手動維持同步）
Nodes=2
NProcs=16
NProcsPerNode=$((NProcs / Nodes))

# 要跑的程式（請改成實際路徑，例如家目錄 sample 內之 pi-cuda）
EXEC="${MULTI_NODE_GPU_EXEC:-${HOME}/sample/GPU_multiNodes/pi-cuda}"

# --- module：以下為佔位，請改為貴中心 nvhpc / HPC-X 或 Intel MPI ---
# module load ...

export LANG=C
export OMPI_MCA_plm_rsh_agent=/bin/pjrsh

HOSTFILE="${PWD}/hostfile.${PJM_JOBID:-local}"
: "${PJM_O_NODEINF:?請在 PJM 批次內執行（需要 PJM_O_NODEINF）}"

while read -r node; do
  [[ -z "${node// }" ]] && continue
  echo "${node} slots=${PJM_PROC_BY_NODE:-$((NProcsPerNode))}"
done < "${PJM_O_NODEINF}" > "${HOSTFILE}"

MPIRUN="$(command -v mpirun)"
if [[ -z "${MPIRUN}" ]]; then
  echo "找不到 mpirun，請 module load OpenMPI／HPC-X 等" >&2
  exit 1
fi

if [[ ! -x "${EXEC}" ]]; then
  echo "找不到或可執行檔不存在: ${EXEC}" >&2
  echo "請設定 MULTI_NODE_GPU_EXEC 或將 pi-cuda 等置於預設路徑。" >&2
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
