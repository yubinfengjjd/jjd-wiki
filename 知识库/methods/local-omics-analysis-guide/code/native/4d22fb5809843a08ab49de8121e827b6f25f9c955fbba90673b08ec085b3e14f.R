build_focal_spatial_panel <- function(panel_specs, limits, nhood_store, coords_store, group_store) {
  if (nrow(panel_specs) == 0) return(NULL)
  row_plots <- lapply(seq_len(nrow(panel_specs)), function(i) {
    sample_id <- panel_specs$sample[[i]]
    celltype <- panel_specs$celltype[[i]]
    (
      build_focal_spatial_plot(sample_id, celltype, "High", limits, nhood_store, coords_store, group_store) +
      build_focal_spatial_plot(sample_id, celltype, "Low", limits, nhood_store, coords_store, group_store)
    ) +
      plot_annotation(title = panel_specs$direction[[i]]) &
      theme(plot.title = element_text(size = 10.1, face = "bold", colour = "#2C2722"))
  })

  wrap_plots(row_plots, ncol = 1, guides = "collect") &
    theme(legend.position = "right")
}
