#!/usr/bin/env Rscript
# Verification driver for cell-cell-communication / cellchat-lr-inference

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
source(file.path(args$code, "cellchat_lr_inference.R"))

lr_df <- utils::read.csv(file.path(args$example, "cai_cellchat_lr_slice.csv"), stringsAsFactors = FALSE)
res <- run_cellchat_lr_inference(lr_df, pval_cutoff = 0.05, min_prob = 0)

stopifnot(nrow(res$pathway_ranking) >= 5L)
stopifnot(all(diff(res$pathway_ranking$total_prob) <= 1e-12))
stopifnot(sum(res$sender_receiver_long$n_interactions) == nrow(res$filtered_lr))
stopifnot(sum(res$hub_strength$outgoing_count) == sum(res$hub_strength$incoming_count))

utils::write.csv(res$pathway_ranking, file.path(args$out, "pathway_ranking.csv"), row.names = FALSE)
utils::write.csv(res$sender_receiver_matrix, file.path(args$out, "sender_receiver_matrix.csv"), row.names = FALSE)
utils::write.csv(res$hub_strength, file.path(args$out, "hub_strength.csv"), row.names = FALSE)

checks_json <- sprintf(
  '{\n  "scope": "Real Cai 2026 CellChat LR slice (%d significant edges across Fib->Epi and C8_Fib_CCL19->TME); verified pathway probability aggregation/ranking, sender-receiver interaction count matrix, and outgoing/incoming hub conservation.",\n  "checks": [\n    "significant_lr_edges=%d, pathways_ranked=%d",\n    "pathway_total_prob_monotone_nonincreasing=true",\n    "sender_receiver_pair_count=%d, hub_in_out_balanced=true",\n    "top_pathway=%s"\n  ]\n}\n',
  nrow(res$filtered_lr), nrow(res$filtered_lr), nrow(res$pathway_ranking),
  nrow(res$sender_receiver_long), res$pathway_ranking$pathway_name[1]
)
writeLines(checks_json, con = file.path(args$out, "checks.json"), useBytes = TRUE)
