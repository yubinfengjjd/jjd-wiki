guide_colorbar_paper <- function(barheight_pt = 42, barwidth_pt = 7.5, title.position = "top", ticks = TRUE) {
  ggplot2::guide_colorbar(
    barheight = .unit(barheight_pt, "pt"),
    barwidth = .unit(barwidth_pt, "pt"),
    title.position = title.position,
    ticks = ticks,
    ticks.colour = "#222222",
    frame.colour = "#222222"
  )
}
