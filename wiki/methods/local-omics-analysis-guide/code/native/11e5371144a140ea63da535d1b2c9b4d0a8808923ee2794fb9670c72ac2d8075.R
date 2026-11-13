wf_copy_pdf_png <- function(plot, step_dirs, stem, width = 7, height = 5, paper_level = "reject", note = "", manifest = wf_manifest_init()) {
  spec <- get_figure_spec()
  png_dpi <- switch(
    paper_level,
    main_text = spec$export$main_text_png_dpi %||% 600,
    supplementary = spec$export$supplementary_png_dpi %||% spec$export$png_dpi %||% 300,
    spec$export$png_dpi %||% 300
  )
  out_prefix <- file.path(step_dirs$pdf, stem)
  files <- save_figure(plot, out_prefix = out_prefix, width = width, height = height, dpi = png_dpi, bg = spec$canvas$background %||% "white")
  manifest <- wf_manifest_add(manifest, files$pdf, "pdf", paper_level = paper_level, note = note)
  wf_manifest_add(manifest, files$png, "png", "reject", note)
}
