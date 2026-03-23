/*
 * region_fapp_mpi_c.c — MPI C：僅在 rank 0 呼叫 fapp_start / fapp_stop。
 * 建置：make region_fapp_mpi_c（需 mpifcc / mpifccpx 與 -Nfjprof）
 *
 * C 程式需引入標頭檔：#include "fj_tool/fapp.h"（Fujitsu TCS 提供）
 * 介面：fapp_start(name, number, level) / fapp_stop(name, number, level)
 *
 * 執行（計算節點，4 rank，僅量測 rank 0）：
 *   mpiexec -n 4 fapp -C -d ./tmp_fapp -L 1 ./region_fapp_mpi_c
 */

#include "fj_tool/fapp.h"   /* APP API（需 -Nfjprof / -ffj-fjprof） */
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

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

int main(int argc, char **argv) {
    int rank = 0, nprocs = 1;
    const long long n = resolve_n();
    double s1 = 0.0, s2 = 0.0;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

    if (rank == 0) {
        /* --- 外層區域（level=0）--- */
        fapp_start("mpi_outer", 1, 0);

            /* --- 子區域 A（level=1）--- */
            fapp_start("mpi_heavy", 1, 1);
            s1 = heavy_kernel(n);
            fapp_stop("mpi_heavy", 1, 1);

            /* --- 子區域 B（level=1）--- */
            fapp_start("mpi_light", 1, 1);
            s2 = light_kernel(n);
            fapp_stop("mpi_light", 1, 1);

        fapp_stop("mpi_outer", 1, 0);

        printf("rank 0 checksum_heavy=%.12f checksum_light=%.12f nprocs=%d\n",
               s1, s2, nprocs);
    }

    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
    return 0;
}
