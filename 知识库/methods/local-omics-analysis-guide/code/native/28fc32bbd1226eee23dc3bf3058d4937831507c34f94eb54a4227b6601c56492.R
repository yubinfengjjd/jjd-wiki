wf_plot_spatial_structure_ref2_style <- function(df, feature_name = NULL, palette, legend_title = NULL, point_size = NULL, point_alpha = NULL, legend_levels = NULL, add_domain_labels = FALSE, label_map = NULL, backdrop_df = NULL, backdrop_size = NULL, backdrop_fill = "#F3F3F3", backdrop_colour = "#D9D9D9", backdrop_alpha = 1) {
  ref2 <- wf_spatial_ref2_spec()
  legend_levels <- legend_levels %||% wf_order_discrete_levels(df$value, names(palette))
  df$value <- factor(as.character(df$value), levels = legend_levels)
  point_size <- point_size %||% ref2$point_size
  point_alpha <- point_alpha %||% ref2$point_alpha
  backdrop_size <- backdrop_size %||% max(point_size * 0.94, 1.7)

  p <- ggplot()
  if (!is.null(backdrop_df) && nrow(backdrop_df) > 0) {
    p <- p +
      ggplot2::geom_point(data = backdrop_df, ggplot2::aes(x = x, y = y), inherit.aes = FALSE, shape = 21, size = backdrop_size, alpha = backdrop_alpha, stroke = max(ref2$stroke * 0.7, 0.18), fill = backdrop_fill, colour = backdrop_colour)
  }

  p <- p +
    geom_point(data = df, aes(x = x, y = y, fill = value), shape = 21, size = point_size, alpha = point_alpha, stroke = ref2$stroke, colour = ref2$border_colour) +
    scale_x_continuous(expand = ggplot2::expansion(mult = 0.02)) +
    scale_y_reverse(expand = ggplot2::expansion(mult = 0.02)) +
    coord_fixed() +
    scale_fill_manual(values = palette[legend_levels], breaks = legend_levels, drop = FALSE, na.value = "#D9D9D9") +
    labs(fill = legend_title %||% "") +
    guides(fill = guide_legend(override.aes = list(shape = 21, size = max(point_size, 3.6), alpha = 1, colour = ref2$border_colour, stroke = ref2$stroke), byrow = TRUE)) +
    theme_spatial_paper() +
    ggplot2::theme(plot.title = ggplot2::element_blank(), plot.subtitle = ggplot2::element_blank(), plot.background = ggplot2::element_rect(fill = ref2$background, colour = NA), panel.background = ggplot2::element_rect(fill = ref2$background, colour = NA), panel.border = ggplot2::element_blank(), legend.position = "right", legend.title = ggplot2::element_text(size = 8.8, face = "bold", margin = ggplot2::margin(b = 4)), legend.text = ggplot2::element_text(size = 8.1), legend.key.height = grid::unit(ref2$legend_key_size_pt, "pt"), legend.spacing.y = grid::unit(1.5, "pt"), legend.box.margin = ggplot2::margin(0, 0, 0, 2), plot.margin = ggplot2::margin(5, 6, 5, 6))

  if (isTRUE(add_domain_labels)) {
    label_map <- label_map %||% stats::setNames(as.character(seq_along(legend_levels) - 1L), legend_levels)
    centroids <- df %>% dplyr::filter(!is.na(value)) %>% dplyr::group_by(value) %>% dplyr::summarise(x = stats::median(x, na.rm = TRUE), y = stats::median(y, na.rm = TRUE), .groups = "drop")
    centroids$label <- unname(label_map[as.character(centroids$value)])
    centroids <- centroids[!is.na(centroids$label) & nzchar(centroids$label), , drop = FALSE]
    if (nrow(centroids) > 0) {
      p <- p + ggplot2::geom_label(data = centroids, ggplot2::aes(x = x, y = y, label = label), inherit.aes = FALSE, size = ref2$domain_label_size, fontface = "bold", label.size = 0.18, label.padding = grid::unit(0.09, "lines"), fill = ref2$domain_label_fill, colour = ref2$domain_label_colour)
    }
  }
  p
}
