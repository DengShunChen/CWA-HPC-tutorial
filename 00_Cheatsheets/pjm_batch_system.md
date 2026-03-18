# PJM 批次系統使用指南

> Fujitsu A64FX / FX1000 專用批次作業管理系統

---

## 🎯 什麼是 PJM？

**PJM (Parallels Job Manager)** 是 Fujitsu 超級電腦系統的批次作業管理系統，類似於其他 HPC 系統的 SLURM 或 PBS。

---

## 📝 基本 PJM 作業腳本

### 單節點作業（範例：向量加法）

建立 `job_vec_add.sh`：

```bash
#!/bin/bash
#PJM -L "rscgrp=small"           # 資源群組
#PJM -L "node=1"                 # 使用 1 個節點
#PJM -L "elapse=00:10:00"        # 最長執行時間 10 分鐘
#PJM -g <your_group>             # 你的群組名稱（請修改）
#PJM -j                          # 合併標準輸出與標準錯誤

# 載入必要環境
module load lang/tcsds-1.2.37   # Fujitsu 編譯器

# 執行程式
./vec_add_fortran
```

### 提交作業

```bash
# 提交作業
pjsub job_vec_add.sh

# 查看作業狀態
pjstat

# 取消作業
pjdel <job_id>

# 查看輸出
cat job_vec_add.sh.o<job_id>
```

---

## 📊 常用 PJM 指令

| 指令 | 說明 | 範例 |
|-----|------|------|
| `pjsub` | 提交批次作業 | `pjsub job.sh` |
| `pjstat` | 查看作業狀態 | `pjstat` |
| `pjstat -v` | 詳細作業資訊 | `pjstat -v <job_id>` |
| `pjdel` | 取消作業 | `pjdel <job_id>` |
| `pjhist` | 查看歷史作業 | `pjhist` |

---

## 🔄 工作流程

```
1. 在 x86 電腦上編輯程式碼
   ↓
2. 使用 cross compiler 編譯（frtpx / FCC）
   ↓
3. 準備 PJM 作業腳本
   ↓
4. 透過 pjsub 提交到 FX1000 叢集
   ↓
5. pjstat 監控作業狀態
   ↓
6. 查看輸出結果
```

---

## 📄 完整範例作業腳本

### Fortran 程式作業腳本

```bash
#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:15:00"
#PJM -g <your_group>
#PJM -j
#PJM -o vec_add_output.log

# 載入環境
module load lang/tcsds-1.2.37

# 顯示執行資訊
echo "========================================="
echo "  作業開始"
echo "========================================="
echo "節點: $(hostname)"
echo "時間: $(date)"
echo

# 執行程式
echo ">>> 執行 Fortran 向量加法..."
./vec_add_fortran
echo

# 執行優化版本
echo ">>> 執行 Fortran 優化版本..."
./vec_add_optimized_fortran
echo

echo "========================================="
echo "  作業完成"
echo "========================================="
```

### C++ 程式作業腳本

```bash
#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:15:00"
#PJM -g <your_group>
#PJM -j
#PJM -o vec_add_cpp_output.log

# 載入環境
module load lang/tcsds-1.2.37

# 顯示執行資訊
echo "========================================="
echo "  C++ 向量加法作業"
echo "========================================="

# 執行基礎版本
echo ">>> 基礎版本:"
./vec_add_cpp

# 執行優化版本
echo ">>> 優化版本:"
./vec_add_optimized_cpp

echo "作業完成: $(date)"
```

---

## ⚙️ 資源配置選項

### 基本資源選項

| PJM 參數 | 說明 | 範例 |
|---------|------|------|
| `-L "rscgrp=<group>"` | 資源群組 | `rscgrp=small` |
| `-L "node=<N>"` | 節點數量 | `node=1` |
| `-L "elapse=HH:MM:SS"` | 最長執行時間 | `elapse=00:30:00` |
| `-g <group>` | 使用者群組 | `-g ga00` |
| `-j` | 合併 stdout/stderr | `-j` |
| `-o <file>` | 輸出檔案 | `-o output.log` |

### 進階選項（OpenMP）

```bash
#!/bin/bash
#PJM -L "rscgrp=small"
#PJM -L "node=1"
#PJM -L "elapse=00:10:00"
#PJM --mpi "proc=1"              # MPI 程序數
#PJM --omp "thread=48"           # OpenMP 執行緒數 (A64FX 有 48 核心)

export OMP_NUM_THREADS=48

./my_openmp_program
```

---

## 💡 使用技巧

### 1. 互動式測試（不建議用於生產）

```bash
# 申請互動式節點（方便除錯）
pjsub --interact -L "node=1" -L "elapse=00:30:00" -g <group>
```

### 2. 批次提交多個作業

```bash
# 建立提交腳本
for i in {1..10}; do
  sed "s/INPUT/$i/g" template.sh > job_$i.sh
  pjsub job_$i.sh
done
```

### 3. 等待作業完成

```bash
# 監控直到作業完成
while pjstat | grep -q <job_id>; do
  sleep 5
done
echo "作業已完成！"
```

---

## 🐛 常見問題

### Q: 如何知道我的群組名稱？
**A**: 詢問系統管理員，或查看 `~/.bashrc` 中的設定。

### Q: 作業一直卡在 QUEUED 狀態？
**A**: 可能是：
- 資源不足（等待其他作業完成）
- 執行時間超過群組限制
- 節點數量超過可用資源

### Q: 如何查看作業輸出？
**A**: 預設輸出檔案為 `<script_name>.o<job_id>`，使用 `cat` 或 `less` 查看。

---

## 📚 延伸閱讀

- Fujitsu PRIMEHPC FX1000 使用手冊
- PJM 官方文件

---

**熟悉 PJM 是在 FX1000 上開發的關鍵！🚀**
