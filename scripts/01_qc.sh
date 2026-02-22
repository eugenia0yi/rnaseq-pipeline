#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

THREADS="${THREADS:-4}"
mkdir -p results/qc logs

echo "[QC] Running FastQC on data/*.fastq.gz ..."
fastqc -o results/qc -t "$THREADS" data/*.fastq.gz 2>&1 | tee "logs/01_fastqc.log"

echo "[QC] Running MultiQC ..."
multiqc -o results/qc results/qc 2>&1 | tee "logs/01_multiqc.log"

echo "[QC] Done. Open: results/qc/multiqc_report.html"
