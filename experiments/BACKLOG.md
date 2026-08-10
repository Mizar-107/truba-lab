# Experiment backlog

Candidates, in no particular order. Each should stay small enough to run in minutes and produce one artifact worth keeping.

- **002 — π scaling**: same Monte-Carlo π code on 1 core vs a full 112-core orfoz node; measure the actual speedup curve (1 → 4 → 16 → 56 → 112).
- **003 — Mandelbrot array job**: render the set as a 50-tile Slurm job array, stitch tiles into one PNG. Teaches `--array`, produces something pretty.
- **004 — MPI hello**: 80 ranks across 2 barbun nodes (`module load` + `mpicc` + `srun`). First multi-node job.
- **005 — P100 does math**: PyTorch matmul/bandwidth benchmark on the P100, or a 5-minute char-LM training run with a loss curve. Checks what the software stack (modules, CUDA toolchain, pip) actually supports on sm_60.
- **006 — watch yourself on Grafana**: fire a 20-job array and capture the blip on the cluster dashboards. Observability tourism.
- **007 — node autopsy**: one inventory job per partition (lscpu, free, nvidia-smi, interconnect) → a hardware table of what each queue actually buys you.
- **008 — tools field test**: exercise `tools/run.sh` + `fetch.sh` end-to-end (they were written for 002+ but haven't run yet).
