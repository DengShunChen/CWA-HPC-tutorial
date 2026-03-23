#!/bin/bash
# PJM：一鍵執行 09 profiling 工作流（FIPP + FAPP）
# 使用前請修改 <your_group>

#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:20:00"
#PJM -g <your_group>
#PJM -j
#PJM -o profile_workflow_job.log

set -euo pipefail

# 載入 TCS（先嘗試 FX1000 常見路徑，再退回舊版 module 名稱）
if command -v module >/dev/null 2>&1; then
  module use /package/fx1000/modulefiles/ >/dev/null 2>&1 || true
  if ! module load tcsds/1.2.40 >/dev/null 2>&1; then
    module load lang/tcsds-1.2.37 >/dev/null 2>&1 || true
  fi
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "${PJM_O_WORKDIR:-$HERE}" || exit 1

echo "節點: $(hostname)  時間: $(date)"
echo "工作目錄: $(pwd)"

chmod +x ./run_profile_workflow.sh

# 執行 all：FIPP + FAPP；MPI 範例預設關閉（避免與站台配額衝突）。
# 若要演練 MPI，請改為 --mpi-n 4 並於 #PJM 加上對應的 --mpi proc 設定。
./run_profile_workflow.sh --mode all --outdir ./profile_out --level 1 --mpi-n 0

echo "完成時間: $(date)"
echo "建議下一步（登入節點）："
echo "  1) 檢視 ./profile_out/**/analysis.txt"
echo "  2) 依 PROFILE_REVIEW_TEMPLATE.md 填寫判讀結果"
