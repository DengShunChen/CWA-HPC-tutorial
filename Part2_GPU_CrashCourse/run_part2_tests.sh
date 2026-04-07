#!/usr/bin/env bash
# Part2 GPU 自動檢查：比照 Part1「run_all_tests.sh」— 可在 GPU 計算節點（CN）直接跑，或以 --submit-pjm 由登入節點送批次。
#
# 用法：
#   ./run_part2_tests.sh                    # 須已在 GPU 節點（nvidia-smi 可用）
#   ./run_part2_tests.sh --report FILE.log  # 同上，輸出附加寫入報告
#   export PJM_GROUP=你的群組
#   ./run_part2_tests.sh --submit-pjm       # 登入節點：產生 PJM 腳本並 pjsub（GPU 資源）
#
# 環境變數（--submit-pjm 與直接執行皆可沿用）：
#   PJM_GROUP           叢集群組（--submit-pjm 時若未設，嘗試 groups 第一個）
#   PART2_PJM_LOG       預設 part2_gpu_autotest.log（相對於提交時工作目錄）
#   PART2_PJM_ELAPSE    預設 01:00:00
#   PART2_PJM_RU        預設 rscunit_pg01
#   PART2_PJM_RG        預設 gpu-rd-small
#   PART2_GPU_SHARE     預設 1
#   PART2_VNODE         預設 1
#   PART2_VNODE_CORE    預設 1
#   PART2_VNODE_MEM     預設 64Gi
#   PART2_MPI_PROC      預設 1（--mpi proc=）
#   PART2_CUDA_MODULE     可選，寫入批次內 export，供 run_part2_gpu.sh 優先 module load
#   PART2_SKIP_07_NOTICE  設為 1 時不印 07 章節提示
#
# 另可沿用既有手寫批次：pjsub job_run_part2_gpu.sh（行為等同直接 exec run_part2_gpu.sh）
#
# 涵蓋章節（與 run_part2_gpu.sh 對齊）：
#   01–05  編譯＋煙霧測試
#   06     Singularity／PyTorch GPU（選用，有 SIF 與 singularity/apptainer 時）
#   07     多節點：結束後印 07 目錄與 sample 提示（範例程式為 07/mpi_cuda_rank_info；PART2_SKIP_07_NOTICE=1 略過）

set -uo pipefail

PART2_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_FILE=""
SUBMIT_PJM=0
INSIDE_JOB=0
VERBOSE=0

usage() {
  sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage ;;
    --report)
      [ $# -ge 2 ] || { echo "需要 --report <檔案>" >&2; exit 2; }
      REPORT_FILE="$2"
      shift 2
      ;;
    --submit-pjm) SUBMIT_PJM=1; shift ;;
    --inside-job) INSIDE_JOB=1; shift ;;
    --verbose) VERBOSE=1; shift ;;
    *) echo "未知參數: $1（試 --help）" >&2; exit 2 ;;
  esac
done

