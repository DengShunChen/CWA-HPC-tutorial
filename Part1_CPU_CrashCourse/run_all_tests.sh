#!/usr/bin/env bash
# Part 1 全自動測試：編譯 + 執行驗證
# 批次提交：本課程以 Fujitsu PJM 為主（#PJM、pjsub）；--submit-pjm 會產生 PJM 工作腳本。
#
# 用法：
#   ./run_all_tests.sh                          # 本機（預設）
#   ./run_all_tests.sh --report FILE.log        # 寫入報告（含環境快照）
#   ./run_all_tests.sh --report FILE.log --verbose  # 另附完整 make／執行輸出（檔案可能很大）
#   PJM_GROUP=your_group ./run_all_tests.sh --submit-pjm
#       # 登入節點有 pjsub 時：產生工作腳本並提交，計算節點上執行與本機相同之測試
#
# 涵蓋範圍（預設）— 對齊 Part1 編號目錄：
#   00_HPC_Workflow：無程式可測，本腳本不包含。
#   01–03：make + 執行；03 對 C++ 做數值字串抽樣。
#   04–07：make + make run_all。
#   08：make + microbench_dbg／microbench_opt；buggy_bounds 僅確認已建置、不執行。
#   09：委派 09/.../run_tests.sh（MPI／FAPP／FIPP 延伸見該腳本與 RUN_* 環境變數）。
#   10：Optimization_Loop_Demo — make + 執行 loop_baseline／loop_optimized，比對 checksum（容差與 run_optimization_loop.sh 一致）；不跑 fipp 全 7 步（該流程請手動跑 run_optimization_loop.sh）。
#   未納入：pjm_smoke_test.sh（需自行改群組與 pjsub）。
#
# 環境變數（--submit-pjm 與「直接執行」皆可沿用）：
#   PJM_GROUP      必填：叢集群組（僅 --submit-pjm）
#   PJM_RSCGRP     預設 small
#   PJM_ELAPSE     預設 01:00:00（完整 Part1 測試較久，可再加長）
#   PJM_LOG        預設 part1_autotest.log（相對於提交時的工作目錄）
#   PJM_MODULE_USE 預設 /package/fx1000/modulefiles/；若設為 0 則不執行 module use
#   PJM_MODULE     預設 tcsds/1.2.40；若設為 0 或空則不執行 module load
#   PART1_SKIP_09=1  略過第 09 章（加速 smoke）
#   PART1_SKIP_10=1  略過第 10 章 Optimization_Loop_Demo
#   PART1_LOOP_FAST=1  第 10 章改用較小 LOOP_DEMO_N／REPS（可另設 PART1_LOOP_DEMO_N、PART1_LOOP_DEMO_REPS）
#   若目前 PATH 無 frt，腳本會嘗試 source 常見 module 初始化檔並執行上述 module use/load（pjsub 非互動工作常需此行為）。
#
# 教學預設：須「編譯且執行」Fortran／C++ 全測。ln23 可用 cross **frtpx** 編譯，
# 但完整測試執行請在 fx1000 計算節點原生 **frt** 環境（或 pjsub）進行。

set -uo pipefail

PART1_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILURES=0
REPORT_FILE=""
VERBOSE=0
SUBMIT_PJM=0
INSIDE_JOB=0
SKIP_09=0
SKIP_10=0
RUN_START_SEC="$SECONDS"

usage() {
  sed -n '2,48p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage ;;
    --report)
      [ $# -ge 2 ] || { echo "需要 --report <檔案>"; exit 2; }
      REPORT_FILE="$2"
      shift 2
      ;;
    --submit-pjm) SUBMIT_PJM=1; shift ;;
    --inside-job) INSIDE_JOB=1; shift ;;
    --verbose) VERBOSE=1; shift ;;
    *) echo "未知參數: $1（試 --help）" >&2; exit 2 ;;
  esac
done

[ "${PART1_SKIP_09:-0}" = 1 ] && SKIP_09=1
[ "${PART1_SKIP_10:-0}" = 1 ] && SKIP_10=1

