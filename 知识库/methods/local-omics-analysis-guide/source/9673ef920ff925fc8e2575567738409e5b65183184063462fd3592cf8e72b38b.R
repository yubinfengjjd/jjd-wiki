#!/usr/bin/env Rscript

# scTenifoldKnk virtual knockout pipeline (Epithelial)
# - Auto-discover .RData/.rda in target directory
# - Prefer Seurat; otherwise accept genes x cells matrix (auto-transpose)
# - Subset Epithelial cells, build scGRN, run virtual KO
# - Export results + 4 panels (A–D) + combined panel

### SECTION:CONFIG
options(stringsAsFactors = FALSE, warn = 1)

args <- commandArgs(trailingOnly = TRUE)

guess_data_dir <- function() {
  cwd <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
  subs <- tryCatch(list.dirs(cwd, full.names = TRUE, recursive = FALSE), error = function(e) character())
  if (length(subs)) {
    b <- basename(subs)
    idx <- which(grepl("^16[.]20", b))
    if (length(idx)) return(subs[[idx[[1]]]])
  }
  file.path(cwd, "16.20种修饰量化")
}

cfg <- list(
  data_dir = guess_data_dir(),
  out_root = NULL, # default: <data_dir>/results_scTenifoldKnk
  cell_type = "Epithelial",
  ko_candidates = c("UBE2L6", "VDAC2", "SPI1"),
  seed = 2026L,
  downsample_if_gt = 8000L,
  downsample_to = 6000L,
  gene_limit = 8000L,
  # NOTE: scTenifoldKnk runtime scales steeply with gene count on Windows.
  # If you want the full 5k–7.5k gene run, increase this and expect a long runtime.
  target_genes_default = 3000L,
  max_attempts = 3L,
  min_sig_fdr_excl_ko = 3L
)

if (length(args) >= 1 && nzchar(args[[1]])) cfg$data_dir <- args[[1]]
if (length(args) >= 2 && nzchar(args[[2]])) cfg$out_root <- args[[2]]
if (length(args) >= 3 && nzchar(args[[3]])) cfg$ko_candidates <- strsplit(args[[3]], ",", fixed = TRUE)[[1]]
if (length(args) >= 4 && nzchar(args[[4]])) cfg$cell_type <- args[[4]]

cfg$data_dir <- normalizePath(cfg$data_dir, winslash = "/", mustWork = FALSE)
if (is.null(cfg$out_root) || !nzchar(cfg$out_root)) cfg$out_root <- file.path(cfg$data_dir, "results_scTenifoldKnk")
cfg$out_root <- normalizePath(cfg$out_root, winslash = "/", mustWork = FALSE)

dir.create(cfg$out_root, showWarnings = FALSE, recursive = TRUE)

now_tag <- format(Sys.time(), "%Y%m%d_%H%M%S")
tmp_log_dir <- file.path(cfg$out_root, "_logs")
dir.create(tmp_log_dir, showWarnings = FALSE, recursive = TRUE)
run_log_tmp <- file.path(tmp_log_dir, paste0("run_", now_tag, ".log"))

### SECTION:UTILS
log_msg <- function(...) {
  msg <- paste0("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] ", paste0(..., collapse = ""))
  cat(msg, "\n")
  cat(msg, "\n", file = run_log_tmp, append = TRUE)
}

time_it <- function(label, f) {
  t0 <- Sys.time()
  on.exit({
    dt <- difftime(Sys.time(), t0, units = "secs")
    log_msg(label, " took ", sprintf("%.1f", as.numeric(dt)), " s")
  }, add = TRUE)
  f()
}

write_lines_safe <- function(path, x) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  writeLines(x, con = path, useBytes = TRUE)
}

write_json_safe <- function(path, x) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  jsonlite::write_json(x, path = path, pretty = TRUE, auto_unbox = TRUE)
}

setup_local_lib <- function() {
  local_lib <- file.path(getwd(), ".tmp_libs", "R")
  dir.create(local_lib, showWarnings = FALSE, recursive = TRUE)
  .libPaths(c(local_lib, .libPaths()))
  invisible(local_lib)
}

install_if_missing <- function(pkgs) {
  for (p in pkgs) {
    if (!requireNamespace(p, quietly = TRUE)) {
      install.packages(p, repos = "https://cloud.r-project.org", dependencies = TRUE)
    }
  }
}

install_scTenifoldKnk <- function() {
  if (requireNamespace("scTenifoldKnk", quietly = TRUE)) return(TRUE)
  ok <- FALSE
  try({
    install.packages("scTenifoldKnk", repos = "https://cloud.r-project.org", dependencies = TRUE)
    ok <- requireNamespace("scTenifoldKnk", quietly = TRUE)
  }, silent = TRUE)
  if (ok) return(TRUE)

  install_if_missing(c("remotes"))
  try(remotes::install_github("cailab-tamu/scTenifoldKnk", upgrade = "never", dependencies = TRUE), silent = TRUE)
  requireNamespace("scTenifoldKnk", quietly = TRUE)
}

### SECTION:PKGS
time_it("Package install/load", function() {
  setup_local_lib()
  install_if_missing(c("jsonlite"))
  if (!install_scTenifoldKnk()) stop("Failed to install/load scTenifoldKnk (CRAN/GitHub).")
  install_if_missing(c("Matrix", "parallel", "ggplot2", "ggrepel", "patchwork", "scales"))
  suppressPackageStartupMessages({
    library(jsonlite)
    library(Matrix)
    library(parallel)
    library(ggplot2)
    library(ggrepel)
    library(patchwork)
    library(scales)
  })
})

log_msg("========== scTenifoldKnk pipeline started ==========")
log_msg("data_dir=", cfg$data_dir)
log_msg("out_root=", cfg$out_root)
log_msg("cell_type=", cfg$cell_type)
log_msg("ko_candidates=", paste(cfg$ko_candidates, collapse = ","))
log_msg("max_attempts=", cfg$max_attempts, " | min_sig_fdr_excl_ko=", cfg$min_sig_fdr_excl_ko)
log_msg(".libPaths: ", paste(.libPaths(), collapse = " | "))

