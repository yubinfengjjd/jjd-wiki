# Panel adapter: one native SCP CellStatPlot panel from cell-level metadata.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

stat_palette_args <- function(style) {
  palette <- get_style(style, "palette", "Paired")
  if (is.character(palette) && length(palette) > 1L) {
    list(palette = get_style(style, "palette_name", "Paired"), palcolor = palette)
  } else {
    list(palette = palette, palcolor = get_style(style, "palcolor", NULL))
  }
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"metadata" %in% names(tables)) stop("Missing table: metadata")
  if (!exists("scp_stat_meta", mode = "function")) {
    stop("Native CellStat core not loaded; source code/core.R first", call. = FALSE)
  }
  pal <- stat_palette_args(style)
  scp_stat_meta(
    meta.data = tables$metadata,
    stat.by = get_style(style, "stat_col", "stat"),
    group.by = get_style(style, "group_col", "group"),
    type = get_style(style, "plot_type", "pie"),
    stat_type = get_style(style, "stat_type", "percent"),
    NA_stat = get_style(style, "NA_stat", TRUE),
    group_levels = if (is.null(style$group_levels)) NULL else unlist(style$group_levels),
    stat_levels = if (is.null(style$celltype_levels)) NULL else unlist(style$celltype_levels),
    palette = pal$palette,
    palcolor = pal$palcolor,
    alpha = get_style(style, "alpha", 1),
    bg_col = get_style(style, "bg_col", NULL),
    bg_palette = get_style(style, "bg_palette", "Paired"),
    bg_palcolor = get_style(style, "bg_palcolor", NULL),
    bg_alpha = get_style(style, "bg_alpha", 0.2),
    flip = get_style(style, "flip", FALSE),
    label = get_style(style, "label", FALSE),
    label.size = get_style(style, "label_size", 3.5),
    label.fg = get_style(style, "label_fg", "black"),
    label.bg = get_style(style, "label_bg", "white"),
    label.bg.r = get_style(style, "label_bg_r", 0.1),
    position = get_style(style, "position", "stack"),
    xlab = get_style(style, "xlab", NULL),
    ylab = get_style(style, "ylab", NULL),
    legend_title = get_style(style, "legend_title", NULL),
    merge_polar_endpoints = get_style(style, "merge_polar_endpoints", FALSE),
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
