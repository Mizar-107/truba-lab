#!/usr/bin/env bash
# Sync an experiment dir to ARF scratch and submit a job script.
#   usage: TRUBA_USER=<user> tools/run.sh <experiment-dir> <script.slurm> [extra sbatch args...]
#   env:   TRUBA_USER (required), TRUBA_HOST (default 172.16.6.11), TRUBA_KEY (default ~/.ssh/id_ed25519)
#   example: TRUBA_USER=me tools/run.sh experiments/002-pi-scaling job.slurm -p debug
# Status: written 2026-08-10, not yet field-tested (BACKLOG 008).
set -euo pipefail

[ $# -ge 2 ] || { echo "usage: TRUBA_USER=<user> $0 <experiment-dir> <script.slurm> [sbatch args...]" >&2; exit 1; }
EXP_DIR=${1%/}; SCRIPT=$2; shift 2
: "${TRUBA_USER:?set TRUBA_USER}"
HOST=${TRUBA_HOST:-172.16.6.11}
KEY=${TRUBA_KEY:-$HOME/.ssh/id_ed25519}
EXP=$(basename "$EXP_DIR")
DEST="/arf/scratch/$TRUBA_USER/truba-lab/$EXP"

[ -f "$EXP_DIR/$SCRIPT" ] || { echo "error: $EXP_DIR/$SCRIPT not found" >&2; exit 1; }

ssh -i "$KEY" -o BatchMode=yes -o ConnectTimeout=10 "$TRUBA_USER@$HOST" "mkdir -p '$DEST'"

# ship top-level files (scripts, sources); results/ and README stay local
find "$EXP_DIR" -maxdepth 1 -type f ! -name 'README*' -exec \
  scp -i "$KEY" -o BatchMode=yes {} "$TRUBA_USER@$HOST:$DEST/" \;

# submit; capture stderr — the Turkish filter messages live there
ssh -i "$KEY" -o BatchMode=yes "$TRUBA_USER@$HOST" "cd '$DEST' && sbatch $* '$SCRIPT' 2>&1"
