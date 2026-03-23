#!/usr/bin/env bash
# 09_Profiler_Toolkit_TCS — 自測：編譯 kernel_profile_opt、正確性抽樣
#
# FX1000：登入節點可用 frtpx 編譯，但完整執行與取樣請在計算節點（frt 環境）。
# 本腳本為「編譯 + 執行」自測，若僅有 frtpx 會中止並提示改以 pjsub。
#
# 選用環境變數（需 TCS 工具在 PATH，且建議 frt 編譯之執行檔）：
#   RUN_FIPP_TEST=1     — 驗證 fipp 取樣可寫入資料目錄
#   RUN_FIPPPX_TEST=1   — 先 fipp 取樣，再 fipppx -A 分析（依賴 fipp／fipppx）
#   RUN_FAPP_TEST=1     — 驗證 Advanced Performance Profiler 之 fapp 取樣（語法與 fipp 同型：-C -d）
#
# FX1000 上可一次跑：  make test-profilers
# 或：  RUN_FIPP_TEST=1 RUN_FIPPPX_TEST=1 RUN_FAPP_TEST=1 bash ./run_tests.sh

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

if ! command -v frt >/dev/null 2>&1 && command -v frtpx >/dev/null 2>&1; then
  echo "ABORT  目前僅有 frtpx（cross），請於 fx1000 計算節點（frt）執行 run_tests.sh，或用 pjsub 執行 job_kernel_profile.sh" >&2
  exit 3
fi

# 登入節點常限制長時間 CPU 工作；預設用較小 n 做自測（與下方 checksum 一致）。
# 完整量測請在計算節點執行並 unset KERNEL_PROFILE_N（沿用模組內 kernel_n_default）。
export KERNEL_PROFILE_N="${KERNEL_PROFILE_N:-5000000}"

failures=0
fail() { echo "FAIL  $*" >&2; failures=$((failures + 1)); }
pass() { echo "PASS  $*"; }

count_files() {
  find "$1" -type f 2>/dev/null | wc -l
}

extract_metric() {
  # 從輸出中擷取 key=number（允許同一行有多個 key=value）。
  local key="$1" text="$2"
  local value
  value="$(
    echo "$text" \
      | grep -oE "${key}=[[:space:]]*[+-]?[0-9]+([.][0-9]+)?([eE][+-]?[0-9]+)?" \
      | awk -F= 'NR==1 {print $2; exit}' \
      | tr -d '[:space:]' || true
  )"
  echo "$value"
}

assert_close() {
  # 浮點容差比對，避免不同最佳化路徑造成尾數抖動。
  local actual="$1" expected="$2" tol="$3" label="$4"
  awk -v a="$actual" -v e="$expected" -v t="$tol" -v l="$label" '
    BEGIN {
      d = a - e; if (d < 0) d = -d;
      if (d > t) {
        printf("FAIL  %s 不符（actual=%s expected=%s tol=%s）\n", l, a, e, t) > "/dev/stderr";
        exit 1;
      }
    }
  ' || failures=$((failures + 1))
}

echo "---- 09_Profiler_Toolkit_TCS / run_tests.sh ----"

if ! make clean >/dev/null 2>&1 || ! make; then
  fail "make"
  exit "$failures"
fi

out="$(./kernel_profile_opt 2>&1)" || {
  fail "kernel_profile_opt 執行"
  exit "$failures"
}

echo "$out" | grep -q 'checksum_heavy=' || fail "輸出應含 checksum_heavy="
echo "$out" | grep -q 'checksum_stream=' || fail "輸出應含 checksum_stream="
echo "$out" | grep -q 'checksum_branch=' || fail "輸出應含 checksum_branch="
echo "$out" | grep -q 'checksum_light=' || fail "輸出應含 checksum_light="
echo "$out" | grep -q 'time_s=' || fail "輸出應含 time_s="

# 參考值對應 KERNEL_PROFILE_N=5000000（見 kernel_phases 註解）
heavy="$(extract_metric 'checksum_heavy' "$out")"
light="$(extract_metric 'checksum_light' "$out")"
if [ -n "$heavy" ]; then
  assert_close "$heavy" "248.997858" "0.001" "checksum_heavy"
else
  fail "未擷取到 checksum_heavy（輸出格式可能改變）"
fi
if [ -n "$light" ]; then
  assert_close "$light" "1.499985" "0.001" "checksum_light"
else
  fail "未擷取到 checksum_light（輸出格式可能改變）"
fi

if [[ -x ./region_marked ]]; then
  out_r="$(./region_marked 2>&1)" || fail "region_marked 執行"
  echo "$out_r" | grep -q 'checksum_heavy=' || fail "region_marked 輸出格式"
  echo "$out_r" | grep -q 'checksum_stream=' || fail "region_marked 缺 checksum_stream"
  echo "$out_r" | grep -q 'checksum_branch=' || fail "region_marked 缺 checksum_branch"
  heavy_r="$(extract_metric 'checksum_heavy' "$out_r")"
  if [ -n "$heavy_r" ]; then
    assert_close "$heavy_r" "248.997858" "0.001" "region_marked checksum_heavy"
  else
    fail "未擷取到 region_marked checksum_heavy（輸出格式可能改變）"
  fi
  pass "region_marked 執行與抽樣（frt 環境）"
