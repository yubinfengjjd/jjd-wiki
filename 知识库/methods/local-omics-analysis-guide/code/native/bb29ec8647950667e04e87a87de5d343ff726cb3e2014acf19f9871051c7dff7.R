wf_plot_spatial_feature_ref1_style <- function(df, feature_name = NULL, legend_title = NULL, limits = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver(), point_size = NULL, point_alpha = NULL, background = NULL, legend_barheight_pt = NULL, legend_barwidth_pt = NULL) {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package 'scales' is required", call. = FALSE)
  ref1 <- wf_spatial_ref1_spec()
  feature_label <- legend_title %||% feature_name %||% "Feature"
  if (is.null(limits)) {
    limits <- wf_pretty_limits(df$value, lower_q = 0.02, upper_q = 0.98, include_zero = all(df$value >= 0, na.rm = TRUE))
  }
  if (inherits(breaks, "waiver")) {
    breaks <- wf_pretty_breaks(limits, n = 4, include_zero = all(limits >= 0))
  }
  point_size <- point_size %||% ref1$point_size
  point_alpha <- point_alpha %||% ref1$point_alpha
  background <- background %||% ref1$background
  legend_barheight_pt <- legend_barheight_pt %||% ref1$legend_barheight_pt
  legend_barwidth_pt <- legend_barwidth_pt %||% ref1$legend_barwidth_pt

  ggplot(df, aes(x = x, y = y, fill = value)) +
    geom_point(shape = 21, size = point_size, alpha = point_alpha, stroke = ref1$stroke, colour = ref1$border_colour) +
    scale_x_continuous(expand = ggplot2::expansion(mult = 0.02)) +
    scale_y_reverse(expand = ggplot2::expansion(mult = 0.02)) +
    coord_fixed() +
    ggplot2::scale_fill_gradientn(
      colours = ref1$continuous_hex,
      limits = limits,
      oob = scales::squish,
      na.value = "#D9D9D9",
      breaks = breaks,
      labels = labels
    ) +
    labs(fill = feature_label) +
    guides(fill = guide_colorbar_paper(barheight_pt = legend_barheight_pt, barwidth_pt = legend_barwidth_pt, title.position = "top", ticks = TRUE)) +
    theme_spatial_paper() +
    ggplot2::theme(
      plot.title = ggplot2::element_blank(),
      plot.subtitle = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(fill = background, colour = NA),
      panel.background = ggplot2::element_rect(fill = background, colour = NA),
      panel.border = ggplot2::element_blank(),
      legend.position = "right",
      legend.title = ggplot2::element_text(size = 8.8, face = "bold", margin = ggplot2::margin(b = 3)),
      legend.text = ggplot2::element_text(size = 8.2),
      legend.box.margin = ggplot2::margin(0, 0, 0, 2),
      plot.margin = ggplot2::margin(5, 6, 5, 6)
    )
}
