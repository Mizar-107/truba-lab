# 007 — Node autopsy

**Date:** 2026-08-11 · **Cluster:** ARF · one inventory job per partition ([`autopsy.slurm`](autopsy.slurm))

## Goal

A hardware table of what each queue actually buys you — CPU, RAM, interconnect, GPU, OS — plus the per-queue submit-filter rules, learned empirically (rejections are data).

## The table (5/7 collected)

| Partition | Node seen | CPU | Cores | RAM | Interconnect | GPU | Job |
|---|---|---|---|---:|---|---|---|
| `debug` | barbun2 | 2× Xeon Gold 6148 | 40 | 376 Gi | IB EDR 100 Gb/s | — | 6224542 |
| `barbun` | barbun54 | 2× Xeon Gold 6148 | 40 | 376 Gi | IB EDR 100 Gb/s | — | 6224553 |
| `orfoz` | orfoz205 | 2× Xeon Platinum 8480+ | 112 | 251 Gi | **IB NDR 400 Gb/s** (+2× QDR 40) | — | 6224544 |
| `smp` | orkinos1 | **16×** Xeon E7-4850 v3 | 224 | **3.9 Ti** | IB FDR 56 Gb/s ×2 | — | 6224545 |
| `barbun-cuda` | barbun121 | 2× Xeon Gold 6148 | 40 | 376 Gi | IB EDR 100 Gb/s | 2× Tesla P100 16 GB | 6224547 |
| `hamsi` | *pending (Priority)* | | | | | | 6224554 |
| `akya-cuda` | *pending (Priority)* | | | | | | 6224546 |

All observed nodes run Rocky Linux 9.2, kernel 5.14. Raw outputs in [`results/`](results/).

## Submit-filter core rules (complete ledger so far)

| Partition | Rule | How we know |
|---|---|---|
| `debug` | ≥1 core fine | accepted `-c 1` |
| `orfoz` | 56 or 112 per node | rejection message (001) |
| `barbun` | 20 per node | rejection: `node basina 20 cekirdek talep edilmelidir` |
| `hamsi` | 56 per node | rejection: `node basina 56 cekirdek talep ediniz` |
| `barbun-cuda` | multiples of 20 (20/GPU) | rejection (001) |
| `akya-cuda` | `-c 10 --gres=gpu:1` accepted | no rejection (job queued) |
| `smp` | ≥1 core fine | accepted `-c 1` |

## Notable

- **orfoz is on 400 Gb NDR InfiniBand** — 4× the bandwidth of the barbun/hamsi EDR fabric. Multi-node jobs want orfoz for more than its core count.
- **orkinos1 (smp) is a 16-socket, 224-core, 3.9 TiB Haswell-EX museum piece** — slow cores, absurd memory. This is where "my dataset doesn't fit in RAM" goes to die.
- barbun nodes carry 376 Gi RAM — generous for 40 cores (9.4 Gi/core).
- Two Priority-pending jobs (hamsi, akya-cuda) will fill their rows when the queues clear.
