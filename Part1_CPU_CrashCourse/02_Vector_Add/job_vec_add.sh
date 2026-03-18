#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:15:00"
#PJM -g <your_group>              # ← 請修改為您的群組名稱
#PJM -j
#PJM -o vec_add_benchmark.log

# 載入 Fujitsu 編譯器環境
module load lang/tcsds-1.2.37

echo "========================================="
echo "  向量加法效能對比測試"
echo "========================================="
echo "節點: $(hostname)"
echo "時間: $(date)"
echo "CPU: Fujitsu A64FX (ARM SVE 512-bit)"
echo

# Fortran 測試
echo ">>> Fortran 基礎版本 (-Kfast):"
./vec_add_fortran
echo

echo ">>> Fortran 優化版本 (-Kfast -KSVE):"
./vec_add_optimized_fortran
echo

# C++ 測試
echo ">>> C++ 基礎版本 (-Kfast):"
./vec_add_cpp
echo

echo ">>> C++ 優化版本 (-Kfast -KSVE):"
./vec_add_optimized_cpp
echo

echo "========================================="
echo "  測試完成: $(date)"
echo "========================================="
