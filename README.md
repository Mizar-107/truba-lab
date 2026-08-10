# truba-lab

Personal lab notebook of experiments on [TRUBA](https://www.truba.gov.tr) — Turkey's national HPC infrastructure (TÜBİTAK ULAKBİM) — mostly on the **ARF** cluster.

Part playground, part field guide. The official docs leave gaps (submit-filter rules, Turkish-only error messages, Windows client pitfalls); everything I hit and solved is written down here so the next person doesn't have to rediscover it.

## Experiments

| # | Experiment | Result |
|---|---|---|
| [001](experiments/001-hello/) | Hello world, CPU + GPU | End-to-end pipeline proven. CPU job on `debug` (Xeon Gold 6148), GPU job on `barbun-cuda` (Tesla P100 16GB, CUDA 12.7). Three undocumented submit-filter rules discovered along the way. |
| [002](experiments/002-pi-scaling/) | π strong scaling, 1→112 threads | **110.2× speedup** on one full orfoz node (2× Xeon Platinum 8480+, 98.3% efficiency, 22.8 GSamples/s) — near-perfect linear. `tools/` field-tested in the process. |

Candidates queued in [experiments/BACKLOG.md](experiments/BACKLOG.md).

## How this repo works

- Experiments are numbered, append-only, self-contained: a `README.md` lab note (goal → method → what broke → results → lessons), the job script(s), and small result artifacts (`results/`). Big data stays on cluster scratch.
- [`docs/setup.md`](docs/setup.md) — zero-to-first-job path (VPN → SSH → key → scratch → `sbatch`).
- [`docs/gotchas.md`](docs/gotchas.md) — the field guide: everything the official docs don't tell you.
- [`tools/`](tools/) — thin helpers: `run.sh` syncs an experiment dir to scratch and submits; `fetch.sh` pulls the outputs back.

## Caveats

Personal notes, not official documentation. Cluster policies change; "verified" dates are noted inline. Queue rules and IPs are as published in TRUBA's own public docs — no credentials or VPN profiles live here.
