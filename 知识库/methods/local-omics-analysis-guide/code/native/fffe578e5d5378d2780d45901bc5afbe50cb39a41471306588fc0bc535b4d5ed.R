wf_detect_celltype_cols <- function(md, known = NULL) {
  num_cols <- names(md)[vapply(md, is.numeric, logical(1))]
  exclude <- grepl("^(nCount_|nFeature_|percent\\.)", num_cols) | grepl("^PTM_|^nhood_|^PC_|^UMAP_", num_cols) | grepl("domain|cluster|score|zscore", num_cols, ignore.case = TRUE)
  num_cols <- num_cols[!exclude]
  if (!is.null(known)) {
    known2 <- intersect(known, num_cols)
    if (length(known2) > 0) return(known2)
  }
  valid <- vapply(num_cols, function(x) {
    v <- md[[x]]
    v <- v[is.finite(v)]
    length(v) > 10 && mean(v >= 0 & v <= 1) > 0.8
  }, logical(1))
  num_cols[valid]
}
