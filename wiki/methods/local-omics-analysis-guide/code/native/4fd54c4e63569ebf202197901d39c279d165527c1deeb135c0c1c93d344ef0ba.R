wf_make_simple_network_plot <- function(edge_df, centroids, title) {
  edge_df <- edge_df[!(edge_df$x_from == edge_df$x_to & edge_df$y_from == edge_df$y_to), , drop = FALSE]
  if (nrow(edge_df) == 0) return(ggplot() + annotate("text", x = 1, y = 1, label = "No significant LR edges") + theme_void())
  ggplot() +
    geom_curve(data = edge_df, aes(x = x_from, y = y_from, xend = x_to, yend = y_to, linewidth = weight), colour = "#F4A261", curvature = 0.18, alpha = 0.6) +
    geom_point(data = centroids, aes(x = x, y = y, fill = group), shape = 21, size = 6, colour = "#333333") +
    geom_text(data = centroids, aes(x = x, y = y, label = group), nudge_y = 7, size = 3.2) +
    scale_fill_manual(values = wf_named_palette(centroids$group, "d3")) +
    scale_linewidth(range = c(0.3, 2.5)) +
    coord_fixed() +
    labs(title = title, fill = "Celltype", linewidth = "Weight") +
    theme_void() +
    theme(legend.position = "right", plot.title = element_text(hjust = 0, face = "bold"))
}
