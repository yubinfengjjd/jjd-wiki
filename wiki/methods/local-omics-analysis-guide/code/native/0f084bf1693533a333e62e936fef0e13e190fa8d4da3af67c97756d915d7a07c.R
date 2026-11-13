compute_focal_limits <- function(panel_specs, nhood_store) {
  all_values <- unlist(lapply(seq_len(nrow(panel_specs)), function(i) {
    nhood_store[[panel_specs$sample[[i]]]][, panel_specs$celltype[[i]], drop = TRUE]
  }))
  limits <- stats::quantile(all_values, probs = c(0.03, 0.97), na.rm = TRUE, names = FALSE, type = 7)
  if (!all(is.finite(limits)) || diff(limits) <= 0) limits <- range(all_values, na.rm = TRUE)
  limits
}
