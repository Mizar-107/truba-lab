# 001 — Hello world (CPU + GPU)

**Date:** 2026-08-09/10 · **Cluster:** ARF · **Jobs:** 6214258 (CPU), 6214262 (GPU)

## Goal

Prove the full pipeline end-to-end — VPN → SSH → scratch → `sbatch` → output file — once on CPU, once on GPU. Zero science, maximum plumbing.

## Method

Two minimal scripts: [`hello_world.slurm`](hello_world.slurm) (1 core, echoes host/job info + CPU model) and [`hello_gpu.slurm`](hello_gpu.slurm) (1 GPU, runs `nvidia-smi`).

## What broke first (the actual findings)

Three submit-filter rules, none of them in the queue documentation, all reported as Turkish stderr messages followed by a generic English `QOS policy` error:

| Rejection | Rule |
|---|---|
| `Lutfen islerinizi /arf/scratch/ dizini altinda calistiriniz!` | Jobs must be submitted from `/arf/scratch/$USER`, not home |
| `Orfoz kuyruguna gonderilen islerde node basina 56/112 cekirdek talep ediniz.` | `orfoz` (the default partition!) only takes half-node (56) or full-node (112) core requests |
| `barbun-cuda kuyruguna gonderilen islerin cekirdek sayisi 20 ve katlari olmalidir` | GPU jobs on `barbun-cuda` must request cores in multiples of 20 (= 20 cores per GPU) |

Working submissions: `sbatch -p debug hello_world.slurm` and `sbatch -p barbun-cuda -c 20 hello_gpu.slurm`, both from scratch.

## Results

Raw outputs in [`results/`](results/), archived as captured at run time.

- **CPU** — job 6214258 landed on `barbun120` via `debug`: Intel Xeon Gold 6148 @ 2.40GHz. Submitted and finished within a 15-second polling window.
- **GPU** — job 6214262 landed on `barbun122` via `barbun-cuda`: 2× Tesla P100-PCIE-16GB visible on the node, driver 565.57.01, CUDA 12.7.

## Lessons

- `debug` (4 h limit, mixed node pool) is the iteration queue — it accepts 1-core jobs while the default `orfoz` rejects anything smaller than half a node.
- Prefer CLI overrides (`-p`, `-c`) over editing scripts; the same script then works across queues.
- Slurm's stated error is often not the real reason — read the Turkish stderr line above it. Full list of these in [docs/gotchas.md](../../docs/gotchas.md).