if (!dir.exists(cfg$data_dir)) stop("Data directory does not exist: ", cfg$data_dir)

### SECTION:LOAD_INPUT
discover_rdata <- function(data_dir) {
  files <- list.files(data_dir, pattern = "[.](rdata|rda)$", full.names = TRUE, recursive = TRUE, ignore.case = TRUE)
  if (!length(files)) stop("No .RData/.rda found under: ", data_dir)
  info <- file.info(files)
  size <- as.numeric(info[["size"]])
  mtime <- as.numeric(info[["mtime"]])
  ord <- order(size, mtime, decreasing = TRUE, na.last = TRUE)
  files <- files[ord]
  size <- size[ord]
  mtime <- mtime[ord]

  if (length(files) > 1) {
    top_size <- size[[1]]
    idx <- which(size >= (0.98 * top_size))
    if (length(idx) > 1) {
      sub <- idx[which.max(mtime[idx])]
      files <- c(files[sub], files[-sub])
      size <- c(size[sub], size[-sub])
      mtime <- c(mtime[sub], mtime[-sub])
    }
  }

  list(files = files, size = size, mtime = mtime)
}

pick <- time_it("Discover RData", function() discover_rdata(cfg$data_dir))
log_msg("RData candidates (top 10):")
for (i in seq_len(min(10, length(pick$files)))) {
  log_msg("  ", i, ") ", pick$files[[i]], " | ", pick$size[[i]], " bytes | ",
          format(as.POSIXct(pick$mtime[[i]], origin = "1970-01-01", tz = "UTC"), "%Y-%m-%d %H:%M:%S"), " UTC")
}
target_rdata <- pick$files[[1]]
log_msg("Selected RData: ", target_rdata)

env <- new.env(parent = emptyenv())
obj_names <- time_it("Load RData", function() {
  load(target_rdata, envir = env)
  ls(env)
})
log_msg("Loaded objects: ", paste(obj_names, collapse = ", "))

is_seurat_obj <- function(x) inherits(x, "Seurat")

pick_seurat <- function(env, obj_names) {
  hits <- obj_names[vapply(obj_names, function(nm) is_seurat_obj(env[[nm]]), logical(1))]
  if (!length(hits)) return(list(name = NULL, obj = NULL))
  if ("UC" %in% hits) return(list(name = "UC", obj = env[["UC"]]))
  ncells <- vapply(hits, function(nm) {
    x <- env[[nm]]
    tryCatch(ncol(x), error = function(e) 0L)
  }, integer(1))
  nm <- hits[[which.max(ncells)]]
  list(name = nm, obj = env[[nm]])
}

pick_matrix <- function(env, obj_names, exclude = character()) {
  nms <- setdiff(obj_names, exclude)
  ok <- vapply(nms, function(nm) {
    x <- env[[nm]]
    inherits(x, "dgCMatrix") || is.matrix(x) || is.data.frame(x)
  }, logical(1))
  nms <- nms[ok]
  if (!length(nms)) return(list(name = NULL, mat = NULL))
  dims <- vapply(nms, function(nm) {
    x <- env[[nm]]
    if (is.data.frame(x)) x <- as.matrix(x)
    if (is.null(dim(x))) return(0)
    prod(dim(x))
  }, numeric(1))
  nm <- nms[[which.max(dims)]]
  list(name = nm, mat = env[[nm]])
}

seu <- pick_seurat(env, obj_names)
seurat_name <- seu$name
seurat_obj <- seu$obj

if (!is.null(seurat_obj)) {
  time_it("Load Seurat (on demand)", function() {
    install_if_missing(c("Seurat", "SeuratObject"))
    suppressPackageStartupMessages(library(Seurat))
  })
  log_msg("Using Seurat object: ", seurat_name, " (", nrow(seurat_obj), " genes x ", ncol(seurat_obj), " cells)")
}

find_celltype_column <- function(meta, target_label) {
  cols <- colnames(meta)
  priority <- c("celltype", "cell_type", "CellType", "annotation", "major_celltype", "major", "celltype_major",
                "celltypes", "cell.types", "cell_type1", "celltype1")
  cols2 <- unique(c(intersect(priority, cols), cols))

  best <- NULL
  best_n <- -1L
  for (col in cols2) {
    v <- meta[[col]]
    if (is.list(v) || is.matrix(v)) next
    if (is.numeric(v)) next
    v <- as.character(v)
    n <- sum(grepl(target_label, v, ignore.case = TRUE), na.rm = TRUE)
    if (n > best_n) {
      best <- col
      best_n <- n
    }
  }
  list(col = best, n_match = best_n)
}

extract_epithelial_from_seurat <- function(obj, target_label) {
  meta <- obj@meta.data
  hit <- find_celltype_column(meta, target_label)
  if (is.null(hit$col) || hit$n_match <= 0) {
    stop("Could not find meta.data column containing label: ", target_label,
         ". Available meta.data columns: ", paste(colnames(meta), collapse = ", "))
  }
  col <- hit$col
  v <- as.character(meta[[col]])
  keep <- grepl(target_label, v, ignore.case = TRUE)
  cells <- rownames(meta)[keep]
  if (!length(cells)) stop("Matched column but got 0 cells for label: ", target_label)
  log_msg("Celltype column selected: ", col, " | matched ", sum(keep), " cells")
  subset(obj, cells = cells)
}

as_dgC <- function(x) {
  if (inherits(x, "dgCMatrix")) return(x)
  if (is.data.frame(x)) x <- as.matrix(x)
  if (!is.matrix(x)) stop("Unsupported matrix type: ", paste(class(x), collapse = "/"))
  Matrix::Matrix(x, sparse = TRUE)
}

