assign_epi_high_low <- function(values, spot_ids, min_n = 10L) {
  if (length(values) < 2) {
    return(list(labels = setNames(rep(NA_character_, length(values)), spot_ids), threshold = NA_real_, method = "insufficient_spots"))
  }
  thr <- stats::median(values, na.rm = TRUE)
  prelim <- ifelse(values > thr, "high", "low")
  prelim_tbl <- table(prelim)
  ratio <- if (length(prelim_tbl) == 2) max(prelim_tbl) / max(1, min(prelim_tbl)) else Inf
  if (length(prelim_tbl) == 2 && all(prelim_tbl >= min_n) && ratio <= 1.8) {
    return(list(labels = setNames(prelim, spot_ids), threshold = thr, method = "sample_median"))
  }
  ord <- order(values, spot_ids, decreasing = TRUE, na.last = TRUE)
  labels <- rep("low", length(values))
  labels[ord[seq_len(ceiling(length(ord) / 2))]] <- "high"
  list(labels = setNames(labels, spot_ids), threshold = thr, method = "rank_balanced_median_tie_fix")
}
