#!/usr/bin/env bash
# Pull job outputs for an experiment back from ARF scratch into <experiment-dir>/results/.
#   usage: TRUBA_USER=<user> tools/fetch.sh <experiment-dir>
#   env:   TRUBA_USER (required), TRUBA_HOST (default 172.16.6.11), TRUBA_KEY (default ~/.ssh/id_ed25519)
# Status: field-tested 2026-08-10 (002). First attempt failed silently on a stale key path,
# hence the empty-results warning below. WSL note: /tmp is wiped on VM restart — re-copy the key.
set -euo pipefail

[ $# -ge 1 ] || { echo "usage: TRUBA_USER=<user> $0 <experiment-dir>" >&2; exit 1; }
EXP_DIR=${1%/}
: "${TRUBA_USER:?set TRUBA_USER}"
HOST=${TRUBA_HOST:-172.16.6.11}
KEY=${TRUBA_KEY:-$HOME/.ssh/id_ed25519}
EXP=$(basename "$EXP_DIR")
DEST="/arf/scratch/$TRUBA_USER/truba-lab/$EXP"

mkdir -p "$EXP_DIR/results"
scp -i "$KEY" -o BatchMode=yes "$TRUBA_USER@$HOST:$DEST/*.out" "$EXP_DIR/results/" 2>/dev/null || true
scp -i "$KEY" -o BatchMode=yes "$TRUBA_USER@$HOST:$DEST/*.err" "$EXP_DIR/results/" 2>/dev/null || true
if [ -z "$(ls -A "$EXP_DIR/results" 2>/dev/null)" ]; then
    echo "warning: nothing fetched — job still running, or bad TRUBA_KEY/host? (ssh manually to check)" >&2
fi
ls -la "$EXP_DIR/results/"
