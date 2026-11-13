# Grouped violin + box + jitter with precomputed p labels and mean/SD labels.
# The plotting function does not run tests; summaries must be supplied.
# Returns a ggplot object; does not read files or save.

plot_grouped_violin <- function(
    df,
    summaries,
    celltype_col = "celltype",
    group_col = "group",
    value_col = "value",
    celltype_levels = NULL,
    group_levels = c("Control", "Glaucoma"),
    color_scheme = c("#FF7F0E", "#1F77B4"),
    title = "Complement Pathway Score Comparison",
    ylab = "Pathway Score",
    dodge_width = 0.8,
    violin_width = 0.7,
    box_width = 0.18,
    jitter_width = 0.18,
    base_size = 11,
    base_family = "sans"
) {
  required <- c(celltype_col, group_col, value_col)
  if (!all(required %in% names(df))) {
    stop("Missing value columns: ",
         paste(setdiff(required, names(df)), collapse = ", "))
  }
  required_sum <- c("celltype", "group", "p_label", "p_y", "mean_sd_label", "mean_y")
  if (!all(required_sum %in% names(summaries))) {
    stop("Missing summary columns: ",
         paste(setdiff(required_sum, names(summaries)), collapse = ", "))
  }

  if (is.null(celltype_levels)) celltype_levels <- unique(as.character(df[[celltype_col]]))
  df[[celltype_col]] <- factor(as.character(df[[celltype_col]]), levels = celltype_levels)
  df[[group_col]] <- factor(as.character(df[[group_col]]), levels = group_levels)
  summaries$celltype <- factor(as.character(summaries$celltype), levels = celltype_levels)
  summaries$group <- factor(as.character(summaries$group), levels = group_levels)

  p_data <- summaries[!duplicated(summaries$celltype), , drop = FALSE]

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = .data[[celltype_col]], y = .data[[value_col]])
  ) +
    ggplot2::geom_violin(
      ggplot2::aes(fill = .data[[group_col]]),
      position = ggplot2::position_dodge(dodge_width),
      width = violin_width, alpha = 0.5, trim = FALSE, linewidth = 0.3
    ) +
    ggplot2::geom_boxplot(
      ggplot2::aes(group = interaction(.data[[celltype_col]], .data[[group_col]])),
      position = ggplot2::position_dodge(dodge_width),
      width = box_width, outlier.size = 0.4, alpha = 0.85, linewidth = 0.3
    ) +
    ggplot2::geom_jitter(
      ggplot2::aes(color = .data[[group_col]]),
      position = ggplot2::position_jitterdodge(
        jitter.width = jitter_width, dodge.width = dodge_width
      ),
      size = 0.6, alpha = 0.25
    ) +
    ggplot2::geom_text(
      data = p_data,
      ggplot2::aes(x = celltype, y = p_y, label = p_label),
      size = 3.2, vjust = -0.3, family = base_family, inherit.aes = FALSE
    ) +
    ggplot2::geom_text(
      data = summaries,
      ggplot2::aes(x = celltype, y = mean_y, label = mean_sd_label, group = group),
      position = ggplot2::position_dodge(dodge_width),
      size = 2, color = "black", vjust = 0.5, family = base_family,
      inherit.aes = FALSE
    ) +
    ggplot2::scale_fill_manual(values = color_scheme) +
    ggplot2::scale_color_manual(values = color_scheme) +
    ggplot2::labs(title = title, y = ylab, x = NULL) +
    ggplot2::theme_classic(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5, size = 13),
      axis.text.x = ggplot2::element_text(
        angle = 30, hjust = 1, size = 9, colour = "black"
      ),
      axis.text.y = ggplot2::element_text(size = 9, colour = "black"),
      axis.title.y = ggplot2::element_text(size = 11),
      axis.ticks.length = grid::unit(0.12, "cm"),
      legend.position = "top",
      legend.title = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(size = 10),
      panel.grid.major.y = ggplot2::element_line(color = "grey90", linewidth = 0.3),
      plot.margin = ggplot2::margin(0.8, 0.8, 0.8, 0.8, "cm")
    ) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.05, 0.22))
    )

  p
}

`%||%` <- function(a, b) if (!is.null(a)) a else b

draw_grouped_violin <- function(values, summaries, style = list()) {
  plot_grouped_violin(
    df = values,
    summaries = summaries,
    celltype_col = style$celltype_col %||% "celltype",
    group_col = style$group_col %||% "group",
    value_col = style$value_col %||% "value",
    celltype_levels = style$celltype_levels,
    group_levels = style$group_levels %||% c("Control", "Glaucoma"),
    color_scheme = style$color_scheme %||% c("#FF7F0E", "#1F77B4"),
    title = style$title %||% "Complement Pathway Score Comparison",
    ylab = style$ylab %||% "Pathway Score",
    dodge_width = style$dodge_width %||% 0.8,
    violin_width = style$violin_width %||% 0.7,
    box_width = style$box_width %||% 0.18,
    jitter_width = style$jitter_width %||% 0.18,
    base_size = style$base_size %||% 11,
    base_family = style$font_family %||% "sans"
  )
}
