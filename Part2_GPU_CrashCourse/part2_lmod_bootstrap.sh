# Part2 共用：非登入／PJM 腳本環境下初始化 Lmod，並補上常見 MODULEPATH。
# 由 run_part2_gpu.sh、04/.../run_singularity_gpu_test.sh source（勿單獨執行）。
# shellcheck shell=bash

part2_lmod_bootstrap() {
  for init in \
    /usr/share/lmod/lmod/init/bash \
    /etc/profile.d/lmod.sh \
    /usr/share/Modules/init/bash \
    /etc/profile.d/modules.sh; do
    [[ -f "$init" ]] || continue
    # shellcheck source=/dev/null
    source "$init" || true
  done
  for mp in \
    /package/x86_64/nvidia/hpc_sdk/modulefiles \
    /package/x86_64/modulefiles \
    "${HOME}/privatemodules/x86_64"; do
    if [[ -d "$mp" ]]; then
      case ":${MODULEPATH:-}:" in
        *":$mp:"*) ;;
        *) export MODULEPATH="${mp}${MODULEPATH:+:}${MODULEPATH:-}" ;;
      esac
    fi
  done
}

# Singularity：① /package/x86_64/modulefiles 常見 singularity/ce-3.9.5_nosuid
#            ② $HOME/privatemodules/x86_64 常見 singularity/ce-3.9.5（與 _nosuid）
# 先試 nosuid：僅掛套件樹、未掛 privatemodules 的節點也能過。
part2_try_load_singularity_module() {
  command -v singularity >/dev/null 2>&1 && return 0
  command -v apptainer >/dev/null 2>&1 && return 0
  command -v module >/dev/null 2>&1 || return 1

  if [[ -n "${PART2_SINGULARITY_MODULE:-}" ]]; then
    module load "${PART2_SINGULARITY_MODULE}" 2>/dev/null || true
    command -v singularity >/dev/null 2>&1 && return 0
    command -v apptainer >/dev/null 2>&1 && return 0
  fi

  for m in \
    singularity/ce-3.9.5_nosuid \
    singularity/ce-3.9.5 \
    singularity; do
    module load "$m" 2>/dev/null || continue
    command -v singularity >/dev/null 2>&1 && return 0
    command -v apptainer >/dev/null 2>&1 && return 0
  done
  return 1
}
