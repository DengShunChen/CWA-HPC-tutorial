#!/bin/bash
#PBS -N matrix_multiply
#PBS -l select=1:ncpus=1
#PBS -l walltime=00:10:00
#PBS -q workq

# 矩陣乘法作業腳本
# 用於提交到 HPC 叢集

cd $PBS_O_WORKDIR

echo "========================================"
echo "  矩陣乘法效能測試"
echo "========================================"
echo "主機名稱: $(hostname)"
echo "工作目錄: $(pwd)"
echo ""

# 執行基礎版本
echo "--- Fortran 基礎版本 ---"
./matrix_multiply_fortran

echo ""
echo "--- Fortran 優化版本 ---"
./matrix_multiply_optimized_fortran

echo ""
echo "--- C++ 基礎版本 ---"
./matrix_multiply_cpp

echo ""
echo "--- C++ 優化版本 ---"
./matrix_multiply_optimized_cpp

echo ""
echo "測試完成！"
