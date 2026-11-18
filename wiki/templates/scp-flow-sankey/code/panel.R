# Panel adapter: one native SCP CellStatPlot sankey panel from a long
# render-cell-linkage table (cell x dimension rows).
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"linkage" %in% names(tables)) stop("Missing table: linkage")
  if (!exists("scp_sankey_linkage_plot", mode = "function")) {
    stop("Native sankey core not loaded; source code/core.R first", call. = FALSE)
  }
  dimension_levels <- get_style(style, "dimension_levels", NULL)
  if (!is.null(dimension_levels)) {
    dimension_levels <- lapply(dimension_levels, function(x) as.character(unlist(x)))
  }
  scp_sankey_linkage_plot(
    tables$linkage,
    cell_col = get_style(style, "cell_col", "cell"),
    dimension_col = get_style(style, "dimension_col", "dimension"),
    category_col = get_style(style, "category_col", "category"),
    dimension_order_col = get_style(style, "dimension_order_col", "dimension_order"),
    dimension_levels = dimension_levels,
    palette = get_style(style, "palette", "Paired"),
    palcolor = get_style(style, "palcolor", NULL),
    alpha = get_style(style, "alpha", 1),
    legend.position = get_style(style, "legend_position", "right"),
    legend.direction = get_style(style, "legend_direction", "vertical"),
    seed = get_style(style, "seed", 11),
    scp = scp
  )
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
