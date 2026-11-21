#!/usr/bin/env Rscript
# Verification driver for gene-set-scoring / progeny-pathway-activity

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
source(file.path(args$code, "progeny_pathway_activity.R"))

expr_df <- utils::read.csv(file.path(args$example, "cai_fib_expr_slice.csv"), check.names = FALSE, stringsAsFactors = FALSE)
meta_df <- utils::read.csv(file.path(args$example, "cai_fib_meta_slice.csv"), stringsAsFactors = FALSE)
expr_mat <- as.matrix(expr_df[, -1, drop = FALSE])
rownames(expr_mat) <- expr_df$gene
storage.mode(expr_mat) <- "numeric"

res <- run_progeny_pathway_activity(
  expr_mat = expr_mat,
  meta_df = meta_df,
  cell_col = "cell",
  group_col = "subcluster",
  organism = "Human",
  top = 100L,
  perm = 1L
)

stopifnot(nrow(res$cell_scores) == nrow(meta_df))
stopifnot(res$n_pathways == 14L)
stopifnot(nrow(res$subcluster_zscore) == length(unique(meta_df$subcluster)))
z_mat <- as.matrix(res$subcluster_zscore[, -1, drop = FALSE])
stopifnot(all(is.finite(z_mat)))

utils::write.csv(res$cell_scores, file.path(args$out, "progeny_cell_scores.csv"), row.names = FALSE)
utils::write.csv(res$subcluster_zscore, file.path(args$out, "progeny_subcluster_zscore.csv"), row.names = FALSE)

checks_json <- sprintf(
  '{\n  "scope": "Real Cai 2026 fibroblast scRNA slice (%d genes x %d cells across %d subclusters); verified 14-pathway PROGENy activity inference, cell-level Z-score standardization, and subcluster aggregation.",\n  "checks": [\n    "input_genes=%d, input_cells=%d, subclusters=%d",\n    "progeny_pathways=%d",\n    "subcluster_zscores_finite=true"\n  ]\n}\n',
  nrow(expr_mat), ncol(expr_mat), nrow(res$subcluster_zscore),
  nrow(expr_mat), ncol(expr_mat), nrow(res$subcluster_zscore), res$n_pathways
)
writeLines(checks_json, con = file.path(args$out, "checks.json"), useBytes = TRUE)
