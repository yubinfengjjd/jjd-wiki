save_pdf_only <- function(plot_obj, out_file, width = 10.5, height = 6.8, bg = 'white') {
  suppressWarnings(ggplot2::ggsave(out_file, plot_obj, width = width, height = height, units = 'in', bg = bg, device = grDevices::cairo_pdf))
  invisible(out_file)
}
