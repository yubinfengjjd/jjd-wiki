# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:4463-4490
# sha256(func-block)=e9b3ee68af2f432cd1a015b8854c64d8462b4ab185c870e7883a745105c5808d
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
CellStatPlot <- function(srt, stat.by, group.by = NULL, split.by = NULL, bg.by = NULL, cells = NULL, flip = FALSE,
                         NA_color = "grey", NA_stat = TRUE, keep_empty = FALSE, individual = FALSE, stat_level = NULL,
                         plot_type = c("bar", "rose", "ring", "pie", "trend", "area", "dot", "sankey", "chord", "venn", "upset"),
                         stat_type = c("percent", "count"), position = c("stack", "dodge"),
                         palette = "Paired", palcolor = NULL, alpha = 1,
                         bg_palette = "Paired", bg_palcolor = NULL, bg_alpha = 0.2,
                         label = FALSE, label.size = 3.5, label.fg = "black", label.bg = "white", label.bg.r = 0.1,
                         aspect.ratio = NULL, title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                         legend.position = "right", legend.direction = "vertical",
                         theme_use = "theme_scp", theme_args = list(),
                         combine = TRUE, nrow = NULL, ncol = NULL, byrow = TRUE, force = FALSE, seed = 11) {
  cells <- cells %||% colnames(srt@assays[[1]])
  meta.data <- srt@meta.data[cells, , drop = FALSE]

  plot <- StatPlot(
    meta.data = meta.data, stat.by = stat.by, group.by = group.by, split.by = split.by, bg.by = bg.by, flip = flip,
    NA_color = NA_color, NA_stat = NA_stat, keep_empty = keep_empty, individual = individual, stat_level = stat_level,
    plot_type = plot_type, stat_type = stat_type, position = position,
    palette = palette, palcolor = palcolor, alpha = alpha,
    bg_palette = bg_palette, bg_palcolor = bg_palcolor, bg_alpha = bg_alpha,
    label = label, label.size = label.size, label.fg = label.fg, label.bg = label.bg, label.bg.r = label.bg.r,
    aspect.ratio = aspect.ratio, title = title, subtitle = subtitle, xlab = xlab, ylab = ylab,
    legend.position = legend.position, legend.direction = legend.direction,
    theme_use = theme_use, theme_args = theme_args,
    combine = combine, nrow = nrow, ncol = ncol, byrow = byrow, force = force, seed = seed
  )
  return(plot)
}
