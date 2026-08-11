# truba-lab

Personal lab notebook of experiments on [TRUBA](https://www.truba.gov.tr) — Turkey's national HPC infrastructure (TÜBİTAK ULAKBİM) — mostly on the **ARF** cluster.

Part playground, part field guide. The official docs leave gaps (submit-filter rules, Turkish-only error messages, Windows client pitfalls); everything I hit and solved is written down here so the next person doesn't have to rediscover it.

## Experiments

| # | Experiment | Result |
|---|---|---|
| [001](experiments/001-hello/) | Hello world, CPU + GPU | End-to-end pipeline proven. CPU job on `debug` (Xeon Gold 6148), GPU job on `barbun-cuda` (Tesla P100 16GB, CUDA 12.7). Three undocumented submit-filter rules discovered along the way. |
| [002](experiments/002-pi-scaling/) | π strong scaling, 1→112 threads | **110.2× speedup** on one full orfoz node (2× Xeon Platinum 8480+, 98.3% efficiency, 22.8 GSamples/s) — near-perfect linear. `tools/` field-tested in the process. |
| [003](experiments/003-mandelbrot-array/) | Mandelbrot as a job array | 50-task array + `afterok` stitcher → seamless 2800×2000 render for ~50 core-seconds. Fan-out/fan-in with nothing but Slurm. |
| [004](experiments/004-mpi-hello/) | MPI across 2 nodes + fabric ping-pong | One 112-rank world on orfoz[204-205]: **5.2 µs latency, 17.3 GB/s** inter-node, untuned. Found two launch traps: batch shells need `-l` for modules, and `srun` (no PMIx) silently launches singletons — use `mpirun`. |
| [005](experiments/005-p100-bench/) | PyTorch on the P100 | **8.62 TFLOPS fp32** (93% of spec), 537 GB/s HBM2, PCIe saturated, 95.6k samples/s training. torch 2.7.1+cu118 still ships sm_60 kernels; fp16 buys memory, not speed. |
| [006](experiments/006-grafana-burst/) | Watch yourself on Grafana | 20-task burst caught live on TRUBA's built-in per-user/per-job dashboards — free observability nobody mentions. |
| [007](experiments/007-node-autopsy/) | Node autopsy, all partitions | Hardware table of every queue: orfoz on 400Gb NDR, a 16-socket 3.9TiB `smp` node, and the complete per-queue core-rule ledger. (2 queues still pending.) |
| [009](experiments/009-osu-fabric/) | OSU fabric microbenchmarks | The real numbers: **1.35 µs / 29.9 GB/s uni / 56.7 GB/s bi** between orfoz nodes — 004's gap was technique, not hardware. Bonus find: module trees differ across orfoz nodes. |

Candidates queued in [experiments/BACKLOG.md](experiments/BACKLOG.md).

## How this repo works

- Experiments are numbered, append-only, self-contained: a `README.md` lab note (goal → method → what broke → results → lessons), the job script(s), and small result artifacts (`results/`). Big data stays on cluster scratch.
- [`docs/setup.md`](docs/setup.md) — zero-to-first-job path (VPN → SSH → key → scratch → `sbatch`).
- [`docs/gotchas.md`](docs/gotchas.md) — the field guide: everything the official docs don't tell you.
- [`tools/`](tools/) — thin helpers: `run.sh` syncs an experiment dir to scratch and submits; `fetch.sh` pulls the outputs back.

## Caveats

Personal notes, not official documentation. Cluster policies change; "verified" dates are noted inline. Queue rules and IPs are as published in TRUBA's own public docs — no credentials or VPN profiles live here.
