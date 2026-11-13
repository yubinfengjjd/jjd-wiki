# Diagnose the actual public reference/query representation without changing it.
args <- commandArgs(TRUE)
describe <- function(value) list(class = class(value), typeof = typeof(value),
  dim = dim(value), length = length(value), is_s4 = isS4(value), is_matrix = is.matrix(value),
  dimnames_sha256 = digest::digest(dimnames(value), algo = "sha256"),
  numeric_matrix_sha256 = digest::digest(as.matrix(value), algo = "sha256"))
report <- list(state = "not_run")
tryCatch(withCallingHandlers({
  load(args[[1]])
  ref <- Seurat::NormalizeData(pancreas_sub[, seq_len(300L)], verbose = FALSE)
  qry <- Seurat::NormalizeData(pancreas_sub[, 301:400], verbose = FALSE)
  report$input_assays <- list(reference = describe(SeuratObject::GetAssayData(ref, assay = "RNA", layer = "data")),
                             query = describe(SeuratObject::GetAssayData(qry, assay = "RNA", layer = "data")))
  report$input_pca <- list(reference_loadings = describe(SeuratObject::Loadings(ref[["PCA"]])),
                          reference_variable_features = SeuratObject::VariableFeatures(ref),
                          loadings_features = rownames(SeuratObject::Loadings(ref[["PCA"]])))
  report$project_default_source <- deparse(getFromNamespace("ProjectCellEmbeddings.default", "Seurat"), width.cutoff = 500L)
  before <- serialize(list(qry, ref), NULL)
  module <- new.env(parent = globalenv())
  source(file.path(args[[2]], "code/analysis.R"), local = module)
  set.seed(11L)
  result <- module$run_reference_mapping(qry, ref, parameters = list(
    ref_pca = "PCA", ref_umap = "UMAP", ref_group = "CellType", ref_dims = 1:20,
    projection_method = "knn", k = 10, distance_metric = "cosine", vote_fun = "mean"))
  report$input_unchanged <- identical(before, serialize(list(qry, ref), NULL))
  saveRDS(result$result, file.path(args[[3]], "result.rds"))
  report$state <- "executed"
}, error = function(error) {
  report$error_calls <<- lapply(sys.calls(), function(call) paste(deparse(call[[1]]), collapse = " "))
  report$condition_call <<- paste(deparse(conditionCall(error)), collapse = " ")
  report$error_frames <<- lapply(Filter(function(frame) exists("reference.data", frame, inherits = FALSE), sys.frames()),
    function(frame) list(reference_data = describe(get("reference.data", frame, inherits = FALSE)),
                         features = if (exists("features", frame, inherits = FALSE)) get("features", frame, inherits = FALSE) else NULL,
                         dims = if (exists("dims", frame, inherits = FALSE)) get("dims", frame, inherits = FALSE) else NULL,
                         query_data = if (exists("query", frame, inherits = FALSE)) describe(get("query", frame, inherits = FALSE)) else NULL))
  report$input_unchanged <<- identical(before, serialize(list(qry, ref), NULL))
}), error = function(error) report$error <<- conditionMessage(error))
jsonlite::write_json(report, file.path(args[[3]], "representation.json"), auto_unbox = TRUE, pretty = TRUE)
if (!identical(report$state, "executed")) quit(status = 1L)
