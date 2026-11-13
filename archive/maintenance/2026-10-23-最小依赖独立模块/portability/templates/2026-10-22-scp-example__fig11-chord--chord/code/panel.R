# Panel adapter: one native SCP chord panel from a cell-level linkage table.
# The chord diagram is base/grid graphics, so `draw()` replays the recorded
# plot on the current device; multi-panel composition must use graphics::layout
# or par(mfrow) at the call layer, not patchwork.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"linkage" %in% names(tables)) stop("Missing table: linkage")
  if (!exists("scp_chord_long_meta", mode = "function")) {
    stop("Native chord core not loaded; source code/core.R first", call. = FALSE)
  }
  scp_chord_long_meta(
    linkage = tables$linkage,
    cell_col = get_style(style, "cell_col", "cell"),
    dimension_col = get_style(style, "dimension_col", "dimension"),
    category_col = get_style(style, "category_col", "category"),
    dimension_order_col = get_style(style, "dimension_order_col", "dimension_order"),
    dimension_order = if (is.null(style$dimension_order)) NULL else unlist(style$dimension_order),
    category_levels = if (is.null(style$category_levels)) NULL else lapply(style$category_levels, as.character),
    palette = get_style(style, "palette", "Paired"),
    palcolor = get_style(style, "palcolor", NULL),
    NA_color = get_style(style, "NA_color", "grey"),
    transparency = get_style(style, "transparency", 0.2),
    link_lwd = get_style(style, "link_lwd", 1),
    link_lty = get_style(style, "link_lty", 1),
    link_border = get_style(style, "link_border", 1),
    seed = get_style(style, "seed", 11),
    scp = scp
  )
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  grDevices::replayPlot(p)
  invisible(p)
}
