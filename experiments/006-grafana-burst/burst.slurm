#!/bin/bash
# 006 — 20-task load burst: enough of a blip to see yourself on the cluster dashboards.
# Submit:  sbatch -p debug burst.slurm   (40 core-minutes total — deliberately tiny)
#SBATCH --job-name=burst
#SBATCH --array=0-19
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:04:00
#SBATCH --output=burst_%A_%a.out
#SBATCH --error=burst_%A_%a.err

echo "task ${SLURM_ARRAY_TASK_ID} spinning on $(hostname)"
timeout 150 bash -c 'while :; do :; done'
echo "done"
