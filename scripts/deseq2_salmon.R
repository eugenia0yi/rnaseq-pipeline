suppressPackageStartupMessages({
  library(tximport)
  library(DESeq2)
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(ggrepel)
})

project_root <- normalizePath(file.path(getwd()))
samples_path <- file.path(project_root, "samples.csv")
salmon_dir <- file.path(project_root, "results", "salmon")
gtf_gz <- file.path(project_root, "ref", "annotation.gtf.gz")
out_dir <- file.path(project_root, "results", "deseq2")

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

if (!file.exists(samples_path)) stop("samples.csv not found.")
if (!dir.exists(salmon_dir)) stop("results/salmon not found. Run salmon quant first.")
if (!file.exists(gtf_gz)) stop("ref/annotation.gtf.gz not found. Download GTF in scripts/02_ref_download.sh first.")

message("[DESeq2] Reading sample sheet...")
samples <- read_csv(samples_path, show_col_types = FALSE) %>%
  mutate(sample = as.character(sample),
         condition = as.factor(condition))

# Build quant.sf paths
files <- file.path(salmon_dir, samples$sample, "quant.sf")
names(files) <- samples$sample

missing <- files[!file.exists(files)]
if (length(missing) > 0) {
  stop("Missing quant.sf for samples: ", paste(names(missing), collapse = ", "))
}

message("[DESeq2] Building tx2gene from GTF...")
# Minimal GTF parser for transcript_id and gene_id
# Reads gz directly; pulls only fields + attribute column
gtf <- read_tsv(gtf_gz,
                comment = "#",
                col_names = c("seqname","source","feature","start","end","score","strand","frame","attribute"),
                col_types = "ccccccccc",
                progress = FALSE)

extract_attr <- function(x, key) {
  # key like transcript_id or gene_id
  pattern <- paste0(key, ' "([^"]+)"')
  m <- regexpr(pattern, x, perl = TRUE)
  ifelse(m > 0, sub(pattern, "\\1", regmatches(x, m), perl = TRUE), NA_character_)
}

tx2gene <- gtf %>%
  filter(feature == "transcript" | feature == "exon") %>% # keep common
  mutate(transcript_id = extract_attr(attribute, "transcript_id"),
         gene_id = extract_attr(attribute, "gene_id")) %>%
  select(transcript_id, gene_id) %>%
  filter(!is.na(transcript_id), !is.na(gene_id)) %>%
  distinct()

tx2gene_path <- file.path(out_dir, "tx2gene.tsv")
write_tsv(tx2gene, tx2gene_path)

message("[DESeq2] Importing Salmon quantifications with tximport...")
txi <- tximport(files, type = "salmon", tx2gene = tx2gene, countsFromAbundance = "no")

message("[DESeq2] Running DESeq2...")
dds <- DESeqDataSetFromTximport(txi, colData = samples, design = ~ condition)
dds <- DESeq(dds)

res <- results(dds)
res_tbl <- as.data.frame(res) %>%
  tibble::rownames_to_column("gene_id") %>%
  arrange(padj)

# Save count matrix (gene-level)
counts_mat <- as.data.frame(counts(dds, normalized = FALSE))
counts_path <- file.path(out_dir, "gene_counts.tsv")
write_tsv(tibble::rownames_to_column(counts_mat, "gene_id"), counts_path)

# Save DE results
res_path <- file.path(out_dir, "deseq2_results.tsv")
write_tsv(res_tbl, res_path)

message("[DESeq2] Making PCA plot...")
vsd <- vst(dds, blind = TRUE)
pca <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
percentVar <- round(100 * attr(pca, "percentVar"))

p_pca <- ggplot(pca, aes(PC1, PC2, color = condition, label = name)) +
  geom_point(size = 3) +
  geom_text_repel(max.overlaps = 20, size = 3) +
  xlab(paste0("PC1: ", percentVar[1], "% variance")) +
  ylab(paste0("PC2: ", percentVar[2], "% variance")) +
  theme_minimal()

ggsave(filename = file.path(out_dir, "pca.png"), plot = p_pca, width = 7, height = 5, dpi = 200)

message("[DESeq2] Making volcano plot...")
vol <- res_tbl %>%
  mutate(sig = !is.na(padj) & padj < 0.05 & abs(log2FoldChange) >= 1)

p_vol <- ggplot(vol, aes(x = log2FoldChange, y = -log10(pvalue), label = gene_id)) +
  geom_point(alpha = 0.6) +
  geom_point(data = subset(vol, sig), size = 1.5) +
  geom_text_repel(data = head(subset(vol, sig), 15), size = 3, max.overlaps = 15) +
  theme_minimal() +
  xlab("log2 Fold Change") +
  ylab("-log10(p-value)")

ggsave(filename = file.path(out_dir, "volcano.png"), plot = p_vol, width = 7, height = 5, dpi = 200)

message("[DESeq2] Done.")
message("Outputs:")
message("  - ", counts_path)
message("  - ", res_path)
message("  - ", file.path(out_dir, "pca.png"))
message("  - ", file.path(out_dir, "volcano.png"))
message("  - ", tx2gene_path)
