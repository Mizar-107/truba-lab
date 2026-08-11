#!/bin/bash -l
# 005 — PyTorch benchmark on a P100. One-time env setup (login node, ~2 GB download to scratch):
#   python3 -m venv /arf/scratch/$USER/venvs/torch
#   source /arf/scratch/$USER/venvs/torch/bin/activate
#   pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cu118
# Then:  sbatch -p barbun-cuda job.slurm   (20 cores = 1 GPU's share on these nodes)
#SBATCH --job-name=p100-bench
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --gres=gpu:1
#SBATCH --mem=32G
#SBATCH --time=00:15:00
#SBATCH --output=gpu_bench_%j.out
#SBATCH --error=gpu_bench_%j.err

source /arf/scratch/$USER/venvs/torch/bin/activate
python gpu_bench.py
