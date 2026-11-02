pick_focal_celltypes <- function(all_stats) {
  score_tbl <- all_stats %>%
    group_by(celltype) %>%
    summarise(
      mean_effect = mean(effect_high_low, na.rm = TRUE),
      mean_abs_effect = mean(abs(effect_high_low), na.rm = TRUE),
      sig_support = sum(fdr < 0.05, na.rm = TRUE),
      best_fdr = min(fdr, na.rm = TRUE),
      .groups = "drop"
    )

  top_pos <- score_tbl %>%
    filter(is.finite(mean_effect), mean_effect > 0) %>%
    arrange(desc(sig_support), desc(mean_effect), desc(mean_abs_effect), best_fdr) %>%
    slice_head(n = 1)
  top_neg <- score_tbl %>%
    filter(is.finite(mean_effect), mean_effect < 0) %>%
    arrange(desc(sig_support), mean_effect, desc(mean_abs_effect), best_fdr) %>%
    slice_head(n = 1)

  bind_rows(top_pos, top_neg)
}
