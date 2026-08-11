#!/bin/bash
# 003 — Mandelbrot as a Slurm job array: 50 tasks, one 40-row strip each (2800x2000 total).
# Submit from /arf/scratch/$USER/truba-lab/003-mandelbrot-array (tools/run.sh does this):
#   sbatch -p debug job.slurm
# Then stitch after the array finishes:
#   sbatch -p debug --dependency=afterok:<ARRAY_JOBID> stitch.slurm
#SBATCH --job-name=mandel
#SBATCH --array=0-49%10
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:10:00
#SBATCH --output=mandel_%A_%a.out
#SBATCH --error=mandel_%A_%a.err

W=2800; H=2000; ITER=2000; ROWS=40
ID=${SLURM_ARRAY_TASK_ID}
BIN=/tmp/mandel_${SLURM_JOB_ID}_${ID}
gcc -O2 -o "$BIN" mandel.c -lm
"$BIN" $W $H $ITER $((ID * ROWS)) $(((ID + 1) * ROWS)) "$(printf 'tile_%03d.ppmraw' "$ID")"
rm -f "$BIN"
echo "task $ID: rows $((ID * ROWS))-$(((ID + 1) * ROWS - 1)) on $(hostname)"
