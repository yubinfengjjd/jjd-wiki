# Run one standalone module from an isolated copy and save its actual output.
# Usage: Rscript --vanilla portable_run.R <method> <code_dir> <fixture> <out_rds>
args <- commandArgs(trailingOnly = TRUE)
method <- args[1]
code_dir <- normalizePath(args[2], mustWork = TRUE)
fixture <- args[3]
out_file <- args[4]
stopifnot(!grepl("scp-local", code_dir, ignore.case = TRUE))
script_path <- normalizePath(
  sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]),
  mustWork = TRUE)
rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
command_line <- paste(shQuote(rscript), "--vanilla", shQuote(script_path), method,
                      shQuote(code_dir), shQuote(fixture), shQuote(out_file), collapse = " ")
code_files <- list.files(code_dir, recursive = TRUE, full.names = TRUE)
code_sha256 <- setNames(
  vapply(code_files, function(path) digest::digest(path, algo = "sha256", file = TRUE), ""),
  substring(code_files, nchar(code_dir) + 2))
started_at <- format(Sys.time(), tz = "UTC", usetz = TRUE)
load(fixture)
stopifnot(inherits(pancreas_sub, "Seurat"))
test_cells <- as.integer(Sys.getenv("SCP_TEST_CELLS", "0"))
rename_cells <- identical(Sys.getenv("SCP_TEST_RENAME"), "1")
case <- list(label = method, parameters = list())
run_case <- function(label, fn, ...) {
  arguments <- list(...)
  keep <- nzchar(names(arguments)) & !names(arguments) %in% c("srt", "qry", "ref", "bundle")
  sanitise <- function(value) {
    if (isS4(value) || is.environment(value) || is.function(value)) {
      paste0("<", class(value)[1], ">")
    } else if (is.list(value)) {
      lapply(value, sanitise)
    } else {
      value
    }
  }
  captured <- lapply(arguments[keep], sanitise)
  case <<- list(label = label, parameters = captured)
  do.call(fn, arguments)
}
slice_cells <- function(n) {
  n <- if (!is.na(test_cells) && test_cells > 0) min(test_cells, ncol(pancreas_sub)) else n
  object <- pancreas_sub[, seq_len(n)]
  if (rename_cells) colnames(object) <- paste0("cell_", seq_len(ncol(object)))
  object
}
Serial <- BiocParallel::SerialParam()
set.seed(11)
options(future.globals.maxSize = 4 * 1024^3)
future::plan("sequential")

env <- new.env(parent = globalenv())
old <- setwd(code_dir)
on.exit(setwd(old), add = TRUE)
entry_file <- switch(method,
  "monocle2" = "monocle2.R", "monocle3" = "monocle3.R",
  "monocle2-core" = "monocle2_core.R", "monocle3-core" = "monocle3_core.R",
  "monocle2-plot" = "monocle2_plot.R", "monocle3-plot" = "monocle3_plot.R",
  "reference-transfer" = "transfer.R", "analysis.R")
source(file.path(code_dir, entry_file), local = env)
setwd(old)

