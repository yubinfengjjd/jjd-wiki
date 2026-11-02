build_focal_spatial_plot <- function(sample_id, celltype, group_name, limits, nhood_store, coords_store, group_store) {
  df <- coords_store[[sample_id]]
  df$value <- nhood_store[[sample_id]][rownames(df), celltype]
  df$group <- as.character(group_store[[sample_id]][rownames(df)])
  df_highlight <- df[df$group == group_name, c("x", "y", "value"), drop = FALSE]
  backdrop_df <- df[, c("x", "y"), drop = FALSE]
  wf_plot_spatial_feature_ref1_style(
    df = df_highlight,
    feature_name = display_ct(celltype),
    legend_title = "Nhood abundance",
    limits = limits,
    point_size = 2.18,
    point_alpha = 0.98,
    legend_barheight_pt = 40,
    legend_barwidth_pt = 8,
    backdrop_df = backdrop_df,
    backdrop_size = 2.02,
    backdrop_fill = "#F4F4F4",
    backdrop_colour = "#D8D8D8",
    background = "#FFFFFF"
  ) +
    theme(legend.position = "right")
}
