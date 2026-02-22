# Small RNA-seq Pipeline (FastQC → Salmon → tximport/DESeq2)

This is a **minimal, practical project template** you can run on a laptop or a small server.

## What you provide
- FASTQ(.gz) files (paired-end or single-end)
- Species: **human** or **mouse**
- `samples.csv` sample sheet (template provided)

## Folder layout
```
rnaseq_small/
  data/              # put FASTQs here
  ref/               # transcriptome + salmon index
  results/
    qc/              # FastQC + MultiQC
    salmon/          # salmon per-sample outputs
    deseq2/          # gene counts + DE results + plots
  scripts/           # runnable scripts
  logs/              # logs from each step
  samples.csv        # your sample sheet
```

---

## Quick start (recommended)

### 0) Create conda env
Option A (environment.yml):
```bash
cd rnaseq_small
conda env create -f environment.yml
conda activate rnaseq
```

Option B (one-liner):
```bash
conda create -n rnaseq -y -c conda-forge -c bioconda fastqc multiqc salmon pigz r-base r-tximport r-deseq2 r-tidyverse r-ggplot2 r-ggrepel r-pheatmap r-readr
conda activate rnaseq
```

Verify:
```bash
salmon --version
fastqc --version
multiqc --version
R --version
```

### 1) Put FASTQs in `data/`
```bash
ls -lh data | head
```

### 2) Create `samples.csv`
Copy a template then edit filenames:
- `samples_paired.template.csv`
- `samples_single.template.csv`

Example paired-end:
```csv
sample,condition,read1,read2
S1,control,data/S1_R1.fastq.gz,data/S1_R2.fastq.gz
S2,control,data/S2_R1.fastq.gz,data/S2_R2.fastq.gz
S3,treated,data/S3_R1.fastq.gz,data/S3_R2.fastq.gz
S4,treated,data/S4_R1.fastq.gz,data/S4_R2.fastq.gz
```

### 3) Run QC
```bash
bash scripts/01_qc.sh
open results/qc/multiqc_report.html
```

### 4) Download reference transcripts
Pick one (human or mouse) and set the URL inside the script:
```bash
bash scripts/02_ref_download.sh human
# or
bash scripts/02_ref_download.sh mouse
```

### 5) Build salmon index
```bash
bash scripts/03_index.sh
```

### 6) Quantify all samples (reads `samples.csv`)
```bash
bash scripts/04_quant.sh
```

### 7) Differential expression (tximport + DESeq2)
```bash
bash scripts/05_deseq2.sh
```

Outputs go to `results/deseq2/`:
- `gene_counts.tsv`
- `deseq2_results.tsv`
- `pca.png`
- `volcano.png`

---

## Notes
- This template uses Salmon transcript quantification + **tximport** to gene counts for **DESeq2**.
- For transcript-to-gene mapping (`tx2gene`), this template expects a **GENCODE GTF** file:
  - Put it at `ref/annotation.gtf.gz` (download link is species/version specific).
  - The DESeq2 script will parse it to create `tx2gene.tsv`.

If you tell me:
1) human or mouse, 2) paired or single, 3) 2–3 example FASTQ filenames  
I can fill in the exact official GENCODE links and tweak scripts for your dataset.