guess_genes_by_cells <- function(mat) {
  nr <- nrow(mat)
  nc <- ncol(mat)
  if (nr >= nc) return(TRUE)
  if (nc >= 2000 && nr <= 1000) return(FALSE)
  FALSE
}

extract_input <- function(seurat_obj, env, obj_names, cell_type_label) {
  if (!is.null(seurat_obj)) {
    obj_epi <- time_it("Subset Epithelial (Seurat)", function() extract_epithelial_from_seurat(seurat_obj, cell_type_label))
    assay <- if ("RNA" %in% Seurat::Assays(obj_epi)) "RNA" else Seurat::DefaultAssay(obj_epi)
    counts <- Seurat::GetAssayData(obj_epi, assay = assay, slot = "counts")
    counts <- as_dgC(counts)
    list(source = "Seurat", obj_epi = obj_epi, counts = counts)
  } else {
    mm <- pick_matrix(env, obj_names)
    if (is.null(mm$mat)) stop("No Seurat object and no matrix-like object found in loaded RData.")
    mat <- as_dgC(mm$mat)
    if (!guess_genes_by_cells(mat)) {
      log_msg("Matrix appears to be cells x genes; transposing to genes x cells.")
      mat <- Matrix::t(mat)
    }
    if (is.null(rownames(mat))) rownames(mat) <- paste0("G", seq_len(nrow(mat)))
    if (is.null(colnames(mat))) colnames(mat) <- paste0("C", seq_len(ncol(mat)))
    log_msg("Using matrix object: ", mm$name, " (", nrow(mat), " genes x ", ncol(mat), " cells)")
    list(source = "matrix", obj_epi = NULL, counts = mat)
  }
}

input <- extract_input(seurat_obj, env, obj_names, cfg$cell_type)
counts_all <- input$counts

### SECTION:PREP
is_integerish <- function(x) {
  if (inherits(x, "dgCMatrix")) {
    if (!length(x@x)) return(TRUE)
    return(all(abs(x@x - round(x@x)) < 1e-8) && all(x@x >= 0))
  }
  all(abs(x - round(x)) < 1e-8) && all(x >= 0)
}

is_raw_counts <- is_integerish(counts_all)
log_msg("Input appears raw counts: ", if (is_raw_counts) "TRUE" else "FALSE (treated as normalized)")

# Cell downsampling (reproducible)
set.seed(cfg$seed)
nCells0 <- ncol(counts_all)
if (nCells0 > cfg$downsample_if_gt) {
  keep_n <- as.integer(max(5000L, min(8000L, cfg$downsample_to)))
  keep_n <- min(keep_n, nCells0)
  keep <- sample(colnames(counts_all), size = keep_n, replace = FALSE)
  counts_all <- counts_all[, keep, drop = FALSE]
  log_msg("Downsampled cells: ", nCells0, " -> ", ncol(counts_all), " (seed=", cfg$seed, ")")
}

# Gene cleanup: remove all-zero, deduplicate (keep highest mean)
counts_all <- counts_all[Matrix::rowSums(counts_all) > 0, , drop = FALSE]
dup <- duplicated(rownames(counts_all))
if (any(dup)) {
  log_msg("Duplicated gene symbols detected: ", sum(dup), " (keeping highest mean-expr row per symbol)")
  rn <- rownames(counts_all)
  m <- Matrix::rowMeans(counts_all)
  ord <- order(rn, -m)
  counts_all <- counts_all[ord, , drop = FALSE]
  counts_all <- counts_all[!duplicated(rownames(counts_all)), , drop = FALSE]
}

# KO gene selection with case-insensitive match fallback
pick_ko_gene <- function(counts, candidates) {
  rn <- rownames(counts)
  rn_up <- toupper(rn)
  for (g in candidates) {
    g2 <- toupper(trimws(g))
    if (!nzchar(g2)) next
    hit <- which(rn_up == g2)
    if (length(hit)) return(rn[[hit[[1]]]])
  }
  # Last resort: choose a high-variance, reasonably expressed gene.
  m <- Matrix::rowMeans(counts)
  v <- Matrix::rowMeans(counts^2) - m^2
  ok <- which(m > stats::quantile(m, 0.5))
  if (!length(ok)) ok <- seq_len(nrow(counts))
  rn[[ok[[which.max(v[ok])]]]]
}

ko_gene <- pick_ko_gene(counts_all, cfg$ko_candidates)
if (!(ko_gene %in% rownames(counts_all))) stop("KO gene selection failed.")
if (!(toupper(ko_gene) %in% toupper(cfg$ko_candidates))) {
  log_msg("KO fallback selected from data: ", ko_gene, " (none of candidates found)")
} else {
  log_msg("KO gene selected: ", ko_gene)
}

# Dynamic qc_minCells and gene filtering
qc_minCells_dyn <- max(25L, as.integer(floor(0.005 * ncol(counts_all))))
qc_minCells_dyn <- min(200L, qc_minCells_dyn)
log_msg("qc_minCells (dynamic) = ", qc_minCells_dyn)

select_hvgs <- function(counts, target) {
  target <- as.integer(max(2000L, min(7500L, target)))
  target <- min(target, nrow(counts))
  lib <- Matrix::colSums(counts)
  sf <- stats::median(lib)
  norm <- t(t(counts) / pmax(lib, 1) * sf)
  norm <- log1p(norm * 1e4)
  m <- Matrix::rowMeans(norm)
  v <- Matrix::rowMeans(norm^2) - m^2
  score <- v / (m + 1e-6)
  ord <- order(score, decreasing = TRUE)
  rownames(counts)[ord[seq_len(target)]]
}

