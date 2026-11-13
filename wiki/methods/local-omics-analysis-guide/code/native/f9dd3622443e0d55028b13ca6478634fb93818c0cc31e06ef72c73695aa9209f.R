make_group_map <- function(obj, group_col, sample_title, palette) {
  df <- wf_spatial_df(obj, group_col, source = "meta")
  levs <- unique(as.character(df$value))
  pal <- palette[intersect(names(palette), levs)]
  pal <- c(pal, setNames(rep("#BBBBBB", sum(!(levs %in% names(pal)))), levs[!(levs %in% names(pal))]))
  ggplot(df, aes(x = x, y = y, fill = value)) +
    geom_point(shape = 21, size = 2.2, stroke = 0.15, color = "#3A3A3A") +
    scale_fill_manual(values = pal, drop = FALSE) +
    coord_equal() +
    labs(title = sample_title, x = NULL, y = NULL, fill = "Group") +
    theme_void() +
    theme(
      legend.position = "right",
      plot.title = element_text(face = "bold", hjust = 0.5)
    )
}
