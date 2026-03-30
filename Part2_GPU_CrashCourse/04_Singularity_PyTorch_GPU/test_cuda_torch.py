#!/usr/bin/env python3
"""Singularity + --nv 環境下之 PyTorch GPU 煙霧測試（對應 torch 1.13.1 / CUDA 11.6 映像）。"""

from __future__ import annotations

import sys
import time

import torch


def main() -> int:
    print("PyTorch:", torch.__version__)
    print("CUDA (torch build):", torch.version.cuda)
    cuda_ok = torch.cuda.is_available()
    print("cuda.is_available():", cuda_ok)
    if not cuda_ok:
        print(
            "FAIL: 容器內無法使用 CUDA。請確認："
            "① singularity/apptainer 使用 `exec --nv`；"
            "② 已在 GPU 節點上執行且 nvidia-smi 正常。",
            file=sys.stderr,
        )
        return 1

    n = torch.cuda.device_count()
    print("device_count:", n)
    for i in range(n):
        print(f"  [{i}] {torch.cuda.get_device_name(i)}")

    dev = torch.device("cuda:0")
    a = torch.randn(1024, 1024, device=dev)
    b = torch.randn(1024, 1024, device=dev)
    torch.cuda.synchronize()
    t0 = time.perf_counter()
    _ = a @ b
    torch.cuda.synchronize()
    dt = time.perf_counter() - t0
    print(f"matmul 1024^2 on GPU: {dt:.4f} s")
    print("OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
