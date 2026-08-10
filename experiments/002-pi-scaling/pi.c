/* Monte-Carlo pi with OpenMP — strong-scaling probe.
 * Usage: ./pi [n_samples]   (thread count via OMP_NUM_THREADS)
 * Prints one CSV line: threads,samples,pi,seconds,samples_per_sec
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <omp.h>

static inline uint64_t xorshift64(uint64_t *s) {
    uint64_t x = *s;
    x ^= x << 13; x ^= x >> 7; x ^= x << 17;
    return *s = x;
}

int main(int argc, char **argv) {
    long long n = (argc > 1) ? atoll(argv[1]) : 1000000000LL;
    long long hits = 0;
    int nt = 0;
    double t0 = omp_get_wtime();
    #pragma omp parallel reduction(+:hits)
    {
        #pragma omp single
        nt = omp_get_num_threads();
        uint64_t seed = 0x9E3779B97F4A7C15ULL ^ (0xBF58476D1CE4E5B9ULL * (uint64_t)(omp_get_thread_num() + 1));
        long long local_n = n / omp_get_num_threads();
        if (omp_get_thread_num() == 0) local_n += n % omp_get_num_threads();
        for (long long i = 0; i < local_n; i++) {
            double x = (double)(xorshift64(&seed) >> 11) * (1.0 / 9007199254740992.0);
            double y = (double)(xorshift64(&seed) >> 11) * (1.0 / 9007199254740992.0);
            if (x * x + y * y <= 1.0) hits++;
        }
    }
    double dt = omp_get_wtime() - t0;
    printf("%d,%lld,%.8f,%.3f,%.3e\n", nt, n, 4.0 * (double)hits / (double)n, dt, (double)n / dt);
    return 0;
}
