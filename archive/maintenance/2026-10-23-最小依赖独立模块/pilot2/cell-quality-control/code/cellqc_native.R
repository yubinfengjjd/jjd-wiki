# Minimal runtime module extracted verbatim from SCP-local 0.5.6 (GPL (>= 3)).
# Source: https://github.com/zhanghao-njmu/SCP commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
# Roots: RunCellQC, RunDoubletCalling, db_scDblFinder, db_scds, db_Scrublet, db_DoubletDetection
# Functions: db_scDblFinder, db_scds, db_Scrublet, db_DoubletDetection, RunDoubletCalling, isOutlier, RunCellQC, check_DataType, PrepareEnv, Env_requirements, installed_Python_pkgs, exist_Python_pkgs, env_exist, get_envname, find_conda, conda_install, conda_python, run_Python, check_Python, check_R, as_matrix
# Function bodies are copied from the pinned source without algorithm changes.
# Automatic installation is disabled by the caller. Local resources are loaded only by the caller.

# ---- SCP-cellqc.R:17-31 : db_scDblFinder ----
db_scDblFinder <- function(srt, assay = "RNA", db_rate = ncol(srt) / 1000 * 0.01, ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  check_R("scDblFinder")
  sce <- as.SingleCellExperiment(srt, assay = assay)
  sce <- scDblFinder::scDblFinder(sce, dbr = db_rate, verbose = FALSE, ...)
  srt[["db.scDblFinder_score"]] <- sce[["scDblFinder.score"]]
  srt[["db.scDblFinder_class"]] <- sce[["scDblFinder.class"]]
  return(srt)
}

# ---- SCP-cellqc.R:50-70 : db_scds ----
db_scds <- function(srt, assay = "RNA", db_rate = ncol(srt) / 1000 * 0.01, method = c("hybrid", "cxds", "bcds"), ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  check_R("scds")
  method <- match.arg(method)
  sce <- as.SingleCellExperiment(srt, assay = assay)
  sce <- scds::cxds_bcds_hybrid(sce, ...)
  srt[["db.scds_cxds_score"]] <- sce[["cxds_score"]]
  srt[["db.scds_bcds_score"]] <- sce[["bcds_score"]]
  srt[["db.scds_hybrid_score"]] <- sce[["hybrid_score"]]
  ntop <- ceiling(db_rate * ncol(sce))
  db_qc <- names(sort(srt[[paste0("db.scds_", method, "_score"), drop = TRUE]], decreasing = TRUE)[1:ntop])
  srt[[paste0("db.scds_", method, "_class")]] <- "singlet"
  srt[[paste0("db.scds_", method, "_class")]][db_qc, ] <- "doublet"
  return(srt)
}

# ---- SCP-cellqc.R:89-113 : db_Scrublet ----
db_Scrublet <- function(srt, assay = "RNA", db_rate = ncol(srt) / 1000 * 0.01, ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  check_Python("scrublet")
  scr <- import("scrublet")
  raw_counts <- t(as_matrix(GetAssayData(object = srt, assay = assay, slot = "counts")))
  scrub <- scr$Scrublet(raw_counts, expected_doublet_rate = db_rate, ...)
  res <- scrub$scrub_doublets()
  doublet_scores <- res[[1]]
  predicted_doublets <- res[[2]]

  srt[["db.Scrublet_score"]] <- doublet_scores
  srt[["db.Scrublet_class"]] <- sapply(predicted_doublets, function(i) {
    switch(as.character(i),
      "FALSE" = "singlet",
      "TRUE" = "doublet"
    )
  })
  return(srt)
}

# ---- SCP-cellqc.R:132-159 : db_DoubletDetection ----
db_DoubletDetection <- function(srt, assay = "RNA", db_rate = ncol(srt) / 1000 * 0.01, ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  check_Python("doubletdetection")
  doubletdetection <- import("doubletdetection")
  counts <- GetAssayData(object = srt, assay = assay, slot = "counts")
  clf <- doubletdetection$BoostClassifier(
    n_iters = as.integer(5),
    standard_scaling = TRUE,
    ...
  )
  labels <- clf$fit(Matrix::t(counts))$predict()
  scores <- clf$doublet_score()

  srt[["db.DoubletDetection_score"]] <- scores
  srt[["db.DoubletDetection_class"]] <- sapply(labels, function(i) {
    switch(as.character(i),
      "0" = "singlet",
      "1" = "doublet"
    )
  })
  return(srt)
}

