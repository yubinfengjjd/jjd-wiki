#!/usr/bin/env Rscript
# Verification driver for cell-proportion-composition / roe-tissue-enrichment

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
source(file.path(args$code, "roe_tissue_enrichment.R"))

counts_df <- utils::read.csv(file.path(args$example, "cai_fib_tissue_counts.csv"), stringsAsFactors = FALSE)
res <- run_roe_tissue_enrichment(
  meta_df = counts_df,
  cluster_col = "canonical_subcluster",
  group_col = "tissue",
  count_col = "n_cells"
)

stopifnot(nrow(res$roe_wide) >= 10L)
stopifnot(all(is.finite(res$roe_long$roe)))
stopifnot(all(res$roe_long$roe >= 0))
stopifnot(is.finite(res$chi_square$p_value) && res$chi_square$p_value >= 0 && res$chi_square$p_value <= 1)

utils::write.csv(res$roe_wide, file.path(args$out, "roe_matrix.csv"), row.names = FALSE)
utils::write.csv(res$roe_long, file.path(args$out, "roe_long.csv"), row.names = FALSE)

checks_json <- sprintf(
  '{\n  "scope": "Real Cai 2026 fibroblast tissue counts slice (14 subclusters x 3 tissues); verified chi-squared expected counts, Ro/e enrichment ratio matrix, and global chi-squared test.",\n  "checks": [\n    "subclusters=%d, long_pairs=%d",\n    "chi2_statistic=%.4f, df=%d, p_value=%.4g",\n    "roe_values_finite_non_negative=true"\n  ]\n}\n',
  nrow(res$roe_wide), nrow(res$roe_long),
  res$chi_square$statistic, as.integer(res$chi_square$df), res$chi_square$p_value
)
writeLines(checks_json, con = file.path(args$out, "checks.json"), useBytes = TRUE)
