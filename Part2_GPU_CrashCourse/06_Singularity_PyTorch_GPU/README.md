# 06_Singularity_PyTorch_GPU — Singularity + PyTorch GPU 測試

以 **Singularity／Apptainer** 掛載 NVIDIA 驅動（`--nv`），在容器內執行 **PyTorch 1.13.1（CUDA 11.6）** 並驗證 GPU 可用。映像定義與中心範例檔一致，可對照：

- `torch_1.13.1_cuda11.6.def`（本目錄，與 `$HOME/sample/singularity/torch_1.13.1_cuda11.6.def` 相同內容）
- 已建好的 SIF（**不進版控**，體積大）：預設路徑 **`$HOME/sample/singularity/torch_1.13.1_cuda11.6.sif`**

---

## 前置條件

1. 在 **GPU 計算節點**上操作（登入節點通常無 GPU；見上層 [`../README.md`](../README.md) 與 [`00_Cheatsheets/pjm_batch_system.md`](../../00_Cheatsheets/pjm_batch_system.md) 的 **GPU 互動式**）。
2. Host 上 `nvidia-smi` 正常；已安裝 **Singularity** 或 **Apptainer**。若 `which singularity` 無結果，需 `module load`；常見出處：
   - **`/package/x86_64/modulefiles`**：`singularity/ce-3.9.5_nosuid`（全站套件樹，無 suid 版）
   - **`$HOME/privatemodules/x86_64`**：`singularity/ce-3.9.5`、`singularity/ce-3.9.5_nosuid`  
   `part2_lmod_bootstrap.sh` 會把上述 `MODULEPATH` 併入；`run_singularity_gpu_test.sh`／`run_part2_gpu.sh` 會依序嘗試載入 `ce-3.9.5_nosuid` → `ce-3.9.5` → `singularity`。仍失敗時：`export PART2_SINGULARITY_MODULE=<模組全名>`。
3. SIF 檔存在；若路徑不同請設環境變數：
   ```bash
   export SINGULARITY_SIF=/你的路徑/torch_1.13.1_cuda11.6.sif
   ```

---

## 快速測試（互動式 shell 內）

```bash
cd Part2_GPU_CrashCourse/06_Singularity_PyTorch_GPU
chmod +x run_singularity_gpu_test.sh
./run_singularity_gpu_test.sh
```

預期：印出 `cuda.is_available(): True`、裝置名稱、一段小矩陣乘法時間，最後 `OK`。

---

## 自行由 def 建映像（選用，耗時長）

```bash
singularity build torch_1.13.1_cuda11.6.sif torch_1.13.1_cuda11.6.def
# 或
apptainer build torch_1.13.1_cuda11.6.sif torch_1.13.1_cuda11.6.def
```

完成後：

```bash
export SINGULARITY_SIF="$(pwd)/torch_1.13.1_cuda11.6.sif"
./run_singularity_gpu_test.sh
```

---

## PJM 批次提交（選用）

```bash
cd Part2_GPU_CrashCourse/06_Singularity_PyTorch_GPU
pjsub job_singularity_torch_gpu.sh
```

請依貴站政策修改 `job_singularity_torch_gpu.sh` 內之 `#PJM` 資源行（與互動式 `pjsub` 參數對齊）。

---

## 檔案說明

| 檔案 | 說明 |
|------|------|
| `torch_1.13.1_cuda11.6.def` | 映像定義（Docker bootstrap → PyTorch 1.13.1 + CUDA 11.6） |
| `test_cuda_torch.py` | 檢查 `torch.cuda`、裝置名稱、GPU 上 `1024×1024` matmul |
| `run_singularity_gpu_test.sh` | `singularity exec --nv` 掛載本目錄並執行測試 |
| `job_singularity_torch_gpu.sh` | PJM 批次範例 |

---

## 學習重點

- 容器內 CUDA **與主機驅動**版本需相容；映像為 CUDA 11.6 **runtime**，由 `--nv` 綁主機驅動。
- 深度學習工作流常為「Host 編排 + 容器內 PyTorch」，與前幾章裸機 `nvcc` 流程互補。
