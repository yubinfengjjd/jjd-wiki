r <- readRDS("scripts/dep_trace_extra.rds")
for (nm in names(r)) {
  x <- r[[nm]]; cat("=====", nm, "=====\n")
  if (!is.null(x$error)) { cat("ERROR", x$error, "\n"); next }
  cat("closure:", paste(x$seen, collapse=", "), "\n")
  ext <- unique(unlist(lapply(x$globals, `[[`, "functions")))
  cat("external:", paste(sort(ext), collapse=", "), "\n\n")
}
