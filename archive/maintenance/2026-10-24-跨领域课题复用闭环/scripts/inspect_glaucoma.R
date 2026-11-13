args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2L)
project <- normalizePath(args[[1]], winslash = "/", mustWork = TRUE)
output <- args[[2]]
suppressPackageStartupMessages(library(SeuratObject))
stopifnot(requireNamespace("jsonlite", quietly = TRUE))
files <- c("GSE251716_seurat_annotated.rds", "GSE251716_seurat_annotated_pathway_scored.rds")
observations <- lapply(files, function(name) {
  object <- readRDS(file.path(project, name))
  meta <- object[[]]
  factors <- intersect(c("celltype", "CellType", "group", "condition", "orig.ident", "sample"), colnames(meta))
  summaries <- lapply(factors, function(column) as.list(table(meta[[column]], useNA = "ifany")))
  names(summaries) <- factors
  reductions <- lapply(object@reductions, function(reduction) {
    dims <- dim(reduction@cell.embeddings)
    list(rows = dims[[1]], dimensions = dims[[2]])
  })
  list(file = name, object_class = class(object), dimensions = dim(object),
       assays = names(object@assays), active_assay = object@active.assay,
       reductions = reductions, metadata_columns = colnames(meta),
       signature_columns = grep("score|AUCell|UCell|AddModule|ssGSEA|singscore",
                                colnames(meta), value = TRUE, ignore.case = TRUE),
       categorical_counts = summaries,
       provenance_scope = "Read-only object structure. Annotation correctness and prior successful execution not certified.")
})
names(observations) <- files
packages <- c("Seurat", "SeuratObject", "Matrix", "jsonlite", "ggplot2", "rlang",
              "BiocParallel", "harmony", "SingleR", "scDblFinder", "monocle", "monocle3",
              "AUCell", "UCell", "GSVA", "singscore")
available <- lapply(packages, function(package) {
  if (requireNamespace(package, quietly = TRUE)) as.character(packageVersion(package)) else NULL
})
names(available) <- packages
report <- list(project = project, R_version = R.version.string, libraries = .libPaths(),
               packages = available, object_observations = observations,
               action = "read_only_inspection", analysis_executed = FALSE)
jsonlite::write_json(report, output, pretty = TRUE, auto_unbox = TRUE, null = "null")
cat("Read-only object inspection saved; no project files written.\n")
