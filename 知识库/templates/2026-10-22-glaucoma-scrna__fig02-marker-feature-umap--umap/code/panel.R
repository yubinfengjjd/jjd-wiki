# Panel adapter: 3x3 marker feature UMAP grid (one logical panel).
plot_panel <- function(tables, style) {
  if (!"feature_umap" %in% names(tables)) {
    stop("Missing table: feature_umap")
  }
  draw_feature_umap_grid(tables$feature_umap, style)
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
