# 00_HPC_Workflow - 合規登入、資料流與跨架構安裝

> 對齊 14:00-14:40 實作演練：先取得計算資源，再進行資料與環境操作。

---

## 目標

- 使用 SSH 金鑰完成安全登入（避免密碼散落）
- 查詢個人配額（Quota）並判讀容量風險
- 先以 `pjsub --interact` 取得計算節點 shell，再進行實作
- 建立 `/IFS` 與 `/OFS` 工作目錄，練習 `tar` + `rsync` 巨量資料搬移
- 在可連外節點（如 `h6dm23`）準備 `aarch64` 離線套件，供 FX1000 使用

---

## 14:00-14:40 建議流程（Checkpoint）

| 時段 | 任務 | 通過標準 |
|------|------|----------|
| 14:00-14:10 | SSH 金鑰登入 + Quota 檢查 | 可無密碼登入；能說出目前配額使用率 |
| 14:10-14:20 | `pjsub --interact` | 成功進入計算節點 shell（`hostname` 非 login node） |
| 14:20-14:30 | `/IFS`、`/OFS` 建目錄 + `tar` + `rsync` | 完成一次資料打包與搬移 |
| 14:30-14:40 | 跨架構套件準備（`aarch64`） | 產出可離線安裝的 wheels / conda pkgs |

---

## 1) 合規登入與 Quota

### SSH 金鑰（首次）

```bash
# 本機端
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/fx1000_ed25519
ssh-copy-id -i ~/.ssh/fx1000_ed25519.pub <user>@<login-host>
```

`~/.ssh/config` 建議：

```text
Host fx1000
  HostName <login-host>
  User <user>
  IdentityFile ~/.ssh/fx1000_ed25519
  IdentitiesOnly yes
```

### Quota 查詢（站台命令可能不同）

```bash
showquota
showquota_all
```

> 若你的站台命令不同，以上改為貴中心指定指令；重點是上機前先確認配額，避免作業中途寫滿。

---

## 2) 先取計算資源：`pjsub --interact`

```bash
pjsub --interact -L "rscgrp=small" -L "node=1" -L "elapse=00:30:00" -g <your_group>
hostname
uname -m   # 預期 aarch64
```

> 防呆原則：**不要**在 login node 跑長時間/大量計算。

---

## 3) `/IFS` 與 `/OFS`：目錄建立、`tar` 打包、`rsync` 搬移

```bash
# 依帳號調整路徑
IFS_WORK=/IFS/$USER/part1_lab
OFS_WORK=/OFS/$USER/part1_lab

mkdir -p "$IFS_WORK/raw" "$IFS_WORK/pkg" "$OFS_WORK/archive"
cd "$IFS_WORK/raw"

# 建立測試資料（示意）
for i in $(seq -w 1 20); do
  dd if=/dev/urandom of="meteo_${i}.bin" bs=1M count=8 status=none
done

# 打包（保留 metadata）
cd "$IFS_WORK"
tar -cvf pkg/meteo_raw.tar raw

# 高效同步（可續傳 + 顯示進度）
rsync -avh --info=progress2 pkg/meteo_raw.tar "$OFS_WORK/archive/"
```

建議驗證：

```bash
du -sh "$IFS_WORK/pkg" "$OFS_WORK/archive"
tar -tf "$OFS_WORK/archive/meteo_raw.tar" | head
```

---

## 4) 跨架構安裝：在可連外節點準備 `aarch64` 套件

假設 `h6dm23` 可連外（`x86_64`）：

```bash
ssh <user>@h6dm23
uname -m  # x86_64
```

### 方案 A：Conda（推薦）

```bash
export CONDA_SUBDIR=linux-aarch64
conda create -y -p "$HOME/conda-aarch64-pkgs" python=3.11 numpy scipy
```

### 方案 B：pip 下載 wheels

```bash
mkdir -p "$HOME/wheels-aarch64"
python -m pip download \
  --dest "$HOME/wheels-aarch64" \
  --platform manylinux2014_aarch64 \
  --only-binary=:all: \
  --python-version 311 \
  numpy scipy pandas
```

搬移到 FX1000（離線區）：

```bash
rsync -avh "$HOME/wheels-aarch64/" <user>@<login-host>:/OFS/<user>/wheels-aarch64/
```

FX1000 計算節點離線安裝：

```bash
python -m pip install --no-index --find-links=/OFS/$USER/wheels-aarch64 numpy scipy pandas
```

---

## 任務分級（Must / Should / Could）

| 層級 | 任務 |
|------|------|
| **Must** | 完成 `pjsub --interact`、建立 `/IFS` `/OFS` 目錄、完成一次 `tar` + `rsync` |
| **Should** | 能說明為何跨架構下載需指定 `aarch64` 目標 |
| **Could** | 建立可重複使用的離線安裝目錄（含 `requirements.txt` 與版本鎖定） |

---

## 常見雷區

- 在 login node 直接跑大迴圈或大量 I/O
- 未先查配額，導致作業中途寫滿
- 在 `x86_64` 直接安裝套件後拿去 `aarch64` 執行
- `rsync` 路徑尾斜線用錯（來源內容 vs 來源目錄本身）

---

## 下一步

完成本章後，進入 [`../01_Hello`](../01_Hello/) 與 [`../02_Vector_Add`](../02_Vector_Add/) 進行 A64FX 原生編譯與優化循環。
