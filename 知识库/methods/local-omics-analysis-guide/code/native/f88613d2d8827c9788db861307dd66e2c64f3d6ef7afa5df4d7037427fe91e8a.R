wf_heatmap_save <- function(mat, step_dirs, stem, title, paper_level = "supplementary", note = "", manifest = wf_manifest_init()) {
  legend_title <- if (grepl("nes|enrichment", title, ignore.case = TRUE)) {
    "NES"
  } else if (any(mat < 0, na.rm = TRUE)) {
    "Correlation"
  } else {
    "Weight"
  }
  ht <- complex_heatmap_defaults(mat, title = title, legend_title = legend_title, palette = if (any(mat < 0, na.rm = TRUE)) "diverging" else "continuous")
  out <- file.path(step_dirs$pdf, paste0(stem, ".pdf"))
  save_complexheatmap_pdf(ht, out_file = out, width = 8.6, height = 6.2)
  wf_manifest_add(manifest, out, "pdf", paper_level = paper_level, note = note)
}
