#!/bin/bash
# 003 stitcher — runs after the array (--dependency=afterok:<ARRAY_JOBID>).
# Concatenates the 50 raw strips into one P6 PPM.
#SBATCH --job-name=mandel-stitch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --output=stitch_%j.out
#SBATCH --error=stitch_%j.err

W=2800; H=2000
printf 'P6\n%d %d\n255\n' $W $H > mandelbrot.ppm
cat tile_*.ppmraw >> mandelbrot.ppm            # zero-padded names sort into row order
ls -la mandelbrot.ppm
md5sum mandelbrot.ppm
echo "tiles: $(ls tile_*.ppmraw | wc -l)"
