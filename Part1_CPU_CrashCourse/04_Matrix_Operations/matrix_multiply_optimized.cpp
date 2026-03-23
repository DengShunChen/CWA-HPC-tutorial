// 矩陣乘法 - C++ 優化版本
// 功能：C = A * B (矩陣乘法)
// 優化技巧：
//   1. RAII 記憶體管理 (std::vector 取代 raw new/delete)
//   2. 迴圈重排序 (i-k-j) 改善 cache locality
//   3. 分塊 (Blocking/Tiling) 提高 L1/L2 cache 利用率
//   4. 編譯器提示：__builtin_expect、restrict 語義
//   5. constexpr 編譯期常數

#include <iostream>
#include <chrono>
#include <iomanip>
#include <vector>
#include <algorithm>
#include <numeric>
#include <cstddef>
#include <cmath>

// ── 編譯期常數 ──────────────────────────────────
constexpr int N = 512;            // 矩陣維度 (N x N)
constexpr int BLOCK_SIZE = 64;    // Cache blocking 大小 (通常 32-128)

// ── RAII 矩陣類別 ──────────────────────────────────
// 用一維 std::vector 模擬二維矩陣，row-major layout
class Matrix {
public:
    explicit Matrix(int dim, double init_val = 0.0)
        : dim_(dim), data_(static_cast<std::size_t>(dim) * dim, init_val) {}

    // 二維索引存取
    [[nodiscard]] double& operator()(int row, int col) noexcept {
        return data_[static_cast<std::size_t>(row) * dim_ + col];
    }
    [[nodiscard]] const double& operator()(int row, int col) const noexcept {
        return data_[static_cast<std::size_t>(row) * dim_ + col];
    }

    // 取得底層指標 (供高效能核心使用)
    [[nodiscard]] double*       raw() noexcept       { return data_.data(); }
    [[nodiscard]] const double* raw() const noexcept { return data_.data(); }

    [[nodiscard]] int dim() const noexcept { return dim_; }

    // 填零
    void zero() noexcept { std::fill(data_.begin(), data_.end(), 0.0); }

private:
    int dim_;
    std::vector<double> data_;
};

// ── 分塊矩陣乘法核心 ──────────────────────────────
// 使用 __restrict__ 提示無別名，讓編譯器更積極向量化
static void blocked_matmul(const double* __restrict__ A,
                           const double* __restrict__ B,
                           double* __restrict__ C,
                           int n, int bs) noexcept
{
    for (int ii = 0; ii < n; ii += bs) {
        const int i_end = std::min(ii + bs, n);
        for (int kk = 0; kk < n; kk += bs) {
            const int k_end = std::min(kk + bs, n);
            for (int jj = 0; jj < n; jj += bs) {
                const int j_end = std::min(jj + bs, n);

                // 小塊內: i-k-j 順序 (B 的 row 連續存取)
                for (int i = ii; i < i_end; ++i) {
                    const int i_row = i * n;          // 預算 row offset
                    for (int k = kk; k < k_end; ++k) {
                        const double a_ik = A[i_row + k];  // 提升不變量
                        const int k_row = k * n;
                        for (int j = jj; j < j_end; ++j) {
                            C[i_row + j] += a_ik * B[k_row + j];
                        }
                    }
                }
            }
        }
    }
}

// ── 驗證用的 naive 乘法 (小範圍) ──────────────────
[[maybe_unused]]
static double naive_element(const Matrix& A, const Matrix& B,
                            int row, int col) noexcept
{
    double sum = 0.0;
    for (int k = 0; k < A.dim(); ++k) {
        sum += A(row, k) * B(k, col);
    }
    return sum;
}

// ── 主程式 ──────────────────────────────────────
int main() {
    std::cout << "=========================================\n"
              << "  矩陣乘法 - 優化版本 ⚡\n"
              << "=========================================\n"
              << "矩陣大小:     " << N << " x " << N << '\n'
              << "優化技巧:     i-k-j 迴圈 + Blocking + RAII + restrict\n"
              << "Block 大小:   " << BLOCK_SIZE << '\n'
              << "sizeof(double): " << sizeof(double) << " bytes\n"
              << "記憶體用量:   ~" << (3ULL * N * N * sizeof(double)) / (1024 * 1024)
              << " MB (3 矩陣)\n\n";

    // ── 配置矩陣 (RAII，離開 scope 自動釋放) ──
    Matrix A(N);
    Matrix B(N);
    Matrix C(N, 0.0);

    // ── 初始化 ──
    std::cout << "初始化矩陣 A 和 B...\n";
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            A(i, j) = static_cast<double>(i + j) / N;
            B(i, j) = static_cast<double>(i - j) / N;
        }
    }

    // ── 計時並執行 ──
    auto start = std::chrono::high_resolution_clock::now();

    blocked_matmul(A.raw(), B.raw(), C.raw(), N, BLOCK_SIZE);

    auto end = std::chrono::high_resolution_clock::now();
    const std::chrono::duration<double> elapsed = end - start;

    // ── 效能指標 ──
    const double seconds = elapsed.count();
    const double gflops  = (2.0 * N * N * N) / (seconds * 1.0e9);

    std::cout << "\n=========================================\n"
              << "  計算完成\n"
              << "=========================================\n"
              << "執行時間:    " << std::fixed << std::setprecision(6)
              << seconds << " 秒\n"
              << "GFLOPS:      " << std::setprecision(3) << gflops << '\n'
              << '\n';

    // ── 驗證結果 ──
    std::cout << "結果矩陣 C 的部分元素：\n"
              << "C(0,0)   = " << C(0, 0) << '\n'
              << "C(0,1)   = " << C(0, 1) << '\n'
              << "C(n-1,n-1) = " << C(N-1, N-1) << '\n';

    // 驗證: 用 naive 方法計算 C(0,0)，確認分塊結果正確
    const double expected = naive_element(A, B, 0, 0);
    std::cout << "\n驗證 C(0,0):  計算值=" << C(0, 0)
              << "  期望值=" << expected
              << "  " << (std::abs(C(0,0) - expected) < 1e-9 ? "✅ PASS" : "❌ FAIL")
              << '\n' << std::endl;

    return 0;
    // A, B, C 在此自動解構，無 memory leak 風險
}
