#!/bin/bash
# 批次測試 Part2 GPU：與互動式相同資源語系，但使用批次輸出 log（較適合自動驗證）。
# 提交：  pjsub job_run_part2_gpu.sh
# 與 Part1 對齊之「登入節點一鍵送批次」：./run_part2_tests.sh --submit-pjm（會寫入 .part2_gpu_autotest_job.sh 再 pjsub）
# 互動式：多數站台進 shell 後執行 bash run_part2_gpu.sh；若 PJM 支援行尾啟動腳本，可用 ... -j run_part2_gpu.sh
#
# 若需與下列互動式等價之資源，可對照修改（1 core / 1 MPI proc）：
#   pjsub -N interact --interact -L ru=rscunit_pg01 -L rg=gpu-rd-small \
#     -L gpu-share=1 -L vnode=1 -L vnode-core=1 -L vnode-mem=64Gi \
#     -L elapse=1:00:00 --mpi proc=1 --sparam wait-time=600 \
#     -o '/users/xb80/tmp/interact.%j' -j

#PJM -N part2-gpu-test
#PJM -j
#PJM -o part2_gpu.%j.out
#PJM -L ru=rscunit_pg01
#PJM -L rg=gpu-rd-small
#PJM -L gpu-share=1
#PJM -L vnode=1
#PJM -L vnode-core=1
#PJM -L vnode-mem=64Gi
#PJM -L elapse=1:00:00
#PJM --mpi proc=1
#PJM --sparam wait-time=600

set -euo pipefail
# PJM 執行時工作目錄未必是教材目錄；優先同目錄之 run_part2_gpu.sh，否則用環境變數或預設 clone 路徑
SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
NEAR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
if [[ -f "$NEAR/run_part2_gpu.sh" ]]; then
  cd "$NEAR"
elif [[ -n "${PART2_GPU_DIR:-}" && -f "${PART2_GPU_DIR}/run_part2_gpu.sh" ]]; then
  cd "${PART2_GPU_DIR}"
elif [[ -n "${PJM_O_WORKDIR:-}" && -f "${PJM_O_WORKDIR}/run_part2_gpu.sh" ]]; then
  cd "${PJM_O_WORKDIR}"
else
  PART2_GPU_DIR="${PART2_GPU_DIR:-${HOME}/source_code/CWA-HPC-tutorial/Part2_GPU_CrashCourse}"
  cd "${PART2_GPU_DIR}" || {
    echo "找不到教材目錄（需含 run_part2_gpu.sh）。請：① 於 Part2_GPU_CrashCourse 內執行 pjsub；或 ② export PART2_GPU_DIR=/正確路徑" >&2
    exit 1
  }
fi
exec bash ./run_part2_gpu.sh
