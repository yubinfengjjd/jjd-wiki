# Panel adapter: cell-proportion stacked bars with flow ribbons.
plot_panel <- function(tables, style) {
  if (!"proportions" %in% names(tables)) {
    stop("Missing table: proportions")
  }
  draw_cellprop_flow(tables$proportions, style)
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
