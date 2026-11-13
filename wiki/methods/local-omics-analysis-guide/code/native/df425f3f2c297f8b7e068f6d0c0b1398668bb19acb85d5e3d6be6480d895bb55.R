save_fig <- function(p, path_pdf, path_png, w, h) {
  dir.create(dirname(path_pdf), showWarnings = FALSE, recursive = TRUE)
  ok_pdf <- FALSE
  if (capabilities("cairo")) {
    try({
      ggplot2::ggsave(path_pdf, plot = p, width = w, height = h, units = "in", device = grDevices::cairo_pdf)
      ok_pdf <- TRUE
    }, silent = TRUE)
  }
  if (!ok_pdf) ggplot2::ggsave(path_pdf, plot = p, width = w, height = h, units = "in")
  ggplot2::ggsave(path_png, plot = p, width = w, height = h, units = "in", dpi = 600, bg = "white")
}
