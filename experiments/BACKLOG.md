# Experiment backlog

Candidates, in no particular order. Each should stay small enough to run in minutes and produce one artifact worth keeping.

- **005 — P100 does math**: PyTorch matmul/bandwidth benchmark on the P100, or a 5-minute char-LM training run with a loss curve. Checks what the software stack (modules, CUDA toolchain, pip) actually supports on sm_60.
- **006 — watch yourself on Grafana**: fire a 20-job array and capture the blip on the cluster dashboards. Observability tourism.

Done: 002 (π scaling, 110.2×), 003 (Mandelbrot array), 004 (MPI + fabric ping-pong, 17.3 GB/s), 007 (node autopsy — hamsi & akya-cuda rows pending), 008 (tools field test — folded into 002).

New candidate: **009 — OSU microbenchmarks**: proper `osu_latency`/`osu_bw` sweep of the NDR fabric with UCX tuning — 004's naive numbers (5.2 µs / 17.3 GB/s) suggest real headroom.
