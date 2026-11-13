ensure_output_dirs <- function(cfg) {
  for (d in unlist(cfg$output_dir, use.names = FALSE)) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
  }
}