filter_and_select_genes <- function(counts, ko_gene, qc_minCells, gene_limit, target_genes) {
  nGenes <- nrow(counts)
  if (nGenes <= gene_limit) {
    genes <- rownames(counts)
    if (!is.null(ko_gene) && ko_gene %in% genes) genes <- union(ko_gene, genes)
    return(list(genes = genes, strategy = "no_filter"))
  }

  log_msg("nGenes=", nGenes, " > ", gene_limit, ": applying low-expression filter + HVG selection")
  keep <- Matrix::rowSums(counts > 0) >= qc_minCells
  counts2 <- counts[keep, , drop = FALSE]
  log_msg("After low-expression filter (>=", qc_minCells, " cells): ", nrow(counts2), " genes")
  hvgs <- select_hvgs(counts2, target = target_genes)
  genes <- hvgs
  if (!is.null(ko_gene) && ko_gene %in% rownames(counts)) genes <- union(ko_gene, genes)
  list(genes = genes, strategy = paste0("lowExpr>=", qc_minCells, "+HVG_", min(length(genes), 7500L)))
}

gene_sel <- time_it("Gene filtering/HVG", function() {
  filter_and_select_genes(
    counts = counts_all,
    ko_gene = ko_gene,
    qc_minCells = qc_minCells_dyn,
    gene_limit = cfg$gene_limit,
    target_genes = cfg$target_genes_default
  )
})

analysis_genes <- gene_sel$genes
log_msg("Gene selection strategy: ", gene_sel$strategy)
log_msg("Analysis genes: ", length(analysis_genes))

counts <- counts_all[analysis_genes, , drop = FALSE]
counts <- counts[Matrix::rowSums(counts) > 0, , drop = FALSE]

compute_meanExpr <- function(seurat_epi, counts_mat) {
  if (!is.null(seurat_epi)) {
    assay <- if ("RNA" %in% Seurat::Assays(seurat_epi)) "RNA" else Seurat::DefaultAssay(seurat_epi)
    data_mat <- Seurat::GetAssayData(seurat_epi, assay = assay, slot = "data")
    if (!inherits(data_mat, "dgCMatrix")) data_mat <- as_dgC(data_mat)
    if (!length(data_mat@x)) {
      seurat_epi <- Seurat::NormalizeData(seurat_epi, verbose = FALSE)
      data_mat <- Seurat::GetAssayData(seurat_epi, assay = assay, slot = "data")
      if (!inherits(data_mat, "dgCMatrix")) data_mat <- as_dgC(data_mat)
    }
    data_mat <- data_mat[rownames(counts_mat), colnames(counts_mat), drop = FALSE]
    Matrix::rowMeans(data_mat)
  } else {
    lib <- Matrix::colSums(counts_mat)
    sf <- stats::median(lib)
    norm <- t(t(counts_mat) / pmax(lib, 1) * sf)
    norm <- log1p(norm * 1e4)
    Matrix::rowMeans(norm)
  }
}

meanExpr <- time_it("Compute mean expression", function() compute_meanExpr(input$obj_epi, counts))
meanExpr[is.na(meanExpr)] <- 0

# Output directory layout (requested)
out_dir <- file.path(cfg$out_root, cfg$cell_type, paste0("KO_", ko_gene))
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
run_log_final <- file.path(out_dir, "run.log")
invisible(file.copy(run_log_tmp, run_log_final, overwrite = TRUE))
log_msg("Final output dir: ", out_dir)

nnz <- length(counts@x)
log_msg("Epithelial subset matrix: nCells=", ncol(counts), " | nGenes=", nrow(counts), " | sparsity=",
        sprintf("%.4f", 1 - (nnz / (ncol(counts) * nrow(counts)))))

### SECTION:RUN
# Parameters (official defaults + requested micro-tuning)
nCells <- ncol(counts)
nGenes <- nrow(counts)

qc_minLSize_auto <- if (is_raw_counts) 1000L else 0L
qc_mtThreshold_auto <- 0.1
qc_diag <- list()
if (is_raw_counts) {
  lib <- Matrix::colSums(counts)
  qc_diag$libSize_quantiles <- as.numeric(stats::quantile(lib, probs = c(0.01, 0.05, 0.1, 0.25, 0.5, 0.9, 0.95, 0.99), na.rm = TRUE))
  names(qc_diag$libSize_quantiles) <- c("p01", "p05", "p10", "p25", "p50", "p90", "p95", "p99")
  qc_minLSize_auto <- as.integer(max(200, min(1000, floor(stats::quantile(lib, 0.1, na.rm = TRUE)))))

  mt_genes <- grep("^(MT-|mt-)", rownames(counts), value = TRUE)
  if (length(mt_genes)) {
    mt_pct <- Matrix::colSums(counts[mt_genes, , drop = FALSE]) / pmax(lib, 1)
    qc_diag$mtPct_quantiles <- as.numeric(stats::quantile(mt_pct, probs = c(0.5, 0.9, 0.95, 0.99), na.rm = TRUE))
    names(qc_diag$mtPct_quantiles) <- c("p50", "p90", "p95", "p99")
    qc_mtThreshold_auto <- as.numeric(max(0.1, min(0.25, stats::quantile(mt_pct, 0.95, na.rm = TRUE))))
  } else {
    qc_diag$mtPct_quantiles <- NULL
  }
}
log_msg("Auto QC thresholds (used when qc=TRUE): qc_minLSize=", qc_minLSize_auto, " | qc_mtThreshold=", sprintf("%.3f", qc_mtThreshold_auto))

base_params <- list(
  qc = is_raw_counts,
  qc_mtThreshold = qc_mtThreshold_auto,
  qc_minLSize = qc_minLSize_auto,
  qc_minCells = qc_minCells_dyn,
  nc_lambda = 0,
  # Start from official defaults; only increase in later attempts if needed.
  nc_nNet = 5,
  nc_nCells = min(400L, nCells),
  nc_nComp = if (nGenes >= 4000) 5 else 3,
  nc_scaleScores = TRUE,
  nc_symmetric = FALSE,
  nc_q = 0.9,
  td_K = 3,
  td_maxIter = 1000,
  td_maxError = 1e-05,
  td_nDecimal = 3,
  ma_nDim = 2,
  # Cap worker count on Windows to avoid oversubscription / instability.
  nCores = max(1L, min(parallel::detectCores() - 1L, 8L))
)

