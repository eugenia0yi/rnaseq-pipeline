#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

mkdir -p results/deseq2 logs

Rscript scripts/deseq2_salmon.R 2>&1 | tee "logs/05_deseq2.log"

echo "[DESeq2] Done. See results/deseq2/"
