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
# 環境變數（僅 --submit-pjm）：
#   PJM_GROUP      必填：叢集群組
#   PJM_RSCGRP     預設 small
#   PJM_ELAPSE     預設 01:00:00（完整 Part1 測試較久，可再加長）
#   PJM_LOG        預設 part1_autotest.log（相對於提交時的工作目錄）
#   PJM_MODULE_USE 預設 /package/fx1000/modulefiles/；若設為 0 則不執行 module use
#   PJM_MODULE     預設 tcsds/1.2.40；若設為 0 或空則不執行 module load
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

usage() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
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
VERBOSE: $VERBOSE
================================================================================"
  echo "$block"
  if [ -n "$REPORT_FILE" ]; then echo "$block" >>"$REPORT_FILE"; fi
}

preflight_check_runtime() {
  # 教學要求為「編譯 + 執行」全測：ln23 可用 frtpx 編譯，但完整執行必須在 fx1000 的 frt 環境。
  if [ "${INSIDE_JOB:-0}" -eq 1 ]; then
    return 0
  fi
  if command -v frt >/dev/null 2>&1; then
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

test_04() {
  run_make "04_Matrix_Operations" "04_Matrix_Operations" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) make run_all 輸出："
    if (cd "$PART1_ROOT/04_Matrix_Operations" && make run_all) 2>&1 | tee_report; then
      pass "04_Matrix_Operations make run_all"
    else
      fail "04_Matrix_Operations make run_all"
    fi
  else
    if (cd "$PART1_ROOT/04_Matrix_Operations" && make run_all >/dev/null); then
      pass "04_Matrix_Operations make run_all"
    else
      fail "04_Matrix_Operations make run_all"
    fi
  fi
}

test_05() {
  run_make "05_File_IO" "05_File_IO" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) make run_all 輸出："
    if (cd "$PART1_ROOT/05_File_IO" && make run_all) 2>&1 | tee_report; then
      pass "05_File_IO make run_all"
    else
      fail "05_File_IO make run_all"
    fi
  else
    if (cd "$PART1_ROOT/05_File_IO" && make run_all >/dev/null); then
      pass "05_File_IO make run_all"
    else
      fail "05_File_IO make run_all"
    fi
  fi
}

test_06() {
  run_make "06_Functions_Modules" "06_Functions_Modules" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) make run_all 輸出："
    if (cd "$PART1_ROOT/06_Functions_Modules" && make run_all) 2>&1 | tee_report; then
      pass "06_Functions_Modules make run_all"
    else
      fail "06_Functions_Modules make run_all"
    fi
  else
    if (cd "$PART1_ROOT/06_Functions_Modules" && make run_all >/dev/null); then
      pass "06_Functions_Modules make run_all"
    else
      fail "06_Functions_Modules make run_all"
    fi
  fi
}

test_07() {
  run_make "07_Structures" "07_Structures" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) make run_all 輸出："
    if (cd "$PART1_ROOT/07_Structures" && make run_all) 2>&1 | tee_report; then
      pass "07_Structures make run_all"
    else
      fail "07_Structures make run_all"
    fi
  else
    if (cd "$PART1_ROOT/07_Structures" && make run_all >/dev/null); then
      pass "07_Structures make run_all"
    else
      fail "07_Structures make run_all"
    fi
  fi
}

test_08() {
  run_make "08_Debug_Profile" "08_Debug_Profile" || return
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) microbench_dbg / microbench_opt 輸出末段（tail -25）："
    (cd "$PART1_ROOT/08_Debug_Profile" && ./microbench_dbg) 2>&1 | tail -25 | tee_report
    (cd "$PART1_ROOT/08_Debug_Profile" && ./microbench_opt) 2>&1 | tail -25 | tee_report
  fi
  if (cd "$PART1_ROOT/08_Debug_Profile" && \
      ./microbench_dbg >/dev/null && ./microbench_opt >/dev/null); then
    pass "08_Debug_Profile microbench 執行"
  else
    fail "08_Debug_Profile microbench 執行"
  fi
}

test_09() {
  if [ "$VERBOSE" = 1 ]; then
    log "(verbose) 09 run_tests.sh 完整輸出："
    # 使用 > >(tee) 保留子程序結束碼（避免 2>&1 | tee 永遠為成功）
    if bash "$PART1_ROOT/09_Profiler_Toolkit_TCS/run_tests.sh" > >(tee_report) 2>&1; then
      pass "09_Profiler_Toolkit_TCS run_tests.sh"
    else
      fail "09_Profiler_Toolkit_TCS run_tests.sh"
    fi
  else
    if bash "$PART1_ROOT/09_Profiler_Toolkit_TCS/run_tests.sh"; then
      pass "09_Profiler_Toolkit_TCS run_tests.sh"
    else
      fail "09_Profiler_Toolkit_TCS run_tests.sh"
    fi
  fi
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
  # 01–09 含多次大迴圈與矩陣測試，計算節點建議至少 1 小時（可 export PJM_ELAPSE 覆寫）
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
  test_04
  test_05
  test_06
  test_07
  test_08
  test_09
  log "===== 結束：失敗項目數 = $FAILURES ====="
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
