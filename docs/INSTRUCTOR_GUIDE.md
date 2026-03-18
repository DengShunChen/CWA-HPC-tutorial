# ProgramingTutorial 講師教學指南

> 給授課講師的教學流程、時間分配與常見問題處理

---

## 1. 課程總覽

| 場次 | 時長 | 主題 | 前置需求 |
|------|------|------|----------|
| **上半年** | 3 小時 | CPU 程式語言速成 | 無（完全初學者） |
| **下半年** | 3 小時 | GPU 加速與實戰 | 需完成上半年課程 |

---

## 2. 上半年課程（Part 1）教學流程

### 2.1 建議時程（3 小時）

| 時間 | 主題 | 資料夾 | 教學重點 |
|------|------|--------|----------|
| 0:00–0:20 | HPC Hello World | 01_Hello | 環境測試、編譯流程、編輯-編譯-執行 |
| 0:20–1:10 | 向量運算與優化 | 02_Vector_Add | **核心**：慢版 vs 快版對比、Cache locality |
| 1:10–1:50 | 動手練習 | 03_Challenge | 學員獨立修改：向量加法→乘法 |
| 1:50–2:40 | 矩陣運算與快取 | 04_Matrix_Operations | 迴圈順序、Blocking、Row/Column-major |
| 2:40–3:10 | 檔案 I/O | 05_File_IO | 讀寫、緩衝、錯誤處理 |
| 3:10–3:30 | 自由練習 / Q&A | 各章節 | 複習、提問、延伸 |

### 2.2 關鍵教學點

1. **01_Hello**：確認 `frtpx`、`FCC` 或 `gfortran`、`g++` 可用
2. **02_Vector_Add**：務必展示優化前後效能差異，解釋「為什麼快」
3. **04_Matrix_Operations**：用圖解說明快取局部性與迴圈順序影響
4. **03_Challenge**：留足時間讓學員動手，必要時提供提示

### 2.3 常見學員問題

| 問題 | 建議回答 |
|------|----------|
| Fortran 和 C++ 該學哪個？ | 兩者都學基礎，HPC 領域兩者皆常見 |
| 優化真的有必要嗎？ | 是，HPC 程式常跑數天，2x 優化可省一半時間與成本 |
| 編譯失敗？ | 查 `00_Cheatsheets/compilation_guide.md` |

---

## 3. 下半年課程（Part 2）教學流程

### 3.1 建議時程（3 小時）

| 時間 | 主題 | 資料夾 | 教學重點 |
|------|------|--------|----------|
| 0:00–0:30 | 複習 + GPU 概念 | README + 01_CUDA_Hello | 上半年重點、GPU 架構、Host/Device |
| 0:30–2:00 | CUDA 核心語法 | 02_Vector_Add_GPU | Kernel、cudaMalloc/cudaMemcpy、Thread/Block/Grid |
| 2:00–3:00 | 實戰案例 | 03_Heat_Diffusion_Demo | 熱傳導模擬、CPU vs GPU 對比 |

### 3.2 關鍵教學點

1. **01_CUDA_Hello**：先跑 `nvidia-smi`、`device_query` 確認 GPU 可用
2. **02_Vector_Add_GPU**：對照 CPU 版 vec_add，強調 Host/Device 資料傳輸成本
3. **03_Heat_Diffusion_Demo**：目前僅有框架，可視時間決定是否深入實作

### 3.3 常見學員誤區

| 誤區 | 糾正 |
|------|------|
| "GPU 一定比 CPU 快" | 資料傳輸有成本，小資料量可能 CPU 更快 |
| "寫 CUDA 很難" | 基本概念簡單，從 vec_add 開始即可 |
| "優化隨便做就好" | GPU 優化與 CPU 不同，需理解記憶體階層 |

---

## 4. 課前檢查清單

### 4.1 環境

- [ ] 編譯器已安裝並可執行（`frtpx`、`FCC` 或 `gfortran`、`g++`）
- [ ] CUDA 環境可用（`nvcc`、`nvidia-smi`）
- [ ] PJM 或 PBS 可提交作業（若使用批次系統）
- [ ] 學員帳號可登入、有足夠配額

### 4.2 教材

- [ ] 已 `make all` 成功編譯
- [ ] 各章節 README 可正常閱讀
- [ ] `00_Cheatsheets/` 可快速查閱

### 4.3 備援方案

- 若 A64FX 不可用：改用 gfortran/g++ 在 x86 上執行
- 若 GPU 不可用：可僅講解 CUDA 概念與程式碼，不實際執行

---

## 5. 參考文件速查

| 情境 | 文件 |
|------|------|
| 語法不確定 | `00_Cheatsheets/syntax_rosetta_stone.md` |
| 編譯失敗 | `00_Cheatsheets/compilation_guide.md` |
| 優化原理 | `00_Cheatsheets/optimization_mindset.md` |
| 提交作業 | `00_Cheatsheets/pjm_batch_system.md` |
| 專案總覽 | `PROJECT_SUMMARY.md` |
| 技術架構 | `docs/ARCHITECTURE.md` |

---

## 6. 課後建議

1. 請學員完成 `03_Challenge` 並回傳或分享
2. 鼓勵閱讀 `optimization_mindset.md` 深化理解
3. 收集學員回饋，用於改進教材

---

**祝教學順利！🚀**
