#!/bin/bash
# TRUBA GPU sanity check. Submit from /arf/scratch/$USER.
# Verified:  cd /arf/scratch/$USER && sbatch -p barbun-cuda hello_gpu.slurm
# barbun-cuda: 2x Tesla P100 16GB/node, cores must be multiples of 20 (20 per GPU).
# akya-cuda (V100-class) may have its own core rule — the submit error will say.
#SBATCH --job-name=hello-gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --gres=gpu:1
#SBATCH --mem=16G
#SBATCH --time=00:05:00
#SBATCH --output=hello_gpu_%j.out
#SBATCH --error=hello_gpu_%j.err

echo "GPU hello from $(hostname)"
nvidia-smi
echo "---"
nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv
