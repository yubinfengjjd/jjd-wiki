save_gg <- function(plot_obj, dir_path, stem, width = 7.5, height = 5.5, dpi = 300, bg = "white") {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(dir_path, paste0(stem, ".pdf"))
  png_path <- file.path(dir_path, paste0(stem, ".png"))
  suppressWarnings(ggplot2::ggsave(pdf_path, plot_obj, width = width, height = height, units = "in", bg = bg, device = grDevices::cairo_pdf))
  suppressWarnings(ggplot2::ggsave(png_path, plot_obj, width = width, height = height, units = "in", dpi = dpi, bg = bg))
  invisible(list(pdf = pdf_path, png = png_path))
}
