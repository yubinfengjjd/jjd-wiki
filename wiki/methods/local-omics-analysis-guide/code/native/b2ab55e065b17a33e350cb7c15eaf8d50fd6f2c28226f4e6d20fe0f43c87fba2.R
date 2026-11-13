make_feature_map <- function(df, feature_title) {
  wf_plot_spatial_feature_ref1_style(df, feature_name = feature_title, legend_title = feature_title) +
    ggtitle(feature_title) +
    theme(
      plot.title = element_text(face = 'bold', size = 10.8, hjust = 0.5),
      legend.position = 'right'
    )
}
