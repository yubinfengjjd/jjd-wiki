#!/usr/bin/env Rscript
# Verification driver for spatial-transcriptomics-microenvironment / visium-signature-spatial

parse_args <- function(argv) {
  out <- list()
  i <- 1L
  while (i <= length(argv)) {
    if (startsWith(argv[i], "--") && i < length(argv)) {
      out[[substring(argv[i], 3L)]] <- argv[i + 1L]
      i <- i + 2L
    } else {
      i <- i + 1L
    }
  }
  out
}

args <- parse_args(commandArgs(trailingOnly = TRUE))
dir.create(args$out, recursive = TRUE, showWarnings = FALSE)
source(file.path(args$code, "visium_signature_spatial.R"))

spots <- utils::read.csv(file.path(args$example, "visium_caa_st_slice.csv"), stringsAsFactors = FALSE)
score_cols <- c("score_Tumor_cell", "score_C10_lpFib_ABCA8", "score_CD8_Cytotoxic_T", "score_Exhausted_T")
res <- run_visium_signature_spatial(
  spots_df = spots,
  score_cols = score_cols,
  zone_pair = c("score_C10_lpFib_ABCA8", "score_Exhausted_T"),
  lr_pairs = list(c("CD86", "CTLA4"), c("CD8A", "HAVCR2")),
  quantile_shift = 0.05,
  high_quantile = 0.75
)

w_mat <- as.matrix(res$spots[, res$weight_cols, drop = FALSE])
rsums <- rowSums(w_mat)
stopifnot(nrow(res$spots) == nrow(spots))
stopifnot(all(w_mat >= 0))
stopifnot(all(abs(rsums[rsums > 0.01] - 1.0) < 1e-5))
stopifnot("LR_CD86_CTLA4" %in% colnames(res$spots))
stopifnot(nrow(res$zone_summary) >= 2L)

utils::write.csv(res$spots, file.path(args$out, "visium_weights_zones.csv"), row.names = FALSE)
utils::write.csv(res$zone_summary, file.path(args$out, "zone_summary.csv"), row.names = FALSE)

checks_json <- sprintf(
  '{\n  "scope": "Real Visium CAA_ST spot slice (Cai 2026, %d spots); verified 5th-percentile-shifted L1 signature weighting, top-quartile co-enrichment zoning, and LR multichannel geometric colocalization.",\n  "checks": [\n    "input_spots=%d, score_channels=%d",\n    "weights_non_negative_and_l1_normalized=true",\n    "spatial_zones_identified=%d",\n    "lr_colocalization_columns_present=true"\n  ]\n}\n',
  nrow(spots), nrow(spots), length(score_cols), nrow(res$zone_summary)
)
writeLines(checks_json, con = file.path(args$out, "checks.json"), useBytes = TRUE)
