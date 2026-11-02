.libPaths(c("E:/research-wiki-env/R-lib-scp/4.5", .libPaths()))
load("E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda")
f <- function(object, assay=NULL, slot=NULL, layer=NULL, ...) { if (is.null(layer) && !is.null(slot)) layer <- slot; SeuratObject::GetAssayData(object=object, assay=assay, layer=layer, ...) }
x <- tryCatch(f(pancreas_sub), error=function(e) conditionMessage(e))
cat(if (is.character(x)) x else "OK default", "\n")
