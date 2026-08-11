/* 004 — MPI hello across nodes + inter-node fabric ping-pong.
 * Rank 0 prints a per-node rank roster, then measures against the LAST rank
 * (block distribution puts it on the other node):
 *   - latency: 8 B round-trips
 *   - bandwidth: 64 MiB messages
 */
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LAT_REPS 2000
#define BW_REPS  20
#define BW_BYTES (64 * 1024 * 1024)

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    char name[MPI_MAX_PROCESSOR_NAME]; int nl;
    MPI_Get_processor_name(name, &nl);

    /* roster */
    char *all = NULL;
    if (rank == 0) all = malloc((size_t)size * MPI_MAX_PROCESSOR_NAME);
    MPI_Gather(name, MPI_MAX_PROCESSOR_NAME, MPI_CHAR,
               all, MPI_MAX_PROCESSOR_NAME, MPI_CHAR, 0, MPI_COMM_WORLD);
    if (rank == 0) {
        printf("Merhaba from %d ranks\n", size);
        for (int i = 0; i < size; i++) {
            char *ni = all + (size_t)i * MPI_MAX_PROCESSOR_NAME;
            int first = 1;
            for (int j = 0; j < i; j++)
                if (!strcmp(ni, all + (size_t)j * MPI_MAX_PROCESSOR_NAME)) { first = 0; break; }
            if (first) {
                int cnt = 0;
                for (int j = 0; j < size; j++)
                    if (!strcmp(ni, all + (size_t)j * MPI_MAX_PROCESSOR_NAME)) cnt++;
                printf("  node %-12s : %d ranks (first: rank %d)\n", ni, cnt, i);
            }
        }
        fflush(stdout);
    }

    int partner = size - 1;
    double lat_us = 0.0, bw_gbs = 0.0;

    MPI_Barrier(MPI_COMM_WORLD);
    if (size > 1 && (rank == 0 || rank == partner)) {
        char small[8] = {0};
        MPI_Status st;
        /* warmup */
        for (int i = 0; i < 100; i++) {
            if (rank == 0) { MPI_Send(small, 8, MPI_CHAR, partner, 0, MPI_COMM_WORLD);
                             MPI_Recv(small, 8, MPI_CHAR, partner, 0, MPI_COMM_WORLD, &st); }
            else           { MPI_Recv(small, 8, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &st);
                             MPI_Send(small, 8, MPI_CHAR, 0, 0, MPI_COMM_WORLD); }
        }
        double t0 = MPI_Wtime();
        for (int i = 0; i < LAT_REPS; i++) {
            if (rank == 0) { MPI_Send(small, 8, MPI_CHAR, partner, 0, MPI_COMM_WORLD);
                             MPI_Recv(small, 8, MPI_CHAR, partner, 0, MPI_COMM_WORLD, &st); }
            else           { MPI_Recv(small, 8, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &st);
                             MPI_Send(small, 8, MPI_CHAR, 0, 0, MPI_COMM_WORLD); }
        }
        lat_us = (MPI_Wtime() - t0) / LAT_REPS / 2.0 * 1e6;   /* one-way */
    }

    MPI_Barrier(MPI_COMM_WORLD);
    if (size > 1 && (rank == 0 || rank == partner)) {
        char *buf = malloc(BW_BYTES);
        memset(buf, 1, BW_BYTES);
        MPI_Status st;
        /* warmup */
        for (int i = 0; i < 2; i++) {
            if (rank == 0) { MPI_Send(buf, BW_BYTES, MPI_CHAR, partner, 1, MPI_COMM_WORLD);
                             MPI_Recv(buf, BW_BYTES, MPI_CHAR, partner, 1, MPI_COMM_WORLD, &st); }
            else           { MPI_Recv(buf, BW_BYTES, MPI_CHAR, 0, 1, MPI_COMM_WORLD, &st);
                             MPI_Send(buf, BW_BYTES, MPI_CHAR, 0, 1, MPI_COMM_WORLD); }
        }
        double t0 = MPI_Wtime();
        for (int i = 0; i < BW_REPS; i++) {
            if (rank == 0) { MPI_Send(buf, BW_BYTES, MPI_CHAR, partner, 1, MPI_COMM_WORLD);
                             MPI_Recv(buf, BW_BYTES, MPI_CHAR, partner, 1, MPI_COMM_WORLD, &st); }
            else           { MPI_Recv(buf, BW_BYTES, MPI_CHAR, 0, 1, MPI_COMM_WORLD, &st);
                             MPI_Send(buf, BW_BYTES, MPI_CHAR, 0, 1, MPI_COMM_WORLD); }
        }
        double t = MPI_Wtime() - t0;
        bw_gbs = 2.0 * BW_BYTES * BW_REPS / t / 1e9;          /* both directions counted */
        free(buf);
    }

    MPI_Barrier(MPI_COMM_WORLD);
    if (rank == 0 && size > 1) {
        printf("ping-pong rank 0 <-> rank %d:\n", partner);
        printf("  latency  (8 B, one-way)   : %.2f us\n", lat_us);
        printf("  bandwidth (64 MiB msgs)   : %.2f GB/s\n", bw_gbs);
    }
    MPI_Finalize();
    return 0;
}
