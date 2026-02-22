# RNA-seq Analysis Pipeline

A reproducible small RNA-seq analysis workflow built with Bash, Salmon, and DESeq2.

---

## Overview

This pipeline performs:

1. Quality control (FastQC + MultiQC)
2. Transcript quantification using Salmon
3. Differential expression analysis with DESeq2
4. Organized project structure for reproducibility

Designed for small bulk RNA-seq datasets (paired or single-end).

---

## Project Structure

rnaseq_small/
├── data/
├── ref/
├── results/
│ ├── qc/
│ ├── salmon/
│ └── deseq2/
├── scripts/
│ ├── 01_qc.sh
│ ├── 02_ref_download.sh
│ ├── 03_index.sh
│ ├── 04_quant.sh
│ └── 05_deseq2.sh
├── environment.yml
└── README.md

---

## Environment Setup

```bash
conda env create -f environment.yml
conda activate rnaseq
## Workflow

The analysis follows a fully scripted and reproducible workflow:

### 1. Quality Control

```bash
bash scripts/01_qc.sh
```

- Runs FastQC on all FASTQ files
- Aggregates reports using MultiQC
- Output directory: `results/qc/`

---

### 2. Reference Preparation

```bash
bash scripts/02_ref_download.sh
bash scripts/03_index.sh
```

- Downloads reference transcriptome
- Builds Salmon index
- Output directory: `ref/`

---

### 3. Transcript Quantification (Salmon)

```bash
bash scripts/04_quant.sh
```

- Performs pseudo-alignment using Salmon
- Generates transcript-level quantification
- Outputs include:
- TPM values
- Estimated counts
- Output directory: `results/salmon/`

---

### 4. Differential Expression Analysis (DESeq2)

```bash
bash scripts/05_deseq2.sh
```

- Imports Salmon quantification results
- Performs normalization and dispersion estimation
- Fits negative binomial model
- Outputs:
- Normalized count matrix
- Differential expression table
- MA plot
- Volcano plot
- Output directory: `results/deseq2/`

---

## Statistical Framework

- Transcript-level quantification: Salmon (quasi-mapping / pseudo-alignment)
- Gene-level differential expression: DESeq2
- Statistical model: Negative Binomial GLM
- Multiple testing correction: Benjamini–Hochberg FDR

---

## Reproducibility

- Fully scripted Bash workflow
- Environment version controlled via `environment.yml`
- Organized directory structure
- Compatible with paired-end and single-end datasets

---

## Author

Eugenia Yi
RNA-seq Pipeline Project