params_record <- list(
  timestamp = now_tag,
  input_file = target_rdata,
  objects = obj_names,
  used_object = if (!is.null(seurat_name)) seurat_name else "matrix",
  cell_type = cfg$cell_type,
  ko_gene = ko_gene,
  ko_candidates = cfg$ko_candidates,
  nCells = nCells,
  nGenes = nGenes,
  sparsity = as.numeric(1 - (nnz / (nCells * nGenes))),
  is_raw_counts = is_raw_counts,
  gene_selection_strategy = gene_sel$strategy,
  qc_minCells_dyn = qc_minCells_dyn,
  qc_auto = list(
    qc_minLSize_auto = qc_minLSize_auto,
    qc_mtThreshold_auto = qc_mtThreshold_auto,
    diagnostics = qc_diag
  ),
  params = base_params,
  references = list(
    cran_refman = "https://cran.r-project.org/web/packages/scTenifoldKnk/refman/scTenifoldKnk.html",
    github_repo = "https://github.com/cailab-tamu/scTenifoldKnk",
    paper = "Osorio D et al. Patterns (N Y). 2022;3(3):100434. doi:10.1016/j.patter.2022.100434."
  )
)
write_json_safe(file.path(out_dir, "params.json"), params_record)

run_knk <- function(params_local) {
  params_call <- params_local
  nc_q <- params_call$nc_q
  params_call$nc_q <- NULL
  do.call(scTenifoldKnk::scTenifoldKnk, c(list(countMatrix = counts, gKO = ko_gene), params_call, list(nc_q = nc_q)))
}

estimate_density <- function(net) {
  if (is.null(net) || is.null(dim(net))) return(NA_real_)
  if (inherits(net, "dgCMatrix")) {
    nnz0 <- length(net@x)
    p <- nrow(net)
    denom <- max(1, p * p - p)
    return(nnz0 / denom)
  }
  p <- nrow(net)
  denom <- max(1, p * p - p)
  sum(net != 0) / denom
}

try_adjust_nc_q <- function(res, params_local) {
  tn <- res$tensorNetworks
  if (is.null(tn)) return(list(res = res, params = params_local, adjusted = FALSE, density = NA_real_))
  net0 <- NULL
  if (is.list(tn) && ("WT" %in% names(tn)) && is.list(tn$WT) && length(tn$WT) >= 1) net0 <- tn$WT[[1]]
  if (is.null(net0) && is.list(tn) && length(tn) >= 1) net0 <- tn[[1]]
  dens <- estimate_density(net0)
  if (is.na(dens)) return(list(res = res, params = params_local, adjusted = FALSE, density = dens))

  if (dens < 0.001 && params_local$nc_q > 0.85) {
    params2 <- params_local
    params2$nc_q <- 0.85
    log_msg("Network too sparse (density=", sprintf("%.4f", dens), "); re-running with nc_q=0.85")
    res2 <- time_it("Re-run scTenifoldKnk (nc_q adjust)", function() run_knk(params2))
    return(list(res = res2, params = params2, adjusted = TRUE, density = dens))
  }
  list(res = res, params = params_local, adjusted = FALSE, density = dens)
}

normalize_diffreg <- function(df0) {
  if (is.null(df0) || !nrow(df0)) stop("diffRegulation missing or empty")
  cn <- colnames(df0)
  colnames(df0) <- tolower(cn)
  if (!("gene" %in% colnames(df0))) {
    hit <- intersect(c("genes", "symbol", "genename"), colnames(df0))
    if (length(hit)) df0$gene <- df0[[hit[[1]]]]
  }
  if (!("p.value" %in% colnames(df0))) {
    hit <- intersect(c("pvalue", "pval", "p_val"), colnames(df0))
    if (length(hit)) df0$`p.value` <- df0[[hit[[1]]]]
  }
  if (!("p.adj" %in% colnames(df0))) {
    hit <- intersect(c("padj", "p_adj", "fdr", "qvalue", "q_value"), colnames(df0))
    if (length(hit)) df0$`p.adj` <- df0[[hit[[1]]]]
  }
  if (!("distance" %in% colnames(df0))) {
    hit <- intersect(c("dist", "delta", "perturbation"), colnames(df0))
    if (length(hit)) df0$distance <- df0[[hit[[1]]]]
  }
  need <- c("gene", "distance", "fc", "p.value")
  miss <- setdiff(need, colnames(df0))
  if (length(miss)) stop("diffRegulation missing required columns: ", paste(miss, collapse = ","))
  df0$gene <- as.character(df0$gene)
  df0$distance <- as.numeric(df0$distance)
  df0$fc <- as.numeric(df0$fc)
  df0$`p.value` <- as.numeric(df0$`p.value`)
  if (!("p.adj" %in% colnames(df0)) || all(!is.finite(df0$`p.adj`))) {
    df0$`p.adj` <- p.adjust(df0$`p.value`, method = "BH")
  } else {
    df0$`p.adj` <- as.numeric(df0$`p.adj`)
    bad <- which(!is.finite(df0$`p.adj`))
    if (length(bad)) df0$`p.adj`[bad] <- p.adjust(df0$`p.value`[bad], method = "BH")
  }
  df0
}

evaluate_quality <- function(df0, ko) {
  n_fdr <- sum(df0$`p.adj` < 0.05, na.rm = TRUE)
  n_fdr_ex <- sum(df0$`p.adj` < 0.05 & (df0$gene != ko), na.rm = TRUE)
  list(n_sig_fdr = n_fdr, n_sig_fdr_excl_ko = n_fdr_ex)
}

res_cache_path <- file.path(out_dir, "scTenifoldKnk_result.rds")
reuse_cached <- file.exists(res_cache_path)

attempts_dir <- file.path(out_dir, "attempts")
dir.create(attempts_dir, showWarnings = FALSE, recursive = TRUE)

