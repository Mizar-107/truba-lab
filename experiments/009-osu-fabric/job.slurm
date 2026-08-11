#!/bin/bash -l
# 009 — OSU microbenchmarks between 2 orfoz nodes (NDR fabric), 1 rank per node.
# Prereq (login node, into this experiment's scratch dir):
#   wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.4.tar.gz
# Submit:  sbatch -p orfoz job.slurm
# (the 2x56-core allocation satisfies the orfoz rule; mpirun then launches just 2 ranks, one per node)
#SBATCH --job-name=osu
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=56
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=00:25:00
#SBATCH --output=osu_%j.out
#SBATCH --error=osu_%j.err

# Some orfoz nodes see a different module tree (job 6224811 couldn't find lib/openmpi/5.0.4
# on orfoz[324-325] though orfoz[204-205] had it) — discover whatever OpenMPI this node offers.
OMPIMOD=$(module -t avail 2>&1 | grep -E "^lib/openmpi/5" | sort -V | tail -1)
[ -z "$OMPIMOD" ] && OMPIMOD=$(module -t avail 2>&1 | grep -E "^lib/openmpi/" | sort -V | tail -1)
echo "openmpi module: ${OMPIMOD:-NONE-FOUND}"
module load "$OMPIMOD"
which mpicc mpirun || exit 1
echo "nodes: $SLURM_JOB_NODELIST"

if [ -z "$(find . -maxdepth 4 -name osu_latency -type f 2>/dev/null | head -1)" ]; then
    tar xzf osu-micro-benchmarks-*.tar.gz
    cd osu-micro-benchmarks-*/
    ./configure CC=mpicc CXX=mpicxx > configure.log 2>&1
    make -j 16 > make.log 2>&1 || make > make.log 2>&1
    cd ..
fi

LAT=$(find osu-micro-benchmarks-*/ -name osu_latency -type f | head -1)
BW=$(find osu-micro-benchmarks-*/ -name osu_bw -type f | head -1)
BIBW=$(find osu-micro-benchmarks-*/ -name osu_bibw -type f | head -1)
echo "binaries: $LAT $BW $BIBW"

echo "===LATENCY==="
mpirun -np 2 --map-by node "$LAT"
echo "===BW==="
mpirun -np 2 --map-by node "$BW"
echo "===BIBW==="
mpirun -np 2 --map-by node "$BIBW"
