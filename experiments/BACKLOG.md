# Experiment backlog

Candidates, in no particular order. Each should stay small enough to run in minutes and produce one artifact worth keeping.

- **004 — MPI hello**: 80 ranks across 2 barbun nodes (`module load` + `mpicc` + `srun`). First multi-node job.
- **005 — P100 does math**: PyTorch matmul/bandwidth benchmark on the P100, or a 5-minute char-LM training run with a loss curve. Checks what the software stack (modules, CUDA toolchain, pip) actually supports on sm_60.
- **006 — watch yourself on Grafana**: fire a 20-job array and capture the blip on the cluster dashboards. Observability tourism.

Done: 002 (π scaling, 110.2×), 003 (Mandelbrot array), 007 (node autopsy — hamsi & akya-cuda rows pending), 008 (tools field test — folded into 002).