best <- list(score = -Inf, attempt = NA_integer_, res = NULL, df0 = NULL, params = NULL, adj = NULL, quality = NULL)

if (reuse_cached) {
  log_msg("Found cached result: ", res_cache_path, " (reusing; delete this file to force rerun)")
  res_try <- readRDS(res_cache_path)
  df_try <- normalize_diffreg(res_try$diffRegulation)
  q_try <- evaluate_quality(df_try, ko_gene)
  log_msg("Cached quality: n_sig_fdr=", q_try$n_sig_fdr, " | n_sig_fdr_excl_ko=", q_try$n_sig_fdr_excl_ko)
  best <- list(score = q_try$n_sig_fdr_excl_ko, attempt = 0L, res = res_try, df0 = df_try,
               params = base_params, adj = list(adjusted = FALSE, density = NA_real_), quality = q_try)
} else {
  attempt_params <- vector("list", length = cfg$max_attempts)
  attempt_params[[1]] <- base_params
  if (cfg$max_attempts >= 2L) {
    p2 <- base_params
    p2$nc_q <- 0.85
    if (nCells >= 3000) {
      p2$nc_nNet <- max(p2$nc_nNet, 8L)
      p2$nc_nCells <- max(p2$nc_nCells, min(500L, nCells))
    } else {
      p2$nc_nNet <- max(p2$nc_nNet, 6L)
      p2$nc_nCells <- max(p2$nc_nCells, min(450L, nCells))
    }
    attempt_params[[2]] <- p2
  }
  if (cfg$max_attempts >= 3L) {
    p3 <- attempt_params[[2]]
    if (is.null(p3)) p3 <- base_params
    p3$nc_nNet <- max(p3$nc_nNet, 10L)
    p3$nc_nCells <- max(p3$nc_nCells, min(600L, nCells))
    p3$td_maxIter <- max(p3$td_maxIter, 1500L)
    attempt_params[[3]] <- p3
  }

  for (i in seq_len(cfg$max_attempts)) {
    p_try <- attempt_params[[i]]
    if (is.null(p_try)) next
    log_msg("---- Attempt ", i, "/", cfg$max_attempts, " params: nc_q=", p_try$nc_q,
            ", nc_nNet=", p_try$nc_nNet, ", nc_nCells=", p_try$nc_nCells, ", nc_nComp=", p_try$nc_nComp,
            ", td_maxIter=", p_try$td_maxIter, ", nCores=", p_try$nCores, " ----")

    set.seed(cfg$seed)
    res_try <- time_it(paste0("Run scTenifoldKnk (attempt ", i, ")"), function() run_knk(p_try))
    adj_try <- try_adjust_nc_q(res_try, p_try)
    res_try <- adj_try$res
    p_try <- adj_try$params

    df_try <- normalize_diffreg(res_try$diffRegulation)
    q_try <- evaluate_quality(df_try, ko_gene)
    log_msg("Attempt ", i, " quality: n_sig_fdr=", q_try$n_sig_fdr, " | n_sig_fdr_excl_ko=", q_try$n_sig_fdr_excl_ko)

    attempt_dir <- file.path(attempts_dir, paste0("attempt_", i))
    dir.create(attempt_dir, showWarnings = FALSE, recursive = TRUE)
    saveRDS(res_try, file.path(attempt_dir, "scTenifoldKnk_result.rds"))
    write.csv(df_try, file.path(attempt_dir, "diffRegulation.csv"), row.names = FALSE)
    write_json_safe(file.path(attempt_dir, "params.json"), modifyList(params_record, list(
      attempt = i,
      params = p_try,
      nc_q_auto_adjusted = adj_try$adjusted,
      network_density_estimate = adj_try$density,
      quality = q_try
    )))

    score <- q_try$n_sig_fdr_excl_ko
    if (is.finite(score) && score > best$score) {
      best <- list(score = score, attempt = i, res = res_try, df0 = df_try, params = p_try, adj = adj_try, quality = q_try)
    }
    if (q_try$n_sig_fdr_excl_ko >= cfg$min_sig_fdr_excl_ko) {
      log_msg("Stopping early: achieved n_sig_fdr_excl_ko >= ", cfg$min_sig_fdr_excl_ko)
      break
    }
  }
}

if (is.null(best$res) || is.null(best$df0)) stop("All attempts failed to produce a valid diffRegulation table.")
res <- best$res
df0 <- best$df0
params_best <- best$params

params_record$params <- params_best
params_record$chosen_attempt <- best$attempt
params_record$nc_q_auto_adjusted <- best$adj$adjusted
params_record$network_density_estimate <- best$adj$density
params_record$quality <- best$quality
write_json_safe(file.path(out_dir, "params.json"), params_record)

saveRDS(res, file.path(out_dir, "scTenifoldKnk_result.rds"))

df <- data.frame(
  gene = df0$gene,
  distance = df0$distance,
  FC = df0$fc,
  p.value = df0$`p.value`,
  p.adj = df0$`p.adj`,
  stringsAsFactors = FALSE
)
df$log2FC <- log2(df$FC)
df$perturb_mag <- df$distance
df$log2Perturb <- log2(df$distance + 1e-300)
df$sig_p <- df$p.value < 0.05
df$sig_fdr <- df$p.adj < 0.05
df$meanExpr <- meanExpr[df$gene]
df$meanExpr[is.na(df$meanExpr)] <- 0
df$sig_used <- df$sig_fdr

write.csv(df, file.path(out_dir, "diffRegulation.csv"), row.names = FALSE)

### SECTION:EXPORT
sig_used <- "p.adj"
log_msg("Significance used for plots: ", sig_used, " < 0.05 (both p.value and p.adj computed)")
log_msg("Chosen attempt: ", best$attempt, " | n_sig_fdr_excl_ko=", best$quality$n_sig_fdr_excl_ko)

