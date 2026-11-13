guide_legend_paper <- function(title.position = "top", override.aes = list(), nrow = NULL) {
  ggplot2::guide_legend(
    title.position = title.position,
    nrow = nrow,
    byrow = !is.null(nrow),
    override.aes = override.aes,
    keyheight = .unit(10, "pt"),
    keywidth = .unit(10, "pt")
  )
}
