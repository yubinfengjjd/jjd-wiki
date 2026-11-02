# Panel adapter: one native SCP ring panel from render-cell-proportions.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

ring_palette_args <- function(style) {
  palette <- get_style(style, "palette", "Paired")
  if (is.character(palette) && length(palette) > 1L) {
    list(palette = get_style(style, "palette_name", "Paired"), palcolor = palette)
  } else {
    list(palette = palette, palcolor = get_style(style, "palcolor", NULL))
  }
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"proportions" %in% names(tables)) stop("Missing table: proportions")
  if (!exists("scp_ring_proportions", mode = "function")) {
    stop("Native ring core not loaded; source code/core.R first", call. = FALSE)
  }
  pal <- ring_palette_args(style)
  scp_ring_proportions(
    tables$proportions,
    group_col = get_style(style, "group_col", "group"),
    stat_col = get_style(style, "celltype_col", "celltype"),
    value_col = get_style(style, "proportion_col", "proportion"),
    stat_type = get_style(style, "stat_type", "percent"),
    group_levels = if (is.null(style$group_levels)) NULL else unlist(style$group_levels),
    stat_levels = if (is.null(style$celltype_levels)) NULL else unlist(style$celltype_levels),
    palette = pal$palette,
    palcolor = pal$palcolor,
    alpha = get_style(style, "alpha", 1),
    flip = get_style(style, "flip", FALSE),
    label = get_style(style, "label", TRUE),
    label.size = get_style(style, "label_size", 3.5),
    label.fg = get_style(style, "label_fg", "black"),
    label.bg = get_style(style, "label_bg", "white"),
    label.bg.r = get_style(style, "label_bg_r", 0.1),
    position = get_style(style, "position", "stack"),
    xlab = get_style(style, "xlab", NULL),
    ylab = get_style(style, "ylab", NULL),
    legend_title = get_style(style, "legend_title", NULL),
    merge_polar_endpoints = get_style(style, "merge_polar_endpoints", TRUE),
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
