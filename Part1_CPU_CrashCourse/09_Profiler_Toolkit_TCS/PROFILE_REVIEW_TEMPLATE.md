# Profiling 判讀模板（課堂交付版）

> 對象：`09_Profiler_Toolkit_TCS/run_profile_workflow.sh` 產出的結果。

---

## A. 執行資訊

- 日期時間：
- 節點（hostname）：
- 模式（fipp / fapp / all）：
- 參數（`KERNEL_PROFILE_N`、`--level`、`--mpi-n`）：

---

## B. FIPP（全域趨勢）

1. `fipp_all` 的 Top 熱點函式/區域：
2. `phase_heavy` / `phase_stream` / `phase_branch` / `phase_light` 時間占比（約略）：
3. 是否符合預期（計算密集 > 分支 > 記憶體 > 輕量，或你實測的實際排序）：

---

## C. FIPP（區段模式）

1. `fipp_region` 是否成功收到 `region_marked` 區段資料：
2. 和 `fipp_all` 相比，I/O 噪音是否降低：
3. 你觀察到的差異（一句話）：

---

## D. FAPP（細粒度）

1. `fapp_level1` 是否可區分 `main_region` / `heavy` / `memory_branch_mix` / `light`：
2. `stream` / `branch` 是否在 `level=2` 子區域可見：
3. 當 `-L 0`（若有執行）時，是否僅保留外層區域：
4. 你認為下一步優化應先改哪個區域，為什麼：

---

## E. MPI（選修）

1. `rank 0 only` 量測是否成功（輸出有 `rank 0 ...`）：
2. 其他 rank 未量測是否符合設計：
3. 若要量測全部 rank，你會怎麼改程式：

---

## F. 結論與行動

- 本輪主要瓶頸：
- 下輪要改的項目（1-2 項）：
- 預估風險（數值誤差、記憶體、I/O）：
