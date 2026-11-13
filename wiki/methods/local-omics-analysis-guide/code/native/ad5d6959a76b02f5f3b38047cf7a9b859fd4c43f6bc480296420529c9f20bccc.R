wf_plot_spatial_discrete <- function(df, title, palette, legend_title = NULL, point_size = 1.72, point_alpha = 0.96, legend_levels = NULL) {
  wf_plot_spatial_structure_ref2_style(
    df = df,
    feature_name = title,
    palette = palette,
    legend_title = legend_title,
    point_size = point_size,
    point_alpha = point_alpha,
    legend_levels = legend_levels
  )
}
