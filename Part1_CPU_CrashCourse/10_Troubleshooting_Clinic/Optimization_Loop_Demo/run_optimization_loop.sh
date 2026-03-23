#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

OUTDIR="${OUTDIR:-./loop_reports}"
BASE_DIR="${OUTDIR}/baseline"
OPT_DIR="${OUTDIR}/optimized"
rm -rf "$BASE_DIR" "$OPT_DIR"
mkdir -p "$BASE_DIR" "$OPT_DIR"
rm -f "${OUTDIR}/baseline_analysis.txt" "${OUTDIR}/optimized_analysis.txt" \
      "${OUTDIR}/baseline_output.txt" "${OUTDIR}/optimized_output.txt" "${OUTDIR}/summary.txt"

echo "=== Optimization Loop Demo ==="
echo "workdir: $HERE"
echo "outdir : $OUTDIR"

echo "[1/7] profiling (baseline 前置編譯)"
make clean >/dev/null 2>&1 || true
make baseline

echo "[2/7] analysis profiling report (baseline)"
fipp -C -d "$BASE_DIR" ./loop_baseline | tee "${OUTDIR}/baseline_run_stdout.log"
fipppx -A -d "$BASE_DIR" > "${OUTDIR}/baseline_analysis.txt" 2>&1

echo "[3/7] identify slow coding"
echo "  - 請查看 ${OUTDIR}/baseline_analysis.txt 的 Procedures/Loops profile"
echo "  - baseline 版本使用不友善走訪與迴圈內分支"

echo "[4/7] optimize coding"
make optimized

echo "[5/7] check output result"
./loop_baseline > "${OUTDIR}/baseline_output.txt"
./loop_optimized > "${OUTDIR}/optimized_output.txt"

extract_metric() {
  local key="$1" file="$2"
  grep -oE "${key}=[[:space:]]*[0-9.eE+-]+" "$file" | awk -F= 'NR==1 {gsub(/[[:space:]]/,"",$2); print $2}'
}

BASE_SUM="$(extract_metric checksum "${OUTDIR}/baseline_output.txt")"
OPT_SUM="$(extract_metric checksum "${OUTDIR}/optimized_output.txt")"
BASE_T="$(extract_metric time_s "${OUTDIR}/baseline_output.txt")"
OPT_T="$(extract_metric time_s "${OUTDIR}/optimized_output.txt")"

awk -v b="$BASE_SUM" -v o="$OPT_SUM" '
  BEGIN {
    d = b - o; if (d < 0) d = -d;
    if (d > 1.0e-5) {
      printf("checksum 差異過大: baseline=%s optimized=%s\n", b, o) > "/dev/stderr";
      exit 1;
    }
  }
'

echo "  checksum baseline=${BASE_SUM}"
echo "  checksum optimized=${OPT_SUM}"

echo "[6/7] reprofiling (optimized)"
fipp -C -d "$OPT_DIR" ./loop_optimized | tee "${OUTDIR}/optimized_run_stdout.log"
fipppx -A -d "$OPT_DIR" > "${OUTDIR}/optimized_analysis.txt" 2>&1

echo "[7/7] summarize"
awk -v b="$BASE_T" -v o="$OPT_T" '
  BEGIN {
    sp = (o > 0 ? b / o : 0);
    printf("baseline time_s=%s\noptimized time_s=%s\nspeedup=%.3fx\n", b, o, sp);
  }
' | tee "${OUTDIR}/summary.txt"

echo "完成："
echo "  - ${OUTDIR}/baseline_analysis.txt"
echo "  - ${OUTDIR}/optimized_analysis.txt"
echo "  - ${OUTDIR}/summary.txt"
