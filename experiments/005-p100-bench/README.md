# 005 — What can a 2016 Tesla P100 still do?

**Date:** 2026-08-11 · **Job:** 6224850 · **Node:** barbun131 (`barbun-cuda`) · **Elapsed:** 27 s

## Goal

Put real numbers on the free GPU tier: matmul TFLOPS, memory bandwidth, PCIe, and an actual training loop — plus establish a working PyTorch recipe for these nodes.

## Setup (one-time, login node)

```bash
python3 -m venv /arf/scratch/$USER/venvs/torch
source /arf/scratch/$USER/venvs/torch/bin/activate
pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cu118
```

Key fact: **torch 2.7.1+cu118 still ships sm_60 kernels** — a current PyTorch runs on this 2016 card, no ancient-version archaeology required. (`pip install numpy` too, to silence a harmless warning.) Login nodes have outbound internet; the ~2 GB download goes to scratch.

## Results ([raw](results/gpu_bench_6224850.out))

| Test | Result | vs spec |
|---|---|---|
| matmul fp32 8192² | **8.62 TFLOPS** | 93% of the 9.3 TF peak |
| matmul fp16 8192² | 7.72 TFLOPS | **no speedup** — see below |
| device memory copy | 537 GB/s | ~73% of 732 GB/s HBM2 |
| H2D over PCIe (pinned) | 12.3 GB/s | PCIe 3.0 ×16 saturated |
| MLP training (Adam, bs 512) | 187 steps/s · 95.6k samples/s | loss decreasing, mechanics proven |

## Findings

- **fp32 is where the P100 delivers** — 93% of spec through plain `torch.matmul` is as good as it gets.
- **fp16 buys memory, not speed, on sm_60.** The P100's on-paper 2:1 fp16 rate doesn't materialize through the modern cuBLAS path — treat half precision here as a way to fit bigger models in 16 GB, not as acceleration. (Tensor cores arrived with V100/sm_70.)
- PCIe 3.0 is the data-loading ceiling: 12.3 GB/s means feeding the GPU from host is ~40× slower than on-device bandwidth — keep datasets resident.
- Verdict: perfectly usable for ≤16 GB fp32 workloads, fine-tuning small models, and learning distributed-training mechanics; wrong tool for anything wanting bf16/tensor cores.
