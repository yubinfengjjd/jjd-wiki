wf_plot_spatial_continuous <- function(df, title, legend_title = NULL, limits = NULL, palette = c("mako", "cividis", "viridis", "default"), theme_variant = c("default", "qc"), background = NULL, point_size = NULL, point_alpha = 0.96, legend_barheight_pt = NULL, legend_barwidth_pt = NULL, breaks = ggplot2::waiver(), labels = ggplot2::waiver()) {
  theme_variant <- match.arg(theme_variant)
  if (theme_variant == "qc") {
    return(plot_spatial_continuous_df(
      df = df,
      title = legend_title %||% title,
      legend_title = legend_title %||% title,
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
    ))
  }
  wf_plot_spatial_feature_ref1_style(
    df = df,
    feature_name = legend_title %||% title,
    legend_title = legend_title %||% title,
    limits = limits,
    breaks = breaks,
    labels = labels,
    point_size = point_size,
    point_alpha = point_alpha,
    background = background,
    legend_barheight_pt = legend_barheight_pt,
    legend_barwidth_pt = legend_barwidth_pt
  )
}
