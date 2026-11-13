.libPaths(c("E:/research-wiki-env/R-lib-scp/4.5", .libPaths()))
for (p in c("gtable","ggplot2","grid","gridExtra","patchwork","ggpubr")) {
  ns <- tryCatch(loadNamespace(p), error=function(e) NULL)
  if (!is.null(ns)) cat(p, ":", exists("is.grob", envir=ns, inherits=FALSE), "\n")
}
