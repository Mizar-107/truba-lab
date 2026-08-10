# Experiment backlog

Candidates, in no particular order. Each should stay small enough to run in minutes and produce one artifact worth keeping.

- **003 — Mandelbrot array job**: render the set as a 50-tile Slurm job array, stitch tiles into one PNG. Teaches `--array`, produces something pretty.
- **004 — MPI hello**: 80 ranks across 2 barbun nodes (`module load` + `mpicc` + `srun`). First multi-node job.
- **005 — P100 does math**: PyTorch matmul/bandwidth benchmark on the P100, or a 5-minute char-LM training run with a loss curve. Checks what the software stack (modules, CUDA toolchain, pip) actually supports on sm_60.
- **006 — watch yourself on Grafana**: fire a 20-job array and capture the blip on the cluster dashboards. Observability tourism.
- **007 — node autopsy**: one inventory job per partition (lscpu, free, nvidia-smi, interconnect) → a hardware table of what each queue actually buys you.

Done: 002 (π scaling, 110.2×), 008 (tools field test — folded into 002).
