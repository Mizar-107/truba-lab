#!/bin/bash
# TRUBA/ARF first job.
# MUST be submitted from scratch:  mkdir -p /arf/scratch/$USER && cd /arf/scratch/$USER
# Verified:                        sbatch -p debug hello_world.slurm
# (default partition orfoz only accepts 56- or 112-core jobs; debug takes small ones, 4h max)
#SBATCH --job-name=hello
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:02:00
#SBATCH --output=hello_%j.out
#SBATCH --error=hello_%j.err

echo "Merhaba TRUBA — hello from $(hostname)"
echo "Date      : $(date)"
echo "Job ID    : ${SLURM_JOB_ID}"
echo "Partition : ${SLURM_JOB_PARTITION}"
echo "Nodes     : ${SLURM_JOB_NODELIST}"
echo "CPUs/node : ${SLURM_CPUS_ON_NODE}"
grep -m1 'model name' /proc/cpuinfo || true
