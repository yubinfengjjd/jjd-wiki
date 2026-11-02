save_figure <- function(plot_obj, out_prefix, width = 7, height = 5, dpi = 600, bg = "white") {
  plot_guard(plot_obj = plot_obj, reason = paste0("save_figure failed for ", out_prefix))
  dir.create(dirname(out_prefix), recursive = TRUE, showWarnings = FALSE)

  pdf_file <- paste0(out_prefix, ".pdf")
  png_file <- paste0(out_prefix, ".png")

  pdf_dev <- if (isTRUE(capabilities("cairo"))) grDevices::cairo_pdf else grDevices::pdf
  if (identical(pdf_dev, grDevices::pdf)) {
    suppressWarnings(ggplot2::ggsave(
      filename = pdf_file,
      plot = plot_obj,
      device = pdf_dev,
      width = width,
      height = height,
      units = "in",
      dpi = 300,
      bg = bg,
      useDingbats = FALSE
    ))
  } else {
    suppressWarnings(ggplot2::ggsave(
      filename = pdf_file,
      plot = plot_obj,
      device = pdf_dev,
      width = width,
      height = height,
      units = "in",
      dpi = 300,
      bg = bg
    ))
  }

  suppressWarnings(ggplot2::ggsave(
    filename = png_file,
    plot = plot_obj,
    width = width,
    height = height,
    units = "in",
    dpi = dpi,
    bg = bg
  ))

  invisible(list(pdf = pdf_file, png = png_file))
}
