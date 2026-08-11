#!/bin/bash -l
# 004 — MPI across 2 orfoz nodes (56 ranks each = 112 total, satisfies the 56/node rule).
# NOTE the -l: ARF batch shells don't initialise the module system without a login shell.
# Submit from scratch (tools/run.sh):  sbatch -p orfoz job.slurm
#SBATCH --job-name=mpi-hello
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=56
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=00:10:00
#SBATCH --output=mpi_%j.out
#SBATCH --error=mpi_%j.err

command -v module >/dev/null || source /etc/profile.d/modules.sh 2>/dev/null
module load lib/openmpi/5.0.4
echo "nodes: $SLURM_JOB_NODELIST"
mpicc -O3 -o mpi_hello mpi_hello.c
# Plain srun launches 112 independent singletons here (no PMIx wiring) — ask for pmix
# explicitly, and fall back to OpenMPI's own launcher if the plugin is missing.
srun --mpi=pmix ./mpi_hello || mpirun ./mpi_hello