# 報告檔寫在 Part1 根目錄下（若為相對路徑）
if [ -n "$REPORT_FILE" ] && [[ "$REPORT_FILE" != /* ]]; then
  REPORT_FILE="$PART1_ROOT/$REPORT_FILE"
fi

log() {
  local line="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  echo "$line"
  if [ -n "${REPORT_FILE:-}" ]; then echo "$line" >>"$REPORT_FILE"; fi
}

pass() { log "PASS  $*"; }
fail() { log "FAIL  $*"; FAILURES=$((FAILURES + 1)); }

# verbose 時將子程序輸出同步寫入報告（若已指定 --report）
tee_report() {
  if [ -n "$REPORT_FILE" ]; then
    tee -a "$REPORT_FILE"
  else
    cat
  fi
}

part1_init_module_cmd() {
  if type module >/dev/null 2>&1; then
    return 0
  fi
  local f
  for f in /etc/profile.d/modules.sh /usr/share/lmod/lmod/init/bash /usr/share/Modules/init/bash; do
    if [ -f "$f" ]; then
      # shellcheck source=/dev/null
      . "$f"
      break
    fi
  done
  type module >/dev/null 2>&1
}

# 於 pjsub 非互動 shell 中補上 TCS，使 frt 進入 PATH（與 --submit-pjm 內嵌行為一致）
part1_try_module_load_tcs() {
  command -v frt >/dev/null 2>&1 && return 0
  part1_init_module_cmd || return 1
  local mod_use="${PJM_MODULE_USE:-/package/fx1000/modulefiles/}"
  local mod="${PJM_MODULE:-tcsds/1.2.40}"
  [ "$mod" = "0" ] && return 1
  [ -z "$mod" ] && return 1
  if [ -n "$mod_use" ] && [ "$mod_use" != "0" ]; then
    module use "$mod_use" 2>/dev/null || true
  fi
  module load "$mod" 2>/dev/null || return 1
  command -v frt >/dev/null 2>&1
}

dump_environment() {
  local block
  block="================================================================================
Part1 測試環境快照
時間: $(date '+%Y-%m-%d %H:%M:%S %z')
主機: $(hostname 2>/dev/null || echo '(unknown)')
使用者: ${USER:-?}
工作目錄: $PART1_ROOT
uname: $(uname -a)
Shell: ${BASH_VERSION:-?}
--- 編譯器（Fortran：ln23 可 frtpx；fx1000 計算節點用 frt） ---
$(command -v frt >/dev/null 2>&1 && { echo "frt: $(command -v frt)"; frt --version 2>&1 | head -8; } || echo "frt: 未找到（請於 A64FX 計算節點 module load TCS 後再測）")
$(command -v frtpx >/dev/null 2>&1 && { echo "frtpx: $(command -v frtpx)"; frtpx --version 2>&1 | head -8; } || echo "frtpx: 未找到")
$(command -v g++ >/dev/null 2>&1 && { echo "g++: $(command -v g++)"; g++ --version 2>&1 | head -3; } || echo "g++: 未找到")
$(command -v FCC >/dev/null 2>&1 && { echo "FCC: $(command -v FCC)"; FCC --version 2>&1 | head -5; } || echo "FCC: 未找到")
--- 其他 ---
$(command -v make >/dev/null 2>&1 && make --version 2>&1 | head -1 || echo "make: 未找到")
pjsub: $(command -v pjsub 2>/dev/null || echo 未找到)
VERBOSE: $VERBOSE  PART1_SKIP_09: $SKIP_09  PART1_SKIP_10: $SKIP_10
================================================================================"
  echo "$block"
  if [ -n "$REPORT_FILE" ]; then echo "$block" >>"$REPORT_FILE"; fi
}

preflight_check_runtime() {
  # 教學要求為「編譯 + 執行」全測：ln23 可用 frtpx 編譯，但完整執行必須在 fx1000 的 frt 環境。
  if [ "${INSIDE_JOB:-0}" -eq 1 ]; then
    if command -v frt >/dev/null 2>&1; then
      return 0
    fi
    if part1_try_module_load_tcs; then
      log "（--inside-job）已補載 TCS，找到 frt。"
      return 0
    fi
    log "================================================================================"
    log "ABORT（非測試 FAIL）：--inside-job 環境仍無 frt。請確認 PJM 腳本內 module load，或設 PJM_MODULE／PJM_MODULE_USE。"
    log "================================================================================"
    exit 3
  fi
  if command -v frt >/dev/null 2>&1; then
    return 0
  fi
  if part1_try_module_load_tcs; then
    log "已透過 module 載入 TCS（PJM_MODULE_USE／PJM_MODULE），找到 frt。"
    return 0
  fi
  if command -v frtpx >/dev/null 2>&1; then
    log "================================================================================"
    log "ABORT（非測試 FAIL）：目前僅有 cross-compiler frtpx（如 ln23），完整執行測試需 fx1000 計算節點的 frt。"
    log "請擇一："
    log "  • 由登入節點提交批次："
    log "      export PJM_GROUP=你的群組"
    log "      ./run_all_tests.sh --submit-pjm"
    log "  • 進入 fx1000 計算節點（module load tcsds/1.2.40）後執行："
    log "      ./run_all_tests.sh --report part1_autotest_report.txt"
    log "================================================================================"
    exit 3
  fi
  log "================================================================================"
  log "ABORT（非測試 FAIL）：目前環境找不到 Fortran 原生編譯器 frt，無法進行 Part1 完整執行測試。"
  log "請擇一："
  log "  • 進入 A64FX 計算節點（module load tcsds/1.2.40）後再執行："
  log "      ./run_all_tests.sh --report part1_autotest_report.txt"
  log "  • 由登入節點提交批次："
  log "      export PJM_GROUP=你的群組"
  log "      ./run_all_tests.sh --submit-pjm"
  log "================================================================================"
  exit 3
}

run_make() {
  local name="$1" dir="$2"
  local d="$PART1_ROOT/$dir"
  log "---- make: $name ----"
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) make clean && make 完整輸出："
    if (cd "$d" && make clean && make) 2>&1 | tee_report; then
      pass "make $name"
    else
      fail "make $name"
      return 1
    fi
  else
    if (cd "$d" && make clean >/dev/null && make); then
      pass "make $name"
    else
      fail "make $name"
      return 1
    fi
  fi
}

# 共通：某章 make 成功後執行 make run_all（04–07）
test_chapter_make_run_all() {
  local label="$1" subdir="$2"
  local d="$PART1_ROOT/$subdir"
  run_make "$label" "$subdir" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) $label make run_all 輸出："
    if (cd "$d" && make run_all) 2>&1 | tee_report; then
      pass "$label make run_all"
    else
      fail "$label make run_all"
    fi
  else
    if (cd "$d" && make run_all >/dev/null); then
      pass "$label make run_all"
    else
      fail "$label make run_all"
    fi
  fi
}

test_01() {
  run_make "01_Hello" "01_Hello" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) hello_fortran / hello_cpp 輸出："
    (cd "$PART1_ROOT/01_Hello" && ./hello_fortran) 2>&1 | tee_report
    (cd "$PART1_ROOT/01_Hello" && ./hello_cpp) 2>&1 | tee_report
  fi
  if (cd "$PART1_ROOT/01_Hello" && ./hello_fortran >/dev/null && ./hello_cpp >/dev/null); then
    pass "01_Hello 執行"
  else
    fail "01_Hello 執行"
  fi
}

test_02() {
  run_make "02_Vector_Add" "02_Vector_Add" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) 向量加法各程式輸出末段（tail -30，避免日誌過大）："
    local x
    for x in vec_add_fortran vec_add_cpp vec_add_optimized_fortran vec_add_optimized_cpp; do
      echo "--- $x ---" | tee_report
      (cd "$PART1_ROOT/02_Vector_Add" && "./$x") 2>&1 | tail -30 | tee_report
    done
  fi
  if (cd "$PART1_ROOT/02_Vector_Add" && \
      ./vec_add_fortran >/dev/null && ./vec_add_cpp >/dev/null && \
      ./vec_add_optimized_fortran >/dev/null && ./vec_add_optimized_cpp >/dev/null); then
    pass "02_Vector_Add 四程式執行"
  else
    fail "02_Vector_Add 四程式執行"
  fi
}

test_03() {
  run_make "03_Challenge" "03_Challenge" || return
  local out cpp_ok=0
  out="$(cd "$PART1_ROOT/03_Challenge" && ./multiply_cpp 2>&1)" || true
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) multiply_cpp 完整輸出："
    echo "$out" | tee_report
  fi
  if echo "$out" | grep -q "前 5 個結果: 0.000000 2.000000 8.000000 18.000000 32.000000"; then
    cpp_ok=1
  fi
  if (cd "$PART1_ROOT/03_Challenge" && ./multiply_fortran >/dev/null); then
    if [ "$cpp_ok" = 1 ]; then
      pass "03_Challenge 執行與 C++ 數值抽樣"
    else
      fail "03_Challenge C++ 數值抽樣不符預期"
    fi
  else
    fail "03_Challenge Fortran 執行"
  fi
}

test_08() {
  local d="$PART1_ROOT/08_Debug_Profile"
  run_make "08_Debug_Profile" "08_Debug_Profile" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) microbench_dbg / microbench_opt 輸出末段（tail -25）："
    (cd "$d" && ./microbench_dbg) 2>&1 | tail -25 | tee_report
    (cd "$d" && ./microbench_opt) 2>&1 | tail -25 | tee_report
  fi
  if (cd "$d" && ./microbench_dbg >/dev/null && ./microbench_opt >/dev/null); then
    pass "08_Debug_Profile microbench 執行"
  else
    fail "08_Debug_Profile microbench 執行"
  fi
  if [[ -x "$d/buggy_bounds" ]]; then
    pass "08_Debug_Profile buggy_bounds 已建置（未執行；教學除錯用）"
  else
    fail "08_Debug_Profile buggy_bounds 未建置"
  fi
}

test_09() {
  local rt=0
  log "---- 09_Profiler_Toolkit_TCS / run_tests.sh ----"
  if [ "$VERBOSE" = 1 ]; then
    bash "$PART1_ROOT/09_Profiler_Toolkit_TCS/run_tests.sh" > >(tee_report) 2>&1
    rt=$?
  else
    bash "$PART1_ROOT/09_Profiler_Toolkit_TCS/run_tests.sh"
    rt=$?
  fi
  if [ "$rt" -eq 0 ]; then
    pass "09_Profiler_Toolkit_TCS run_tests.sh"
  else
    fail "09_Profiler_Toolkit_TCS run_tests.sh（exit $rt）"
  fi
}

test_10_loop_metric() {
  local key="$1" text="$2"
  echo "$text" | grep -oE "${key}=[[:space:]]*[0-9.eE+-]+" | head -1 | awk -F= '{gsub(/[[:space:]]/,"",$2); print $2}'
}

test_10() {
  local d="$PART1_ROOT/10_Troubleshooting_Clinic/Optimization_Loop_Demo"
  log "---- 10 Optimization_Loop_Demo（make + baseline/optimized；checksum 一致；不跑 fipp）----"
  if [ "${PART1_LOOP_FAST:-0}" = 1 ]; then
    export LOOP_DEMO_N="${PART1_LOOP_DEMO_N:-400}"
    export LOOP_DEMO_REPS="${PART1_LOOP_DEMO_REPS:-4}"
  fi
  run_make "10_Optimization_Loop_Demo" "10_Troubleshooting_Clinic/Optimization_Loop_Demo" || return
  local out_b out_o cb co
  out_b="$(cd "$d" && ./loop_baseline 2>&1)" || {
    fail "10 loop_baseline 執行"
    return
  }
  out_o="$(cd "$d" && ./loop_optimized 2>&1)" || {
    fail "10 loop_optimized 執行"
    return
  }
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) loop_baseline / loop_optimized 輸出："
    echo "$out_b" | tee_report
    echo "$out_o" | tee_report
  fi
  if ! echo "$out_b" | grep -q 'checksum=' || ! echo "$out_o" | grep -q 'checksum='; then
    fail "10 輸出應含 checksum="
    return
  fi
  cb="$(test_10_loop_metric checksum "$out_b")"
  co="$(test_10_loop_metric checksum "$out_o")"
  if [ -z "$cb" ] || [ -z "$co" ]; then
    fail "10 無法擷取 checksum"
    return
  fi
  if ! awk -v b="$cb" -v o="$co" 'BEGIN {
    d = b - o; if (d < 0) d = -d;
    exit(d > 1.0e-5 ? 1 : 0)
  }'; then
    fail "10 baseline/optimized checksum 差異過大（baseline=$cb optimized=$co）"
    return
  fi
  pass "10 Optimization_Loop_Demo 編譯與 checksum 一致"
}

submit_pjm_job() {
  local group="${PJM_GROUP:-$(groups | awk '{print $1}')}"
  if [ -z "$group" ]; then
    echo "錯誤：送批次需設定環境變數 PJM_GROUP（您的叢集群組）" >&2
    exit 2
  fi
  if ! command -v pjsub >/dev/null 2>&1; then
    echo "錯誤：找不到 pjsub，無法送批次" >&2
    exit 2
  fi

  local rscgrp="${PJM_RSCGRP:-small}"
  # 01–10 含多次大迴圈與矩陣測試，計算節點建議至少 1 小時（可 export PJM_ELAPSE 覆寫）
  local elapse="${PJM_ELAPSE:-01:00:00}"
  local logf="${PJM_LOG:-part1_autotest.log}"
  local mod_use="${PJM_MODULE_USE:-/package/fx1000/modulefiles/}"
  local mod="${PJM_MODULE:-tcsds/1.2.40}"
  local jobfile="$PART1_ROOT/.part1_autotest_job.sh"
  local qroot
  printf -v qroot '%q' "$PART1_ROOT"

  local use_line=""
  if [ -n "$mod_use" ] && [ "$mod_use" != "0" ]; then
    use_line="module use ${mod_use} 2>/dev/null || true"
  else
    use_line="# PJM_MODULE_USE=0，略過 module use"
  fi

  local mod_line="module load ${mod} 2>/dev/null || true"
  if [ "$mod" = "0" ] || [ -z "$mod" ]; then
    mod_line="# PJM_MODULE=0，略過 module load"
  fi

  cat >"$jobfile" <<EOF
#!/bin/bash
#PJM -L "rscgrp=${rscgrp}"
#PJM -L "node=1"
#PJM -L "elapse=${elapse}"
#PJM -g ${group}
#PJM -j
#PJM -o ${logf}

set -euo pipefail
${use_line}
${mod_line}
cd ${qroot}
exec bash ./run_all_tests.sh --inside-job --report part1_autotest_report.txt
EOF
  chmod +x "$jobfile"
  echo "已寫入: $jobfile"
  local out
  if ! out=$(pjsub "$jobfile" 2>&1); then
    echo "$out" >&2
    fail "pjsub 提交失敗"
    return 1
  fi
  echo "$out"
  local jid
  jid=$(echo "$out" | grep -oE '[0-9]{6,}' | head -1)
  echo "[$(date '+%H:%M:%S')] 推測 Job ID: ${jid:-未知}（請以叢集實際輸出為準）"

  if command -v pjwait >/dev/null 2>&1 && [ -n "${jid:-}" ]; then
    echo "[$(date '+%H:%M:%S')] 等待工作完成 (pjwait $jid)..."
    if pjwait "$jid"; then pass "pjwait 結束"; else fail "pjwait 非零狀態"; fi
  else
    echo "[$(date '+%H:%M:%S')] 未使用 pjwait。請以 pjstat 查詢或查看日誌: ${logf}"
  fi
}

run_all() {
  log "===== Part1 自動測試開始 ====="
  log "目錄: $PART1_ROOT"
  if [ -n "$REPORT_FILE" ]; then
    dump_environment
  fi
  preflight_check_runtime
  test_01
  test_02
  test_03
  test_chapter_make_run_all "04_Matrix_Operations" "04_Matrix_Operations"
  test_chapter_make_run_all "05_File_IO" "05_File_IO"
  test_chapter_make_run_all "06_Functions_Modules" "06_Functions_Modules"
  test_chapter_make_run_all "07_Structures" "07_Structures"
  test_08
  if [ "$SKIP_09" = 1 ]; then
    log "略過 09（PART1_SKIP_09=1）"
  else
    test_09
  fi
  if [ "$SKIP_10" = 1 ]; then
    log "略過 10（PART1_SKIP_10=1）"
  else
    test_10
  fi
  log "===== 結束：失敗項目數 = $FAILURES；總耗時約 $((SECONDS - RUN_START_SEC)) 秒 ====="
}

if [ "$INSIDE_JOB" -eq 1 ]; then
  run_all
  exit "$FAILURES"
fi

if [ "$SUBMIT_PJM" -eq 1 ]; then
  submit_pjm_job
  exit "$FAILURES"
fi

run_all
exit "$FAILURES"
