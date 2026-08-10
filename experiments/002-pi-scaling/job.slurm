#!/bin/bash
# 002 — strong scaling of Monte-Carlo pi on one full node (112 cores).
# Submit from /arf/scratch/$USER (or via tools/run.sh):
#   sbatch -p debug job.slurm      # -c 112 steers it onto an orfoz-class node in the debug pool
#   sbatch -p orfoz job.slurm      # fallback if debug refuses 112 cores
#SBATCH --job-name=pi-scaling
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=112
#SBATCH --mem=8G
#SBATCH --time=00:20:00
#SBATCH --output=pi_scaling_%j.out
#SBATCH --error=pi_scaling_%j.err

echo "host: $(hostname)"
lscpu | grep -E 'Model name|^CPU\(s\)|Socket|NUMA node\(s\)'
gcc --version | head -1
gcc -O2 -fopenmp -o pi pi.c

export OMP_PROC_BIND=true
N=${N:-8000000000}
echo "CSV_BEGIN"
echo "threads,samples,pi,seconds,samples_per_sec"
for t in 1 2 4 8 16 28 56 112; do
    OMP_NUM_THREADS=$t ./pi "$N"
done
echo "CSV_END"
