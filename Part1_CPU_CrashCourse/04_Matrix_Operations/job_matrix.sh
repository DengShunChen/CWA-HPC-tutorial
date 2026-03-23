#!/bin/bash
# PJM 範例：於計算節點執行矩陣乘法效能對比（與 02_Vector_Add/job_vec_add.sh 相同批次語法）
# 使用方式：在 04_Matrix_Operations 目錄下 pjsub job_matrix.sh（請先將 <your_group> 改為實際群組）

#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:15:00"
#PJM -g <your_group>              # ← 請修改為您的群組名稱
#PJM -j
#PJM -o matrix_multiply_benchmark.log

module load lang/tcsds-1.2.37

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "${PJM_O_WORKDIR:-$HERE}" || exit 1

echo "========================================"
echo "  矩陣乘法效能測試（PJM）"
echo "========================================"
echo "主機名稱: $(hostname)"
echo "工作目錄: $(pwd)"
echo "時間: $(date)"
echo ""

make clean && make

echo ""
make run_all

echo ""
echo "========================================="
echo "  測試完成: $(date)"
echo "========================================="
