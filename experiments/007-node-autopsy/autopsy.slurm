#!/bin/bash
# 007 — node autopsy: one small job per partition, hardware inventory to stdout.
# Submit once per partition (core rules differ; the submit filter's Turkish errors are data too):
#   sbatch -p debug autopsy.slurm
#   sbatch -p barbun autopsy.slurm
#   sbatch -p hamsi autopsy.slurm
#   sbatch -p orfoz -c 56 autopsy.slurm
#   sbatch -p smp autopsy.slurm
#   sbatch -p akya-cuda -c 10 --gres=gpu:1 autopsy.slurm
#   sbatch -p barbun-cuda -c 20 --gres=gpu:1 autopsy.slurm
#SBATCH --job-name=autopsy
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:05:00
#SBATCH --output=autopsy_%j.out
#SBATCH --error=autopsy_%j.err

echo "partition: ${SLURM_JOB_PARTITION}"
echo "node:      $(hostname)"
lscpu | grep -E '^Model name|^CPU\(s\)|^Socket|^Thread|^NUMA node\(s\)'
free -h | awk 'NR<=2'
for d in /sys/class/infiniband/*; do
    [ -e "$d" ] && echo "ib: $(basename "$d") $(cat "$d"/ports/*/rate 2>/dev/null | head -1)"
done
command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader
{ cat /etc/redhat-release || grep PRETTY_NAME /etc/os-release; } 2>/dev/null
uname -r
