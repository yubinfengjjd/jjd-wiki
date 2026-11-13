r <- readRDS("scripts/dep_trace.rds")
for (nm in names(r)) {
  x <- r[[nm]]
  cat("=====", nm, "=====\n")
  if (!is.null(x$error)) { cat("ERROR", x$error, "\n"); next }
  cat("closure size:", length(x$seen), "\n")
  cat("closure:", paste(x$seen, collapse=", "), "\n")
  ext <- unique(unlist(lapply(x$globals, `[[`, "functions")))
  cat("external functions:", paste(sort(ext), collapse=", "), "\n")
  vars <- unique(unlist(lapply(x$globals, `[[`, "variables")))
  cat("globals/vars:", paste(sort(setdiff(vars, c("T","F","NULL","TRUE","FALSE","..."))), collapse=", "), "\n\n")
}
