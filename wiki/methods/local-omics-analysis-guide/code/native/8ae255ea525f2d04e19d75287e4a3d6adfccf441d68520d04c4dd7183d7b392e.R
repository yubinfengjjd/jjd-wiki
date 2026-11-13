wf_wrap_grouped_panel <- function(plot_list, ncol = NULL, panel_background = "#FFFFFF", guides = "collect") {
  plot_guard(plot_list = plot_list, reason = "Grouped panel assembly failed")
  if (is.null(ncol)) {
    ncol <- if (length(plot_list) <= 2) length(plot_list) else ceiling(sqrt(length(plot_list)))
  }
  patchwork::wrap_plots(plot_list, ncol = max(1L, ncol), guides = guides) &
    theme(
      legend.position = "right",
      legend.justification = "center",
      legend.box.margin = margin(0, 0, 0, 2),
      panel.spacing = grid::unit(6, "pt"),
      plot.background = element_rect(fill = panel_background, colour = NA),
      panel.background = element_rect(fill = panel_background, colour = NA),
      plot.margin = margin(5, 6, 5, 6)
    )
}
