tune_signaling_role_heatmap <- function(heatmap_obj) {
  n_rows <- nrow(heatmap_obj@matrix)
  row_font <- if (n_rows >= 75) 4.8 else if (n_rows >= 55) 5.8 else 7.1
  col_font <- if (n_rows >= 55) 7.8 else 8.8
  heatmap_obj@row_names_param$gp <- grid::gpar(fontsize = row_font, fontface = 'bold', lineheight = 0.9)
  heatmap_obj@column_names_param$gp <- grid::gpar(fontsize = col_font, lineheight = 0.96)
  heatmap_obj@row_names_param$max_width <- grid::unit(34, 'mm')
  heatmap_obj@column_names_param$max_height <- grid::unit(30, 'mm')
  heatmap_obj
}
