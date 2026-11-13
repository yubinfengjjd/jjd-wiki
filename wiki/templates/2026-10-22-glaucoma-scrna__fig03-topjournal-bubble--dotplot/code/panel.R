# Panel adapter: top-journal bubble dot plot (one logical panel).
plot_panel <- function(tables, style) {
  if (!"dotplot" %in% names(tables)) {
    stop("Missing table: dotplot")
  }
  draw_dotplot_bubble(tables$dotplot, style)
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