# ---- SCP-cellqc.R:180-215 : RunDoubletCalling ----
RunDoubletCalling <- function(srt, assay = "RNA", db_method = "scDblFinder", db_rate = ncol(srt) / 1000 * 0.01, ...) {
  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    stop("Data type is not raw counts!")
  }
  if (db_method %in% c("scDblFinder", "Scrublet", "DoubletDetection", "scds_cxds", "scds_bcds", "scds_hybrid")) {
    methods <- unlist(strsplit(db_method, "_"))
    method1 <- methods[1]
    method2 <- methods[2]
    if (is.na(method2)) {
      args1 <- mget(names(formals()), sys.frame(sys.nframe()))
      args2 <- as.list(match.call())
    } else {
      args1 <- c(mget(names(formals()), sys.frame(sys.nframe())), method = method2)
      args2 <- c(as.list(match.call()), method = method2)
    }
    for (n in names(args2)) {
      args1[[n]] <- args2[[n]]
    }
    args1 <- args1[!names(args1) %in% c("db_method", "...")]
    tryCatch(expr = {
      srt <- do.call(
        what = paste0("db_", method1),
        args = args1
      )
    }, error = function(e) {
      message(e)
    })
    return(srt)
  } else {
    stop(paste(db_method, "is not a suppoted doublet-calling method!"))
  }
}

# ---- SCP-cellqc.R:238-254 : isOutlier ----
isOutlier <- function(x, nmads = 2.5, constant = 1.4826, type = c("both", "lower", "higher")) {
  type <- match.arg(type, c("both", "lower", "higher"))
  mad <- mad(x, constant = constant, na.rm = TRUE)
  upper <- median(x, na.rm = TRUE) + nmads * mad
  lower <- median(x, na.rm = TRUE) - nmads * mad
  if (type == "both") {
    out <- which(x > upper | x < lower)
  }
  if (type == "lower") {
    out <- which(x < lower)
  }
  if (type == "higher") {
    out <- which(x > upper)
  }
  out <- c(which(is.na(x)), out)
  return(out)
}

