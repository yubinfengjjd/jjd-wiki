detect_weight_columns <- function(meta, dominant_values = NULL) {
  meta <- as.data.frame(meta)
  numeric_cols <- colnames(meta)[vapply(meta, is.numeric, logical(1))]
  numeric_cols <- setdiff(
    numeric_cols,
    c("nCount_Spatial", "nFeature_Spatial", "percent.mt", "percent.ribo", "UBE2L6_expr")
  )
  if (!length(numeric_cols)) return(character())
  candidate_tbl <- meta[, numeric_cols, drop = FALSE]
  in_unit_range <- vapply(candidate_tbl, function(x) {
    x <- x[is.finite(x)]
    length(x) > 0 && min(x) >= 0 && max(x) <= 1.05
  }, logical(1))
  numeric_cols <- numeric_cols[in_unit_range]
  if (!length(numeric_cols)) return(character())
  if (!is.null(dominant_values)) {
    dominant_values <- unique(as.character(dominant_values))
    dominant_values <- dominant_values[!is.na(dominant_values)]
    hits <- intersect(dominant_values, numeric_cols)
    if (length(hits) >= 3) {
      row_sums <- rowSums(as.matrix(meta[, hits, drop = FALSE]), na.rm = TRUE)
      if (mean(row_sums > 0.75 & row_sums < 1.25, na.rm = TRUE) > 0.7) return(hits)
    }
  }
  row_score <- vapply(numeric_cols, function(x) mean(is.finite(meta[[x]])), numeric(1))
  numeric_cols <- numeric_cols[row_score > 0.95]
  if (!length(numeric_cols)) return(character())
  row_sums <- rowSums(as.matrix(meta[, numeric_cols, drop = FALSE]), na.rm = TRUE)
  if (mean(row_sums > 0.75 & row_sums < 1.25, na.rm = TRUE) > 0.7) numeric_cols else character()
}
