save_gg <- function(plot_obj, stem, width = 7.2, height = 6.6, dpi = 320, bg = 'white') {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(out_dir, paste0(stem, '.pdf'))
  png_path <- file.path(out_dir, paste0(stem, '.png'))
  suppressWarnings(ggplot2::ggsave(pdf_path, plot_obj, width = width, height = height, units = 'in', bg = bg, device = grDevices::cairo_pdf))
  suppressWarnings(ggplot2::ggsave(png_path, plot_obj, width = width, height = height, units = 'in', dpi = dpi, bg = bg))
}
