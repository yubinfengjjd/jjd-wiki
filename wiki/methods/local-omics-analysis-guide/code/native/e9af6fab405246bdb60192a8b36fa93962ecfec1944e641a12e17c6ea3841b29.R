wf_step_dirs <- function(cfg, step_id, label, script_basename = NULL) {
  root <- wf_step_root(cfg, step_id, label)
  code_dir <- file.path(root, "code")
  result_dir <- file.path(root, "result")
  polished_dir <- file.path(result_dir, "polished")
  out <- list(
    root = root,
    code = code_dir,
    result = result_dir,
    pdf = file.path(result_dir, "pdf"),
    tables = file.path(result_dir, "tables"),
    rds = file.path(result_dir, "rds"),
    logs = file.path(result_dir, "logs"),
    polished = polished_dir,
    pdf_single_panel = file.path(polished_dir, "pdf_single_panel"),
    png_single_panel = file.path(polished_dir, "png_single_panel"),
    manifest = file.path(result_dir, "manifest.csv")
  )
  for (x in out[c("root", "code", "result", "pdf", "tables", "rds", "logs", "polished", "pdf_single_panel", "png_single_panel")]) dir.create(x, recursive = TRUE, showWarnings = FALSE)
  if (!is.null(script_basename)) {
    src <- file.path(cfg$project_root, "workflow", script_basename)
    if (file.exists(src)) file.copy(src, file.path(code_dir, script_basename), overwrite = TRUE)
  }
  snap_files <- c(
    file.path(cfg$project_root, "code", "config.yml"),
    file.path(cfg$project_root, "code", "style", "FIGURE_SPEC_ST.yaml"),
    file.path(cfg$project_root, "code", "R", "plot_helpers.R"),
    file.path(cfg$project_root, "code", "R", "workflow_helpers.R")
  )
  for (f in snap_files[file.exists(snap_files)]) file.copy(f, file.path(code_dir, basename(f)), overwrite = TRUE)
  out
}
