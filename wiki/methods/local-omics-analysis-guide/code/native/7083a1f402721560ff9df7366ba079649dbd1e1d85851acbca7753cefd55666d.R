wf_plot_spatial_binary <- function(obj, column, title) {
  df <- wf_spatial_df(obj, column, source = "meta")
  df$value <- factor(df$value, levels = c("High", "Low"))
  wf_plot_spatial_discrete(df, title, palette = wf_group_palette(), legend_title = "Group")
}
