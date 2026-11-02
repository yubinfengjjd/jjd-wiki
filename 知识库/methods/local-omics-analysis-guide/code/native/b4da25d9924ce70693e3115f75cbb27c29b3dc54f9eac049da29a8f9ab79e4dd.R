panel_label <- function(...) {
  p <- patchwork::wrap_plots(...)
  p + patchwork::plot_annotation(tag_levels = "A", tag_suffix = ")")
}
