# Compare the unchanged scDblFinder call against the real wrapper output.
args <- commandArgs(TRUE)
input <- readRDS(args[[1]])
actual <- readRDS(args[[2]])
before <- serialize(input, NULL)
set.seed(11L)
sce <- Seurat::as.SingleCellExperiment(input, assay = "RNA")
reference <- scDblFinder::scDblFinder(sce, dbr = 0.01, verbose = FALSE)
metadata <- actual[[]]
checks <- list(
  input_unchanged = identical(before, serialize(input, NULL)),
  cell_ids_equal = identical(colnames(reference), colnames(actual)),
  scores_equal = identical(unname(reference$scDblFinder.score), unname(metadata$db.scDblFinder_score)),
  classes_equal = identical(as.character(reference$scDblFinder.class), as.character(metadata$db.scDblFinder_class)))
stopifnot(all(unlist(checks)))
jsonlite::write_json(list(state = "passed", checks = checks, cells = ncol(actual),
  seed_before_call = 11L, dbr = 0.01,
  scope = "Direct scDblFinder using the unchanged upstream call expression; full unmodified SCP fails at its deprecated Seurat API."),
  args[[3]], auto_unbox = TRUE, pretty = TRUE)
