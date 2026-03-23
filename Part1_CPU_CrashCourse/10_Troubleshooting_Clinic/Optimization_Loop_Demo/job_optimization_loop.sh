#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:20:00"
#PJM -g <your_group>
#PJM -j
#PJM -o optimization_loop_job.log

set -euo pipefail

if command -v module >/dev/null 2>&1; then
  module use /package/fx1000/modulefiles/ >/dev/null 2>&1 || true
  if ! module load tcsds/1.2.40 >/dev/null 2>&1; then
    module load lang/tcsds-1.2.37 >/dev/null 2>&1 || true
  fi
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "${PJM_O_WORKDIR:-$HERE}" || exit 1

echo "node=$(hostname) start=$(date)"
chmod +x ./run_optimization_loop.sh
./run_optimization_loop.sh
echo "done=$(date)"
