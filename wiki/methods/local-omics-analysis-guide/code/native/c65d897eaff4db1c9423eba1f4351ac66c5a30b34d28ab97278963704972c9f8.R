wf_plot_spatial_discrete <- function(df, title, palette, legend_title = NULL, point_size = 1.72, point_alpha = 0.96, legend_levels = NULL) {
  legend_levels <- legend_levels %||% wf_order_discrete_levels(df$value, names(palette))
  df$value <- factor(as.character(df$value), levels = legend_levels)
  ggplot(df, aes(x = x, y = y, colour = value)) +
    geom_point(size = point_size, alpha = point_alpha, stroke = 0, shape = 16) +
    scale_x_continuous(expand = ggplot2::expansion(mult = 0.015)) +
    scale_y_reverse(expand = ggplot2::expansion(mult = 0.015)) +
    coord_fixed() +
    scale_colour_manual(values = palette[legend_levels], breaks = legend_levels, drop = FALSE, na.value = "#DDD7C8") +
    labs(title = title, colour = legend_title %||% "") +
    guides(colour = guide_legend(override.aes = list(size = 3.2, alpha = 1), byrow = TRUE)) +
    theme_spatial_paper() +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      legend.title = ggplot2::element_text(size = 8.5, face = "bold"),
      legend.text = ggplot2::element_text(size = 8.1),
      legend.key.height = grid::unit(8, "pt"),
      legend.spacing.y = grid::unit(1.5, "pt")
    )
}
