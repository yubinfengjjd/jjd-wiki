# Regression using the exact public case; no substitute PCA is constructed.
args <- commandArgs(TRUE)
load(args[[1]])
if (length(args) >= 4L) {
  recorded <- unserialize(readBin(args[[4]], "raw", n = file.info(args[[4]])$size))
  qry <- recorded[[1]]
  ref <- recorded[[2]]
} else {
  ref <- Seurat::NormalizeData(pancreas_sub[, seq_len(300L)], verbose = FALSE)
  qry <- Seurat::NormalizeData(pancreas_sub[, 301:400], verbose = FALSE)
}
stopifnot(identical(colnames(ref), colnames(pancreas_sub)[seq_len(300L)]),
          identical(colnames(qry), colnames(pancreas_sub)[301:400]))
stopifnot(identical(dim(SeuratObject::Loadings(ref[["PCA"]])), c(0L, 0L)))
before <- serialize(list(qry, ref), NULL)
module <- new.env(parent = globalenv())
source(file.path(args[[2]], "code/analysis.R"), local = module)
set.seed(11L)
error <- tryCatch({
  module$run_reference_mapping(qry, ref, parameters = list(
    ref_pca = "PCA", ref_umap = "UMAP", ref_group = "CellType", ref_dims = 1:20,
    projection_method = "knn", k = 10, distance_metric = "cosine", vote_fun = "mean"))
  NULL
}, error = conditionMessage)
expected <- "Reference reduction 'PCA' has no feature loadings; pcaproject requires a fitted reference reduction with feature loadings."
report <- list(kind = "missing-reference-loadings-regression", passed = identical(error, expected),
               execution_state = "not_run", algorithm_verification_state = "not_run",
               expected_error = expected, actual_error = error,
               input_object_unchanged = identical(before, serialize(list(qry, ref), NULL)),
               input_serialized_sha256 = digest::digest(before, algo = "sha256", serialize = FALSE),
               reference_loadings_dim = dim(SeuratObject::Loadings(ref[["PCA"]])),
               scientific_parameters_changed = FALSE)
jsonlite::write_json(report, file.path(args[[3]], "guard-test.json"), auto_unbox = TRUE, pretty = TRUE)
if (!report$passed || !report$input_object_unchanged) quit(status = 1L)
