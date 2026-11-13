align_meta_to_expr <- function(sobj, expr_mat) {
  spots <- colnames(expr_mat)
  md <- sobj@meta.data
  if (!all(spots %in% rownames(md))) {
    missing <- sum(!spots %in% rownames(md))
    stop("Metadata alignment failure: ", missing, " spots missing in meta.data.", call. = FALSE)
  }
  md[spots, , drop = FALSE]
}
