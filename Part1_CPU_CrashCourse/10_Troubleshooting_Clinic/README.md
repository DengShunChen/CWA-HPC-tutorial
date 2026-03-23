# 10_Troubleshooting_Clinic - Q&A 與進階排錯

> 對齊 16:30-17:00：PJM 錯誤碼、Walltime、OOM、Core dump 與求援流程。

---

## 目標

- 能快速判讀常見 PJM 失敗情境（含 Code 28/29、walltime）
- 能從 log 分辨是資源配置問題、程式錯誤，還是記憶體不足
- 能用最小步驟重現並排除 OOM
- 能產出 core dump 並讀出第一版堆疊線索

---

## 1) PJM 常見錯誤快速表

> 各站台代碼定義可能略有差異；最終以貴中心手冊為準。

| 現象 | 常見原因 | 第一時間動作 |
|------|----------|--------------|
| `Code 28` | 資源請求不合法或與群組權限不符（rscgrp/node/proc） | 檢查 `#PJM -L`、`-g`；改用站台核准資源組合 |
| `Code 29` | 作業屬性不一致（腳本參數衝突或策略限制） | 精簡為最小可行腳本，再逐項加回參數 |
| Walltime 超時 | `elapse` 設太短，或程式卡住 | 拉長 `elapse` 或先做小規模測試 |
| 長時間 QUEUED | 佇列滿載或資源請求過大 | 降低資源需求，或改離峰時段提交 |

建議查詢：

```bash
pjstat -v <job_id>
pjhist <job_id>
```

---

## 2) Walltime 與中斷保護

腳本建議加上明確時間限制與輸出：

```bash
#PJM -L "elapse=00:20:00"
#PJM -j
#PJM -o job.log
```

若要演練安全中斷：

```bash
pjsub long_job.sh
pjstat
pjdel <job_id>   # 安全釋放資源
```

---

## 3) OOM（Out Of Memory）排查

典型訊號：

- log 出現 `Killed`、`oom`、`out of memory`
- 程式在大矩陣或高並行度時突然中止

建議流程：

1. 先縮小問題：降低資料尺寸、縮短迴圈、保留可重現
2. 調整平行配置：減少 MPI 行程數（每行程可用記憶體增加）
3. 若是 MPI+OpenMP，先固定總核心數，再改 `proc x thread` 組合
4. 監看記憶體峰值（站台工具或 `/proc/meminfo`）

示意（概念）：

```bash
# 先 48 ranks（高壓）
mpiexec -n 48 ./solver

# 改 12 ranks + 每 rank 較多記憶體空間
mpiexec -n 12 ./solver
```

---

## 4) Core dump（Segmentation Fault）實作

### 4.1 產出 core

```bash
ulimit -c unlimited
./buggy_program
```

若系統採集中式收集，可再查：

```bash
coredumpctl list
```

### 4.2 讀取 core（首輪）

```bash
gdb ./buggy_program core
(gdb) bt
(gdb) frame 0
(gdb) info locals
```

> 本課主軸仍是 TCS 工具；此處提供 core 檔案第一時間解讀流程，方便 Q&A 現場快速定位。

---

## 5) 求援流程（CWA + Fujitsu）

提交工單時請一次附上：

- Job script（含 `#PJM`）
- `pjstat -v <job_id>` 與 `pjhist <job_id>` 輸出
- 作業 log（stdout/stderr）
- 重現步驟（最小化輸入）
- 編譯命令與模組版本（`module list`）
- 是否為互動節點或批次節點執行

---

## 任務分級（Must / Should / Could）

| 層級 | 任務 |
|------|------|
| **Must** | 能解釋一個 PJM 失敗案例，並給出下一步檢查命令 |
| **Should** | 完成一次 OOM 重現與「降低 MPI ranks」修正 |
| **Could** | 產出 core 並回報 top frame 函式名稱 |

---

## 與 Part1 的銜接

- 批次腳本與監控：[`../04_Matrix_Operations`](../04_Matrix_Operations/)
- 除錯與 profiler：[`../08_Debug_Profile`](../08_Debug_Profile/)
- FIPP / fapp 延伸：[`../09_Profiler_Toolkit_TCS`](../09_Profiler_Toolkit_TCS/)
