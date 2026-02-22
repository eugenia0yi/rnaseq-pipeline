#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

THREADS="${THREADS:-8}"
mkdir -p ref logs

if [[ ! -f ref/transcripts.fa ]]; then
  echo "Error: ref/transcripts.fa not found. Run scripts/02_ref_download.sh first."
  exit 1
fi

echo "[INDEX] Building Salmon index..."
salmon index -t ref/transcripts.fa -i ref/salmon_index -p "$THREADS" 2>&1 | tee "logs/03_salmon_index.log"

echo "[INDEX] Done. Index at ref/salmon_index/"
