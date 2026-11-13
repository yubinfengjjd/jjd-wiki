# Minimal runtime module extracted from SCP-local 0.5.6 (GPL (>= 3)).
# Source: https://github.com/zhanghao-njmu/SCP commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
# Roots: RunSingleR
# Functions: RunSingleR, check_DataType, check_R
# Score-vector names are removed before Seurat metadata assignment; numeric
# values and positional order remain those returned by the pinned algorithm.
# Automatic installation is disabled by the caller. Local resources are loaded only by the caller.

# ---- SCP-cell_annotation.R:655-787 : RunSingleR ----
RunSingleR <- function(srt_query, srt_ref, query_group = NULL, ref_group = NULL,
                       query_assay = "RNA", ref_assay = "RNA",
                       genes = "de", de.method = "wilcox", sd.thresh = 1, de.n = NULL,
                       aggr.ref = FALSE, aggr.args = list(),
                       quantile = 0.8, fine.tune = TRUE, tune.thresh = 0.05, prune = TRUE,
                       BPPARAM = BiocParallel::bpparam()) {
  check_R("SingleR")
  if (!is.null(ref_group)) {
    if (length(ref_group) == ncol(srt_ref)) {
      srt_ref[["ref_group"]] <- ref_group
    } else if (length(ref_group) == 1) {
      if (!ref_group %in% colnames(srt_ref@meta.data)) {
        stop("ref_group must be one of the column names in the meta.data")
      } else {
        srt_ref[["ref_group"]] <- srt_ref[[ref_group]]
      }
    } else {
      stop("Length of ref_group must be one or length of srt_ref.")
    }
    ref_group <- "ref_group"
  } else {
    stop("'ref_group' must be provided.")
  }
  if (!is.null(query_group)) {
    if (length(query_group) == ncol(srt_query)) {
      srt_query[["query_group"]] <- query_group
    } else if (length(query_group) == 1) {
      if (!query_group %in% colnames(srt_query@meta.data)) {
        stop("query_group must be one of the column names in the meta.data")
      } else {
        srt_query[["query_group"]] <- srt_query[[query_group]]
      }
    } else {
      stop("Length of query_group must be one or length of srt_query.")
    }
    query_group <- "query_group"
    method <- "SingleRCluster"
  } else {
    method <- "SingleRCell"
  }

  status_query <- check_DataType(data = GetAssayData(srt_query, slot = "data", assay = query_assay))
  message("Detected srt_query data type: ", status_query)
  status_ref <- check_DataType(data = GetAssayData(srt_ref, slot = "data", assay = ref_assay))
  message("Detected srt_ref data type: ", status_ref)
  if (status_ref != status_query || any(status_query == "unknown", status_ref == "unknown")) {
    warning("Data type is unknown or different between query and ref.", immediate. = TRUE)
  }

  assays_query <- list(
    counts = GetAssayData(object = srt_query, assay = query_assay, slot = "counts"),
    logcounts = GetAssayData(object = srt_query, assay = query_assay, slot = "data")
  )
  sce_query <- as(SummarizedExperiment::SummarizedExperiment(assays = assays_query), Class = "SingleCellExperiment")
  metadata_query <- srt_query[[]]
  SummarizedExperiment::colData(x = sce_query) <- S4Vectors::DataFrame(metadata_query)

  assays_ref <- list(
    counts = GetAssayData(object = srt_ref, assay = ref_assay, slot = "counts"),
    logcounts = GetAssayData(object = srt_ref, assay = ref_assay, slot = "data")
  )
  sce_ref <- as(SummarizedExperiment::SummarizedExperiment(assays = assays_ref), Class = "SingleCellExperiment")
  metadata_ref <- srt_ref[[]]
  SummarizedExperiment::colData(x = sce_ref) <- S4Vectors::DataFrame(metadata_ref)

  if (method == "SingleRCluster") {
    message("Perform ", method, " on the data...")
    SingleRCluster_results <- SingleR::SingleR(
      test = sce_query,
      ref = sce_ref,
      labels = factor(SummarizedExperiment::colData(sce_ref)[[ref_group]]),
      clusters = factor(SummarizedExperiment::colData(sce_query)[[query_group]]),
      de.method = de.method, genes = genes, sd.thresh = sd.thresh, de.n = de.n,
      aggr.ref = aggr.ref, aggr.args = aggr.args,
      quantile = quantile, fine.tune = fine.tune, tune.thresh = tune.thresh, prune = prune,
      BPPARAM = BPPARAM
    )
    names(SingleRCluster_results$labels) <- levels(factor(SummarizedExperiment::colData(sce_query)[[query_group]]))
    rownames(SingleRCluster_results$scores) <- levels(factor(SummarizedExperiment::colData(sce_query)[[query_group]]))
    if (isTRUE(prune)) {
      names(SingleRCluster_results$pruned.labels) <- levels(factor(SummarizedExperiment::colData(sce_query)[[query_group]]))
    }
    srt_query$singler_annotation <- if (isTRUE(prune)) {
      SingleRCluster_results$pruned.labels[as.character(srt_query$query_group)]
    } else {
      SingleRCluster_results$labels[as.character(srt_query$query_group)]
    }
    srt_query$singler_score <- unname(sapply(as.character(unique(srt_query$query_group)), FUN = function(x) {
      if (isTRUE(prune)) {
        y <- SingleRCluster_results$pruned.labels[x]
      } else {
        y <- SingleRCluster_results$labels[x]
      }
      if (is.na(y)) {
        out <- NA
      } else {
        out <- SingleRCluster_results$scores[x, y]
      }
      return(out)
    })[as.character(srt_query$query_group)])
  } else if (method == "SingleRCell") {
    message("Perform ", method, " on the data...")
    SingleRCell_results <- SingleR::SingleR(
      test = sce_query,
      ref = sce_ref,
      labels = factor(SummarizedExperiment::colData(sce_ref)[[ref_group]]),
      clusters = NULL,
      de.method = de.method, genes = genes, sd.thresh = sd.thresh, de.n = de.n,
      aggr.ref = aggr.ref, aggr.args = aggr.args,
      quantile = quantile, fine.tune = fine.tune, tune.thresh = tune.thresh, prune = prune,
      BPPARAM = BPPARAM
    )
    srt_query$singler_annotation <- if (isTRUE(prune)) {
      SingleRCell_results$pruned.labels
    } else {
      SingleRCell_results$labels
    }
    srt_query$singler_score <- unname(sapply(seq_len(ncol(srt_query)), FUN = function(x) {
      if (isTRUE(prune)) {
        y <- SingleRCell_results$pruned.labels[x]
      } else {
        y <- SingleRCell_results$labels[x]
      }
      if (is.na(y)) {
        out <- NA
      } else {
        out <- SingleRCell_results$scores[x, y]
      }
      return(out)
    }))
  }
  return(srt_query)
}