fi

# --- FIPP：取樣並檢查目錄內有檔案 ---
if [[ "${RUN_FIPP_TEST:-0}" == "1" ]] && command -v fipp >/dev/null 2>&1; then
  rm -rf tmp_fipp_autotest
  mkdir -p tmp_fipp_autotest
  fipp_ok=0
  if [[ -x ./region_marked ]]; then
    if fipp -C -d ./tmp_fipp_autotest -Sregion ./region_marked >/dev/null 2>&1; then
      fipp_ok=1
    fi
  else
    if fipp -C -d ./tmp_fipp_autotest ./kernel_profile_opt >/dev/null 2>&1; then
      fipp_ok=1
    fi
  fi
  if [[ "$fipp_ok" -eq 1 ]]; then
    nfiles=$(count_files tmp_fipp_autotest)
    if [[ "$nfiles" -ge 1 ]]; then
      pass "RUN_FIPP_TEST=1：fipp 已產生檔案（${nfiles}）"
    else
      fail "fipp 未產生檔案"
    fi
  else
    fail "fipp 執行失敗"
  fi
  rm -rf tmp_fipp_autotest
elif [[ "${RUN_FIPP_TEST:-0}" == "1" ]]; then
  echo "SKIP  RUN_FIPP_TEST=1 但 PATH 無 fipp" >&2
fi

# --- fipppx：登入節點分析（需先有 fipp 資料）---
if [[ "${RUN_FIPPPX_TEST:-0}" == "1" ]]; then
  if ! command -v fipp >/dev/null 2>&1 || ! command -v fipppx >/dev/null 2>&1; then
    echo "SKIP  RUN_FIPPPX_TEST=1 但缺少 fipp 或 fipppx" >&2
  else
    rm -rf tmp_fipppx_autotest
    mkdir -p tmp_fipppx_autotest
    if fipp -C -d ./tmp_fipppx_autotest ./kernel_profile_opt >/dev/null 2>&1; then
      if fipppx -A -d ./tmp_fipppx_autotest >/dev/null 2>&1; then
        pass "RUN_FIPPPX_TEST=1：fipp 取樣後 fipppx -A 成功"
      else
        fail "fipppx -A 失敗（仍保留 tmp_fipppx_autotest 供除錯，可手動刪除）"
      fi
    else
      fail "fipp 取樣失敗（fipppx 前置）"
    fi
    rm -rf tmp_fipppx_autotest
  fi
fi

# --- FAPP（Advanced Performance Profiler）---
# 一舉兩得：（1）測試原有的 fapp -C -d 介面；（2）若 region_fapp 已建置，
# 再測試 fapp_start／fapp_stop 區域標記版本，並檢查輸出數字正確性。
if [[ "${RUN_FAPP_TEST:-0}" == "1" ]] && command -v fapp >/dev/null 2>&1; then
  rm -rf tmp_fapp_autotest
  mkdir -p tmp_fapp_autotest
  fapp_ok=0
  if [[ -x ./region_fapp ]]; then
    # region_fapp 含有 fapp_start／fapp_stop，須全程式級別啟動 fapp。
    if fapp -C -d ./tmp_fapp_autotest -L 1 ./region_fapp >/dev/null 2>&1; then
      fapp_ok=1
      # 檢查區域程式散出的數字正確性
      out_fa="$(./region_fapp 2>&1 || true)"
      heavy_fa="$(extract_metric 'checksum_heavy' "$out_fa")"
      echo "$out_fa" | grep -q 'checksum_stream=' || fail "region_fapp 缺 checksum_stream"
      echo "$out_fa" | grep -q 'checksum_branch=' || fail "region_fapp 缺 checksum_branch"
      if [ -n "$heavy_fa" ]; then
        assert_close "$heavy_fa" "248.997858" "0.001" "region_fapp checksum_heavy"
      else
        fail "未擷取到 region_fapp checksum_heavy（輸出格式可能改變）"
      fi
    fi
  else
    if fapp -C -d ./tmp_fapp_autotest ./kernel_profile_opt >/dev/null 2>&1; then
      fapp_ok=1
    fi
  fi
  if [[ "$fapp_ok" -eq 1 ]]; then
    nfiles=$(count_files tmp_fapp_autotest)
    if [[ "$nfiles" -ge 1 ]]; then
      pass "RUN_FAPP_TEST=1：fapp 已產生檔案（${nfiles}）"
    else
      fail "fapp 未產生檔案"
    fi
  else
    fail "fapp 執行失敗（若需 fapp_start／fapp_stop 或額外編譯選項，見 README／手冊）"
  fi
  rm -rf tmp_fapp_autotest
elif [[ "${RUN_FAPP_TEST:-0}" == "1" ]]; then
  echo "SKIP  RUN_FAPP_TEST=1 但 PATH 無 fapp" >&2
fi

[[ "$failures" -eq 0 ]] && pass "09 章節檢查通過"
[[ "$failures" -gt 0 ]] && echo "---- 失敗項數: $failures ----" >&2
exit "$failures"
