/*
 * region_fapp.c — 使用 fapp_start / fapp_stop 以「名稱 + 詳細編號 + 量測級別」
 * 標示兩個獨立量測區域（APP / Advanced Performance Profiler）。
 * 建置：make region_fapp_c（需 frt 對應的 fcc / fccpx，並加 -Nfjprof/-ffj-fjprof）
 *
 * 必須在程式碼開頭引入標頭檔：
 *   #include "fj_tool/fapp.h"
 *
 * 介面：fapp_start(name, number, level) / fapp_stop(name, number, level)
 *   name   ─ 字串，自訂區域識別名（報告中顯示為 "name+number"）
 *   number ─ 整數，同一 name 下的流水號
 *   level  ─ 整數，量測深度；執行時 fapp -L N 僅啟用 level ≤ N 的區域
 *
 * 執行（計算節點）：
 *   fapp -C -d ./tmp_fapp -L 1 ./region_fapp_c
 */

#include "fj_tool/fapp.h"   /* APP API（需 -Nfjprof / -ffj-fjprof） */
#include <stdio.h>
#include <stdlib.h>

/* 示範用計算核心：足夠長，方便 profiler 取樣。 */
static double heavy_kernel(long long n) {
    double s = 0.0;
    for (long long i = 1; i <= n; ++i) {
        const double x = (double)i * 1.0e-7;
        s += x * x / (1.0 + x);
    }
    return s;
}

static double light_kernel(long long n) {
    double s = 0.0;
    for (long long i = 1; i <= n; ++i) {
        s += (double)i * 1.0e-8;
    }
    return s;
}

static long long resolve_n(void) {
    const char *env = getenv("KERNEL_PROFILE_N");
    if (!env || !*env) return 5000000LL;
    long long n = atoll(env);
    return n > 0 ? n : 5000000LL;
}

int main(void) {
    const long long n = resolve_n();
    double s1, s2;

    /* --- 外層區域：涵蓋整個計算（level=0）--- */
    fapp_start("main_region", 1, 0);

        /* --- 子區域 A：heavy_kernel（level=1）--- */
        fapp_start("heavy", 1, 1);
        s1 = heavy_kernel(n);
        fapp_stop("heavy", 1, 1);

        /* --- 子區域 B：light_kernel（level=1）--- */
        fapp_start("light", 1, 1);
        s2 = light_kernel(n);
        fapp_stop("light", 1, 1);

    fapp_stop("main_region", 1, 0);

    /* I/O 留在量測區域外（排除 printf 開銷） */
    printf("checksum_heavy=%.12f checksum_light=%.12f\n", s1, s2);
    return 0;
}
