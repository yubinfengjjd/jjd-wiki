make_corrected_group_map <- function(obj, group_col, sample_title, palette) {
  group_df <- wf_spatial_df(obj, group_col, source = 'meta')
  present_levels <- wf_order_discrete_levels(group_df$value, names(palette))
  wf_plot_spatial_structure_ref2_style(
    group_df,
    feature_name = sample_title,
    palette = palette,
    legend_title = 'Group',
    legend_levels = present_levels
  ) +
    ggtitle(sample_title) +
    theme(
      plot.title = element_text(face = 'bold', size = 10.8, hjust = 0.5),
      legend.position = 'right'
    )
}
