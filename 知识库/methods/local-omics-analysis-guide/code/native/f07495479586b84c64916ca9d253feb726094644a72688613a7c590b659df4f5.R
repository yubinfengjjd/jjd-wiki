compute_domain_display_spec <- function(objs) {
  topology_tbl <- bind_rows(lapply(names(objs), function(sample_id) {
    wf_spatial_df(objs[[sample_id]], "BayesSpace_domain", "meta") %>%
      group_by(value) %>%
      summarise(x = mean(x, na.rm = TRUE), y = mean(y, na.rm = TRUE), .groups = "drop") %>%
      mutate(
        sample = sample_id,
        x_scaled = if (dplyr::n() > 1L) scales::rescale(x) else 0.5,
        y_scaled = if (dplyr::n() > 1L) scales::rescale(y) else 0.5
      )
  }))
  raw_order <- topology_tbl %>%
    group_by(value) %>%
    summarise(x_scaled = mean(x_scaled), y_scaled = mean(y_scaled), .groups = "drop") %>%
    arrange(x_scaled, y_scaled) %>%
    pull(value)
  display_labels <- paste("Domain", seq_along(raw_order) - 1L)
  display_map <- setNames(display_labels, raw_order)
  list(raw_order = raw_order, display_levels = unname(display_map[raw_order]), display_map = display_map)
}