# ---- SCP-workflow.R:14-47 : check_DataType ----
check_DataType <- function(srt, data = NULL, slot = "data", assay = NULL) {
  if (is.null(data)) {
    assay <- assay %||% DefaultAssay(srt)
    data <- GetAssayData(srt, slot = slot, assay = assay)
  }
  isfinite <- all(is.finite(range(data, na.rm = TRUE)))
  if (inherits(data, "dgCMatrix")) {
    isfloat <- any(data@x %% 1 != 0, na.rm = TRUE)
  } else {
    isfloat <- any(data[, sample(seq_len(ncol(data)), min(ncol(data), 1000))] %% 1 != 0, na.rm = TRUE)
  }
  islog <- is.finite(expm1(x = max(data, na.rm = TRUE)))
  isnegative <- any(data < 0)

  if (!isTRUE(isfinite)) {
    warning("Infinite values detected!", immediate. = TRUE)
    return("unknown")
  } else if (isTRUE(isnegative)) {
    warning("Negative values detected!", immediate. = TRUE)
    return("unknown")
  } else {
    if (!isfloat) {
      return("raw_counts")
    } else if (isfloat && islog) {
      return("log_normalized_counts")
    } else if (isfloat && !islog) {
      if (isFALSE(isnegative)) {
        return("raw_normalized_counts")
      } else {
        return("unknown")
      }
    }
  }
}

# ---- utils.R:558-617 : check_R ----
check_R <- function(packages, install_methods = c("BiocManager::install", "install.packages", "devtools::install_github"), lib = .libPaths()[1], force = FALSE) {
  status_list <- list()
  for (pkg in packages) {
    version <- NULL
    if (grepl("/", pkg)) {
      # github package
      pkg_name <- strsplit(pkg, split = "/|@|==", perl = TRUE)[[1]][[2]]
    } else {
      pkg_name <- strsplit(pkg, split = "@|==", perl = TRUE)[[1]][[1]]
      if (length(strsplit(pkg, split = "@|==", perl = TRUE)[[1]]) > 1) {
        version <- strsplit(pkg, split = "@|==", perl = TRUE)[[1]][[2]]
      }
    }
    dest <- gsub("@.*|==.*|>=.*", "", pkg)
    if (is.null(version)) {
      force_update <- isTRUE(force)
    } else {
      force_update <- isTRUE(packageVersion(pkg_name) < package_version(version)) || isTRUE(force)
    }
    if (!suppressPackageStartupMessages(requireNamespace(pkg_name, quietly = TRUE)) || isTRUE(force_update)) {
      message("Install package: \"", pkg_name, "\" ...")
      status_list[[pkg]] <- FALSE
      i <- 1
      while (isFALSE(status_list[[pkg]])) {
        tryCatch(expr = {
          if (grepl("BiocManager", install_methods[i])) {
            if (!requireNamespace("BiocManager", quietly = TRUE)) {
              install.packages("BiocManager", lib = lib)
            }
            eval(str2lang(paste0(install_methods[i], "(\"", dest, "\", lib=\"", lib, "\", update = FALSE, upgrade = \"never\", ask = FALSE, force = TRUE)")))
          } else if (grepl("devtools", install_methods[i])) {
            if (!requireNamespace("devtools", quietly = TRUE)) {
              install.packages("devtools", lib = lib)
            }
            if (!requireNamespace("withr", quietly = TRUE)) {
              install.packages("withr", lib = lib)
            }
            eval(str2lang(paste0("withr::with_libpaths(new = \"", lib, "\", ", install_methods[i], "(\"", dest, "\", upgrade = \"never\", force = TRUE))")))
          } else {
            eval(str2lang(paste0(install_methods[i], "(\"", dest, "\", lib=\"", lib, "\", force = TRUE)")))
          }
        }, error = function(e) {
          status_list[[pkg]] <- FALSE
        })
        status_list[[pkg]] <- requireNamespace(pkg_name, quietly = TRUE)
        i <- i + 1
        if (i > length(install_methods)) {
          break
        }
      }
    } else {
      status_list[[pkg]] <- TRUE
    }
  }
  out <- sapply(status_list, isTRUE)
  out <- out[!out]
  if (length(out) > 0) {
    stop("Failed to install the package(s): ", paste0(names(out), collapse = ","), ". Please install manually.")
  }
}

