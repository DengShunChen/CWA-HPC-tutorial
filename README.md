# HPC 程式設計工作坊教材

> 為完全初學者設計的高效能計算程式入門課程  
> 涵蓋 Fortran、C++ 與 CUDA GPU 加速

> **🖥️ 本教材針對 Fujitsu A64FX (FX1000) 平台優化**  
> - 使用 **Fujitsu frtpx (Fortran)** 與 **FCC (C++)** 編譯器  
> - 透過 **PJM 批次系統** 提交作業  
> - 支援 **ARM SVE 512-bit 向量化**

---

## 📚 課程概覽

本教材為年度系列工作坊，分兩次上課：

| 場次 | 時長 | 主題 | 目標 |
|-----|------|------|------|
| **上半年** | 3 小時 | CPU 程式語言速成 | 掌握 Fortran 與 C++ 基礎，能讀懂並修改數值計算程式 |
| **下半年** | 3 小時 | GPU 加速與實戰 | 理解 CUDA 平行運算，體驗 GPU 加速威力 |

---

## 🗂️ 教材結構

```
ProgramingTutorial/
├── 00_Cheatsheets/           # 快速參考資料
│   ├── syntax_rosetta_stone.md      # 三語言語法對照表
│   ├── compilation_guide.md         # 編譯指令速查
│   └── optimization_mindset.md      # HPC 優化思維指南
│
├── Part1_CPU_CrashCourse/    # 上半年：CPU 程式語言
│   ├── 01_Hello/             # 環境測試
│   ├── 02_Vector_Add/        # 核心範例（含優化對比）
│   └── 03_Challenge/         # 練習題
│
└── Part2_GPU_CrashCourse/    # 下半年：GPU 加速
    ├── 01_CUDA_Hello/        # GPU 環境確認
    ├── 02_Vector_Add_GPU/    # CPU 到 GPU 轉換
    └── 03_Heat_Diffusion_Demo/  # 實戰：熱傳導模擬
```

---

## 🎯 教學特色

| 特色 | 說明 |
|-----|------|
| **對比學習** | 同一功能用 Fortran/C++/CUDA 實作，快速掌握差異 |
| **範例導向** | 不教繁瑣語法，直接透過可執行範例學習 |
| **優化思維** | 每個範例提供「慢版」vs「快版」，展示效能差異 |
| **實戰收尾** | 以數值模擬案例整合所學知識 |

---

## 🚀 快速開始

### 上半年課程
1. 參考 [`00_Cheatsheets/`](00_Cheatsheets/) 快速查閱語法
2. 從 [`Part1_CPU_CrashCourse/01_Hello/`](Part1_CPU_CrashCourse/01_Hello/) 開始
3. 重點學習 [`Part1_CPU_CrashCourse/02_Vector_Add/`](Part1_CPU_CrashCourse/02_Vector_Add/) 的優化技巧

### 下半年課程
1. 複習上半年重點（見 `Part2_GPU_CrashCourse/README.md`）
2. 從 [`Part2_GPU_CrashCourse/01_CUDA_Hello/`](Part2_GPU_CrashCourse/01_CUDA_Hello/) 開始
3. 最終挑戰：[`Part2_GPU_CrashCourse/03_Heat_Diffusion_Demo/`](Part2_GPU_CrashCourse/03_Heat_Diffusion_Demo/)

---

## 🔧 環境需求

### 上半年 (CPU 程式語言)
- **CPU 平台**：Fujitsu A64FX (ARM v8.2-A + SVE)
- **Fortran 編譯器**：`frtpx` (Fujitsu Compiler)
- **C++ 編譯器**：`FCC` (Fujitsu C++ Compiler)
- **批次系統**：PJM (Parallels Job Manager)
- **開發環境**：x86 電腦 + cross compiler

### 下半年 (GPU 加速)
- **CUDA Toolkit**：建議 CUDA >= 10.0
- **支援 CUDA 的 GPU**：建議 Compute Capability >= 3.5
- **NVIDIA 驅動程式**：與 CUDA 版本相容

### 快速環境檢查

```bash
# 檢查 Fujitsu 編譯器
frtpx --version
FCC --version

# 檢查 PJM 系統
pjstat --version

# 檢查 CUDA (GPU 課程)
nvcc --version
```

---

## 📖 學習路徑建議

### 完全初學者
1. ✅ 先完成上半年課程，熟悉基本語法
2. ✅ 仔細閱讀 `optimization_mindset.md`
3. ✅ 在兩次課程之間練習 `03_Challenge` 題目
4. ✅ 下半年課程前複習上半年重點

### 有程式基礎者
- 可直接參考 `00_Cheatsheets/syntax_rosetta_stone.md` 快速對照語法
- 重點學習各章節的優化技巧與效能分析

---

## 💡 教材使用提示

- 📋 **語法不確定？** → 查閱 `00_Cheatsheets/syntax_rosetta_stone.md`
- 🔧 **編譯失敗？** → 參考 `00_Cheatsheets/compilation_guide.md`
- ⚡ **如何優化？** → 閱讀 `00_Cheatsheets/optimization_mindset.md`
- 📦 **如何提交作業？** → 查看 `00_Cheatsheets/pjm_batch_system.md`
- 🤔 **看不懂程式碼？** → 每個資料夾的 `README.md` 都有詳細說明

### Fujitsu A64FX 平台特別注意

1. **編譯環境**：在 x86 電腦上使用 cross compiler 編譯
2. **執行方式**：不能直接執行，需透過 `pjsub` 提交到 FX1000
3. **優化關鍵**：使用 `-KSVE` 啟用 ARM SVE 512-bit 向量化
4. **模組載入**：記得在 PJM 腳本中 `module load lang/tcsds-1.2.37`

---

## 📁 專案文件

| 文件 | 說明 |
|------|------|
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | 專案摘要、結構、技術棧 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 技術架構與編譯設計 |
| [docs/INSTRUCTOR_GUIDE.md](docs/INSTRUCTOR_GUIDE.md) | 講師教學指南 |

---

## 📬 聯絡與回饋

如有任何問題或建議，歡迎聯繫講師。

---

**Good luck and happy coding! 🚀**