# Top genes definitions
sig_df <- df[isTRUE(df$sig_used) | (is.logical(df$sig_used) & df$sig_used), , drop = FALSE]
sig_df <- sig_df[is.finite(sig_df$log2FC) & is.finite(sig_df$distance) & is.finite(sig_df$p.value) & is.finite(sig_df$p.adj), , drop = FALSE]
sig_df <- sig_df[order(-abs(sig_df$log2FC), sig_df$p.adj), , drop = FALSE]

top20_a <- sig_df[seq_len(min(20, nrow(sig_df))), , drop = FALSE]
if (nrow(top20_a) < 20) {
  need <- 20 - nrow(top20_a)
  rest <- df[!(df$gene %in% top20_a$gene), , drop = FALSE]
  rest <- rest[order(rest$p.value, -abs(rest$log2FC)), , drop = FALSE]
  top20_a <- rbind(top20_a, rest[seq_len(min(need, nrow(rest))), , drop = FALSE])
}

top20_d <- sig_df[seq_len(min(20, nrow(sig_df))), , drop = FALSE]
if (nrow(top20_d) < 20) {
  need <- 20 - nrow(top20_d)
  rest <- df[!(df$gene %in% top20_d$gene), , drop = FALSE]
  rest <- rest[order(rest$p.value, -rest$distance), , drop = FALSE]
  top20_d <- rbind(top20_d, rest[seq_len(min(need, nrow(rest))), , drop = FALSE])
}

top20_out <- top20_a[, c("gene", "log2FC", "distance", "p.value", "p.adj", "meanExpr")]
write.csv(top20_out, file.path(out_dir, "top20_table.csv"), row.names = FALSE)

# Panel styling (top-journal minimalist)
base_family <- if (.Platform$OS.type == "windows") "Arial" else "sans"
accent <- "#D55E00"      # low-sat orange-red
bg_grey <- "#D0D0D0"
line_grey <- "#8A8A8A"
loess_col <- "#2C4E7D"

theme_paper <- theme_bw(base_family = base_family) + theme(
  panel.grid.minor = element_blank(),
  panel.grid.major = element_line(linewidth = 0.25, color = "#E6E6E6"),
  axis.text = element_text(size = 10, color = "black"),
  axis.title = element_text(size = 11, color = "black"),
  plot.title = element_text(size = 13, face = "bold", hjust = 0),
  plot.subtitle = element_text(size = 10, hjust = 0),
  legend.title = element_text(size = 10),
  legend.text = element_text(size = 9),
  plot.margin = margin(6, 8, 6, 8)
)

save_fig <- function(p, path_pdf, path_png, w, h) {
  dir.create(dirname(path_pdf), showWarnings = FALSE, recursive = TRUE)
  ok_pdf <- FALSE
  if (capabilities("cairo")) {
    try({
      ggplot2::ggsave(path_pdf, plot = p, width = w, height = h, units = "in", device = grDevices::cairo_pdf)
      ok_pdf <- TRUE
    }, silent = TRUE)
  }
  if (!ok_pdf) ggplot2::ggsave(path_pdf, plot = p, width = w, height = h, units = "in")
  ggplot2::ggsave(path_png, plot = p, width = w, height = h, units = "in", dpi = 600, bg = "white")
}

# Panel A: Top 20 Differentially Regulated Genes
top20_a$lab <- sprintf("%.2f", top20_a$log2FC)
sig_label <- paste0(sig_used, "<0.05")
top20_a$fill_sig <- ifelse(top20_a$sig_used, sig_label, "Not significant")
fill_vals <- setNames(c(bg_grey, accent), c("Not significant", sig_label))
pA <- ggplot(top20_a, aes(x = log2FC, y = reorder(gene, log2FC))) +
  geom_col(aes(fill = fill_sig), width = 0.72) +
  geom_vline(xintercept = 0, linewidth = 0.3, color = line_grey) +
  geom_text(aes(label = lab), hjust = ifelse(top20_a$log2FC >= 0, -0.1, 1.1), size = 3.0, color = "black") +
  scale_fill_manual(values = fill_vals, name = NULL) +
  scale_x_continuous(expand = expansion(mult = c(0.05, 0.15))) +
  theme_paper +
  labs(
    title = "Top 20 Differentially Regulated Genes",
    subtitle = paste0("KO gene: ", ko_gene),
    x = "log2(FC)",
    y = NULL
  )

# Label genes for B/C (multi-criteria)
df$score_lab <- (-log10(df$p.value + 1e-300)) * (abs(df$log2FC) + 0.1)
top_lab <- df[order(df$score_lab, decreasing = TRUE), , drop = FALSE]
top_lab <- top_lab[seq_len(min(10, nrow(top_lab))), , drop = FALSE]
if (!(ko_gene %in% top_lab$gene) && (ko_gene %in% df$gene)) {
  top_lab <- unique(rbind(df[df$gene == ko_gene, , drop = FALSE], top_lab))
}

# Panel B: Virtual Gene Perturbation Analysis
df$pert_cat <- "Not significant"
sig_mask <- as.logical(df$sig_used)
if (any(sig_mask, na.rm = TRUE)) {
  q90 <- as.numeric(stats::quantile(df$distance[sig_mask], 0.9, na.rm = TRUE))
  df$pert_cat[sig_mask] <- "Medium"
  df$pert_cat[sig_mask & (df$distance >= q90)] <- "High"
}
df$pert_cat <- factor(df$pert_cat, levels = c("High", "Medium", "Not significant"))

