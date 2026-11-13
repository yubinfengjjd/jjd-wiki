start_phase_log <- function(cfg, phase_id, input_files = character(0), extra = list()) {
  ensure_output_dirs(cfg)
  log_file <- file.path(cfg$output_dir$logs, paste0(phase_id, ".log"))
  seed <- as.integer(cfg$seeds$global)
  set.seed(seed)

  lines <- c(
    paste0("phase=", phase_id),
    paste0("timestamp=", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    paste0("seed=", seed),
    paste0("R.version=", R.version.string),
    paste0("Seurat.version=", as.character(utils::packageVersion("Seurat")))
  )

  if (length(input_files) > 0) {
    lines <- c(lines, "input_md5:")
    for (p in input_files) {
      lines <- c(lines, paste0("- ", p, "\t", safe_md5(p)))
    }
  }
  if (length(extra) > 0) {
    lines <- c(lines, "extra:")
    for (nm in names(extra)) {
      lines <- c(lines, paste0("- ", nm, "=", as.character(extra[[nm]])))
    }
  }

  writeLines(lines, con = log_file)
  capture.output(sessionInfo(), file = log_file, append = TRUE)
  log_file
}
