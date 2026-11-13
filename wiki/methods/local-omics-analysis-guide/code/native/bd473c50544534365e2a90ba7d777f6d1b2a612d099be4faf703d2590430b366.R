save_heatmap_to_dir <- function(heatmap_obj, dir_path, stem, width = 7.8, height = 6.4, dpi = 320) {
  stem <- wf_sanitize_stem(stem)
  pdf_path <- file.path(dir_path, paste0(stem, '.pdf'))
  png_path <- file.path(dir_path, paste0(stem, '.png'))

  grDevices::pdf(pdf_path, width = width, height = height, family = 'Helvetica')
  on.exit(try(grDevices::dev.off(), silent = TRUE), add = TRUE)
  ComplexHeatmap::draw(
    heatmap_obj,
    newpage = FALSE,
    heatmap_legend_side = 'right',
    annotation_legend_side = 'right',
    merge_legend = TRUE,
    padding = grid::unit(c(2.2, 4.6, 1.8, 2.2), 'mm')
  )
  grDevices::dev.off()
  on.exit(NULL, add = FALSE)

  grDevices::png(png_path, width = width, height = height, units = 'in', res = dpi, bg = 'white')
  on.exit(try(grDevices::dev.off(), silent = TRUE), add = TRUE)
  ComplexHeatmap::draw(
    heatmap_obj,
    newpage = FALSE,
    heatmap_legend_side = 'right',
    annotation_legend_side = 'right',
    merge_legend = TRUE,
    padding = grid::unit(c(2.2, 4.6, 1.8, 2.2), 'mm')
  )
  grDevices::dev.off()
  on.exit(NULL, add = FALSE)

  invisible(list(pdf = pdf_path, png = png_path))
}
