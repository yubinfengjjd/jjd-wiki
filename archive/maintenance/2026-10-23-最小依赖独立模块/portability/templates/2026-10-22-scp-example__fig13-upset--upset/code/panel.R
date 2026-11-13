# Panel adapter: one native SCP CellStatPlot(plot_type = "upset") panel from a
# long cell-level membership table (interface render-cell-membership).
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"membership" %in% names(tables)) stop("Missing table: membership")
  if (!exists("scp_upset_table", mode = "function")) {
    stop("Native upset core not loaded; source code/core.R first", call. = FALSE)
  }
  cell_col <- get_style(style, "cell_col", "cell")
  set_col <- get_style(style, "set_col", "set")
  member_col <- get_style(style, "member_col", "member")
  set_levels <- if (is.null(style$set_levels)) NULL else as.character(unlist(style$set_levels))
  wide <- scp_upset_membership(
    tables$membership,
    cell_col = cell_col, set_col = set_col, member_col = member_col,
    set_levels = set_levels
  )
  sets <- if (is.null(set_levels)) colnames(wide) else set_levels
  dat <- scp_upset_table(wide, stat.by = sets,
                         stat_level = get_style(style, "stat_level", "TRUE"))
  p <- plot_scp_upset(
    dat,
    stat.by = sets,
    label.size = get_style(style, "label_size", 3.5),
    label.fg = get_style(style, "label_fg", "black"),
    label.bg = get_style(style, "label_bg", "white"),
    label.bg.r = get_style(style, "label_bg_r", 0.1),
    alpha = get_style(style, "alpha", 1),
    show.legend = isTRUE(get_style(style, "legend", FALSE)),
    title = get_style(style, "title", NULL),
    subtitle = get_style(style, "subtitle", NULL),
    xlab = get_style(style, "xlab", ""),
    fill_palette = get_style(style, "fill_palette", "material-indigo"),
    seed = get_style(style, "seed", 11),
    scp = scp
  )
  # Sizing needs the number of displayed intersections and of sets; keep them
  # with the plot instead of rebuilding the table in render.R.
  attr(p, "scp_upset") <- list(
    sets = sets,
    n_cells = nrow(wide),
    counts = scp_upset_counts(dat),
    n_intersections_total = nrow(scp_upset_counts(dat))
  )
  p
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