if [ -n "$REPORT_FILE" ] && [[ "$REPORT_FILE" != /* ]]; then
  REPORT_FILE="$PART2_ROOT/$REPORT_FILE"
fi

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

part2_tests_chapter_07_notice() {
  if [ "${PART2_SKIP_07_NOTICE:-0}" = 1 ]; then
    return 0
  fi
  echo ""
  echo "########## 07_Multi_Node_GPU_Example（教材提示，非自動測試）##########"
  echo "多節點 GPU + MPI：${PART2_ROOT}/07_Multi_Node_GPU_Example/README.md"
  echo "本倉庫範例：${PART2_ROOT}/07_Multi_Node_GPU_Example（make mpi_cuda_rank_info、pjsub job_mpi_cuda_rank_info.sh）"
  echo "進階腳本可另見：\${HOME}/sample/GPU_multiNodes/"
  if [ -d "${HOME}/sample/GPU_multiNodes" ]; then
    echo "（已偵測到目錄，列舉前幾項）"
    ls -la "${HOME}/sample/GPU_multiNodes" 2>/dev/null | head -12 || true
  else
    echo "（目前無 ${HOME}/sample/GPU_multiNodes，略過列舉）"
  fi
}

part2_preflight_direct() {
  if [ "$INSIDE_JOB" -eq 1 ] || [ "$SUBMIT_PJM" -eq 1 ]; then
    return 0
  fi
  if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
    return 0
  fi
  log "================================================================================"
  log "ABORT（非測試失敗）：目前環境無法使用 GPU（nvidia-smi 不可用或無裝置）。"
  log "請擇一："
  log "  • 進入 GPU 計算節點／互動式資源後執行："
  log "      cd $PART2_ROOT && ./run_part2_tests.sh [--report part2_autotest.log]"
  log "  • 由登入節點送 PJM 批次（與 Part1 run_all_tests.sh --submit-pjm 同概念）："
  log "      export PJM_GROUP=你的群組"
  log "      cd $PART2_ROOT && ./run_part2_tests.sh --submit-pjm"
  log "  • 或手動：pjsub $PART2_ROOT/job_run_part2_gpu.sh"
  log "================================================================================"
  exit 3
}

run_part2_gpu_payload() {
  cd "$PART2_ROOT" || exit 1
  echo ">>> run_part2_tests：run_part2_gpu.sh（編譯 01→05；煙霧 01→05 + 06 Singularity 選用）"
  echo ">>> 結束後：07 多節點提示（PART2_SKIP_07_NOTICE=1 可關）"
  echo ""
  if [ -n "$REPORT_FILE" ]; then
    {
      echo "================================================================================"
      echo "Part2 GPU 檢查報告 開始 $(date '+%Y-%m-%d %H:%M:%S %z')"
      echo "主機: $(hostname 2>/dev/null || true)"
      echo "================================================================================"
    } | tee -a "$REPORT_FILE"
    if [ "$VERBOSE" = 1 ]; then
      bash -x ./run_part2_gpu.sh 2>&1 | tee -a "$REPORT_FILE"
    else
      bash ./run_part2_gpu.sh 2>&1 | tee -a "$REPORT_FILE"
    fi
    ec=${PIPESTATUS[0]}
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] run_part2_gpu.sh 結束，exit=$ec" | tee -a "$REPORT_FILE"
    part2_tests_chapter_07_notice 2>&1 | tee -a "$REPORT_FILE"
    return "$ec"
  fi
  if [ "$VERBOSE" = 1 ]; then
    bash -x ./run_part2_gpu.sh
  else
    bash ./run_part2_gpu.sh
  fi
  ec=$?
  part2_tests_chapter_07_notice
  exit "$ec"
}

submit_pjm_job() {
  local group="${PJM_GROUP:-$(groups 2>/dev/null | awk '{print $1}')}"
  if [ -z "$group" ]; then
    echo "錯誤：送批次請設定環境變數 PJM_GROUP（叢集群組）" >&2
    exit 2
  fi
  if ! command -v pjsub >/dev/null 2>&1; then
    echo "錯誤：找不到 pjsub" >&2
    exit 2
  fi

  local elapse="${PART2_PJM_ELAPSE:-01:00:00}"
  local logf="${PART2_PJM_LOG:-part2_gpu_autotest.log}"
  local ru="${PART2_PJM_RU:-rscunit_pg01}"
  local rg="${PART2_PJM_RG:-gpu-rd-small}"
  local gshare="${PART2_GPU_SHARE:-1}"
  local vn="${PART2_VNODE:-1}"
  local vcore="${PART2_VNODE_CORE:-1}"
  local vmem="${PART2_VNODE_MEM:-64Gi}"
  local mpi_proc="${PART2_MPI_PROC:-1}"
  local jobfile="$PART2_ROOT/.part2_gpu_autotest_job.sh"
  local qroot
  printf -v qroot '%q' "$PART2_ROOT"

  local cuda_export=""
  if [ -n "${PART2_CUDA_MODULE:-}" ]; then
    local qcm
    printf -v qcm '%q' "$PART2_CUDA_MODULE"
    cuda_export="export PART2_CUDA_MODULE=${qcm}"
  else
    cuda_export="# PART2_CUDA_MODULE 未設定"
  fi

  cat >"$jobfile" <<EOF
#!/bin/bash
#PJM -N part2-gpu-autotest
#PJM -j
#PJM -o ${logf}
#PJM -L ru=${ru}
#PJM -L rg=${rg}
#PJM -L gpu-share=${gshare}
#PJM -L vnode=${vn}
#PJM -L vnode-core=${vcore}
#PJM -L vnode-mem=${vmem}
#PJM -L elapse=${elapse}
#PJM -g ${group}
#PJM --mpi proc=${mpi_proc}
#PJM --sparam wait-time=600

set -euo pipefail
${cuda_export}
cd ${qroot}
exec bash ./run_part2_tests.sh --inside-job
EOF
  chmod +x "$jobfile"
  log "已寫入: $jobfile"
  local out
  if ! out=$(pjsub "$jobfile" 2>&1); then
    echo "$out" >&2
    exit 1
  fi
  echo "$out"
  local jid
  jid=$(echo "$out" | grep -oE '[0-9]{6,}' | head -1)
  log "推測 Job ID: ${jid:-未知}（請以叢集實際輸出為準）"

  if command -v pjwait >/dev/null 2>&1 && [ -n "${jid:-}" ]; then
    log "等待工作完成 (pjwait $jid)..."
    pjwait "$jid" || true
  else
    log "未使用 pjwait。請 pjstat 查詢或查看: ${logf}"
  fi
}

if [ "$INSIDE_JOB" -eq 1 ]; then
  part2_preflight_direct
  run_part2_gpu_payload
  exit $?
fi

if [ "$SUBMIT_PJM" -eq 1 ]; then
  submit_pjm_job
  exit 0
fi

part2_preflight_direct
run_part2_gpu_payload
exit $?
