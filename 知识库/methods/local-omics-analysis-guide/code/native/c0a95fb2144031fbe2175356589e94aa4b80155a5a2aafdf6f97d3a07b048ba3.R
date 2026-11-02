build_domain_plot <- function(obj, sample_id, display_spec, palette_display) {
  dom_df <- wf_spatial_df(obj, "BayesSpace_domain", "meta") %>%
    mutate(
      domain_raw = as.character(value),
      value = unname(display_spec$display_map[domain_raw])
    ) %>%
    select(x, y, value)

  label_map <- stats::setNames(gsub("^Domain\\s+", "", display_spec$display_levels), display_spec$display_levels)
  wf_plot_spatial_structure_ref2_style(
    dom_df,
    feature_name = sample_id,
    palette = palette_display,
    legend_title = "Spatial domain",
    point_size = 2.45,
    legend_levels = display_spec$display_levels,
    add_domain_labels = TRUE,
    label_map = label_map
  )
}