# ---- SCP-cellqc.R:314-500 : RunCellQC ----
RunCellQC <- function(srt, assay = "RNA", split.by = NULL, return_filtered = FALSE,
                      qc_metrics = c("doublets", "outlier", "umi", "gene", "mito", "ribo", "ribo_mito_ratio", "species"),
                      db_method = "scDblFinder", db_rate = NULL, db_coefficient = 0.01,
                      outlier_threshold = c(
                        "log10_nCount:lower:2.5",
                        "log10_nCount:higher:5",
                        "log10_nFeature:lower:2.5",
                        "log10_nFeature:higher:5",
                        "featurecount_dist:lower:2.5"
                      ), outlier_n = 1,
                      UMI_threshold = 3000, gene_threshold = 1000,
                      mito_threshold = 20, mito_pattern = c("MT-", "Mt-", "mt-"), mito_gene = NULL,
                      ribo_threshold = 50, ribo_pattern = c("RP[SL]\\d+\\w{0,1}\\d*$", "Rp[sl]\\d+\\w{0,1}\\d*$", "rp[sl]\\d+\\w{0,1}\\d*$"), ribo_gene = NULL,
                      ribo_mito_ratio_range = c(1, Inf),
                      species = NULL, species_gene_prefix = NULL, species_percent = 95,
                      seed = 11) {
  set.seed(seed)

  if (!inherits(srt, "Seurat")) {
    stop("'srt' is not a Seurat object.")
  }
  if (!isTRUE(assay %in% Seurat::Assays(srt))) {
    stop("srt does not contain '", assay, "' assay.")
  }
  if (length(species) != length(species_gene_prefix)) {
    stop("'species_gene_prefix' must be the same length as 'species'.")
  }
  if (length(species) == 0) {
    species <- species_gene_prefix <- NULL
  }
  status <- check_DataType(srt, slot = "counts", assay = assay)
  if (status != "raw_counts") {
    warning("Data type is not raw counts!", immediate. = TRUE)
  }
  if (!paste0("nCount_", assay) %in% colnames(srt@meta.data)) {
    srt@meta.data[[paste0("nCount_", assay)]] <- colSums(srt[[assay]]@counts)
  }
  if (!paste0("nFeature_", assay) %in% colnames(srt@meta.data)) {
    srt@meta.data[[paste0("nFeature_", assay)]] <- colSums(srt[[assay]]@counts > 0)
  }
  srt_raw <- srt
  if (!is.null(split.by)) {
    srtList <- SplitObject(srt, split.by = split.by)
  } else {
    srtList <- list(srt)
  }

  for (i in seq_along(srtList)) {
    srt <- srtList[[i]]
    if (!is.null(split.by)) {
      cat("===", srt@meta.data[[split.by]][1], "===\n")
    }
    ntotal <- ncol(srt)

    db_qc <- c()
    if ("doublets" %in% qc_metrics) {
      if (!is.null(db_method)) {
        if (is.null(db_rate)) {
          db_rate <- ncol(srt) / 1000 * db_coefficient
        }
        if (db_rate >= 1) {
          stop("The db_rate is equal to or greater than 1!")
        }
        for (dbm in db_method) {
          srt <- RunDoubletCalling(srt = srt, db_method = dbm, db_rate = db_rate)
          db_qc <- unique(c(db_qc, colnames(srt)[srt[[paste0("db.", dbm, "_class"), drop = TRUE]] == "doublet"]))
        }
      }
    }

    outlier_qc <- c()
    for (n in 1:length(species)) {
      if (n == 0) {
        break
      }
      sp <- species[n]
      prefix <- species_gene_prefix[n]
      sp_genes <- rownames(srt[[assay]])[grep(pattern = paste0("^", prefix), x = rownames(srt[[assay]]))]
      nCount <- srt[[paste0(c(paste0("nCount_", assay), sp), collapse = ".")]] <- colSums(srt[[assay]]@counts[sp_genes, ])
      nFeature <- srt[[paste0(c(paste0("nFeature_", assay), sp), collapse = ".")]] <- colSums(srt[[assay]]@counts[sp_genes, ] > 0)
      percent.mito <- srt[[paste0(c("percent.mito", sp), collapse = ".")]] <- PercentageFeatureSet(object = srt, assay = assay, pattern = paste0("(", paste0("^", prefix, "-*", mito_pattern), ")", collapse = "|"), features = mito_gene)[[1]]
      percent.ribo <- srt[[paste0(c("percent.ribo", sp), collapse = ".")]] <- PercentageFeatureSet(object = srt, assay = assay, pattern = paste0("(", paste0("^", prefix, "-*", ribo_pattern), ")", collapse = "|"), features = ribo_gene)[[1]]
      percent.genome <- srt[[paste0(c("percent.genome", sp), collapse = ".")]] <- PercentageFeatureSet(object = srt, assay = assay, pattern = paste0("^", prefix))[[1]]
      ribo.mito.ratio <- srt[[paste0(c("percent.ribo", sp), collapse = "."), drop = TRUE]] / srt[[paste0(c("percent.mito", sp), collapse = "."), drop = TRUE]]
      ribo.mito.ratio[is.na(ribo.mito.ratio)] <- 1
      srt[[paste0(c("ribo.mito.ratio", sp), collapse = ".")]] <- ribo.mito.ratio

      if (n == 1) {
        if ("outlier" %in% qc_metrics) {
          # "percent.top_20:higher:5"
          # countx <- as(srt[[assay]]@counts[sp_genes, ], "sparseMatrix")
          # agg <- aggregate(x = countx@x, by = list(rep(colnames(countx), diff(countx@p))), FUN = function(x) {
          #   sum(head(x, 20))
          # })
          # rownames(agg) <- agg[[1]]
          # percent.top_20 <- srt[[paste0(c("percent.top_20", sp), collapse = ".")]] <- agg[colnames(srt), "x"]

          log10_nFeature <- srt[[paste0(c(paste0("log10_nFeature_", assay), sp), collapse = ".")]] <- log10(nFeature)
          log10_nCount <- srt[[paste0(c(paste0("log10_nCount_", assay), sp), collapse = ".")]] <- log10(nCount)
          log10_nCount[is.infinite(log10_nCount)] <- NA
          log10_nFeature[is.infinite(log10_nFeature)] <- NA
          mod <- loess(log10_nFeature ~ log10_nCount)
          pred <- predict(mod, newdata = data.frame(log10_nCount = log10_nCount))
          featurecount_dist <- srt[[paste0(c("featurecount_dist", sp), collapse = ".")]] <- log10_nFeature - pred

          # df <- data.frame(cell = colnames(srt), ribo = srt$percent.ribo.Homo_sapiens, y = log10_nFeature, x = log10_nCount, pred = pred, featurecount_dist = featurecount_dist)
          # lower_df <- subset(df, featurecount_dist < median(df$featurecount_dist) - 2.5 * mad(df$featurecount_dist))
          # higher_df <- subset(df, featurecount_dist > median(df$featurecount_dist) + 2.5 * mad(df$featurecount_dist))
          # ggplot(df) +
          #   geom_point(aes(x = x, y = y, color = featurecount_dist)) +
          #   scale_color_gradientn(colors = c("green", "white", "orange"), values = scales::rescale(c(min(df$featurecount_dist), 0, max(df$featurecount_dist)))) +
          #   geom_point(data = lower_df, aes(x = x, y = y), shape = 21, fill = "transparent", color = "blue") +
          #   geom_point(data = higher_df, aes(x = x, y = y), shape = 21, fill = "transparent", color = "red") +
          #   geom_line(aes(x = x, y = pred), color = "black")+
          #   theme(panel.background = element_rect(fill = "grey"))
          # nrow(lower_df)

          var <- sapply(strsplit(outlier_threshold, ":"), function(x) x[[1]])
          var_valid <- var %in% colnames(srt@meta.data) | sapply(var, FUN = function(x) exists(x, where = environment()))
          if (any(!var_valid)) {
            stop("Variable ", paste0(names(var_valid)[!var_valid], collapse = ","), " is not found in the srt object.")
          }
          outlier <- lapply(strsplit(outlier_threshold, ":"), function(m) {
            colnames(srt)[isOutlier(get(m[1]), nmads = as.numeric(m[3]), type = m[2])]
          })
          names(outlier) <- outlier_threshold
          # print(unlist(lapply(outlier, length)))
          outlier_tb <- table(unlist(outlier))
          outlier_qc <- c(outlier_qc, names(outlier_tb)[outlier_tb >= outlier_n])
          for (nm in names(outlier)) {
            srt[[make.names(nm)]] <- colnames(srt) %in% outlier[[nm]]
          }
        }
      }
    }

    umi_qc <- gene_qc <- mito_qc <- ribo_qc <- ribo_mito_ratio_qc <- species_qc <- c()
    if ("umi" %in% qc_metrics) {
      umi_qc <- colnames(srt)[which(srt[[paste0(c(paste0("nCount_", assay), species[1]), collapse = "."), drop = TRUE]] < UMI_threshold)]
    }
    if ("gene" %in% qc_metrics) {
      gene_qc <- colnames(srt)[which(srt[[paste0(c(paste0("nFeature_", assay), species[1]), collapse = "."), drop = TRUE]] < gene_threshold)]
    }
    if ("mito" %in% qc_metrics) {
      mito_qc <- colnames(srt)[which(srt[[paste0(c("percent.mito", species[1]), collapse = "."), drop = TRUE]] > mito_threshold)]
    }
    if ("ribo" %in% qc_metrics) {
      ribo_qc <- colnames(srt)[which(srt[[paste0(c("percent.ribo", species[1]), collapse = "."), drop = TRUE]] > ribo_threshold)]
    }
    if ("ribo_mito_ratio" %in% qc_metrics) {
      ribo_mito_ratio_qc <- colnames(srt)[which(srt[[paste0(c("ribo.mito.ratio", species[1]), collapse = "."), drop = TRUE]] < ribo_mito_ratio_range[1] | srt[[paste0(c("ribo.mito.ratio", species[1]), collapse = "."), drop = TRUE]] > ribo_mito_ratio_range[2])]
    }
    if ("species" %in% qc_metrics) {
      species_qc <- colnames(srt)[which(srt[[paste0(c("percent.genome", species[1]), collapse = "."), drop = TRUE]] < species_percent)]
    }

    CellQC <- unique(c(db_qc, outlier_qc, umi_qc, gene_qc, mito_qc, ribo_qc, ribo_mito_ratio_qc, species_qc))
    cat(">>>", "Total cells:", ntotal, "\n")
    cat(">>>", "Cells which are filtered out:", length(CellQC), "\n")
    cat("...", length(db_qc), "potential doublets", "\n")
    cat("...", length(outlier_qc), "outlier cells", "\n")
    cat("...", length(umi_qc), "low-UMI cells", "\n")
    cat("...", length(gene_qc), "low-gene cells", "\n")
    cat("...", length(mito_qc), "high-mito cells", "\n")
    cat("...", length(ribo_qc), "high-ribo cells", "\n")
    cat("...", length(ribo_mito_ratio_qc), "ribo_mito_ratio outlier cells", "\n")
    cat("...", length(species_qc), "species-contaminated cells", "\n")
    cat(">>>", "Remained cells after filtering:", ntotal - length(CellQC), "\n")

    qc_nm <- c("db_qc", "outlier_qc", "umi_qc", "gene_qc", "mito_qc", "ribo_qc", "ribo_mito_ratio_qc", "species_qc", "CellQC")
    for (qc in qc_nm) {
      srt[[qc]] <- ifelse(colnames(srt) %in% get(qc), "Fail", "Pass")
      srt[[qc]] <- factor(srt[[qc, drop = TRUE]], levels = c("Pass", "Fail"))
    }

    if (return_filtered) {
      srt <- srt[, srt$CellQC == "Pass"]
      srt@meta.data[, intersect(qc_nm, colnames(srt@meta.data))] <- NULL
    }
    srtList[[i]] <- srt
  }
  cells <- unlist(lapply(srtList, colnames))
  srt_raw <- srt_raw[, cells]
  meta.data <- do.call(rbind.data.frame, unname(lapply(srtList, function(x) x@meta.data)))
  srt_raw <- AddMetaData(srt_raw, metadata = meta.data)
  return(srt_raw)
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

# ---- utils.R:13-129 : PrepareEnv ----
PrepareEnv <- function(conda = "auto", miniconda_repo = "https://repo.anaconda.com/miniconda",
                       envname = NULL, version = "3.8-1", force = FALSE, ...) {
  envname <- get_envname(envname)

  requirements <- Env_requirements(version = version)
  python_version <- requirements[["python"]]
  packages <- requirements[["packages"]]

  if (!is.null(conda)) {
    if (identical(conda, "auto")) {
      conda <- find_conda()
    } else {
      options(reticulate.conda_binary = conda)
      conda <- find_conda()
    }
  }

  if (is.null(conda)) {
    env <- FALSE
  } else {
    envs_dir <- reticulate:::conda_info(conda = conda)$envs_dirs[1]
    env <- env_exist(conda = conda, envname = envname, envs_dir = envs_dir)
    if (isTRUE(force) && isTRUE(env)) {
      unlink(paste0(envs_dir, "/", envname), recursive = TRUE)
      env <- FALSE
    }
  }

  if (isTRUE(env)) {
    python_path <- conda_python(conda = conda, envname = envname)
    # installed_python_version <- reticulate:::python_version(python_path)
    # if (installed_python_version < numeric_version("3.7.0") || installed_python_version >= numeric_version("3.10.0")) {
    #   stop("The python version in the installed SCP environment does not match the requirements. You need to recreate the SCP environment.")
    # }
  } else {
    force <- TRUE
    if (is.null(conda)) {
      message("Conda not found. Installing miniconda...")
      options(timeout = 360)
      version <- "3"
      info <- as.list(Sys.info())
      if (info$sysname == "Darwin" && info$machine == "arm64") {
        base <- "https://github.com/conda-forge/miniforge/releases/latest/download"
        name <- "Miniforge3-MacOSX-arm64.sh"
        return(file.path(base, name))
      }
      base <- miniconda_repo
      info <- as.list(Sys.info())
      arch <- reticulate:::miniconda_installer_arch(info)
      version <- as.character(version)
      name <- if (reticulate:::is_windows()) {
        sprintf(
          "Miniconda%s-latest-Windows-%s.exe", version,
          arch
        )
      } else if (reticulate:::is_osx()) {
        sprintf(
          "Miniconda%s-latest-MacOSX-%s.sh", version,
          arch
        )
      } else if (reticulate:::is_linux()) {
        sprintf("Miniconda%s-latest-Linux-%s.sh", version, arch)
      } else {
        stopf("unsupported platform %s", shQuote(Sys.info()[["sysname"]]))
      }
      url <- file.path(base, name)
      options(reticulate.miniconda.url = url)
      if (!is.na(Sys.getenv("USER", unset = NA))) {
        miniconda_path <- gsub(pattern = "\\$USER", replacement = Sys.getenv("USER"), reticulate::miniconda_path())
      } else {
        miniconda_path <- reticulate::miniconda_path()
      }
      unlink(miniconda_path, recursive = TRUE)
      reticulate::install_miniconda(path = miniconda_path, force = TRUE, update = FALSE)
      conda <- reticulate:::miniconda_conda(miniconda_path)
      envs_dir <- reticulate:::conda_info(conda = conda)$envs_dirs[1]
    }
    if (python_version < numeric_version("3.7.0") || python_version >= numeric_version("3.10.0")) {
      stop("SCP currently only support python version 3.7-3.9!")
    }
    python_path <- reticulate::conda_create(conda = conda, envname = envname, python_version = python_version, packages = "pytables")
    env_path <- paste0(envs_dir, "/", envname)
    env <- file.exists(env_path)
    if (isFALSE(env)) {
      print(reticulate:::conda_info(conda = conda))
      print(reticulate::conda_list(conda = conda))
      stop(
        "Unable to find SCP environment under the expected path: ", env_path, "\n",
        "conda: ", conda, "\n",
        "SCP python: ", python_path, "\n"
      )
    }
  }

  check_Python(packages = packages, envname = envname, conda = conda, force = force, ...)

  Sys.unsetenv("RETICULATE_PYTHON")
  python_path <- conda_python(conda = conda, envname = envname)
  reticulate::use_python(python_path, required = TRUE)

  pyinfo <- utils::capture.output(reticulate::py_config())
  pyinfo_mesg <- c(
    "====================== SCP conda environment ======================",
    paste0("conda: ", conda),
    paste0("environment: ", paste0(envs_dir, "/", get_envname())),
    "======================== SCP python config ========================",
    pyinfo,
    "==================================================================="
  )
  invisible(lapply(pyinfo_mesg, packageStartupMessage))
  invisible(run_Python(command = "import matplotlib", envir = .GlobalEnv))
  if (!interactive()) {
    invisible(run_Python(command = "matplotlib.use('pdf')", envir = .GlobalEnv))
  }
  invisible(run_Python(command = "import matplotlib.pyplot as plt", envir = .GlobalEnv))
  invisible(run_Python(command = "import scanpy", envir = .GlobalEnv))
}

# ---- utils.R:144-265 : Env_requirements ----
Env_requirements <- function(version = "3.8-1") {
  version <- match.arg(version, choices = c("3.8-1", "3.8-2", "3.9-1", "3.10-1", "3.11-1"))
  requirements <- switch(version,
    "3.8-1" = list(
      python = "3.8",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.6.3",
        "numba" = "numba==0.55.2",
        "numpy" = "numpy==1.21.6",
        "palantir" = "palantir==1.0.1",
        "pandas" = "pandas==1.3.5",
        "python-igraph" = "python-igraph==0.10.2",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.10.1",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    ),
    "3.8-2" = list(
      python = "3.8",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.7.3",
        "numba" = "numba==0.58.1",
        "numpy" = "numpy==1.24.4",
        "palantir" = "palantir==1.3.0",
        "pandas" = "pandas==1.5.3",
        "python-igraph" = "python-igraph==0.10.8",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.10.1",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    ),
    "3.9-1" = list(
      python = "3.9",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.8.0",
        "numba" = "numba==0.58.1",
        "numpy" = "numpy==1.25.2",
        "palantir" = "palantir==1.3.0",
        "pandas" = "pandas==1.5.3",
        "python-igraph" = "python-igraph==0.10.8",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.11.3",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    ),
    "3.10-1" = list(
      python = "3.10",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.8.0",
        "numba" = "numba==0.58.1",
        "numpy" = "numpy==1.25.2",
        "palantir" = "palantir==1.3.0",
        "pandas" = "pandas==1.5.3",
        "python-igraph" = "python-igraph==0.10.8",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.11.3",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    ),
    "3.11-1" = list(
      python = "3.10",
      packages = c(
        "leidenalg" = "leidenalg==0.10.1",
        "matplotlib" = "matplotlib==3.8.0",
        "numba" = "numba==0.58.1",
        "numpy" = "numpy==1.25.2",
        "palantir" = "palantir==1.3.0",
        "pandas" = "pandas==1.5.3",
        "python-igraph" = "python-igraph==0.10.8",
        "scanpy" = "scanpy==1.9.5",
        "scikit-learn" = "scikit-learn==1.3.2",
        "scipy" = "scipy==1.11.3",
        "scvelo" = "scvelo==0.2.5",
        "wot" = "wot==1.0.8.post2",
        "trimap" = "trimap==1.1.4",
        "pacmap" = "pacmap==0.7.0",
        "phate" = "phate==1.0.11",
        "bbknn" = "bbknn==1.6.0",
        "scanorama" = "scanorama==1.7.4",
        "scvi-tools" = "scvi-tools==0.20.3"
      )
    )
  )

  return(requirements)
}

# ---- utils.R:271-285 : installed_Python_pkgs ----
installed_Python_pkgs <- function(envname = NULL, conda = "auto") {
  envname <- get_envname(envname)
  if (identical(conda, "auto")) {
    conda <- find_conda()
  } else {
    options(reticulate.conda_binary = conda)
    conda <- find_conda()
  }
  env <- env_exist(conda = conda, envname = envname)
  if (isFALSE(env)) {
    stop("Can not find the conda environment: ", envname)
  }
  all_installed <- reticulate:::conda_list_packages(conda = conda, envname = envname, no_pip = FALSE)
  return(all_installed)
}

# ---- utils.R:291-330 : exist_Python_pkgs ----
exist_Python_pkgs <- function(packages, envname = NULL, conda = "auto") {
  envname <- get_envname(envname)
  if (identical(conda, "auto")) {
    conda <- find_conda()
  } else {
    options(reticulate.conda_binary = conda)
    conda <- find_conda()
  }
  env <- env_exist(conda = conda, envname = envname)
  if (isFALSE(env)) {
    stop("Can not find the conda environment: ", envname)
  }
  all_installed <- installed_Python_pkgs(envname = envname, conda = conda)
  packages_installed <- NULL
  for (i in seq_along(packages)) {
    pkg <- packages[i]
    if (grepl("==", pkg)) {
      pkg_info <- strsplit(pkg, split = "==")[[1]]
      pkg_name <- names(pkg) %||% pkg_info[1]
      pkg_version <- pkg_info[2]
    } else if (grepl("git+", pkg)) {
      pkg_info <- strsplit(pkg, "/")[[1]]
      pkg_name <- names(pkg) %||% pkg_info[length(pkg_info)]
      pkg_version <- NA
    } else {
      pkg_name <- names(pkg) %||% pkg
      pkg_version <- NA
    }
    if (pkg_name %in% all_installed$package) {
      if (!is.na(pkg_version)) {
        packages_installed[pkg] <- all_installed$version[all_installed$package == pkg_name] == pkg_version
      } else {
        packages_installed[pkg] <- TRUE
      }
    } else {
      packages_installed[pkg] <- FALSE
    }
  }
  return(packages_installed)
}

# ---- utils.R:336-353 : env_exist ----
env_exist <- function(conda = "auto", envname = NULL, envs_dir = NULL) {
  envname <- get_envname(envname)
  if (identical(conda, "auto")) {
    conda <- find_conda()
  } else {
    options(reticulate.conda_binary = conda)
    conda <- find_conda()
  }
  if (!is.null(conda)) {
    if (is.null(envs_dir)) {
      envs_dir <- reticulate:::conda_info(conda = conda)$envs_dirs[1]
    }
    exist <- file.exists(paste0(envs_dir, "/", envname))
  } else {
    exist <- FALSE
  }
  return(exist)
}

# ---- utils.R:355-362 : get_envname ----
get_envname <- function(envname = NULL) {
  if (is.character(envname)) {
    envname <- envname
  } else {
    envname <- getOption("SCP_env_name", default = "SCP_env")
  }
  return(envname)
}

# ---- utils.R:367-384 : find_conda ----
find_conda <- function() {
  conda <- tryCatch(reticulate::conda_binary(conda = "auto"), error = identity)
  conda_exist <- !inherits(conda, "error")
  if (isFALSE(conda_exist)) {
    if (!is.na(Sys.getenv("USER", unset = NA))) {
      miniconda_path <- gsub(pattern = "\\$USER", replacement = Sys.getenv("USER"), reticulate::miniconda_path())
    } else {
      miniconda_path <- reticulate::miniconda_path()
    }
    conda_exist <- reticulate:::miniconda_exists(miniconda_path) && reticulate:::miniconda_test(miniconda_path)
    if (isTRUE(conda_exist)) {
      conda <- reticulate:::miniconda_conda(miniconda_path)
    } else {
      conda <- NULL
    }
  }
  return(conda)
}

# ---- utils.R:389-453 : conda_install ----
conda_install <- function(envname = NULL, packages, forge = TRUE, channel = character(),
                          pip = FALSE, pip_options = character(), pip_ignore_installed = FALSE,
                          conda = "auto", python_version = NULL, ...) {
  envname <- get_envname(envname)
  reticulate:::check_forbidden_install("Python packages")
  if (missing(packages)) {
    if (!is.null(envname)) {
      fmt <- paste("argument \"packages\" is missing, with no default",
        "- did you mean 'conda_install(<envname>, %1$s)'?",
        "- use 'py_install(%1$s)' to install into the active Python environment",
        sep = "\n"
      )
      stopf(fmt, deparse1(substitute(envname)), call. = FALSE)
    } else {
      packages
    }
  }
  conda <- reticulate::conda_binary(conda)
  envname <- reticulate:::condaenv_resolve(envname)
  python_package <- if (is.null(python_version)) {
    NULL
  } else if (grepl("[><=]", python_version)) {
    paste0("python", python_version)
  } else {
    sprintf("python=%s", python_version)
  }
  python <- tryCatch(conda_python(envname = envname, conda = conda), error = identity)
  if (inherits(python, "error") || !file.exists(python)) {
    reticulate::conda_create(envname = envname, packages = python_package %||% "python", forge = forge, channel = channel, conda = conda)
    python <- conda_python(envname = envname, conda = conda)
  }
  if (!is.null(python_version)) {
    args <- reticulate:::conda_args("install", envname, python_package)
    status <- reticulate:::system2t(conda, shQuote(args))
    if (status != 0L) {
      fmt <- "installation of '%s' into environment '%s' failed [error code %i]"
      msg <- sprintf(fmt, python_package, envname, status)
      stop(msg, call. = FALSE)
    }
  }
  if (pip) {
    # target_dir <- system2(command = python, args = c("-c \"import site; print(site.getsitepackages()[0])\""), stdout = TRUE)
    # pip_options <- c(pip_options, paste("--target", target_dir))
    result <- reticulate:::pip_install(
      python = python, packages = packages,
      pip_options = pip_options, ignore_installed = pip_ignore_installed,
      conda = conda, envname = envname
    )
    return(result)
  }
  args <- reticulate:::conda_args("install", envname)
  channels <- if (length(channel)) {
    channel
  } else if (forge) {
    "conda-forge"
  }
  for (ch in channels) args <- c(args, "-c", ch)
  args <- c(args, python_package, packages)
  result <- reticulate:::system2t(conda, shQuote(args))
  if (result != 0L) {
    fmt <- "one or more Python packages failed to install [error code %i]"
    stopf(fmt, result)
  }
  invisible(packages)
}

# ---- utils.R:458-478 : conda_python ----
conda_python <- function(envname = NULL, conda = "auto", all = FALSE) {
  envname <- get_envname(envname)
  envname <- reticulate:::condaenv_resolve(envname)
  if (grepl("[/\\\\]", envname)) {
    suffix <- if (reticulate:::is_windows()) "python.exe" else "bin/python"
    path <- file.path(envname, suffix)
    if (file.exists(path)) {
      return(path)
    }
    fmt <- "no conda environment exists at path '%s'"
    stop(sprintf(fmt, envname))
  }
  conda_envs <- reticulate::conda_list(conda = conda)
  conda_envs <- conda_envs[grep(normalizePath(reticulate:::conda_info(conda = conda)$envs_dirs[1], mustWork = FALSE), x = normalizePath(conda_envs$python, mustWork = FALSE), fixed = TRUE), , drop = FALSE]
  env <- conda_envs[conda_envs$name == envname, , drop = FALSE]
  if (nrow(env) == 0) {
    stop("conda environment \"", envname, "\" not found")
  }
  python <- if (all) env$python else env$python[[1L]]
  return(normalizePath(as.character(python), mustWork = FALSE))
}

# ---- utils.R:480-492 : run_Python ----
run_Python <- function(command, envir = .GlobalEnv) {
  tryCatch(expr = {
    eval(
      {
        reticulate::py_run_string(command)
      },
      envir = envir
    )
  }, error = function(error) {
    message(error)
    stop("Failed to run \"", command, "\". Please check manually.")
  })
}

# ---- utils.R:510-546 : check_Python ----
check_Python <- function(packages, envname = NULL, conda = "auto", force = FALSE, pip = TRUE, pip_options = character(), ...) {
  envname <- get_envname(envname)
  if (identical(conda, "auto")) {
    conda <- find_conda()
  } else {
    options(reticulate.conda_binary = conda)
    conda <- find_conda()
  }
  env <- env_exist(conda = conda, envname = envname)
  if (isFALSE(env)) {
    warning(envname, " python environment does not exist. Create it with the PrepareEnv function...", immediate. = TRUE)
    PrepareEnv()
  }
  if (isTRUE(force)) {
    pkg_installed <- setNames(rep(FALSE, length(packages)), packages)
    pip_options <- c(pip_options, "--force-reinstall")
  } else {
    pkg_installed <- exist_Python_pkgs(packages = packages, envname = envname, conda = conda)
  }
  if (sum(!pkg_installed) > 0) {
    pkgs_to_install <- names(pkg_installed)[!pkg_installed]
    message("Try to install ", paste0(pkgs_to_install, collapse = ","), " ...")
    if (isTRUE(pip)) {
      pkgs_to_install <- c("pip", pkgs_to_install)
    }
    tryCatch(expr = {
      conda_install(conda = conda, packages = pkgs_to_install, envname = envname, pip = pip, pip_options = pip_options, ...)
    }, error = identity)
  }

  pkg_installed <- exist_Python_pkgs(packages = packages, envname = envname, conda = conda)
  if (sum(!pkg_installed) > 0) {
    stop("Failed to install the package(s): ", paste0(names(pkg_installed)[!pkg_installed], collapse = ","), " into the environment \"", envname, "\". Please install manually.")
  } else {
    return(invisible(NULL))
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

# ---- utils.R:831-841 : as_matrix ----
as_matrix <- function(x) {
  if (!inherits(matrix, "dgCMatrix")) {
    return(as.matrix(x))
  } else {
    row_pos <- x@i
    col_pos <- findInterval(seq_along(x@x) - 1, x@p[-1])
    out <- asMatrix(rp = row_pos, cp = col_pos, z = x@x, nrows = x@Dim[1], ncols = x@Dim[2])
    attr(out, "dimnames") <- list(x@Dimnames[[1]], x@Dimnames[[2]])
    return(out)
  }
}

