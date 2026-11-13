wf_manifest_write <- function(step_dirs, manifest) { readr::write_csv(manifest, step_dirs$manifest); invisible(step_dirs$manifest) }
