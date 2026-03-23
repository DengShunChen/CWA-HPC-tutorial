#!/usr/bin/env bash
# 09_Profiler_Toolkit_TCS — 一鍵 Profiling 工作流（FIPP / FAPP）
#
# 目的：
#   將「編譯 -> 取樣 -> 分析」收斂為可重複執行的腳本，方便課堂示範與學員自練。
#
# 範例：
#   ./run_profile_workflow.sh --mode fipp
#   ./run_profile_workflow.sh --mode fapp --level 1
#   ./run_profile_workflow.sh --mode all --outdir ./profile_out
#
# 注意：
# - 取樣建議在計算節點執行；fipppx 分析通常在登入節點。
# - 若當前環境無 fipp / fipppx / fapp，腳本會明確提示並退出。

set -euo pipefail

MODE="all"              # fipp | fapp | all
OUTDIR="./profile_out"
LEVEL=1                 # 僅對 fapp 有效
MPI_N=0                 # 0 表示不跑 MPI 範例
BUILD=1                 # 是否先 make clean && make

usage() {
  cat <<'EOF'
用法：
  ./run_profile_workflow.sh [選項]

選項：
  --mode <fipp|fapp|all>   指定執行模式（預設 all）
  --outdir <dir>           輸出根目錄（預設 ./profile_out）
  --level <N>              FAPP 啟用 level（預設 1）
  --mpi-n <N>              若 >0，額外執行 MPI 範例（rank 數）
  --no-build               跳過 make clean && make
  -h, --help               顯示說明
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"; shift 2 ;;
    --outdir)
      OUTDIR="${2:-}"; shift 2 ;;
    --level)
      LEVEL="${2:-}"; shift 2 ;;
    --mpi-n)
      MPI_N="${2:-}"; shift 2 ;;
    --no-build)
      BUILD=0; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "未知參數: $1" >&2
      usage
      exit 2 ;;
  esac
done

case "$MODE" in
  fipp|fapp|all) ;;
  *)
    echo "錯誤：--mode 僅接受 fipp | fapp | all" >&2
    exit 2 ;;
esac

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

echo "[INFO] 工作目錄: $HERE"
echo "[INFO] 模式: $MODE  outdir: $OUTDIR  level: $LEVEL  mpi-n: $MPI_N"

if [[ "$BUILD" -eq 1 ]]; then
  echo "[STEP] make clean && make"
  make clean >/dev/null 2>&1 || true
  make
  if [[ "$MODE" == "fapp" || "$MODE" == "all" ]]; then
    echo "[STEP] 嘗試建置 FAPP 範例（region_fapp）"
    make region_fapp >/dev/null 2>&1 || echo "[WARN] 無法建置 region_fapp，將退回 kernel_profile_opt"
    if [[ "$MPI_N" -gt 0 ]]; then
      make region_fapp_mpi_f90 >/dev/null 2>&1 || echo "[WARN] 無法建置 region_fapp_mpi_f90，略過 MPI FAPP"
    fi
  fi
  if [[ "$MPI_N" -gt 0 ]]; then
    echo "[STEP] 嘗試建置 MPI FIPP 範例（region_mpi_f90）"
    make region_mpi_f90 >/dev/null 2>&1 || echo "[WARN] 無法建置 region_mpi_f90，略過 MPI FIPP"
  fi
fi

mkdir -p "$OUTDIR"

run_fipp() {
  command -v fipp >/dev/null 2>&1 || { echo "[ERR] 找不到 fipp"; return 1; }
  command -v fipppx >/dev/null 2>&1 || { echo "[ERR] 找不到 fipppx"; return 1; }

  local d_all="$OUTDIR/fipp_all"
  local d_region="$OUTDIR/fipp_region"
  local a_all="$OUTDIR/fipp_all_analysis.txt"
  local a_region="$OUTDIR/fipp_region_analysis.txt"
  mkdir -p "$d_all" "$d_region"

  echo "[STEP] FIPP 全程式：kernel_profile_opt"
  fipp -C -d "$d_all" ./kernel_profile_opt
  echo "[STEP] FIPPPX 分析：$d_all -> $a_all"
  fipppx -A -d "$d_all" > "$a_all" 2>&1

  if [[ -x ./region_marked ]]; then
    echo "[STEP] FIPP 區段：region_marked (-Sregion)"
    fipp -C -d "$d_region" -Sregion ./region_marked
    echo "[STEP] FIPPPX 分析：$d_region -> $a_region"
    fipppx -A -d "$d_region" > "$a_region" 2>&1
  else
    echo "[WARN] 未找到 ./region_marked，略過區段量測"
  fi

  if [[ "$MPI_N" -gt 0 && -x ./region_mpi_f90 ]]; then
    local d_mpi="$OUTDIR/fipp_mpi_rank0"
    local a_mpi="$OUTDIR/fipp_mpi_rank0_analysis.txt"
    mkdir -p "$d_mpi"
    echo "[STEP] FIPP MPI（rank0）：mpiexec -n $MPI_N region_mpi_f90"
    mpiexec -n "$MPI_N" fipp -C -d "$d_mpi" -Sregion ./region_mpi_f90
    fipppx -A -d "$d_mpi" > "$a_mpi" 2>&1 || true
  fi
}

run_fapp() {
  command -v fapp >/dev/null 2>&1 || { echo "[ERR] 找不到 fapp"; return 1; }

  local d_fapp="$OUTDIR/fapp_level${LEVEL}"
  mkdir -p "$d_fapp"

  if [[ -x ./region_fapp ]]; then
    echo "[STEP] FAPP Fortran：region_fapp (-L $LEVEL)"
    fapp -C -d "$d_fapp" -L "$LEVEL" ./region_fapp
  else
    echo "[WARN] 未找到 ./region_fapp，改跑 kernel_profile_opt"
    fapp -C -d "$d_fapp" ./kernel_profile_opt
  fi

  if [[ "$MPI_N" -gt 0 && -x ./region_fapp_mpi_f90 ]]; then
    local d_mpi="$OUTDIR/fapp_mpi_rank0_level${LEVEL}"
    mkdir -p "$d_mpi"
    echo "[STEP] FAPP MPI（rank0）：mpiexec -n $MPI_N region_fapp_mpi_f90"
    mpiexec -n "$MPI_N" fapp -C -d "$d_mpi" -L "$LEVEL" ./region_fapp_mpi_f90
  fi
}

case "$MODE" in
  fipp) run_fipp ;;
  fapp) run_fapp ;;
  all)
    run_fipp
    run_fapp
    ;;
esac

echo "[DONE] Profiling 完成：$OUTDIR"
echo "[NEXT] 請依 PROFILE_REVIEW_TEMPLATE.md 填寫觀察結果"
