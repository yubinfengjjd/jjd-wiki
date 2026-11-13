make_heatmap_plot <- function(mat, title, fill_title) {
  df <- as.data.frame(as.table(mat), stringsAsFactors = FALSE)
  colnames(df) <- c("source", "target", "value")
  ggplot(df, aes(x = target, y = source, fill = value)) +
    geom_tile(color = "white", linewidth = 0.35) +
    scale_fill_gradient(low = "#F4F1EA", high = "#B45A3C") +
    labs(title = title, x = NULL, y = NULL, fill = fill_title) +
    theme_paper() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid = element_blank(),
      plot.title = element_text(face = "bold")
    )
}
