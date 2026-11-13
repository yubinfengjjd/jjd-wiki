# Panel adapter: grouped violin + box + jitter with precomputed summaries.
plot_panel <- function(tables, style) {
  if (!all(c("values", "summaries") %in% names(tables))) {
    stop("Missing tables: values and summaries")
  }
  draw_grouped_violin(tables$values, tables$summaries, style)
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
