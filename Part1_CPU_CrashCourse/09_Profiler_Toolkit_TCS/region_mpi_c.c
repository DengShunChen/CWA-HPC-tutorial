#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

/* FIPP region APIs */
extern void fipp_start(void);
extern void fipp_stop(void);

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

int main(int argc, char **argv) {
    int rank = 0, nprocs = 1;
    const long long n = resolve_n();
    double s1 = 0.0, s2 = 0.0;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);

    if (rank == 0) {
        /* 僅量測 rank 0；其他進程不呼叫 fipp_start/stop。 */
        fipp_start();
        s1 = heavy_kernel(n);
        s2 = light_kernel(n);
        fipp_stop();
        printf("rank 0 checksum_heavy=%.12f checksum_light=%.12f nprocs=%d\n", s1, s2, nprocs);
    }

    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
    return 0;
}
