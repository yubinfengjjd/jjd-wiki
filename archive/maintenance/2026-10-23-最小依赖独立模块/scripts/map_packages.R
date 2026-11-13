r <- readRDS("scripts/dep_trace.rds")
inst <- rownames(installed.packages())
exports <- list()
for (p in inst) {
  ns <- tryCatch(loadNamespace(p), error=function(e) NULL)
  if (is.null(ns)) next
  ex <- tryCatch(getNamespaceExports(ns), error=function(e) character())
  exports[[p]] <- ex
}
cat("namespaces loaded:", length(exports), "\n")
# candidates for a function name: packages exporting it
map_name <- function(nm) {
  hits <- names(exports)[vapply(exports, function(e) nm %in% e, logical(1))]
  hits
}
base_fns <- c(ls(baseenv()), getNamespaceExports("stats"), getNamespaceExports("utils"), getNamespaceExports("methods"), getNamespaceExports("grDevices"), getNamespaceExports("graphics"), getNamespaceExports("grid"))
out <- file("scripts/pkg_map.txt","w",encoding="utf-8")
for (t in names(r)) {
  x <- r[[t]]; if(!is.null(x$error)) next
  cat("=====", t, "=====\n", file=out)
  ext <- unique(unlist(lapply(x$globals, `[[`, "functions")))
  ext <- setdiff(ext, base_fns)
  cand <- lapply(sort(ext), function(nm) list(name=nm, pkgs=map_name(nm)))
  unmapped <- vapply(cand, function(z) length(z$pkgs)==0, logical(1))
  cat("UNMAPPED:", paste(vapply(cand[unmapped], `[[`, "", "name"), collapse=", "), "\n", file=out)
  for (z in cand[!unmapped]) cat(z$name, "->", paste(z$pkgs, collapse=","), "\n", file=out)
}
close(out)
