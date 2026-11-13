extract_feature_values <- function(obj, gene, assay) {
  expr <- get_expr_matrix(obj, assay = assay, prefer = 'data')
  if (gene %in% rownames(expr)) return(as.numeric(expr[gene, colnames(obj)]))
  gene_tokens <- unique(unlist(strsplit(gene, '[_:+&]')))
  gene_tokens <- gene_tokens[gene_tokens %in% rownames(expr)]
  if (!length(gene_tokens)) return(rep(NA_real_, ncol(obj)))
  colMeans(as.matrix(expr[gene_tokens, colnames(obj), drop = FALSE]), na.rm = TRUE)
}
