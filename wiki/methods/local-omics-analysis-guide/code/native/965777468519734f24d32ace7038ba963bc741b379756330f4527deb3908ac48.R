filter_and_select_genes <- function(counts, ko_gene, qc_minCells, gene_limit, target_genes) {
  nGenes <- nrow(counts)
  if (nGenes <= gene_limit) {
    genes <- rownames(counts)
    if (!is.null(ko_gene) && ko_gene %in% genes) genes <- union(ko_gene, genes)
    return(list(genes = genes, strategy = "no_filter"))
  }

  log_msg("nGenes=", nGenes, " > ", gene_limit, ": applying low-expression filter + HVG selection")
  keep <- Matrix::rowSums(counts > 0) >= qc_minCells
  counts2 <- counts[keep, , drop = FALSE]
  log_msg("After low-expression filter (>=", qc_minCells, " cells): ", nrow(counts2), " genes")
  hvgs <- select_hvgs(counts2, target = target_genes)
  genes <- hvgs
  if (!is.null(ko_gene) && ko_gene %in% rownames(counts)) genes <- union(ko_gene, genes)
  list(genes = genes, strategy = paste0("lowExpr>=", qc_minCells, "+HVG_", min(length(genes), 7500L)))
}
