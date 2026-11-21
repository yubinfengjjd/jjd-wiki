# Bulk / micro-region RNA-seq (PickSeq mrSEQ) differential expression using DESeq2.
# Adapted from Nirmal et al., Cancer Discovery 2022 (06_mrseq_deseq2_pca_gsea.R).

run_deseq2_mrseq_de <- function(
  counts_mat,
  col_data,
  group_col = "site",
  ref_level = "EM",
  alt_level = "IM",
  min_row_sum = 10L
) {
  if (!requireNamespace("DESeq2", quietly = TRUE)) {
    stop("Missing required R package: DESeq2")
  }
  if (!is.matrix(counts_mat)) {
    counts_mat <- as.matrix(counts_mat)
  }
  storage.mode(counts_mat) <- "integer"

  if (!(group_col %in% colnames(col_data))) {
    stop("Missing group_col in col_data: ", group_col)
  }
  sample_ids <- rownames(col_data)
  if (is.null(sample_ids)) {
    stop("col_data must have sample_ids as rownames")
  }
  common_samples <- intersect(sample_ids, colnames(counts_mat))
  sub_meta <- col_data[common_samples, , drop = FALSE]
  keep_s <- as.character(sub_meta[[group_col]]) %in% c(ref_level, alt_level)
  sub_meta <- sub_meta[keep_s, , drop = FALSE]
  sub_counts <- counts_mat[, rownames(sub_meta), drop = FALSE]

  keep_g <- rowSums(sub_counts) >= as.integer(min_row_sum)
  sub_counts <- sub_counts[keep_g, , drop = FALSE]
  if (nrow(sub_counts) < 5L) {
    stop("Too few expressed genes after min_row_sum filtering")
  }

  design_df <- data.frame(
    group = factor(as.character(sub_meta[[group_col]]), levels = c(ref_level, alt_level)),
    row.names = rownames(sub_meta)
  )

  dds <- suppressMessages(
    DESeq2::DESeqDataSetFromMatrix(
      countData = sub_counts,
      colData = design_df,
      design = ~ group
    )
  )
  dds <- suppressMessages(DESeq2::DESeq(dds, quiet = TRUE))
  res <- DESeq2::results(dds, contrast = c("group", alt_level, ref_level))

  res_df <- as.data.frame(res)
  res_df$gene_id <- rownames(res_df)
  res_df <- res_df[, c("gene_id", "baseMean", "log2FoldChange", "lfcSE", "stat", "pvalue", "padj")]
  res_df <- res_df[order(res_df$padj, res_df$pvalue, na.last = TRUE), , drop = FALSE]
  rownames(res_df) <- NULL

  norm_counts <- DESeq2::counts(dds, normalized = TRUE)
  log2_norm <- round(log2(norm_counts + 1), 5)

  list(
    results = res_df,
    log2_norm = log2_norm,
    size_factors = DESeq2::sizeFactors(dds)
  )
}
