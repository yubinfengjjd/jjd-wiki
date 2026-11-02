wf_plot_spatial_feature_ref1_style <- function(df, feature_name = NULL, legend_title = NULL, limits = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver(), point_size = NULL, point_alpha = NULL, background = NULL, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, backdrop_df = NULL, backdrop_size = NULL, backdrop_fill = "#F3F3F3", backdrop_colour = "#D9D9D9", backdrop_alpha = 1) {
  if (!requireNamespace("scales", quietly = TRUE)) stop("R package scales is required", call. = FALSE)
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
  backdrop_size <- backdrop_size %||% max(point_size * 0.96, 1.7)

  p <- ggplot()
  if (!is.null(backdrop_df) && nrow(backdrop_df) > 0) {
    p <- p +
      ggplot2::geom_point(data = backdrop_df, ggplot2::aes(x = x, y = y), inherit.aes = FALSE, shape = 21, size = backdrop_size, alpha = backdrop_alpha, stroke = max(ref1$stroke * 0.7, 0.18), fill = backdrop_fill, colour = backdrop_colour)
  }

  p +
    geom_point(data = df, aes(x = x, y = y, fill = value), shape = 21, size = point_size, alpha = point_alpha, stroke = ref1$stroke, colour = ref1$border_colour) +
    scale_x_continuous(expand = ggplot2::expansion(mult = 0.02)) +
    scale_y_reverse(expand = ggplot2::expansion(mult = 0.02)) +
    coord_fixed() +
    ggplot2::scale_fill_gradientn(colours = ref1$continuous_hex, limits = limits, oob = scales::squish, na.value = "#D9D9D9", breaks = breaks, labels = labels) +
    labs(fill = feature_label) +
    guides(fill = guide_colorbar_paper(barheight_pt = legend_barheight_pt, barwidth_pt = legend_barwidth_pt, title.position = "top", ticks = TRUE)) +
    theme_spatial_paper() +
    ggplot2::theme(plot.title = ggplot2::element_blank(), plot.subtitle = ggplot2::element_blank(), plot.background = ggplot2::element_rect(fill = background, colour = NA), panel.background = ggplot2::element_rect(fill = background, colour = NA), panel.border = ggplot2::element_blank(), legend.position = "right", legend.title = ggplot2::element_text(size = 8.8, face = "bold", margin = ggplot2::margin(b = 3)), legend.text = ggplot2::element_text(size = 8.2), legend.box.margin = ggplot2::margin(0, 0, 0, 2), plot.margin = ggplot2::margin(5, 6, 5, 6))
}
