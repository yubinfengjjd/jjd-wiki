.libPaths(c("E:/research-wiki-env/R-lib-scp/4.5", .libPaths()))
f <- getS3method("Assays", "Seurat", envir=asNamespace("SeuratObject"))
print(f)
