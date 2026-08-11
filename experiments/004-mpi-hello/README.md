# 004 — MPI across nodes, and first fabric numbers

**Date:** 2026-08-11 · **Cluster:** ARF · **Jobs:** 6224616, 6224620 (instructive failures), **6224630** (success) · **Nodes:** orfoz[204-205]

## Goal

First true multi-node job: one MPI world spanning 2 orfoz nodes (56 ranks each — the 56/node rule), plus a naive ping-pong to put a first number on the NDR InfiniBand fabric.

## Method

[`mpi_hello.c`](mpi_hello.c): rank roster via `MPI_Gather`, then rank 0 ↔ rank 111 (guaranteed inter-node under block distribution) measures 8 B round-trip latency (2000 reps) and 64 MiB message bandwidth (20 reps, both directions counted). `lib/openmpi/5.0.4`, compiled in-job.

## The three-act failure story (the real findings)

1. **`module: command not found`** — ARF batch scripts don't get the module system with a plain `#!/bin/bash`. Fix: **`#!/bin/bash -l`** (job 6224616 died on this).
2. **Plain `srun ./mpi_hello` launches 112 independent singletons** — 112 copies of "Merhaba from 1 ranks". This Slurm build has **no PMIx plugin** (`srun: Invalid MPI type 'pmix'`), so srun cannot wire OpenMPI ranks into one world (job 6224620; its stderr is archived in [`results/`](results/)).
3. **`mpirun` works** — OpenMPI's own launcher reads the Slurm allocation and does the right thing (job 6224630, 4 s).

## Results

```
Merhaba from 112 ranks
  node orfoz204     : 56 ranks (first: rank 0)
  node orfoz205     : 56 ranks (first: rank 56)
ping-pong rank 0 <-> rank 111:
  latency  (8 B, one-way)   : 5.19 us
  bandwidth (64 MiB msgs)   : 17.33 GB/s
```

17.3 GB/s ≈ 139 Gb/s — a single untuned MPI stream pulling a third of the 400 Gb NDR link's line rate, with zero UCX tuning. Latency at 5.2 µs likewise has known headroom (tuned RDMA typically lands ~1–2 µs). A proper `osu_bw`/`osu_latency` sweep is a natural follow-up experiment.

## Lessons

- `#!/bin/bash -l` on every ARF job script that needs `module`.
- **`mpirun`, not `srun`, for OpenMPI on ARF** — check `srun --mpi=list` before trusting srun anywhere else.
- The fabric gives a lazy first attempt 17 GB/s between nodes; communication-heavy multi-node work genuinely belongs on orfoz.
