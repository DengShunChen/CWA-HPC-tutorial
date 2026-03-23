#!/bin/bash
# PJM 煙霧測試：驗證 pjsub 可於計算節點執行指令並寫出日誌。
# 使用：在 Part1_CPU_CrashCourse 目錄執行
#   chmod +x pjm_smoke_test.sh
#   pjsub pjm_smoke_test.sh
# 或：PJM_GROUP=您的群組 PJM_RSCGRP=small bash -c 'sed ...'  # 見 README
#
# 若 <your_group> 與貴帳號不符，請改 #PJM -g 或於提交前 export PJM_GROUP。

#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:05:00"
#PJM -g <your_group>              # ← 改為您的叢集群組（或提交前以 sed 置換）
#PJM -j
#PJM -o pjm_smoke_test.log

set -euo pipefail

echo "=========================================="
echo "PJM smoke test OK"
echo "時間: $(date -Iseconds)"
echo "主機: $(hostname)"
echo "使用者: ${USER:-?}"
echo "PWD: $(pwd)"
echo "uname: $(uname -m)"
echo "=========================================="
