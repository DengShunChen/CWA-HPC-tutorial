#!/usr/bin/env bash
# 以現有 SIF（預設：$HOME/sample/singularity/torch_1.13.1_cuda11.6.sif）執行 PyTorch GPU 測試。
# 覆寫映像路徑：export SINGULARITY_SIF=/path/to/your.sif

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PART2_ROOT="$(cd "${HERE}/.." && pwd)"
# shellcheck source=/dev/null
[[ -f "${PART2_ROOT}/part2_lmod_bootstrap.sh" ]] && source "${PART2_ROOT}/part2_lmod_bootstrap.sh" && part2_lmod_bootstrap
part2_try_load_singularity_module 2>/dev/null || true

SIF="${SINGULARITY_SIF:-${HOME}/sample/singularity/torch_1.13.1_cuda11.6.sif}"

if [[ ! -f "$SIF" ]]; then
  echo "找不到 SIF: $SIF" >&2
  echo "請將映像置於上述路徑，或：export SINGULARITY_SIF=/path/to/torch_1.13.1_cuda11.6.sif" >&2
  exit 1
fi

SING="$(command -v singularity || true)"
APPT="$(command -v apptainer || true)"
if [[ -n "$SING" ]]; then
  CMD=("$SING")
elif [[ -n "$APPT" ]]; then
  CMD=("$APPT")
else
  echo "找不到 singularity 或 apptainer" >&2
  exit 1
fi

exec "${CMD[@]}" exec --nv \
  -B "${HERE}:/tutorial" \
  --pwd /tutorial \
  "$SIF" \
  python3 test_cuda_torch.py
