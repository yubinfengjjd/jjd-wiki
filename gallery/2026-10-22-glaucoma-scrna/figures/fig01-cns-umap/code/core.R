# CNS-style UMAP panel: points, dashed non-convex hulls, centroid labels,
# short arrow axes and a right-side legend. The function returns a ggplot object;
# it does not read files, run analysis, or save output.

plot_cns_umap <- function(
    df,
    x_col = "umap_1",
    y_col = "umap_2",
    group_col = "group",
    group_levels = NULL,
    palette = NULL,
    point_size = 0.9,
    point_alpha = 0.85,
    hull_alpha = 0.22,
    hull_delta = 0.45,
    hull_size = 0.35,
    label_size = 4.5,
    legend_text_size = 9,
    pad_ratio = 0.04,
    axis_len_ratio = 0.12,
    axis_label_size = 3.5,
    base_size = 12,
    family = "sans"
) {
  if (!all(c(x_col, y_col, group_col) %in% names(df))) {
    stop("Missing required columns: ",
         paste(setdiff(c(x_col, y_col, group_col), names(df)), collapse = ", "))
  }
  if (any(is.na(df[[x_col]])) || any(is.na(df[[y_col]]))) {
    stop("UMAP coordinates contain NA; remove or impute before plotting.")
  }

  df <- as.data.frame(df)
  if (is.null(group_levels)) {
    group_levels <- unique(as.character(df[[group_col]]))
  }
  df[[group_col]] <- factor(as.character(df[[group_col]]), levels = group_levels)
  if (any(is.na(df[[group_col]]))) {
    stop("Some rows have a group value not present in group_levels.")
  }

  n_levels <- nlevels(df[[group_col]])
  if (is.null(palette)) {
    palette <- c(
      "#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F", "#8491B4",
      "#91D1C2", "#DC0000", "#7E6148", "#B09C85", "#E18727", "#20854E",
      "#7876B1", "#6F99AD", "#FFDC91", "#EE4C97", "#A6CEE3", "#BC80BD",
      "#FFED6F", "#8DD3C7"
    )
  }
  if (length(palette) < n_levels) {
    palette <- grDevices::hcl.colors(n_levels, "Dark 3")
  }
  mycols <- stats::setNames(palette[seq_len(n_levels)], levels(df[[group_col]]))

  x_range <- range(df[[x_col]], na.rm = TRUE)
  y_range <- range(df[[y_col]], na.rm = TRUE)
  x_span <- diff(x_range)
  y_span <- diff(y_range)
  x_pad <- x_span * pad_ratio
  y_pad <- y_span * pad_ratio
  x_lim <- c(x_range[1] - x_pad, x_range[2] + x_pad)
  y_lim <- c(y_range[1] - y_pad, y_range[2] + y_pad)
  x_axis_len <- x_span * axis_len_ratio
  y_axis_len <- y_span * axis_len_ratio
  x_axis_start <- x_lim[1] + x_pad
  y_axis_start <- y_lim[1] + y_pad

  centroids <- stats::aggregate(
    df[, c(x_col, y_col)],
    by = list(group = df[[group_col]]),
    FUN = stats::median
  )
  names(centroids)[1] <- ".group"

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = .data[[x_col]], y = .data[[y_col]],
      color = .data[[group_col]], fill = .data[[group_col]]
    )
  ) +
    ggunchull::stat_unchull(
      alpha = hull_alpha, linewidth = hull_size, delta = hull_delta,
      linetype = "dashed"
    ) +
    ggplot2::geom_point(size = point_size, alpha = point_alpha, stroke = 0) +
    ggplot2::geom_text(
      data = centroids,
      ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]], label = .data[[".group"]]),
      color = "grey20", size = label_size, fontface = "bold",
      family = family, inherit.aes = FALSE
    ) +
    ggplot2::scale_color_manual(values = mycols, name = NULL) +
    ggplot2::scale_fill_manual(values = mycols, name = NULL) +
    ggplot2::coord_fixed(xlim = x_lim, ylim = y_lim, clip = "off") +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_classic(base_size = base_size, base_family = family) +
    ggplot2::theme(
      aspect.ratio = 1,
      panel.background = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      legend.position = "right",
      legend.title = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(size = legend_text_size, family = family),
      legend.key.size = grid::unit(0.35, "cm"),
      legend.background = ggplot2::element_blank(),
      legend.key = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    ) +
    ggplot2::annotate(
      "segment",
      x = x_axis_start, xend = x_axis_start + x_axis_len,
      y = y_axis_start, yend = y_axis_start,
      linewidth = 0.45, color = "black",
      arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
    ) +
    ggplot2::annotate(
      "segment",
      x = x_axis_start, xend = x_axis_start,
      y = y_axis_start, yend = y_axis_start + y_axis_len,
      linewidth = 0.45, color = "black",
      arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
    ) +
    ggplot2::annotate(
      "text",
      x = x_axis_start + x_axis_len * 0.55,
      y = y_axis_start - y_span * 0.025,
      label = "UMAP_1", size = axis_label_size, fontface = "italic", family = family
    ) +
    ggplot2::annotate(
      "text",
      x = x_axis_start - x_span * 0.025,
      y = y_axis_start + y_axis_len * 0.55,
      label = "UMAP_2", size = axis_label_size, fontface = "italic",
      family = family, angle = 90
    ) +
    ggplot2::guides(
      color = ggplot2::guide_legend(override.aes = list(size = 2.5, alpha = 1)),
      fill = ggplot2::guide_legend(override.aes = list(alpha = 0.25))
    )

  p
}