pB <- ggplot(df, aes(x = log2Perturb, y = -log10(p.value + 1e-300))) +
  geom_point(aes(color = pert_cat), alpha = 0.65, size = 1.25) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", linewidth = 0.35, color = line_grey) +
  ggrepel::geom_text_repel(
    data = top_lab,
    aes(label = gene),
    size = 3.0,
    box.padding = 0.25,
    point.padding = 0.15,
    max.overlaps = 30,
    seed = cfg$seed
  ) +
  scale_color_manual(values = c("High" = accent, "Medium" = "#E69F00", "Not significant" = bg_grey), drop = FALSE) +
  theme_paper +
  labs(
    title = "Virtual Gene Perturbation Analysis",
    subtitle = paste0("KO gene: ", ko_gene, " | sig=", sig_used, "<0.05"),
    x = "log2(distance)",
    y = "-log10(p.value)",
    color = "Perturbation"
  ) +
  theme(legend.position = "right")

# Panel C: Perturbation Magnitude vs Mean Expression
pC_bins <- 5L
bin_by_quantile <- function(x, n = 5L) {
  x <- as.numeric(x)
  probs <- seq(0, 1, length.out = n + 1L)
  br <- as.numeric(stats::quantile(x, probs = probs, na.rm = TRUE, type = 7))
  br <- unique(br)
  if (length(br) < 3L) {
    return(factor(rep("Bin 1", length(x)), levels = "Bin 1"))
  }
  labs <- paste0("Bin ", seq_len(length(br) - 1L))
  cut(x, breaks = br, include.lowest = TRUE, labels = labs, right = TRUE)
}

df$meanExpr_bin <- bin_by_quantile(df$meanExpr, n = pC_bins)
bin_levels <- levels(df$meanExpr_bin)
size_vals <- setNames(seq(0.7, 2.8, length.out = length(bin_levels)), bin_levels)

pC <- ggplot(df, aes(x = log(meanExpr + 1), y = log2Perturb)) +
  geom_point(aes(color = sig_used, size = meanExpr_bin), alpha = 0.55) +
  scale_color_manual(values = c("TRUE" = accent, "FALSE" = bg_grey),
                     labels = c("FALSE" = "Not significant", "TRUE" = paste0(sig_used, "<0.05"))) +
  scale_size_manual(values = size_vals, name = "Mean expression") +
  geom_smooth(method = "loess", color = loess_col, linewidth = 0.9, se = TRUE) +
  ggrepel::geom_text_repel(
    data = top_lab,
    aes(label = gene),
    size = 3.0,
    box.padding = 0.25,
    point.padding = 0.15,
    max.overlaps = 30,
    seed = cfg$seed
  ) +
  theme_paper +
  labs(
    title = "Perturbation Magnitude vs Mean Expression",
    x = "log(meanExpr + 1)",
    y = "log2(distance)",
    color = "Significance"
  )

# Panel D: Top Perturbed Genes (bubble)
top20_d$size_val <- -log10(top20_d$p.adj + 1e-300)
pD <- ggplot(top20_d, aes(x = log2FC, y = reorder(gene, log2FC))) +
  geom_point(aes(size = size_val, color = log2FC), alpha = 0.85) +
  scale_size_continuous(name = "-log10(FDR)", range = c(1.5, 6.0)) +
  scale_color_gradient2(low = "#2C4E7D", mid = "#F7F7F7", high = accent, midpoint = 0, name = "log2FC") +
  theme_paper +
  labs(
    title = "Top Perturbed Genes",
    subtitle = paste0("KO: ", ko_gene),
    x = "log2(FC)",
    y = NULL
  )

combined <- (pA | pB) / (pC | pD) +
  patchwork::plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(face = "bold", size = 16, family = base_family))

time_it("Save figures", function() {
  save_fig(pA, file.path(out_dir, "Panel_A.pdf"), file.path(out_dir, "Panel_A.png"), w = 7.0, h = 6.0)
  save_fig(pB, file.path(out_dir, "Panel_B.pdf"), file.path(out_dir, "Panel_B.png"), w = 7.0, h = 6.0)
  save_fig(pC, file.path(out_dir, "Panel_C.pdf"), file.path(out_dir, "Panel_C.png"), w = 7.0, h = 6.0)
  save_fig(pD, file.path(out_dir, "Panel_D.pdf"), file.path(out_dir, "Panel_D.png"), w = 7.0, h = 6.0)
  save_fig(combined, file.path(out_dir, "combined_panel.pdf"), file.path(out_dir, "combined_panel.png"), w = 14.0, h = 12.0)
})

write_lines_safe(file.path(out_dir, "sessionInfo.txt"), capture.output(sessionInfo()))

# Biological sanity checks (logged)
epi_markers <- c("EPCAM", "KRT8", "KRT18", "KRT19", "MUC1", "ALDH1A1")
imm_markers <- c("PTPRC", "CD3E", "NKG7", "MS4A1", "LYZ")
top_genes <- unique(c(as.character(top20_a$gene), as.character(top20_d$gene)))
hit_epi <- intersect(epi_markers, top_genes)
hit_imm <- intersect(imm_markers, top_genes)
if (length(hit_epi)) log_msg("Sanity: epithelial markers in Top genes: ", paste(hit_epi, collapse = ","))
if (length(hit_imm)) log_msg("Sanity WARNING: immune markers in Top genes: ", paste(hit_imm, collapse = ","))

# Print Top20 in log
log_msg("Top20 table (gene, log2FC, distance, p.value, p.adj, meanExpr):")
for (i in seq_len(nrow(top20_out))) {
  r <- top20_out[i, ]
  log_msg("  ", i, ") ", r$gene,
          " | ", sprintf("%.3f", r$log2FC),
          " | ", sprintf("%.3g", r$distance),
          " | p=", sprintf("%.3g", r$p.value),
          " | padj=", sprintf("%.3g", r$p.adj),
          " | meanExpr=", sprintf("%.3f", r$meanExpr))
}

# Output directory tree
files_out <- list.files(out_dir, recursive = TRUE, all.files = FALSE)
log_msg("Output files (relative):")
for (f in files_out) log_msg("  - ", f)

invisible(file.copy(run_log_tmp, run_log_final, overwrite = TRUE))

cat("\n========== DONE ==========\n")
cat("Output dir:", out_dir, "\n")
cat("KO gene:", ko_gene, "\n")
