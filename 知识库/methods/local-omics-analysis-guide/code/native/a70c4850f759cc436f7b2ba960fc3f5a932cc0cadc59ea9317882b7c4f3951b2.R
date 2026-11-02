wf_with_subplot_title <- function(plot_obj, title, size = 9.2, hjust = 0.5) {
  if (is.null(title) || !nzchar(title)) return(plot_obj)
  plot_obj +
    labs(title = title) +
    theme(
      plot.title = element_text(size = size, face = "bold", hjust = hjust, colour = "#1F1F1F"),
      plot.title.position = "plot",
      plot.margin = margin(5, 6, 5, 6)
    )
}