state <- "passed"
error <- NULL
out <- NULL
tryCatch({
  if (method == "cell-quality-control") {
    srt <- slice_cells(80)
    input_state <- serialize(srt, NULL)
    out <- run_case("QC non-doublet", env$run_cell_quality_control, srt, parameters = list(
      qc_metrics = c("umi", "gene", "mito"), UMI_threshold = 0, gene_threshold = 0,
      mito_threshold = 100, return_filtered = FALSE, assay = "RNA", seed = 11))
  } else if (method == "doublet-detection") {
    srt <- slice_cells(80)
    input_state <- serialize(srt, NULL)
    out <- run_case("doublet scDblFinder", env$run_doublet_detection, srt, parameters = list(
      assay = "RNA", db_method = "scDblFinder", db_rate = 0.01, seed = 11))
  } else if (method == "dimensionality-reduction") {
    srt <- Seurat::NormalizeData(slice_cells(200), verbose = FALSE)
    srt <- Seurat::FindVariableFeatures(srt, nfeatures = 500, verbose = FALSE)
    srt <- Seurat::ScaleData(srt, verbose = FALSE)
    input_state <- serialize(srt, NULL)
    out <- run_case("PCA UMAP", env$run_dimensionality_reduction, srt, parameters = list(
      features = Seurat::VariableFeatures(srt)[1:100],
      linear_reduction = "pca", nonlinear_reduction = "umap",
      linear_reduction_dims = 20, reduction_use = "pca", reduction_dims = 1:20,
      force_linear_reduction = TRUE, force_nonlinear_reduction = TRUE, verbose = FALSE))
  } else if (method == "batch-integration") {
    srt <- slice_cells(120)
    srt$batch <- rep(c("A", "B"), each = ceiling(ncol(srt) / 2), length.out = ncol(srt))
    input_state <- serialize(srt, NULL)
    out <- run_case("Seurat anchor integration", env$run_seurat_integration, srt, "batch", parameters = list(
      nHVF = 300, linear_reduction_dims = 20, nonlinear_reduction_dims = 2,
      cluster_resolution = 0.5, IntegrateData_params = list(k.weight = 30), seed = 11))
  } else if (method == "batch-integration-harmony") {
    srt <- slice_cells(120)
    srt$batch <- rep(c("A", "B"), each = ceiling(ncol(srt) / 2), length.out = ncol(srt))
    input_state <- serialize(srt, NULL)
    out <- run_case("Harmony integration", env$run_batch_integration, srt, parameters = list(
      batch = "batch", nHVF = 300, linear_reduction_dims = 20,
      nonlinear_reduction_dims = 2, cluster_resolution = 0.5, seed = 11))
  } else if (method == "cell-type-annotation") {
    ref <- Seurat::NormalizeData(pancreas_sub[, seq_len(300)], verbose = FALSE)
    qry <- Seurat::NormalizeData(pancreas_sub[, 301:400], verbose = FALSE)
    input_state <- serialize(list(qry, ref), NULL)
    out <- run_case("SingleR annotation", env$run_cell_type_annotation, qry, ref, parameters = list(
      ref_group = "CellType", query_assay = "RNA", ref_assay = "RNA"))
  } else if (method == "differential-expression") {
    srt <- Seurat::NormalizeData(pancreas_sub, verbose = FALSE)
    input_state <- serialize(srt, NULL)
    out <- run_case("Wilcoxon DE", env$run_differential_expression, srt, parameters = list(
      group_by = "CellType", group1 = "Ductal", group2 = "Endocrine",
      test.use = "wilcox", only.pos = FALSE, fc.threshold = 1.0, min.pct = 0.1,
      p.adjust.method = "bonferroni", slot = "data", assay = "RNA",
      verbose = FALSE, BPPARAM = Serial, seed = 11))
  } else if (method == "gene-set-enrichment") {
    term2gene <- data.frame(term = rep(c("T1", "T2"), each = 3),
                            gene = c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam"))
    term2name <- data.frame(term = c("T1", "T2"), name = c("Endocrine", "Ductal"))
    gene_ids <- c("Ins1", "Gcg", "Sst", "Krt19", "Krt8", "Epcam", "Mki67")
    input_state <- serialize(list(gene_ids = gene_ids, TERM2GENE = term2gene,
                                  TERM2NAME = term2name), NULL)
    out <- run_case("ORA custom TERM2GENE", env$run_gene_set_enrichment, gene_ids,
      parameters = list(geneID_groups = NULL, IDtype = "symbol", species = "Homo_sapiens",
        TERM2GENE = term2gene, TERM2NAME = term2name, minGSSize = 1, maxGSSize = 500,
        db_update = FALSE, BPPARAM = Serial, seed = 11))
  } else if (method == "gene-set-scoring") {
    srt <- slice_cells(80)
    input_state <- serialize(srt, NULL)
    out <- run_case("Seurat module score", env$run_gene_set_scoring, srt, parameters = list(
      features = list(Endocrine = c("Gcg", "Sst"), Ductal = c("Krt19", "Krt8", "Epcam")),
      method = "Seurat", classification = FALSE, name = "X", slot = "data",
      assay = "RNA", BPPARAM = Serial, seed = 11))
  } else if (method == "trajectory-inference") {
    srt <- slice_cells(80)
    input_state <- serialize(srt, NULL)
    out <- run_case("Slingshot", env$run_trajectory_inference, srt, parameters = list(
      group.by = "CellType", reduction = "UMAP", dims = 1:2, show_plot = FALSE, seed = 11))
  } else if (method == "trajectory-inference-plot") {
    srt <- slice_cells(80)
    input_state <- serialize(srt, NULL)
    out <- run_case("Slingshot plot", env$run_trajectory_inference, srt, parameters = list(
      group.by = "CellType", reduction = "UMAP", dims = 1:2, show_plot = TRUE, seed = 11))
  } else if (method == "dynamic-feature-analysis") {
    srt <- slice_cells(80)
    srt$fixture_time <- rank(SeuratObject::Embeddings(srt, "PCA")[, 1]) / ncol(srt)
    input_state <- serialize(srt, NULL)
    out <- run_case("GAM dynamic features", env$run_dynamic_feature_analysis, srt, parameters = list(
      lineages = "fixture_time", features = c("Gcg", "Krt19"), slot = "data",
      n_candidates = NULL, BPPARAM = Serial, seed = 11))
  } else if (method == "reference-mapping") {
    ref <- Seurat::NormalizeData(pancreas_sub[, seq_len(300)], verbose = FALSE)
    qry <- Seurat::NormalizeData(pancreas_sub[, 301:400], verbose = FALSE)
    input_state <- serialize(list(qry, ref), NULL)
    out <- run_case("RunSeuratMap projection", env$run_reference_mapping, qry, ref, parameters = list(
      ref_pca = "PCA", ref_umap = "UMAP", ref_group = "CellType", ref_dims = 1:20,
      projection_method = "knn", k = 10, distance_metric = "cosine", vote_fun = "mean"))
  } else if (method == "reference-transfer") {
    ref <- Seurat::NormalizeData(pancreas_sub[, seq_len(300)], verbose = FALSE)
    qry <- Seurat::NormalizeData(pancreas_sub[, 301:400], verbose = FALSE)
    input_state <- serialize(list(qry, ref), NULL)
    res <- run_case("Seurat label transfer", env$run_reference_label_transfer, qry, ref, "CellType", dims = 1:20, k_weight = 50)
    checks <- list(
      one_prediction_per_query = is.data.frame(res$table) && nrow(res$table) == ncol(qry),
      required_columns = is.data.frame(res$table) &&
        all(c("cell_id", "predicted_id", "max_score", "margin") %in% colnames(res$table)),
      query_order_preserved = is.data.frame(res$table) && identical(res$table$cell_id, colnames(qry)),
      anchors_reported = is.numeric(res$anchors) && res$anchors > 0
    )
    if (!all(unlist(checks))) stop("label-transfer checks failed", call. = FALSE)
    jsonlite::write_json(list(method = "reference-transfer", state = "passed",
                              checks = checks, compared_at = format(Sys.time(), tz = "UTC", usetz = TRUE)),
                         file.path(dirname(out_file), "comparison.json"), auto_unbox = TRUE, pretty = TRUE)
    out <- list(result = res, diagnostics = list(upstream_function = "run_reference_label_transfer",
                                                  automatic_installation = FALSE, warnings = character()))
  } else if (method == "rna-velocity") {
    srt <- slice_cells(80)
    input_state <- serialize(srt, NULL)
    out <- run_case("scVelo", env$run_rna_velocity, srt, parameters = list(
      assay_X = "RNA", assay_layers = c("spliced", "unspliced"),
      group_by = "CellType", linear_reduction = "PCA"))
  } else if (method == "monocle2-core") {
    counts <- matrix(seq_len(20), nrow = 5,
                     dimnames = list(paste0("g", 1:5), paste0("c", 1:4)))
    metadata <- data.frame(cell_type = rep("A", 4), row.names = colnames(counts))
    input_state <- serialize(list(counts, metadata), NULL)
    out <- run_case("Monocle2 core", env$run_monocle2_core, counts, metadata,
                    features = rownames(counts), root_state = "1", seed = 11)
  } else if (method == "monocle3-core") {
    counts <- matrix(seq_len(20), nrow = 5,
                     dimnames = list(paste0("g", 1:5), paste0("c", 1:4)))
    metadata <- data.frame(cell_type = rep("A", 4), row.names = colnames(counts))
    reduced <- matrix(seq_len(8), nrow = 4,
                      dimnames = list(colnames(counts), c("UMAP_1", "UMAP_2")))
    input_state <- serialize(list(counts, metadata, reduced), NULL)
    out <- run_case("Monocle3 core", env$run_monocle3_core, counts, metadata,
                    reduced_dim = reduced, use_partition = TRUE, root_cells = colnames(counts)[1],
                    seed = 11)
  } else if (method == "monocle2-plot") {
    input_state <- serialize(NULL, NULL)
    stop("plot layer requires a monocle2 core result; monocle is not installed", call. = FALSE)
  } else if (method == "monocle3-plot") {
    input_state <- serialize(NULL, NULL)
    stop("plot layer requires a monocle3 core result; monocle3 is not installed", call. = FALSE)
  } else if (method == "monocle2") {
    srt <- slice_cells(80)
    input_state <- serialize(srt, NULL)
    out <- run_case("Monocle2 core+adapter with explicit root_state", env$run_trajectory_monocle2, srt,
                    parameters = list(seed = 11, root_state = "1"))
  } else if (method == "monocle3") {
    srt <- slice_cells(80)
    input_state <- serialize(srt, NULL)
    out <- run_case("Monocle3 core+adapter with explicit partition and root", env$run_trajectory_monocle3, srt,
                    parameters = list(seed = 11, use_partition = TRUE,
                                      root_cells = colnames(srt)[1]))
  } else {
    stop("unknown method")
  }
}, error = function(e) {
  state <<- "not_run"
  error <<- conditionMessage(e)
})

if (!is.null(input_state)) {
  current <- if (method %in% c("cell-type-annotation", "reference-mapping", "reference-transfer")) {
    serialize(list(qry, ref), NULL)
  } else if (method == "gene-set-enrichment") {
    serialize(list(gene_ids = gene_ids, TERM2GENE = term2gene, TERM2NAME = term2name), NULL)
  } else if (method == "monocle2-core") {
    serialize(list(counts, metadata), NULL)
  } else if (method == "monocle3-core") {
    serialize(list(counts, metadata, reduced), NULL)
  } else if (method %in% c("monocle2-plot", "monocle3-plot")) {
    serialize(NULL, NULL)
  } else {
    serialize(srt, NULL)
  }
  if (!identical(input_state, current)) stop("input object mutated by the module")
}
result <- list(method = method, state = state, error = error,
               input_unchanged = !is.null(input_state))
if (state == "passed") {
  res <- out$result
  if (inherits(res, "Seurat")) {
    result$seurat <- list(
      cells = colnames(res),
      meta = res[[]],
      reductions = names(res@reductions),
      embeddings = lapply(res@reductions, function(x) x@cell.embeddings)
    )
    result$tools <- lapply(res@tools, function(x) if (is.data.frame(x)) x else x)
  } else {
    result$raw <- res
  }
  result$diagnostics <- out$diagnostics[c("upstream_function", "automatic_installation", "warnings")]
}
saveRDS(result, out_file)
input_file <- sub("[.]rds$", "-input.rds", out_file)
if (!is.null(input_state)) writeBin(input_state, input_file)
jsonlite::write_json(list(
  method = method, state = state, error = error,
  input_unchanged = result$input_unchanged,
  command = command_line, script = script_path,
  code_dir = code_dir, fixture = fixture, out_file = out_file,
  input_file = input_file, case = case, code_sha256 = as.list(code_sha256),
  R_version = paste(R.version$major, R.version$minor, sep = "."),
  platform = R.version$platform,
  started_at = started_at,
  executed_at = format(Sys.time(), tz = "UTC", usetz = TRUE)
), sub("[.]rds$", ".json", out_file), auto_unbox = TRUE, pretty = TRUE)
cat(if (state == "passed") "PORTABILITY_PASS " else "PORTABILITY_NOT_RUN ", method,
    if (!is.null(error)) paste0(" :: ", error) else "", "\n", sep = "")
