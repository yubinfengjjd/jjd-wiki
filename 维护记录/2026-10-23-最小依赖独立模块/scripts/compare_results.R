# Compare standalone module output with the immutable before/ reference.
args <- commandArgs(trailingOnly = TRUE)
method <- args[1]
ref <- readRDS(args[2])
new <- readRDS(args[3])
stopifnot(identical(ref$state, "passed"), identical(new$state, "passed"))
same <- function(a, b, tol = 1e-10) isTRUE(all.equal(a, b, tolerance = tol, check.attributes = FALSE))
checks <- list()
add <- function(label, ok) checks[[label]] <<- isTRUE(ok)
if (method == "cell-quality-control") {
  cols <- c("nCount_RNA", "nFeature_RNA", "CellQC")
  add("QC metadata identical", identical(ref$seurat$meta[, cols], new$seurat$meta[, cols]))
  add("QC cells identical", identical(ref$seurat$cells, new$seurat$cells))
} else if (method == "dimensionality-reduction") {
  add("PCA embeddings equal", same(ref$seurat$embeddings$PCA, new$seurat$embeddings$PCA))
  add("UMAP embeddings equal", same(ref$seurat$embeddings$UMAP, new$seurat$embeddings$UMAP))
  add("reduction names equal", identical(ref$seurat$reductions, new$seurat$reductions))
} else if (method == "batch-integration") {
  add("cells equal", identical(ref$seurat$cells, new$seurat$cells))
  add("Seurat UMAP equal", same(ref$seurat$embeddings$SeuratUMAP2D, new$seurat$embeddings$SeuratUMAP2D))
  cluster <- grep("cluster", colnames(ref$seurat$meta), ignore.case = TRUE, value = TRUE)[1]
  add("cluster assignments equal", identical(as.character(ref$seurat$meta[[cluster]]), as.character(new$seurat$meta[[cluster]])))
  add("reduction names equal", identical(ref$seurat$reductions, new$seurat$reductions))
} else if (method == "differential-expression") {
  a <- ref$tools$DEtest_custom$AllMarkers_wilcox
  b <- new$tools$DEtest_custom$AllMarkers_wilcox
  add("DE table identical", identical(a, b))
  add("DE rows", nrow(b) > 0)
} else if (method == "gene-set-enrichment") {
  a <- ref$raw$results[[1]]@result
  b <- new$raw$results[[1]]@result
  add("ORA table identical", identical(a, b))
  add("ORA rows", nrow(b) > 0)
} else if (method == "gene-set-scoring") {
  cols <- c("X_Endocrine", "X_Ductal")
  add("score columns identical", same(ref$seurat$meta[, cols], new$seurat$meta[, cols]))
} else if (method == "trajectory-inference") {
  add("Lineage1 identical", same(ref$seurat$meta$Lineage1, new$seurat$meta$Lineage1, tol = 1e-12))
  add("BranchID identical", identical(as.character(ref$seurat$meta$BranchID), as.character(new$seurat$meta$BranchID)))
} else if (method == "dynamic-feature-analysis") {
  a <- ref$tools$DynamicFeatures_fixture_time$DynamicFeatures
  b <- new$tools$DynamicFeatures_fixture_time$DynamicFeatures
  add("dynamic table identical", identical(a, b))
  add("dynamic rows", nrow(b) == 2)
} else {
  stop("unknown method")
}
for (label in names(checks)) cat(if (checks[[label]]) "PASS: " else "FAIL: ", label, "\n", sep = "")
passed <- all(unlist(checks))
jsonlite::write_json(list(
  method = method, state = if (passed) "passed" else "failed",
  reference = normalizePath(args[2], mustWork = TRUE),
  candidate = normalizePath(args[3], mustWork = TRUE),
  checks = as.list(checks), compared_at = format(Sys.time(), tz = "UTC", usetz = TRUE)
), file.path(dirname(normalizePath(args[3], mustWork = TRUE)), "comparison.json"),
  auto_unbox = TRUE, pretty = TRUE)
if (!passed) quit(status = 1)
cat("COMPARE_PASS", method, "\n")
