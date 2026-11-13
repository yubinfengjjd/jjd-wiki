build_focal_spatial_specs <- function(all_stats) {
  focal_tbl <- pick_focal_celltypes(all_stats)
  if (nrow(focal_tbl) == 0) return(tibble())

  bind_rows(lapply(seq_len(nrow(focal_tbl)), function(i) {
    ct <- focal_tbl$celltype[[i]]
    mean_eff <- focal_tbl$mean_effect[[i]]
    stat_row <- if (mean_eff >= 0) {
      all_stats %>% filter(celltype == ct) %>% arrange(desc(effect_high_low), fdr) %>% slice_head(n = 1)
    } else {
      all_stats %>% filter(celltype == ct) %>% arrange(effect_high_low, fdr) %>% slice_head(n = 1)
    }
    tibble(
      celltype = ct,
      sample = stat_row$sample,
      direction = ifelse(mean_eff >= 0, "High-enriched niche", "Low-enriched niche")
    )
  })) %>% distinct(celltype, sample, .keep_all = TRUE)
}
