.libPaths(c("E:/research-wiki-env/R-lib-scp/4.5", .libPaths()))
library(Seurat); library(SeuratObject)
load("E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda")
srt <- NormalizeData(pancreas_sub, verbose=FALSE)
asal <- methods::slot(srt, name="assays")[["RNA"]]
x <- tryCatch(FindMarkers(object=asal, slot="data", cells.1=colnames(srt)[1:20], cells.2=colnames(srt)[21:40], test.use="wilcox", logfc.threshold=0, verbose=FALSE), error=function(e) conditionMessage(e))
cat(if (is.character(x)) x else paste("OK rows", nrow(x)), "\n")
