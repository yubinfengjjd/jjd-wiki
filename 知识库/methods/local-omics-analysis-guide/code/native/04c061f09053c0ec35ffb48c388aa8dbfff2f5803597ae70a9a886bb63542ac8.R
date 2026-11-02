wf_copy_single_panel_pdf_png <- function(plot, step_dirs, stem, width = 7, height = 5, paper_level = "reject", note = "", manifest = wf_manifest_init(), bg = NULL) {
  spec <- get_figure_spec()
  png_dpi <- switch(
    paper_level,
    main_text = spec$export$main_text_png_dpi %||% 600,
    supplementary = spec$export$supplementary_png_dpi %||% spec$export$png_dpi %||% 300,
    spec$export$png_dpi %||% 300
  )
  stem <- wf_sanitize_stem(stem)
  pdf_file <- file.path(step_dirs$pdf_single_panel, paste0(stem, ".pdf"))
  png_file <- file.path(step_dirs$png_single_panel, paste0(stem, ".png"))
  bg <- bg %||% (spec$spatial_ref1$panel_background %||% spec$spatial$panel_background %||% spec$canvas$background %||% "white")
  save_panel_pdf(plot, out_file = pdf_file, width = width, height = height, bg = bg)
  suppressWarnings(ggplot2::ggsave(
    filename = png_file,
    plot = plot,
    width = width,
    height = height,
    units = "in",
    dpi = png_dpi,
    bg = bg
  ))
  manifest <- wf_manifest_add(manifest, pdf_file, "pdf", paper_level = paper_level, note = note)
  wf_manifest_add(manifest, png_file, "png", "reject", note)
}
