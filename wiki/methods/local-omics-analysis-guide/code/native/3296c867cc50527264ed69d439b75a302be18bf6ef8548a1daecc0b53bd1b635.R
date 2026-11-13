panel_output_root <- function(cfg, phase_id) {
  out_root <- NULL
  if (!is.null(cfg$output_dir) && !is.null(cfg$output_dir$panel_outputs)) {
    out_root <- cfg$output_dir$panel_outputs
  }
  if (is.null(out_root) || identical(out_root, "") || is.na(out_root)) {
    base <- cfg$base_dir
    if (is.null(base) || identical(base, "") || is.na(base)) {
      base <- getwd()
    }
    out_root <- file.path(base, "panel_outputs")
  }
  normalizePath(file.path(out_root, phase_id), winslash = "/", mustWork = FALSE)
}
