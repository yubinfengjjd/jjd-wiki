plot_compact_linket <- function(immune, cor_tbl, sample_id) {
  ct_order <- colnames(immune)
  plot_levels <- rev(ct_order)
  label_map <- setNames(short_celltype_label(ct_order), ct_order)
  cor_mat <- stats::cor(immune, method = "spearman", use = "pairwise.complete.obs")
  cor_mat[is.na(cor_mat) | is.infinite(cor_mat)] <- 0
  cor_mat <- cor_mat[ct_order, ct_order, drop = FALSE]

  cor_df <- as.data.frame(as.table(cor_mat), stringsAsFactors = FALSE) %>%
    transmute(
      row = Var1,
      col = Var2,
      cor = Freq,
      row_idx = match(Var1, ct_order),
      col_idx = match(Var2, ct_order)
    ) %>%
    filter(row_idx >= col_idx) %>%
    mutate(
      row = factor(row, levels = plot_levels),
      col = factor(col, levels = c(ct_order, "UBE2L6"))
    )

  rho_tbl <- cor_tbl %>%
    filter(celltype %in% ct_order) %>%
    mutate(
      row = factor(celltype, levels = plot_levels),
      col = factor("UBE2L6", levels = c(ct_order, "UBE2L6"))
    )

  sig_tbl <- rho_tbl %>% filter(fdr < 0.05)
  label_tbl <- sig_tbl %>% arrange(desc(abs(rho))) %>% slice_head(n = 4L)

  ggplot() +
    geom_tile(
      data = cor_df,
      aes(x = col, y = row, fill = cor),
      width = 0.96,
      height = 0.96,
      colour = "#E7E2D8",
      linewidth = 0.35
    ) +
    geom_tile(
      data = rho_tbl,
      aes(x = col, y = row, fill = rho),
      width = 0.72,
      height = 0.72,
      colour = NA
    ) +
    geom_tile(
      data = sig_tbl,
      aes(x = col, y = row),
      width = 0.72,
      height = 0.72,
      fill = NA,
      colour = "#2F2F2F",
      linewidth = 0.48
    ) +
    geom_text(
      data = label_tbl,
      aes(x = col, y = row, label = sprintf("%.2f", rho)),
      size = 2.7,
      fontface = "bold",
      colour = "#222222"
    ) +
    scale_x_discrete(position = "top", labels = c(label_map, UBE2L6 = "UBE2L6")) +
    scale_y_discrete(labels = label_map[plot_levels]) +
    scale_diverging_fill_paper(limits = c(-1, 1)) +
    guides(fill = guide_colorbar_paper(barheight_pt = 44, barwidth_pt = 8)) +
    labs(
      title = paste(sample_id, "cell-type correlation matrix"),
      x = NULL,
      y = NULL,
      fill = "Correlation"
    ) +
    coord_equal() +
    theme_heatmap_paper() +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 0, vjust = 0),
      axis.text.y = element_text(size = rel(0.95)),
      plot.margin = margin(8, 12, 8, 8)
    )
}
