wf_plot_spatial_binary <- function(obj, column, title) {
  df <- wf_spatial_df(obj, column, source = "meta")
  df$value <- factor(df$value, levels = c("High", "Low"))
  wf_plot_spatial_structure_ref2_style(df, feature_name = title, palette = wf_group_palette(), legend_title = "Group", legend_levels = c("High", "Low"))
}
