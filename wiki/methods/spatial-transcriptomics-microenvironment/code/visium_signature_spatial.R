# Visium spot spatial signature weighting, co-enrichment zoning, and multichannel LR colocalization.
# Adapted from Cai et al., npj Precision Oncology 2026 (03_spatial_scores_deconv.R).

run_visium_signature_spatial <- function(
  spots_df,
  score_cols,
  zone_pair = NULL,
  lr_pairs = list(),
  quantile_shift = 0.05,
  high_quantile = 0.75
) {
  if (!is.data.frame(spots_df) || nrow(spots_df) == 0L) {
    stop("spots_df must be a non-empty data.frame")
  }
  missing_scores <- setdiff(score_cols, colnames(spots_df))
  if (length(missing_scores) > 0L) {
    stop("Missing score columns: ", paste(missing_scores, collapse = ", "))
  }

  score_mat <- as.matrix(spots_df[, score_cols, drop = FALSE])
  storage.mode(score_mat) <- "numeric"

  # Shift each signature by its lower quantile, clip at 0, and L1-normalize per spot
  nn_mat <- apply(score_mat, 2, function(v) {
    q_lo <- as.numeric(stats::quantile(v, probs = quantile_shift, na.rm = TRUE))
    pmax(v - q_lo, 0)
  })
  row_sums <- rowSums(nn_mat, na.rm = TRUE)
  row_sums[row_sums <= 0] <- 1e-9
  weight_mat <- sweep(nn_mat, 1, row_sums, "/")
  weight_cols <- sub("^score_", "weight_", score_cols)
  colnames(weight_mat) <- weight_cols

  out <- cbind(spots_df, as.data.frame(weight_mat, check.names = FALSE))

  # Optional two-signature high/low spatial co-enrichment zoning
  zone_summary <- data.frame(spatial_zone = character(0), n_spots = integer(0), proportion = numeric(0))
  if (!is.null(zone_pair) && length(zone_pair) == 2L) {
    w1 <- sub("^score_", "weight_", zone_pair[1])
    w2 <- sub("^score_", "weight_", zone_pair[2])
    q1 <- as.numeric(stats::quantile(out[[w1]], probs = high_quantile, na.rm = TRUE))
    q2 <- as.numeric(stats::quantile(out[[w2]], probs = high_quantile, na.rm = TRUE))
    h1 <- out[[w1]] >= q1
    h2 <- out[[w2]] >= q2
    out$spatial_zone <- ifelse(
      h1 & h2, "Joint_High",
      ifelse(h1 & !h2, "Feature1_High_Only",
             ifelse(!h1 & h2, "Feature2_High_Only", "Other_Low"))
    )
    tab <- table(out$spatial_zone)
    zone_summary <- data.frame(
      spatial_zone = names(tab),
      n_spots = as.integer(tab),
      proportion = round(as.numeric(tab) / nrow(out), 5),
      stringsAsFactors = FALSE
    )
  }

  # Multichannel ligand-receptor geometric-mean co-localization
  for (pair in lr_pairs) {
    if (length(pair) == 2L && all(pair %in% colnames(out))) {
      nm <- paste0("LR_", pair[1], "_", pair[2])
      v1 <- pmax(as.numeric(out[[pair[1]]]), 0)
      v2 <- pmax(as.numeric(out[[pair[2]]]), 0)
      out[[nm]] <- round(sqrt(v1 * v2), 5)
    }
  }

  list(
    spots = out,
    zone_summary = zone_summary,
    weight_cols = weight_cols
  )
}
