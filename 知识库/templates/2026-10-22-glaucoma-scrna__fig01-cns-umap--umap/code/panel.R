# Panel adapter: single UMAP panel. All inputs and visual settings are explicit.
plot_panel <- function(tables, style) {
  if (!"umap" %in% names(tables)) {
    stop("Missing table: umap")
  }
  draw_cns_umap(tables$umap, style)
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  if (!is.null(rect) && requireNamespace("grid", quietly = TRUE)) {
    vp <- grid::viewport(
      x = rect$x, y = rect$y, width = rect$width, height = rect$height,
      just = c("left", "bottom")
    )
    print(p, vp = vp)
  } else {
    print(p)
  }
  invisible(p)
}
