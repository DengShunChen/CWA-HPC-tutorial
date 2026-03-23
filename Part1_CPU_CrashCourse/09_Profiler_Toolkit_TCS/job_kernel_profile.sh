#!/bin/bash
# PJM 範例：於計算節點編譯（若需要）、以 fipp 取樣（Instant Performance Profiler）
# 量測目錄 ./tmp 請勿提交版控；分析輸出請在登入節點執行 fipppx -A -d ./tmp
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:15:00"
#PJM -g <your_group>
#PJM -j
#PJM -o kernel_profile_job.log

# 依貴站擇一（FX1000 常見需先 module use）：
#   module use /package/fx1000/modulefiles/ && module load tcsds/1.2.40
module load lang/tcsds-1.2.37

# OpenMP 程式搭配 Profiler 時，建議依手冊設定（純本範例無 OpenMP 可不設）：
# export FLIB_FASTOMP=TRUE

# 建議在 09_Profiler_Toolkit_TCS 目錄下執行 pjsub，或確認工作目錄內已有 kernel_profile_opt
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PJM_O_WORKDIR:-$HERE}" || exit 1

echo "節點: $(hostname)  時間: $(date)  工作目錄: $(pwd)"

# 若已在提交前編譯好執行檔，可註解掉下列一行
# make clean && make

if [[ ! -x ./kernel_profile_opt ]]; then
  echo "錯誤：找不到可執行檔 ./kernel_profile_opt（請先於本目錄 make）" >&2
  exit 1
fi

OUTDIR="${FIPP_OUTDIR:-./tmp}"
mkdir -p "${OUTDIR}"

# 使用完整迭代長度（kernel_n_default）；勿沿用登入節點自測用的 KERNEL_PROFILE_N
unset KERNEL_PROFILE_N

if command -v fipp >/dev/null 2>&1; then
  echo ">>> fipp -C -d ${OUTDIR} ./kernel_profile_opt"
  fipp -C -d "${OUTDIR}" ./kernel_profile_opt
  # 區段量測（若已編譯 region_marked）：fipp -C -d "${OUTDIR}" -Sregion ./region_marked
else
  echo "警告：未找到 fipp，改為直接執行（無 FIPP 取樣）" >&2
  ./kernel_profile_opt
fi

echo "結束: $(date)"
echo "（登入節點）分析輸出範例：fipppx -A -d ${OUTDIR}"
