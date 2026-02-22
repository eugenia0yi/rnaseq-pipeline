#!/usr/bin/env bash
set -euo pipefail

# Reads samples.csv and runs salmon quant for each sample.
# Supports paired-end or single-end based on column presence.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

THREADS="${THREADS:-8}"
mkdir -p results/salmon logs

if [[ ! -d ref/salmon_index ]]; then
  echo "Error: ref/salmon_index not found. Run scripts/03_index.sh first."
  exit 1
fi

if [[ ! -f samples.csv ]]; then
  echo "Error: samples.csv not found in project root."
  echo "Copy a template: samples_paired.template.csv or samples_single.template.csv"
  exit 1
fi

echo "[QUANT] Detecting sample sheet type..."
header="$(head -n 1 samples.csv)"
if echo "$header" | grep -q "read2"; then
  MODE="paired"
else
  MODE="single"
fi
echo "[QUANT] Mode: $MODE"

# Parse CSV (simple parser; assumes no commas inside fields)
tail -n +2 samples.csv | while IFS=',' read -r sample condition read1 read2; do
  [[ -z "${sample// }" ]] && continue
  outdir="results/salmon/${sample}"
  mkdir -p "$outdir"

  echo "[QUANT] Sample: $sample"
  if [[ "$MODE" == "paired" ]]; then
    if [[ -z "${read2:-}" ]]; then
      echo "Error: read2 missing for paired-end sample $sample"
      exit 1
    fi
    salmon quant -i ref/salmon_index -l A \
      -1 "$read1" -2 "$read2" \
      -p "$THREADS" --validateMappings \
      -o "$outdir" 2>&1 | tee "logs/04_salmon_${sample}.log"
  else
    salmon quant -i ref/salmon_index -l A \
      -r "$read1" \
      -p "$THREADS" --validateMappings \
      -o "$outdir" 2>&1 | tee "logs/04_salmon_${sample}.log"
  fi
done

echo "[QUANT] Done. Example output: results/salmon/<SAMPLE>/quant.sf"
