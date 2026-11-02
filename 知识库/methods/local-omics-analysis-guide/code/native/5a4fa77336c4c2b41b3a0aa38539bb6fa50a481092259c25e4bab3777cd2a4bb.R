build_summary_plot <- function(all_stats) {
  rank_tbl <- all_stats %>%
    group_by(celltype) %>%
    summarise(
      focus_score = mean(abs(effect_high_low), na.rm = TRUE) + 0.02 * sum(fdr < 0.05, na.rm = TRUE),
      .groups = "drop"
    )
  focus_levels <- center_focus_levels(rank_tbl$celltype, rank_tbl$focus_score)
  max_abs <- max(abs(all_stats$effect_high_low), na.rm = TRUE)
  max_abs <- if (is.finite(max_abs) && max_abs > 0) max_abs else 0.01
  size_breaks <- pretty(c(0, max_abs), n = 3)
  size_breaks <- size_breaks[size_breaks >= 0 & size_breaks <= max_abs]
  fill_breaks <- pretty(c(-max_abs, max_abs), n = 5)
  fill_breaks <- fill_breaks[fill_breaks >= -max_abs & fill_breaks <= max_abs]

  plot_df <- all_stats %>%
    mutate(
      sample_label = factor(wf_sample_label(sample), levels = unique(wf_sample_label(sample))),
      celltype_label = factor(display_ct(celltype), levels = display_ct(focus_levels)),
      outline = ifelse(fdr < 0.05, "focus", "base")
    )

  ggplot(plot_df, aes(x = sample_label, y = celltype_label)) +
    geom_tile(fill = "#FBF8F3", colour = "#F0EAE0", linewidth = 0.35, width = 0.92, height = 0.92) +
    geom_point(aes(size = abs(effect_high_low), fill = effect_high_low, colour = outline), shape = 21, alpha = 0.96, stroke = 0.55) +
    scale_size_continuous(range = c(3.4, 10.8), breaks = size_breaks, limits = c(0, max_abs)) +
    scale_fill_gradient2(
      low = "#5E7B8F",
      mid = "#EFE7DA",
      high = "#B76445",
      midpoint = 0,
      limits = c(-max_abs, max_abs),
      breaks = fill_breaks,
      oob = scales::squish
    ) +
    scale_colour_manual(values = c(base = "#8A8076", focus = "#2F2924"), guide = "none") +
    labs(
      title = "Neighborhood niche summary",
      subtitle = "Bubble size encodes the High-Low magnitude; fill encodes direction.",
      x = NULL,
      y = NULL,
      size = "|High-Low|",
      fill = "High-Low"
    ) +
    guides(
      size = guide_legend(order = 1, override.aes = list(fill = "#CAD5D1", colour = "#4E4A44", alpha = 1)),
      fill = guide_colorbar_paper(barheight_pt = 42, barwidth_pt = 8)
    ) +
    theme_paper() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.x = element_text(face = "bold", colour = "#2B2B2B"),
      axis.text.y = element_text(colour = "#2B2B2B"),
      legend.box = "vertical",
      legend.spacing.y = grid::unit(2, "pt"),
      plot.title.position = "plot"
    )
}
