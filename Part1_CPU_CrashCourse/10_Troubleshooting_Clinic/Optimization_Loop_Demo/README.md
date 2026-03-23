# Optimization Loop Demo（Part1 / 第10項）

> 目標：完整演示軟體優化循環  
> `profiling -> analysis profiling report -> identify slow coding -> optimize coding -> check output result -> reprofiling`

---

## 檔案

- `loop_baseline.f90`：基準版（刻意保留較差走訪與迴圈內分支）
- `loop_optimized.f90`：優化版（走訪順序與分支拆分）
- `Makefile`：建置 baseline / optimized
- `run_optimization_loop.sh`：一鍵跑完整 6 步驟
- `job_optimization_loop.sh`：PJM 版執行腳本

---

## 一鍵執行（互動節點或計算節點）

```bash
chmod +x run_optimization_loop.sh
./run_optimization_loop.sh
```

輸出會在 `loop_reports/`：

- `baseline_analysis.txt`
- `optimized_analysis.txt`
- `baseline_output.txt`
- `optimized_output.txt`
- `summary.txt`

---

## 批次執行（建議課堂）

先把 `job_optimization_loop.sh` 的 `<your_group>` 換成你的群組，再送：

```bash
pjsub job_optimization_loop.sh
```

---

## 你要怎麼講解（對齊 6 步驟）

1. **profiling（baseline）**  
   `fipp -C -d baseline ./loop_baseline`
2. **analysis profiling report**  
   `fipppx -A -d baseline > baseline_analysis.txt`
3. **identify slow coding**  
   從 `baseline_analysis.txt` 看 hottest procedure / loop
4. **optimize coding**  
   切到 `loop_optimized.f90`（改善記憶體走訪、降低核心分支成本）
5. **check output result**  
   比較 baseline 與 optimized checksum（腳本內含容差檢查）
6. **reprofiling**  
   對 optimized 再跑一次 FIPP + fipppx，對照改善幅度

---

## 可調參數

- `LOOP_DEMO_N`：矩陣尺寸（預設 1200）
- `LOOP_DEMO_REPS`：迭代次數（預設 18）
- `OUTDIR`：報告輸出目錄（預設 `./loop_reports`）

範例：

```bash
LOOP_DEMO_N=1600 LOOP_DEMO_REPS=24 ./run_optimization_loop.sh
```

---

## 驗收標準（建議）

- 可以清楚指出 baseline 的主要熱點
- 優化後 checksum 與 baseline 一致（在容差內）
- `summary.txt` 顯示 speedup（`> 1.0x`）
