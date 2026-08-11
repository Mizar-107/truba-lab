# Experiment backlog

Candidates, in no particular order. Each should stay small enough to run in minutes and produce one artifact worth keeping.

- **010 — distributed training for real**: PyTorch DDP across 2 barbun-cuda nodes (4× P100 over EDR) — measure scaling efficiency of actual training, not microbenchmarks.
- **011 — multi-rail / UCX tuning**: close the 30 → 50 GB/s gap; orfoz nodes carry extra HCAs (2× QDR alongside the NDR port) — can UCX use them?
- **012 — scratch filesystem benchmark**: modest fio/IOR run against /arf/scratch — sequential vs random, one node vs several.
- **013 — Apptainer**: run a containerized workload if the runtime exists on ARF; the reproducibility story.
- **014 — preemption-proof jobs**: checkpoint/requeue pattern with `--signal=B:USR1` traps — survive walltime and requeues gracefully.
- **015 — finish 007**: collect the hamsi and akya-cuda autopsy rows when those queues finally clear.
- **016 — the blog post**: "Turkey's free national supercomputer: what you actually get" — the repo now contains all the numbers.

Done: 002 (π scaling, 110.2×), 003 (Mandelbrot array), 004 (MPI + naive ping-pong), 005 (P100: 8.6 TF fp32), 006 (Grafana), 007 (autopsy — 2 rows pending), 008 (tools test), 009 (OSU: 1.35 µs / 29.9 GB/s).
