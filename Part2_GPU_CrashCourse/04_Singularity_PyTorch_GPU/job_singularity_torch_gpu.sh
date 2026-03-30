#!/bin/bash
# PJM 批次：在 GPU 節點上以 Singularity 跑 PyTorch CUDA 測試。
# 資源行與互動式 pjsub 同語系；若提交失敗請依貴站規範調整 ru/rg、vnode、proc 等。
# 使用：在含本腳本與 test_cuda_torch.py 的目錄下執行 pjsub job_singularity_torch_gpu.sh

#PJM -N sing-torch-gpu
#PJM -j
#PJM -o sing_torch_gpu.%j.out
#PJM -L ru=rscunit_pg01
#PJM -L rg=gpu-rd-small
#PJM -L gpu-share=1
#PJM -L vnode=1
#PJM -L vnode-core=1
#PJM -L vnode-mem=64Gi
#PJM -L elapse=1:00:00
#PJM --mpi proc=1

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
export SINGULARITY_SIF="${SINGULARITY_SIF:-${HOME}/sample/singularity/torch_1.13.1_cuda11.6.sif}"
cd "$ROOT"
bash ./run_singularity_gpu_test.sh
