#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/02_ref_download.sh human
#   bash scripts/02_ref_download.sh mouse
#
# You MUST paste official links (GENCODE) below for your chosen release.
# I can fill exact links once you confirm: species + desired GENCODE version.

SPECIES="${1:-}"
if [[ -z "$SPECIES" ]]; then
  echo "Error: species required: human or mouse"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

mkdir -p ref logs

TRANSCRIPTS_URL=""
GTF_URL=""

if [[ "$SPECIES" == "human" ]]; then
  # TODO: paste GENCODE GRCh38 transcripts fasta.gz link
  TRANSCRIPTS_URL="PASTE_GENCODE_HUMAN_TRANSCRIPTS_FASTA_GZ_LINK"
  # TODO: paste GENCODE GRCh38 annotation gtf.gz link
  GTF_URL="PASTE_GENCODE_HUMAN_GTF_GZ_LINK"
elif [[ "$SPECIES" == "mouse" ]]; then
  # TODO: paste GENCODE GRCm39 transcripts fasta.gz link
  TRANSCRIPTS_URL="PASTE_GENCODE_MOUSE_TRANSCRIPTS_FASTA_GZ_LINK"
  # TODO: paste GENCODE GRCm39 annotation gtf.gz link
  GTF_URL="PASTE_GENCODE_MOUSE_GTF_GZ_LINK"
else
  echo "Error: species must be 'human' or 'mouse'"
  exit 1
fi

if [[ "$TRANSCRIPTS_URL" == PASTE_* || "$GTF_URL" == PASTE_* ]]; then
  echo "You still need to paste the official GENCODE download links in scripts/02_ref_download.sh"
  echo "Tell me species + (paired/single) + example FASTQ names and I'll paste exact links for you."
  exit 1
fi

echo "[REF] Downloading transcripts..."
wget -O ref/transcripts.fa.gz "$TRANSCRIPTS_URL" 2>&1 | tee "logs/02_transcripts_wget.log"
echo "[REF] Extracting to ref/transcripts.fa ..."
gunzip -c ref/transcripts.fa.gz > ref/transcripts.fa

echo "[REF] Downloading annotation GTF..."
wget -O ref/annotation.gtf.gz "$GTF_URL" 2>&1 | tee "logs/02_gtf_wget.log"

echo "[REF] Done."
echo "  - ref/transcripts.fa"
echo "  - ref/annotation.gtf.gz"
