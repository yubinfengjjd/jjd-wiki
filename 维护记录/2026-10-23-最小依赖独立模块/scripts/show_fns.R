r <- readRDS("scripts/dep_trace.rds")
out <- file("scripts/fn_bodies.txt","w",encoding="utf-8")
for (nm in names(r)) {
  x <- r[[nm]]; cat("=====", nm, "=====\n", file=out)
  if (!is.null(x$error)) next
  for (f in names(x$globals)) {
    cat("\n---", f, "---\n", file=out)
    cat(x$globals[[f]]$body, "\n", file=out)
  }
}
close(out)
