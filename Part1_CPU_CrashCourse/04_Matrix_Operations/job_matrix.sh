#!/bin/bash
# PJM 範例：於計算節點執行矩陣乘法效能對比（與 02_Vector_Add/job_vec_add.sh 相同批次語法）
# 使用方式：在 04_Matrix_Operations 目錄下 pjsub job_matrix.sh（請先將 <your_group> 改為實際群組）

#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:15:00"
#PJM -g <your_group>              # ← 請修改為您的群組名稱
#PJM -j
#PJM -o matrix_multiply_benchmark.log
#PJM --mpi "proc=4"               # 可依站台政策調整（示範：4 MPI ranks）
#PJM --omp "thread=12"            # 可依站台政策調整（示範：每 rank 12 threads）

module load lang/tcsds-1.2.37

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "${PJM_O_WORKDIR:-$HERE}" || exit 1

export OMP_NUM_THREADS="${OMP_NUM_THREADS:-12}"
export OMP_PROC_BIND="${OMP_PROC_BIND:-close}"
export OMP_PLACES="${OMP_PLACES:-cores}"

echo "========================================"
echo "  矩陣乘法效能測試（PJM）"
echo "========================================"
echo "主機名稱: $(hostname)"
echo "工作目錄: $(pwd)"
echo "時間: $(date)"
echo "MPI/OMP: proc=4 thread=${OMP_NUM_THREADS}"
echo ""

make clean && make

echo ""
if [ "${INFINITE_LOOP_TEST:-0}" = "1" ]; then
  echo "INFINITE_LOOP_TEST=1：進入安全中止演練模式（請以 pjdel 終止）"
  while true; do
    date
    sleep 30
  done
else
  if command -v numactl >/dev/null 2>&1; then
    echo "偵測到 numactl：以 NUMA node0 綁定執行（示範）"
    numactl --cpunodebind=0 --membind=0 make run_all
  else
    echo "未偵測到 numactl：使用預設綁定策略執行"
    make run_all
  fi
fi

echo ""
echo "========================================="
echo "  測試完成: $(date)"
echo "========================================="
