# Optimization Loop 邏輯說明

> 適用位置：`Part1_CPU_CrashCourse/10_Troubleshooting_Clinic/Optimization_Loop_Demo/`  
> 目的：把「效能調校」變成可重複、可驗證、可教學的流程。

---

## 核心觀念

這個案例不是只追求「跑更快」，而是強調 **科學化優化流程**：

1. 先量測（profiling）
2. 再分析報告（analysis）
3. 找到慢點（identify slow coding）
4. 有目標地修改（optimize coding）
5. 確認答案沒壞（check output result）
6. 再次量測驗證（reprofiling）

若缺任一步，優化就可能變成「猜測」：  
- 沒 profiling：不知道慢在哪  
- 沒 output check：可能變快但算錯  
- 沒 reprofiling：不知道修改是否真的有效

---

## 這個範例怎麼對應 6 步驟

### 1) Profiling（baseline）

- 程式：`loop_baseline.f90`
- 行為：保留較差記憶體走訪與迴圈內分支
- 指令（由 `run_optimization_loop.sh` 執行）：
  - `fipp -C -d loop_reports/baseline ./loop_baseline`

目的：建立「未優化前」的效能基準。

### 2) Analysis profiling report

- 指令：
  - `fipppx -A -d loop_reports/baseline > loop_reports/baseline_analysis.txt`
- 觀察重點：
  - `Procedures profile`
  - `Loops profile`
  - 哪些迴圈/程序佔比最高

目的：從數據找瓶頸，而不是憑直覺改。

### 3) Identify slow coding

依報告辨識慢點，這個範例預期慢點包含：
- 不友善的記憶體存取模式
- 核心迴圈內分支判斷（降低向量化效率）

目的：把「慢」具體化成可修改的程式結構問題。

### 4) Optimize coding

- 程式：`loop_optimized.f90`
- 優化策略：
  - 改善走訪順序（更符合 Fortran 記憶體布局）
  - 將部分分支成本外移/降低核心熱迴圈干擾
  - 保持演算法邏輯一致

目的：針對瓶頸做最小但有效的改動。

### 5) Check output result

- 比較：
  - `baseline_output.txt`
  - `optimized_output.txt`
- 驗證項目：
  - checksum 一致（容差內）

目的：確保是「正確地變快」，不是「算錯了變快」。

### 6) Reprofiling

- 指令：
  - `fipp -C -d loop_reports/optimized ./loop_optimized`
  - `fipppx -A -d loop_reports/optimized > loop_reports/optimized_analysis.txt`
- 產出：
  - `summary.txt`（baseline/optimized time + speedup）

目的：確認優化效果可量化、可重現。

---

## 為什麼這個流程適合教學

- **完整閉環**：從問題到驗證，不停在「只會看報告」
- **可重現**：同一腳本可反覆跑，不靠手動記憶步驟
- **可擴充**：可調 `LOOP_DEMO_N`、`LOOP_DEMO_REPS` 做不同規模實驗
- **可驗收**：有明確輸出（analysis、checksum、speedup）

---

## 你可以怎麼講（講師版簡要）

1. 先讓學員看 baseline report：哪裡最熱  
2. 問學員「你猜怎麼改」  
3. 再切到 optimized 程式講 2-3 個關鍵改動  
4. 強調 checksum 一致的重要性  
5. 最後用 speedup 收斂，形成「數據驅動優化」觀念

---

## 一句話總結

這個範例在教的不是單一技巧，而是一套可複製的工程方法：  
**先量測、再定位、再優化、再驗證。**
