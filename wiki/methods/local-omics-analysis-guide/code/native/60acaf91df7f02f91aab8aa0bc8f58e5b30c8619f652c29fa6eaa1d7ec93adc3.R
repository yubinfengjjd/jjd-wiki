wf_plot_spatial_continuous <- function(df, title, legend_title = NULL, limits = NULL, palette = c("mako", "cividis", "viridis", "default"), theme_variant = c("default", "qc"), background = NULL, point_size = NULL, point_alpha = 0.96, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver()) {
  palette <- match.arg(palette)
  theme_variant <- match.arg(theme_variant)
  spec <- get_figure_spec()
  qc <- spec$qc %||% list()
  if (is.null(limits)) {
    limits <- wf_pretty_limits(df$value, lower_q = 0.02, upper_q = 0.98, include_zero = all(df$value >= 0, na.rm = TRUE))
  }
  if (inherits(breaks, "waiver")) {
    breaks <- wf_pretty_breaks(limits, n = 4, include_zero = all(limits >= 0))
  }
  if (is.null(point_size)) {
    point_size <- if (theme_variant == "qc") qc$spatial_spot_size_factor %||% 2.35 else 1.8
  }
  if (is.null(legend_barheight_pt)) {
    legend_barheight_pt <- if (theme_variant == "qc") qc$spatial_legend_barheight_pt %||% 34 else 38
  }
  if (is.null(legend_barwidth_pt)) {
    legend_barwidth_pt <- if (theme_variant == "qc") qc$spatial_legend_barwidth_pt %||% 7.5 else 8
  }
  plot_spatial_continuous_df(
    df = df,
    title = title,
    legend_title = legend_title,
    limits = limits,
    palette = palette,
    theme_variant = theme_variant,
    background = background,
    point_size = point_size,
    point_alpha = point_alpha,
    legend_barheight_pt = legend_barheight_pt,
    legend_barwidth_pt = legend_barwidth_pt,
    breaks = breaks,
    labels = labels
  )
}
