# Minimal runtime module extracted verbatim from SCP-local 0.5.6 (GPL (>= 3)).
# Source: https://github.com/zhanghao-njmu/SCP commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
# Roots: RunDimReduction, RunUMAP2, RunNMF, RunGLMPCA, RunDM, RunPHATE, RunPaCMAP, RunTriMap, RunLargeVis, RunFR, RunMDS
# Functions: RunDimReduction, RunNMF, RunNMF.Seurat, RunNMF.Assay, RunNMF.default, RunMDS, RunMDS.Seurat, RunMDS.Assay, RunMDS.default, RunGLMPCA, RunGLMPCA.Seurat, RunGLMPCA.Assay, RunGLMPCA.default, RunDM, RunDM.Seurat, RunDM.default, RunUMAP2, RunUMAP2.Seurat, RunUMAP2.default, RunPaCMAP, RunPaCMAP.Seurat, RunPaCMAP.default, RunPHATE, RunPHATE.Seurat, RunPHATE.default, RunTriMap, RunTriMap.Seurat, RunTriMap.default, RunLargeVis, RunLargeVis.Seurat, RunLargeVis.default, RunFR, RunFR.Seurat, RunFR.default, PrepareEnv, Env_requirements, installed_Python_pkgs, exist_Python_pkgs, env_exist, get_envname, find_conda, conda_install, conda_python, run_Python, check_Python, check_R, invoke, as_matrix
# Function bodies are copied from the pinned source without algorithm changes.
# Automatic installation is disabled by the caller. Local resources are loaded only by the caller.

# ---- SCP-workflow.R:781-1011 : RunDimReduction ----
RunDimReduction <- function(srt, prefix = "", features = NULL, assay = NULL, slot = "data",
                            linear_reduction = NULL, linear_reduction_dims = 50,
                            linear_reduction_params = list(), force_linear_reduction = FALSE,
                            nonlinear_reduction = NULL, nonlinear_reduction_dims = 2,
                            reduction_use = NULL, reduction_dims = NULL,
                            graph_use = NULL, neighbor_use = NULL,
                            nonlinear_reduction_params = list(), force_nonlinear_reduction = TRUE,
                            verbose = TRUE, seed = 11) {
  set.seed(seed)
  assay <- assay %||% DefaultAssay(srt)
  if (inherits(srt[[assay]], "ChromatinAssay")) {
    type <- "Chromatin"
  } else {
    type <- "RNA"
  }
  linear_reduction_dims <- min(linear_reduction_dims, nrow(srt[[assay]]) - 1, ncol(srt[[assay]]) - 1, na.rm = TRUE)
  nonlinear_reduction_dims <- min(nonlinear_reduction_dims, nrow(srt[[assay]]) - 1, ncol(srt[[assay]]) - 1, na.rm = TRUE)
  if (!is.null(linear_reduction)) {
    if (any(!linear_reduction %in% c("pca", "svd", "ica", "nmf", "mds", "glmpca", Reductions(srt))) || length(linear_reduction) > 1) {
      stop("'linear_reduction' must be one of 'pca','svd', 'ica', 'nmf', 'mds', 'glmpca'.")
    }
  }
  if (!is.null(nonlinear_reduction)) {
    if (any(!nonlinear_reduction %in% c("umap", "umap-naive", "tsne", "dm", "phate", "pacmap", "trimap", "largevis", "fr", Reductions(srt))) || length(nonlinear_reduction) > 1) {
      stop("'nonlinear_reduction' must be one of 'umap', 'tsne', 'dm', 'phate', 'pacmap', 'trimap', 'largevis', 'fr'.")
    }
    if (is.null(features) && is.null(reduction_use) && is.null(neighbor_use) && is.null(graph_use)) {
      stop("'features', 'reduction_use', 'neighbor_use', or 'graph_use' must be provided when running non-linear dimensionality reduction.")
    }
    if (nonlinear_reduction %in% c("fr")) {
      if (!is.null(graph_use)) {
        message("Non-linear dimensionality reduction(", nonlinear_reduction, ") using Graphs(", graph_use, ") as input")
      } else if (!is.null(neighbor_use)) {
        message("Non-linear dimensionality reduction(", nonlinear_reduction, ") using Neighbors(", neighbor_use, ") as input")
      } else if (!is.null(features)) {
        message("Non-linear dimensionality reduction(", nonlinear_reduction, ") using Features(length:", length(features), ") as input")
      } else if (!is.null(reduction_use)) {
        message("Non-linear dimensionality reduction(", nonlinear_reduction, ") using Reduction(", reduction_use, ", dims:", min(reduction_dims), "-", max(reduction_dims), ") as input")
      }
    } else {
      if (!is.null(features)) {
        message("Non-linear dimensionality reduction(", nonlinear_reduction, ") using Features(length:", length(features), ") as input")
      } else if (!is.null(reduction_use)) {
        message("Non-linear dimensionality reduction(", nonlinear_reduction, ") using Reduction(", reduction_use, ", dims:", min(reduction_dims), "-", max(reduction_dims), ") as input")
      } else if (!is.null(neighbor_use)) {
        message("Non-linear dimensionality reduction(", nonlinear_reduction, ") using Neighbors(", neighbor_use, ") as input")
      } else if (!is.null(graph_use)) {
        message("Non-linear dimensionality reduction(", nonlinear_reduction, ") using Graphs(", graph_use, ") as input")
      }
    }
  }
  if (!is.null(linear_reduction)) {
    if (!isTRUE(force_linear_reduction)) {
      if (linear_reduction %in% Reductions(srt)) {
        if (srt[[linear_reduction]]@assay.used == assay) {
          message("linear_reduction(", linear_reduction, ") is already existed. Skip calculation.")
          reduc <- srt[[linear_reduction]]
          Key(reduc) <- paste0(prefix, linear_reduction, "_")
          srt[[paste0(prefix, linear_reduction)]] <- reduc
          srt@misc[["Default_reduction"]] <- paste0(prefix, linear_reduction)
          return(srt)
        } else {
          message("assay.used is ", srt[[linear_reduction]]@assay.used, ", which is not the same as the ", assay, " specified. Recalculate the linear reduction(pca)")
          linear_reduction <- "pca"
        }
      }
    }
    if (is.null(features) || length(features) == 0) {
      message("No features provided. Use variable features.")
      if (length(VariableFeatures(srt, assay = assay)) == 0) {
        srt <- FindVariableFeatures(srt, assay = assay, verbose = FALSE)
      }
      features <- VariableFeatures(srt, assay = assay)
    }
    fun_use <- switch(linear_reduction,
      "pca" = "RunPCA",
      "svd" = "RunSVD",
      "ica" = "RunICA",
      "nmf" = "RunNMF",
      "mds" = "RunMDS",
      "glmpca" = "RunGLMPCA"
    )
    key_use <- switch(linear_reduction,
      "pca" = "PC_",
      "svd" = "LSI_",
      "ica" = "IC_",
      "nmf" = "BE_",
      "mds" = "MDS_",
      "glmpca" = "GLMPC_"
    )
    components_nm <- switch(linear_reduction,
      "pca" = "npcs",
      "svd" = "n",
      "ica" = "nics",
      "nmf" = "nbes",
      "mds" = "nmds",
      "glmpca" = "L"
    )
    params <- list(
      object = srt, assay = assay, slot = slot,
      features = features, components_nm = linear_reduction_dims,
      reduction.name = paste0(prefix, linear_reduction),
      reduction.key = paste0(prefix, key_use),
      verbose = verbose, seed.use = seed
    )
    if (fun_use %in% c("RunSVD", "RunICA")) {
      params <- params[!names(params) %in% "slot"]
    }
    if (fun_use == "RunGLMPCA") {
      params[["slot"]] <- "counts"
    }
    names(params)[names(params) == "components_nm"] <- components_nm
    for (nm in names(linear_reduction_params)) {
      params[[nm]] <- linear_reduction_params[[nm]]
    }
    srt <- invoke(.fn = fun_use, .args = params)

    if (is.null(rownames(srt[[paste0(prefix, linear_reduction)]]))) {
      rownames(srt[[paste0(prefix, linear_reduction)]]@cell.embeddings) <- colnames(srt)
    }
    if (linear_reduction == "pca") {
      pca.out <- srt[[paste0(prefix, linear_reduction)]]
      center <- rowMeans(GetAssayData(object = srt, slot = "scale.data", assay = assay)[features, , drop = FALSE])
      model <- list(sdev = pca.out@stdev, rotation = pca.out@feature.loadings, center = center, scale = FALSE, x = pca.out@cell.embeddings)
      class(model) <- "prcomp"
      srt@reductions[[paste0(prefix, linear_reduction)]]@misc[["model"]] <- model
    }
    if (linear_reduction %in% c("glmpca", "nmf")) {
      dims_estimate <- 1:linear_reduction_dims
    } else {
      dim_est <- tryCatch(expr = {
        min(
          intrinsicDimension::maxLikGlobalDimEst(data = Embeddings(srt, reduction = paste0(prefix, linear_reduction)), k = 20)[["dim.est"]],
          ncol(Embeddings(srt, reduction = paste0(prefix, linear_reduction)))
        )
      }, error = function(e) {
        message("Can not estimate intrinsic dimensions with maxLikGlobalDimEst.")
        return(NA)
      })
      if (!is.na(dim_est)) {
        dims_estimate <- seq_len(max(min(ncol(Embeddings(srt, reduction = paste0(prefix, linear_reduction))), 10), ceiling(dim_est)))
      } else {
        dims_estimate <- seq_len(min(ncol(Embeddings(srt, reduction = paste0(prefix, linear_reduction))), 30))
      }
    }
    srt@reductions[[paste0(prefix, linear_reduction)]]@misc[["dims_estimate"]] <- dims_estimate
    srt@misc[["Default_reduction"]] <- paste0(prefix, linear_reduction)
  } else if (!is.null(nonlinear_reduction)) {
    if (!isTRUE(force_nonlinear_reduction)) {
      if (nonlinear_reduction %in% Reductions(srt)) {
        if (srt[[nonlinear_reduction]]@assay.used == assay) {
          message("nonlinear_reduction(", nonlinear_reduction, ") is already existed. Skip calculation.")
          reduc <- srt[[nonlinear_reduction]]
          Key(reduc) <- paste0(prefix, nonlinear_reduction, "_")
          srt[[paste0(prefix, nonlinear_reduction)]] <- reduc
          srt@misc[["Default_reduction"]] <- paste0(prefix, nonlinear_reduction)
          return(srt)
        } else {
          message("assay.used is ", srt[[nonlinear_reduction]]@assay.used, ", which is not the same as the ", assay, " specified. Recalculate the nonlinear reduction(umap)")
          nonlinear_reduction <- "umap"
        }
      }
    }
    # if (!is.null(neighbor_use) && !nonlinear_reduction %in% c("umap", "umap-naive", "fr")) {
    #   stop("'neighbor_use' only support 'umap', 'umap-naive' or 'fr' method")
    # }
    # if (!is.null(graph_use) && !nonlinear_reduction %in% c("umap", "umap-naive", "fr")) {
    #   stop("'graph_use' only support 'umap', 'umap-naive' or 'fr' method")
    # }
    fun_use <- switch(nonlinear_reduction,
      "umap" = "RunUMAP2",
      "umap-naive" = "RunUMAP2",
      "tsne" = "RunTSNE",
      "dm" = "RunDM",
      "phate" = "RunPHATE",
      "pacmap" = "RunPaCMAP",
      "trimap" = "RunTriMap",
      "largevis" = "RunLargeVis",
      "fr" = "RunFR"
    )
    components_nm <- switch(nonlinear_reduction,
      "umap" = "n.components",
      "umap-naive" = "n.components",
      "tsne" = "dim.embed",
      "dm" = "ndcs",
      "phate" = "n_components",
      "pacmap" = "n_components",
      "trimap" = "n_components",
      "largevis" = "n_components",
      "fr" = "ndim"
    )
    other_params <- switch(nonlinear_reduction,
      "umap" = list(umap.method = "uwot", return.model = TRUE),
      "umap-naive" = list(umap.method = "naive", return.model = TRUE),
      "tsne" = list(tsne.method = "Rtsne", num_threads = 0, check_duplicates = FALSE),
      "dm" = list(),
      "phate" = list(),
      "pacmap" = list(),
      "trimap" = list(),
      "largevis" = list(),
      "fr" = list()
    )
    nonlinear_reduction_sim <- toupper(gsub(pattern = "-.*", replacement = "", x = nonlinear_reduction))
    params <- list(
      object = srt, assay = assay, slot = slot, components_nm = nonlinear_reduction_dims,
      features = features, reduction = reduction_use, dims = reduction_dims,
      reduction.name = paste0(prefix, nonlinear_reduction_sim, nonlinear_reduction_dims, "D"),
      reduction.key = paste0(prefix, nonlinear_reduction_sim, nonlinear_reduction_dims, "D_"),
      verbose = verbose, seed.use = seed
    )
    if (!is.null(neighbor_use)) {
      params[["neighbor"]] <- neighbor_use
    }
    if (!is.null(graph_use)) {
      params[["graph"]] <- graph_use
    }
    names(params)[names(params) == "components_nm"] <- components_nm
    for (nm in names(other_params)) {
      params[[nm]] <- other_params[[nm]]
    }
    for (nm in names(nonlinear_reduction_params)) {
      params[[nm]] <- nonlinear_reduction_params[[nm]]
    }
    srt <- invoke(.fn = fun_use, .args = params)

    srt@reductions[[paste0(prefix, nonlinear_reduction_sim, nonlinear_reduction_dims, "D")]]@misc[["reduction_dims"]] <- reduction_dims
    srt@reductions[[paste0(prefix, nonlinear_reduction_sim, nonlinear_reduction_dims, "D")]]@misc[["reduction_use"]] <- reduction_use
    srt@misc[["Default_reduction"]] <- paste0(prefix, nonlinear_reduction_sim)
  }
  return(srt)
}

# ---- Seurat-function.R:27-29 : RunNMF ----
RunNMF <- function(object, ...) {
  UseMethod(generic = "RunNMF", object = object)
}

# ---- Seurat-function.R:35-63 : RunNMF.Seurat ----
RunNMF.Seurat <- function(object, assay = NULL, slot = "data", features = NULL, nbes = 50,
                          nmf.method = "RcppML", tol = 1e-5, maxit = 100, rev.nmf = FALSE,
                          ndims.print = 1:5, nfeatures.print = 30,
                          reduction.name = "nmf", reduction.key = "BE_",
                          verbose = TRUE, seed.use = 11, ...) {
  features <- features %||% VariableFeatures(object = object)
  assay <- assay %||% DefaultAssay(object = object)
  assay.data <- GetAssay(object = object, assay = assay)
  reduction.data <- RunNMF(
    object = assay.data,
    assay = assay,
    slot = slot,
    features = features,
    nbes = nbes,
    nmf.method = nmf.method,
    tol = tol,
    maxit = maxit,
    rev.nmf = rev.nmf,
    verbose = verbose,
    ndims.print = ndims.print,
    nfeatures.print = nfeatures.print,
    reduction.key = reduction.key,
    seed.use = seed.use,
    ...
  )
  object[[reduction.name]] <- reduction.data
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:70-100 : RunNMF.Assay ----
RunNMF.Assay <- function(object, assay = NULL, slot = "data", features = NULL, nbes = 50,
                         nmf.method = "RcppML", tol = 1e-5, maxit = 100, rev.nmf = FALSE,
                         ndims.print = 1:5, nfeatures.print = 30,
                         reduction.key = "BE_", verbose = TRUE, seed.use = 11,
                         ...) {
  features <- features %||% VariableFeatures(object = object)
  data.use <- GetAssayData(object = object, slot = slot)
  features.var <- apply(
    X = data.use[features, ], MARGIN = 1,
    FUN = var
  )
  features.keep <- features[features.var > 0]
  data.use <- data.use[features.keep, ]
  reduction.data <- RunNMF(
    object = data.use,
    assay = assay,
    slot = slot,
    nbes = nbes,
    nmf.method = nmf.method,
    tol = tol,
    maxit = maxit,
    rev.nmf = rev.nmf,
    verbose = verbose,
    ndims.print = ndims.print,
    nfeatures.print = nfeatures.print,
    reduction.key = reduction.key,
    seed.use = seed.use,
    ...
  )
  return(reduction.data)
}

# ---- Seurat-function.R:108-162 : RunNMF.default ----
RunNMF.default <- function(object, assay = NULL, slot = "data", nbes = 50,
                           nmf.method = "RcppML", tol = 1e-5, maxit = 100, rev.nmf = FALSE,
                           ndims.print = 1:5, nfeatures.print = 30,
                           reduction.key = "BE_", verbose = TRUE, seed.use = 11, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }
  if (rev.nmf) {
    object <- t(object)
  }
  nbes <- min(nbes, nrow(x = object) - 1)
  if (nmf.method == "RcppML") {
    check_R("zdebruine/RcppML")
    options("RcppML.verbose" = FALSE)
    options("RcppML.threads" = 0)
    if (!"package:Matrix" %in% search()) {
      attachNamespace("Matrix")
    }
    nmf.results <- RcppML::nmf(
      t(object),
      k = nbes, tol = tol, maxit = maxit,
      verbose = verbose, ...
    )
    cell.embeddings <- nmf.results$w
    feature.loadings <- t(nmf.results$h)
  }
  if (nmf.method == "NMF") {
    check_R("NMF")
    seed <- NMF::seed
    nmf.results <- NMF::nmf(x = as_matrix(t(object)), rank = nbes)
    cell.embeddings <- nmf.results@fit@W
    feature.loadings <- t(nmf.results@fit@H)
  }

  rownames(x = feature.loadings) <- rownames(x = object)
  colnames(x = feature.loadings) <- paste0(reduction.key, 1:nbes)
  rownames(x = cell.embeddings) <- colnames(x = object)
  colnames(x = cell.embeddings) <- colnames(x = feature.loadings)
  reduction.data <- CreateDimReducObject(
    embeddings = cell.embeddings,
    loadings = feature.loadings,
    assay = assay,
    key = reduction.key,
    misc = list(slot = slot, nmf.results = nmf.results)
  )
  if (verbose) {
    msg <- capture.output(print(
      x = reduction.data,
      dims = ndims.print,
      nfeatures = nfeatures.print
    ))
    message(paste(msg, collapse = "\n"))
  }
  return(reduction.data)
}

# ---- Seurat-function.R:187-189 : RunMDS ----
RunMDS <- function(object, ...) {
  UseMethod(generic = "RunMDS", object = object)
}

# ---- Seurat-function.R:195-220 : RunMDS.Seurat ----
RunMDS.Seurat <- function(object, assay = NULL, slot = "data",
                          features = NULL, nmds = 50, dist.method = "euclidean", mds.method = "cmdscale",
                          rev.mds = FALSE,
                          reduction.name = "mds", reduction.key = "MDS_",
                          verbose = TRUE, seed.use = 11, ...) {
  features <- features %||% VariableFeatures(object = object)
  assay <- assay %||% DefaultAssay(object = object)
  assay.data <- GetAssay(object = object, assay = assay)
  reduction.data <- RunMDS(
    object = assay.data,
    assay = assay,
    slot = slot,
    features = features,
    nmds = nmds,
    dist.method = dist.method,
    mds.method = mds.method,
    rev.mds = rev.mds,
    verbose = verbose,
    reduction.key = reduction.key,
    seed.use = seed.use,
    ...
  )
  object[[reduction.name]] <- reduction.data
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:227-253 : RunMDS.Assay ----
RunMDS.Assay <- function(object, assay = NULL, slot = "data",
                         features = NULL, nmds = 50, dist.method = "euclidean", mds.method = "cmdscale",
                         rev.mds = FALSE,
                         reduction.key = "MDS_", verbose = TRUE, seed.use = 11, ...) {
  features <- features %||% VariableFeatures(object = object)
  data.use <- GetAssayData(object = object, slot = slot)
  features.var <- apply(
    X = data.use[features, ], MARGIN = 1,
    FUN = var
  )
  features.keep <- features[features.var > 0]
  data.use <- data.use[features.keep, ]
  reduction.data <- RunMDS(
    object = data.use,
    assay = assay,
    slot = slot,
    nmds = nmds,
    dist.method = dist.method,
    mds.method = mds.method,
    rev.mds = rev.mds,
    verbose = verbose,
    reduction.key = reduction.key,
    seed.use = seed.use,
    ...
  )
  return(reduction.data)
}

# ---- Seurat-function.R:263-298 : RunMDS.default ----
RunMDS.default <- function(object, assay = NULL, slot = "data",
                           nmds = 50, dist.method = "euclidean", mds.method = "cmdscale",
                           rev.mds = FALSE,
                           reduction.key = "MDS_", verbose = TRUE, seed.use = 11, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }
  if (rev.mds) {
    object <- t(object)
  }
  nmds <- min(nmds, nrow(x = object) - 1)
  x <- t(as_matrix(object))
  cell.dist <- as.dist(dist(x = x, method = dist.method))
  if (mds.method == "cmdscale") {
    mds.results <- cmdscale(cell.dist, k = nmds, eig = TRUE, ...)
  }
  if (mds.method == "isoMDS") {
    check_R("MASS")
    mds.results <- MASS::isoMDS(cell.dist, k = nmds, ...)
  }
  if (mds.method == "sammon") {
    check_R("MASS")
    mds.results <- MASS::sammon(cell.dist, k = nmds, ...)
  }
  cell.embeddings <- mds.results$points

  rownames(x = cell.embeddings) <- colnames(x = object)
  colnames(x = cell.embeddings) <- paste0(reduction.key, 1:nmds)
  reduction.data <- CreateDimReducObject(
    embeddings = cell.embeddings,
    assay = assay,
    key = reduction.key,
    misc = list(slot = slot, mds.results = mds.results)
  )
  return(reduction.data)
}

# ---- Seurat-function.R:323-325 : RunGLMPCA ----
RunGLMPCA <- function(object, ...) {
  UseMethod(generic = "RunGLMPCA", object = object)
}

# ---- Seurat-function.R:331-355 : RunGLMPCA.Seurat ----
RunGLMPCA.Seurat <- function(object, assay = NULL, slot = "counts",
                             features = NULL, L = 5, fam = c("poi", "nb", "nb2", "binom", "mult", "bern"),
                             rev.gmlpca = FALSE, ndims.print = 1:5, nfeatures.print = 30,
                             reduction.name = "glmpca", reduction.key = "GLMPC_",
                             verbose = TRUE, seed.use = 11, ...) {
  features <- features %||% VariableFeatures(object = object)
  assay <- assay %||% DefaultAssay(object = object)
  assay.data <- GetAssay(object = object, assay = assay)
  reduction.data <- RunGLMPCA(
    object = assay.data,
    assay = assay,
    slot = slot,
    L = L,
    fam = fam,
    rev.gmlpca = rev.gmlpca,
    ndims.print = ndims.print,
    nfeatures.print = nfeatures.print,
    reduction.key = reduction.key,
    verbose = verbose,
    ...
  )
  object[[reduction.name]] <- reduction.data
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:362-388 : RunGLMPCA.Assay ----
RunGLMPCA.Assay <- function(object, assay = NULL, slot = "counts",
                            features = NULL, L = 5, fam = c("poi", "nb", "nb2", "binom", "mult", "bern"),
                            rev.gmlpca = FALSE, ndims.print = 1:5, nfeatures.print = 30,
                            reduction.key = "GLMPC_", verbose = TRUE, seed.use = 11, ...) {
  features <- features %||% VariableFeatures(object = object)
  data.use <- GetAssayData(object = object, slot = slot)
  features.var <- apply(
    X = data.use[features, ], MARGIN = 1,
    FUN = var
  )
  features.keep <- features[features.var > 0]
  data.use <- data.use[features.keep, ]
  reduction.data <- RunGLMPCA(
    object = data.use,
    assay = assay,
    slot = slot,
    L = L,
    fam = fam,
    rev.gmlpca = rev.gmlpca,
    ndims.print = ndims.print,
    nfeatures.print = nfeatures.print,
    reduction.key = reduction.key,
    verbose = verbose,
    ...
  )
  return(reduction.data)
}

# ---- Seurat-function.R:394-430 : RunGLMPCA.default ----
RunGLMPCA.default <- function(object, assay = NULL, slot = "counts",
                              features = NULL, L = 5, fam = c("poi", "nb", "nb2", "binom", "mult", "bern"),
                              rev.gmlpca = FALSE, ndims.print = 1:5, nfeatures.print = 30,
                              reduction.key = "GLMPC_", verbose = TRUE, seed.use = 11, ...) {
  check_R("glmpca")
  if (inherits(object, "dgCMatrix")) {
    object <- as_matrix(object)
  }
  fam <- match.arg(fam)
  glmpca_results <- glmpca::glmpca(Y = object, L = L, fam = fam, ...)
  glmpca_dimnames <- paste0(reduction.key, seq_len(L))
  factors <- as_matrix(glmpca_results$factors)
  loadings <- as_matrix(glmpca_results$loadings)
  colnames(x = factors) <- glmpca_dimnames
  colnames(x = loadings) <- glmpca_dimnames
  factors_l2_norm <- sqrt(colSums(factors^2))
  class(glmpca_results) <- NULL
  glmpca_results$factors <- glmpca_results$loadings <- NULL
  reduction.data <- CreateDimReducObject(
    embeddings = factors,
    key = reduction.key,
    loadings = loadings,
    stdev = factors_l2_norm,
    assay = assay,
    global = TRUE,
    misc = list(slot = slot, glmpca.results = glmpca_results)
  )
  if (verbose) {
    msg <- capture.output(print(
      x = reduction.data,
      dims = ndims.print,
      nfeatures = nfeatures.print
    ))
    message(paste(msg, collapse = "\n"))
  }
  return(reduction.data)
}

# ---- Seurat-function.R:458-460 : RunDM ----
RunDM <- function(object, ...) {
  UseMethod(generic = "RunDM", object = object)
}

# ---- Seurat-function.R:466-511 : RunDM.Seurat ----
RunDM.Seurat <- function(object,
                         reduction = "pca", dims = 1:30,
                         features = NULL, assay = NULL, slot = "data",
                         ndcs = 2, sigma = "local", k = 30, dist.method = "euclidean",
                         reduction.name = "dm", reduction.key = "DM_",
                         verbose = TRUE, seed.use = 11, ...) {
  if (!is.null(x = features)) {
    assay <- assay %||% DefaultAssay(object = object)
    data.use <- as_matrix(t(x = GetAssayData(object = object, slot = slot, assay = assay)[features, , drop = FALSE]))
    if (ncol(x = data.use) < ndcs) {
      stop("Please provide as many or more features than ndcs: ",
        length(x = features), " features provided, ",
        ndcs, " Diffusion components requested",
        call. = FALSE
      )
    }
  } else if (!is.null(x = dims)) {
    data.use <- Embeddings(object[[reduction]])[, dims]
    assay <- DefaultAssay(object = object[[reduction]])
    if (length(x = dims) < ndcs) {
      stop("Please provide as many or more dims than ndcs: ",
        length(x = dims), " dims provided, ", ndcs,
        " DiffusionMap components requested",
        call. = FALSE
      )
    }
  } else {
    stop("Please specify one of dims, features")
  }
  reduction.data <- RunDM(
    object = data.use,
    assay = assay,
    slot = slot,
    ndcs = ndcs,
    sigma = sigma,
    k = k,
    dist.method = dist.method,
    reduction.key = reduction.key,
    seed.use = seed.use,
    verbose = verbose,
    ...
  )
  object[[reduction.name]] <- reduction.data
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:518-538 : RunDM.default ----
RunDM.default <- function(object, assay = NULL, slot = "data",
                          ndcs = 2, sigma = "local", k = 30, dist.method = "euclidean",
                          reduction.key = "DM_", verbose = TRUE, seed.use = 11, ...) {
  check_R("destiny")
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }

  dm.results <- destiny::DiffusionMap(data = as_matrix(object), n_eigs = ndcs, sigma = sigma, k = k, distance = dist.method, verbose = verbose, ...)

  cell.embeddings <- dm.results@eigenvectors
  rownames(x = cell.embeddings) <- rownames(object)
  colnames(x = cell.embeddings) <- paste0(reduction.key, 1:ndcs)
  reduction <- CreateDimReducObject(
    embeddings = cell.embeddings,
    assay = assay,
    key = reduction.key,
    misc = list(slot = slot, dm.results = dm.results)
  )
  return(reduction)
}

# ---- Seurat-function.R:579-581 : RunUMAP2 ----
RunUMAP2 <- function(object, ...) {
  UseMethod(generic = "RunUMAP2", object = object)
}

# ---- Seurat-function.R:587-662 : RunUMAP2.Seurat ----
RunUMAP2.Seurat <- function(object,
                            reduction = "pca", dims = NULL, features = NULL, neighbor = NULL, graph = NULL,
                            assay = NULL, slot = "data",
                            umap.method = "uwot", reduction.model = NULL, n_threads = NULL,
                            return.model = FALSE, n.neighbors = 30L, n.components = 2L,
                            metric = "cosine", n.epochs = 200L, spread = 1, min.dist = 0.3,
                            set.op.mix.ratio = 1, local.connectivity = 1L, negative.sample.rate = 5L,
                            a = NULL, b = NULL, learning.rate = 1, repulsion.strength = 1,
                            reduction.name = "umap", reduction.key = "UMAP_",
                            verbose = TRUE, seed.use = 11L, ...) {
  if (sum(c(is.null(x = dims), is.null(x = features), is.null(neighbor), is.null(x = graph))) == 4) {
    stop("Please specify only one of the following arguments: dims, features, neighbor or graph")
  }
  if (!is.null(x = features)) {
    assay <- assay %||% DefaultAssay(object = object)
    data.use <- as_matrix(t(x = GetAssayData(object = object, slot = slot, assay = assay)[features, , drop = FALSE]))
    if (ncol(x = data.use) < n.components) {
      stop(
        "Please provide as many or more features than n.components: ",
        length(x = features),
        " features provided, ",
        n.components,
        " UMAP components requested",
        call. = FALSE
      )
    }
  } else if (!is.null(x = dims)) {
    data.use <- as_matrix(Embeddings(object[[reduction]])[, dims])
    assay <- DefaultAssay(object = object[[reduction]])
    if (length(x = dims) < n.components) {
      stop(
        "Please provide as many or more dims than n.components: ",
        length(x = dims),
        " dims provided, ",
        n.components,
        " UMAP components requested",
        call. = FALSE
      )
    }
  } else if (!is.null(x = neighbor)) {
    if (!inherits(x = object[[neighbor]], what = "Neighbor")) {
      stop(
        "Please specify a Neighbor object name, ",
        "instead of the name of a ",
        class(object[[neighbor]]),
        " object",
        call. = FALSE
      )
    }
    data.use <- object[[neighbor]]
  } else if (!is.null(x = graph)) {
    if (!inherits(x = object[[graph]], what = "Graph")) {
      stop(
        "Please specify a Graph object name, ",
        "instead of the name of a ",
        class(object[[graph]]),
        " object",
        call. = FALSE
      )
    }
    data.use <- object[[graph]]
  } else {
    stop("Please specify one of dims, features, neighbor, or graph")
  }
  object[[reduction.name]] <- RunUMAP2(
    object = data.use, assay = assay,
    umap.method = umap.method, reduction.model = reduction.model,
    return.model = return.model, n.neighbors = n.neighbors, n.components = n.components,
    metric = metric, n.epochs = n.epochs, spread = spread, min.dist = min.dist,
    set.op.mix.ratio = set.op.mix.ratio, local.connectivity = local.connectivity, negative.sample.rate = negative.sample.rate,
    a = a, b = b, learning.rate = learning.rate, repulsion.strength = repulsion.strength,
    seed.use = seed.use, verbose = verbose, reduction.key = reduction.key
  )
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:669-1119 : RunUMAP2.default ----
RunUMAP2.default <- function(object, assay = NULL,
                             umap.method = "uwot", reduction.model = NULL, n_threads = NULL,
                             return.model = FALSE, n.neighbors = 30L, n.components = 2L,
                             metric = "cosine", n.epochs = 200L, spread = 1, min.dist = 0.3,
                             set.op.mix.ratio = 1, local.connectivity = 1L, negative.sample.rate = 5L,
                             a = NULL, b = NULL, learning.rate = 1, repulsion.strength = 1,
                             reduction.key = "UMAP_", verbose = TRUE, seed.use = 11L, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }
  if (return.model) {
    if (verbose) {
      message("UMAP will return its model")
    }
  }
  if (!is.null(x = reduction.model)) {
    if (verbose) {
      message("Running UMAP projection")
    }
    if (is.null(x = reduction.model) || !inherits(x = reduction.model, what = "DimReduc")) {
      stop("If running projection UMAP, please pass a DimReduc object with the model stored to reduction.model.",
        call. = FALSE
      )
    }
    model <- Misc(object = reduction.model, slot = "model")
    if (length(x = model) == 0) {
      stop("The provided reduction.model does not have a model stored.",
        call. = FALSE
      )
    }
    umap.method <- ifelse("layout" %in% names(model), "naive-predict", "uwot-predict")
  }
  n.epochs <- as.integer(n.epochs)
  n.neighbors <- as.integer(n.neighbors)
  n.components <- as.integer(n.components)
  local.connectivity <- as.integer(local.connectivity)
  negative.sample.rate <- as.integer(negative.sample.rate)

  if (inherits(x = object, what = "Neighbor")) {
    object <- list(idx = Indices(object), dist = Distances(object))
  }

  if (umap.method == "naive") {
    umap.config <- umap::umap.defaults
    umap.config$n_neighbors <- n.neighbors
    umap.config$n_components <- n.components
    umap.config$metric <- metric
    umap.config$n_epochs <- ifelse(is.null(n.epochs), 200, n.epochs)
    umap.config$spread <- spread
    umap.config$min_dist <- min.dist
    umap.config$set_op_mix_ratio <- set.op.mix.ratio
    umap.config$local_connectivity <- local.connectivity
    umap.config$a <- ifelse(is.null(a), NA, a)
    umap.config$b <- ifelse(is.null(b), NA, b)
    umap.config$gamma <- repulsion.strength
    umap.config$alpha <- learning.rate
    umap.config$negative_sample_rate <- negative.sample.rate
    umap.config$random_state <- seed.use
    umap.config$transform_state <- seed.use
    umap.config$verbose <- verbose
    if (is.na(umap.config$a) || is.na(umap.config$b)) {
      umap.config[c("a", "b")] <- umap:::find.ab.params(umap.config$spread, umap.config$min_dist)
      umap.config$min_dist <- umap::umap.defaults$min_dist
    }

    if (inherits(x = object, what = "dist")) {
      knn <- umap:::knn.from.dist(d = object, k = n.neighbors)
      out <- umap::umap(
        d = matrix(nrow = nrow(object)),
        config = umap.config, knn = knn
      )
      embeddings <- out$layout
      rownames(x = embeddings) <- attr(object, "Labels")
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      if (return.model) {
        Misc(reduction, slot = "model") <- out
      }
      return(reduction)
    }
    if (inherits(x = object, what = "list")) {
      # object <- srt@neighbors$Seurat.nn
      # object <- list(idx = Indices(object), dist = Distances(object))

      # j <- as.numeric(t(object$idx))
      # i <- ((1:length(j)) - 1) %/% ncol(object$idx) + 1
      # graph <- as(object = sparseMatrix(
      #   i = i, j = j, x = as.numeric(t(object$dist)),
      #   dims = c(nrow(x = object$idx), nrow(x = object$idx))
      # ), Class = "Graph")
      # rownames(x = graph) <- rownames(object$idx)
      # colnames(x = graph) <- rownames(object$idx)
      # object <- graph
      knn <- umap::umap.knn(indexes = object[["idx"]], distances = object[["dist"]])
      out <- umap::umap(
        d = matrix(nrow = nrow(object[["idx"]])),
        config = umap.config, knn = knn
      )
      embeddings <- out$layout
      rownames(x = embeddings) <- rownames(object[["idx"]])
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      if (return.model) {
        Misc(reduction, slot = "model") <- out
      }
      return(reduction)
    }
    if (inherits(x = object, what = "Graph")) {
      if (!inherits(object, "dgCMatrix")) {
        object <- as.sparse(object[1:nrow(object), ])
      }
      diag(object) <- 0
      if (ncol(object) > 10000) {
        obs_sample <- sample(1:ncol(object), size = 10000)
      } else {
        obs_sample <- 1:ncol(object)
      }
      if (!isSymmetric(as_matrix(object[obs_sample, obs_sample]))) {
        stop("Graph must be a symmetric matrix.")
      }

      coo <- matrix(ncol = 3, nrow = length(object@x))
      coo[, 1] <- rep(1:ncol(object), diff(object@p))
      coo[, 2] <- object@i + 1
      coo[, 3] <- object@x
      colnames(coo) <- c("from", "to", "value")
      coo <- coo[order(coo[, 1], coo[, 2]), ]
      graph <- list(coo = coo, names = rownames(object), n.elements = nrow(object))
      class(graph) <- "coo"

      # diag(object) <- 0
      # if (inherits(object, what = "dgCMatrix")) {
      #   object <- as_matrix(object)
      # } else {
      #   object <- as_matrix(object)
      # }
      # if (!isSymmetric(object)) {
      #   stop("Graph must be a symmetric matrix.")
      # }
      # graph <- umap:::coo(object)
      # # coo <- function(x) {
      # #   if (!is(x, "Matrix")) {
      # #     stop("x must be a square matrix\n")
      # #   }
      # #   if (nrow(x) != ncol(x)) {
      # #     stop("x must be a square matrix\n")
      # #   }
      # #   nx <- nrow(x)
      # #   coo <- matrix(0, ncol = 3, nrow = nx * nx)
      # #   coo[, 1] <- rep(seq_len(nx), nx)
      # #   coo[, 2] <- rep(seq_len(nx), each = nx)
      # #   coo[, 3] <- as.vector(x)
      # #   colnames(coo) <- c("from", "to", "value")
      # #   coo <- coo[order(coo[, 1], coo[, 2]), ]
      # #   make.coo(coo, rownames(x), nrow(x))
      # # }
      # # make.coo <- function(x, names, n.elements) {
      # #   x <- x[, 1:3, drop = FALSE]
      # #   colnames(x) <- c("from", "to", "value")
      # #   result <- list(coo = x, names = names, n.elements = n.elements)
      # #   class(result) <- "coo"
      # #   result
      # # }

      umap.config$init <- "spectral"
      initial <- umap:::make.initial.embedding(V = graph$n.elements, config = umap.config, g = graph)
      embeddings <- umap:::naive.simplicial.set.embedding(g = graph, embedding = initial, config = umap.config)
      embeddings <- umap:::center.embedding(embeddings)
      rownames(x = embeddings) <- rownames(x = object)
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      if (return.model) {
        warning("return.model does not support 'Graph' input.", immediate. = TRUE)
      }
      return(reduction)
    }
    if (inherits(x = object, what = "matrix") || inherits(x = object, what = "Matrix")) {
      # object <- srt@reductions$Seuratpca@cell.embeddings
      out <- umap::umap(d = object, config = umap.config, method = "naive")
      embeddings <- out$layout
      rownames(x = embeddings) <- rownames(object)
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      if (return.model) {
        Misc(reduction, slot = "model") <- out
      }
      return(reduction)
    }
  }

  if (umap.method == "uwot") {
    if (inherits(x = object, what = "dist")) {
      embeddings <- uwot::umap(
        X = object, n_neighbors = n.neighbors, n_threads = n_threads, n_components = n.components,
        metric = metric, n_epochs = n.epochs, learning_rate = learning.rate,
        min_dist = min.dist, spread = spread, set_op_mix_ratio = set.op.mix.ratio,
        local_connectivity = local.connectivity, repulsion_strength = repulsion.strength,
        negative_sample_rate = negative.sample.rate,
        a = a, b = b, verbose = verbose,
        ret_model = FALSE
      )
      rownames(x = embeddings) <- attr(object, "Labels")
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      if (return.model) {
        warning("return.model does not support 'dist' input.", immediate. = TRUE)
      }
      return(reduction)
    }
    if (inherits(x = object, what = "list")) {
      # object <- srt@neighbors$Seurat.nn
      # object <- list(idx = Indices(object), dist = Distances(object))
      out <- uwot::umap(
        X = NULL, nn_method = object, n_threads = n_threads, n_components = n.components,
        metric = metric, n_epochs = n.epochs, learning_rate = learning.rate,
        min_dist = min.dist, spread = spread, set_op_mix_ratio = set.op.mix.ratio,
        local_connectivity = local.connectivity, repulsion_strength = repulsion.strength,
        negative_sample_rate = negative.sample.rate,
        a = a, b = b, verbose = verbose,
        ret_model = return.model
      )
      if (return.model) {
        embeddings <- out$embedding
      } else {
        embeddings <- out
      }
      rownames(x = embeddings) <- row.names(object[["idx"]])
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      if (return.model) {
        out$nn_index <- NULL
        Misc(reduction, slot = "model") <- out
      }
      return(reduction)
    }
    if (inherits(x = object, what = "Graph")) {
      if (!inherits(object, "dgCMatrix")) {
        object <- as.sparse(object[1:nrow(object), ])
      }
      diag(object) <- 0
      if (ncol(object) > 10000) {
        obs_sample <- sample(1:ncol(object), size = 10000)
      } else {
        obs_sample <- 1:ncol(object)
      }
      if (!isSymmetric(as_matrix(object[obs_sample, obs_sample]))) {
        stop("Graph must be a symmetric matrix.")
      }
      val <- split(object@x, rep(1:ncol(object), diff(object@p)))
      pos <- split(object@i + 1, rep(1:ncol(object), diff(object@p)))
      idx <- t(mapply(function(x, y) {
        out <- y[head(order(x, decreasing = TRUE), n.neighbors)]
        length(out) <- n.neighbors
        return(out)
      }, x = val, y = pos))
      connectivity <- t(mapply(function(x, y) {
        out <- y[head(order(x, decreasing = TRUE), n.neighbors)]
        length(out) <- n.neighbors
        out[is.na(out)] <- 0
        return(out)
      }, x = val, y = val))
      idx[is.na(idx)] <- sample(1:nrow(object), size = sum(is.na(idx)), replace = TRUE)
      nn <- list(idx = idx, dist = max(connectivity) - connectivity + min(diff(range(connectivity)), 1) / 1e50)
      # idx <- t(as_matrix(apply(object, 2, function(x) order(x, decreasing = TRUE)[1:n.neighbors])))
      # connectivity <- t(as_matrix(apply(object, 2, function(x) x[order(x, decreasing = TRUE)[1:n.neighbors]])))
      out <- uwot::umap(
        X = NULL, nn_method = nn, n_threads = n_threads, n_components = n.components,
        metric = metric, n_epochs = n.epochs, learning_rate = learning.rate,
        min_dist = min.dist, spread = spread, set_op_mix_ratio = set.op.mix.ratio,
        local_connectivity = local.connectivity, repulsion_strength = repulsion.strength,
        negative_sample_rate = negative.sample.rate,
        a = a, b = b, verbose = verbose,
        ret_model = return.model
      )
      if (return.model) {
        embeddings <- out$embedding
      } else {
        embeddings <- out
      }
      # object <- srt@graphs$BBKNN
      # object@x <- max(object@x) - object@x + 1e-10
      # min_neighbors <- min(rowSums(object > 0))
      # embeddings <- uwot::umap(
      #   X = object*100, n_neighbors = min(min_neighbors,n.neighbors), n_threads = 1, n_components = n.components,
      #   metric = metric, n_epochs = n.epochs, learning_rate = learning.rate,
      #   min_dist = min.dist, spread = spread, set_op_mix_ratio = set.op.mix.ratio,
      #   local_connectivity = local.connectivity, repulsion_strength = repulsion.strength,
      #   negative_sample_rate = negative.sample.rate,
      #   a = a, b = b, verbose = verbose,
      #   ret_model = FALSE
      # )
      rownames(x = embeddings) <- row.names(object)
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      if (return.model) {
        out$nn_index <- NULL
        Misc(reduction, slot = "model") <- out
      }
      return(reduction)
    }
    if (inherits(x = object, what = "matrix") || inherits(x = object, what = "Matrix")) {
      # object <- srt@reductions$Seuratpca@cell.embeddings
      out <- uwot::umap(
        X = object, n_neighbors = n.neighbors, n_threads = n_threads, n_components = n.components,
        metric = metric, n_epochs = n.epochs, learning_rate = learning.rate,
        min_dist = min.dist, spread = spread, set_op_mix_ratio = set.op.mix.ratio,
        local_connectivity = local.connectivity, repulsion_strength = repulsion.strength,
        negative_sample_rate = negative.sample.rate,
        a = a, b = b, verbose = verbose,
        ret_model = return.model
      )
      if (return.model) {
        embeddings <- out$embedding
      } else {
        embeddings <- out
      }
      rownames(x = embeddings) <- row.names(object)
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      if (return.model) {
        out$nn_index <- NULL
        Misc(reduction, slot = "model") <- out
      }
      return(reduction)
    }
  }

  if (umap.method == "naive-predict") {
    if (inherits(x = object, what = "matrix") || inherits(x = object, what = "Matrix")) {
      class(model) <- "umap"
      if (any(!colnames(model$data) %in% colnames(object))) {
        stop("query data must contain the same features with the model:\n", paste(head(colnames(model$data), 10), collapse = ","), " ......")
      }
      embeddings <- predict(model, object[, colnames(model$data)])
      rownames(x = embeddings) <- row.names(object)
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      return(reduction)
    } else {
      stop("naive umap model only support 'matrix' input.")
    }
  }

  if (umap.method == "uwot-predict") {
    if (inherits(x = object, what = "list")) {
      if (ncol(object[["idx"]]) != model$n_neighbors) {
        warning(
          "Number of neighbors between query and reference is not equal to the number of neighbros within reference"
        )
        model$n_neighbors <- ncol(object[["idx"]])
      }
      if (is.null(model$num_precomputed_nns) || model$num_precomputed_nns == 0) {
        model$num_precomputed_nns <- 1
      }
      embeddings <- uwot::umap_transform(
        X = NULL, nn_method = object, model = model, n_epochs = n.epochs,
        n_threads = n_threads, verbose = verbose
      )
      rownames(x = embeddings) <- row.names(object[["idx"]])
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      return(reduction)
    }
    if (inherits(x = object, what = "Graph")) {
      match_k <- t(as_matrix(apply(object, 2, function(x) order(x, decreasing = TRUE)[1:n.neighbors])))
      match_k_connectivity <- t(as_matrix(apply(object, 2, function(x) x[order(x, decreasing = TRUE)[1:n.neighbors]])))
      object <- list(idx = match_k, dist = max(match_k_connectivity) - match_k_connectivity)
      if (is.null(model$num_precomputed_nns) || model$num_precomputed_nns == 0) {
        model$num_precomputed_nns <- 1
      }
      embeddings <- uwot::umap_transform(
        X = NULL, nn_method = object, model = model, n_epochs = n.epochs,
        n_threads = n_threads, verbose = verbose
      )
      rownames(x = embeddings) <- row.names(object[["idx"]])
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      return(reduction)
    }
    if (inherits(x = object, what = "matrix") || inherits(x = object, what = "Matrix")) {
      embeddings <- uwot::umap_transform(
        X = object, model = model, n_epochs = n.epochs,
        n_threads = n_threads, verbose = verbose
      )
      rownames(x = embeddings) <- row.names(object)
      colnames(x = embeddings) <- paste0(reduction.key, 1:n.components)
      reduction <- CreateDimReducObject(
        embeddings = embeddings,
        key = reduction.key,
        assay = assay,
        global = TRUE
      )
      return(reduction)
    }
  }
}

# ---- Seurat-function.R:1151-1153 : RunPaCMAP ----
RunPaCMAP <- function(object, ...) {
  UseMethod(generic = "RunPaCMAP", object = object)
}

# ---- Seurat-function.R:1159-1207 : RunPaCMAP.Seurat ----
RunPaCMAP.Seurat <- function(object, reduction = "pca", dims = NULL, features = NULL,
                             assay = NULL, slot = "data",
                             n_components = 2, n.neighbors = NULL, MN_ratio = 0.5, FP_ratio = 2,
                             distance_method = "euclidean",
                             lr = 1, num_iters = 450L, apply_pca = TRUE, init = "random",
                             reduction.name = "pacmap", reduction.key = "PaCMAP_",
                             verbose = TRUE, seed.use = 11L, ...) {
  if (sum(c(is.null(x = dims), is.null(x = features))) < 1) {
    stop("Please specify only one of the following arguments: dims, features, or graph")
  }
  if (!is.null(x = features)) {
    assay <- assay %||% DefaultAssay(object = object)
    data.use <- as_matrix(t(x = GetAssayData(object = object, slot = slot, assay = assay)[features, , drop = FALSE]))
    if (ncol(x = data.use) < n_components) {
      stop(
        "Please provide as many or more features than n_components: ",
        length(x = features),
        " features provided, ",
        n_components,
        " PaCMAP components requested",
        call. = FALSE
      )
    }
  } else if (!is.null(x = dims)) {
    data.use <- Embeddings(object[[reduction]])[, dims]
    assay <- DefaultAssay(object = object[[reduction]])
    if (length(x = dims) < n_components) {
      stop(
        "Please provide as many or more dims than n_components: ",
        length(x = dims),
        " dims provided, ",
        n_components,
        " PaCMAP components requested",
        call. = FALSE
      )
    }
  } else {
    stop("Please specify one of dims or features")
  }
  object[[reduction.name]] <- RunPaCMAP(
    object = data.use, assay = assay,
    n_components = n_components, n.neighbors = n.neighbors, MN_ratio = MN_ratio, FP_ratio = FP_ratio,
    distance_method = distance_method,
    lr = lr, num_iters = num_iters, apply_pca = apply_pca, init = init,
    reduction.key = reduction.key, verbose = verbose, seed.use = seed.use
  )
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:1214-1244 : RunPaCMAP.default ----
RunPaCMAP.default <- function(object, assay = NULL,
                              n_components = 2, n.neighbors = NULL, MN_ratio = 0.5, FP_ratio = 2,
                              distance_method = "euclidean",
                              lr = 1, num_iters = 450L, apply_pca = TRUE, init = "random",
                              reduction.key = "PaCMAP_", verbose = TRUE, seed.use = 11L, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }

  check_Python("pacmap")
  pacmap <- import("pacmap")

  operator <- pacmap$PaCMAP(
    n_components = as.integer(n_components), n_neighbors = n.neighbors, MN_ratio = MN_ratio, FP_ratio = FP_ratio,
    distance = distance_method,
    lr = lr, num_iters = num_iters, apply_pca = apply_pca,
    verbose = verbose, random_state = as.integer(seed.use)
  )
  embedding <- operator$fit_transform(object, init = init)

  colnames(x = embedding) <- paste0(reduction.key, seq_len(ncol(x = embedding)))
  rownames(x = embedding) <- rownames(object)

  reduction <- CreateDimReducObject(
    embeddings = embedding,
    key = reduction.key,
    assay = assay,
    global = TRUE
  )
  return(reduction)
}

# ---- Seurat-function.R:1280-1282 : RunPHATE ----
RunPHATE <- function(object, ...) {
  UseMethod(generic = "RunPHATE", object = object)
}

# ---- Seurat-function.R:1288-1336 : RunPHATE.Seurat ----
RunPHATE.Seurat <- function(object, reduction = "pca", dims = NULL, features = NULL,
                            assay = NULL, slot = "data",
                            n_components = 2, knn = 5, decay = 40, n_landmark = 2000, t = "auto", gamma = 1,
                            n_pca = 100, knn_dist = "euclidean", knn_max = NULL, t_max = 100,
                            do_cluster = FALSE, n_clusters = "auto", max_clusters = 100,
                            reduction.name = "phate", reduction.key = "PHATE_",
                            verbose = TRUE, seed.use = 11L, ...) {
  if (sum(c(is.null(x = dims), is.null(x = features))) == 2) {
    stop("Please specify only one of the following arguments: dims, features")
  }
  if (!is.null(x = features)) {
    assay <- assay %||% DefaultAssay(object = object)
    data.use <- as_matrix(t(x = GetAssayData(object = object, slot = slot, assay = assay)[features, , drop = FALSE]))
    if (ncol(x = data.use) < n_components) {
      stop(
        "Please provide as many or more features than n_components: ",
        length(x = features),
        " features provided, ",
        n_components,
        " PHATE components requested",
        call. = FALSE
      )
    }
  } else if (!is.null(x = dims)) {
    data.use <- Embeddings(object[[reduction]])[, dims]
    assay <- DefaultAssay(object = object[[reduction]])
    if (length(x = dims) < n_components) {
      stop(
        "Please provide as many or more dims than n_components: ",
        length(x = dims),
        " dims provided, ",
        n_components,
        " PHATE components requested",
        call. = FALSE
      )
    }
  } else {
    stop("Please specify one of dims or features")
  }
  object[[reduction.name]] <- RunPHATE(
    object = data.use, assay = assay,
    n_components = n_components, knn = knn, decay = decay, n_landmark = n_landmark, t = t, gamma = gamma,
    n_pca = n_pca, knn_dist = knn_dist, knn_max = knn_max, t_max = t_max,
    do_cluster = do_cluster, n_clusters = n_clusters, max_clusters = max_clusters,
    reduction.key = reduction.key, verbose = verbose, seed.use = seed.use
  )
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:1344-1399 : RunPHATE.default ----
RunPHATE.default <- function(object, assay = NULL,
                             n_components = 2, knn = 5, decay = 40, n_landmark = 2000, t = "auto", gamma = 1,
                             n_pca = 100, knn_dist = "euclidean", knn_max = NULL, t_max = 100,
                             do_cluster = FALSE, n_clusters = "auto", max_clusters = 100,
                             reduction.key = "PHATE_", verbose = TRUE, seed.use = 11L, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }

  check_Python("phate")
  phate <- import("phate")

  if (is.numeric(knn_max) && length(knn_max) > 0) {
    knn_max <- as.integer(knn_max)
  } else {
    knn_max <- NULL
  }
  operator <- phate$PHATE(
    n_components = as.integer(n_components),
    knn = as.integer(knn),
    decay = as.integer(decay),
    n_landmark = as.integer(n_landmark),
    t = as.character(t),
    gamma = as.numeric(gamma),
    n_pca = as.integer(n_pca),
    knn_dist = as.character(knn_dist),
    knn_max = knn_max,
    random_state = as.integer(seed.use),
    verbose = as.integer(verbose),
    ...
  )
  embedding <- operator$fit_transform(object, t_max = as.integer(t_max))
  colnames(x = embedding) <- paste0(reduction.key, seq_len(ncol(x = embedding)))
  rownames(x = embedding) <- rownames(object)

  reduction <- CreateDimReducObject(
    embeddings = embedding,
    key = reduction.key,
    assay = assay,
    global = TRUE
  )
  if (isTRUE(do_cluster)) {
    if (is.numeric(n_clusters)) {
      n_clusters <- as.integer(n_clusters)
    }
    if (is.numeric(max_clusters)) {
      max_clusters <- as.integer(max_clusters)
    }
    clusters <- phate$cluster$kmeans(operator, n_clusters = n_clusters, max_clusters = max_clusters, random_state = as.integer(seed.use))
    clusters <- clusters + 1
    clusters <- factor(clusters, levels = sort(unique(clusters)))
    names(clusters) <- rownames(embedding)
    Misc(reduction, slot = "clusters") <- clusters
  }
  return(reduction)
}

# ---- Seurat-function.R:1431-1433 : RunTriMap ----
RunTriMap <- function(object, ...) {
  UseMethod(generic = "RunTriMap", object = object)
}

# ---- Seurat-function.R:1439-1487 : RunTriMap.Seurat ----
RunTriMap.Seurat <- function(object, reduction = "pca", dims = NULL, features = NULL,
                             assay = NULL, slot = "data",
                             n_components = 2, n_inliers = 12, n_outliers = 4, n_random = 3, distance_method = "euclidean",
                             lr = 0.1, n_iters = 400,
                             apply_pca = TRUE, opt_method = "dbd",
                             reduction.name = "trimap", reduction.key = "TriMap_",
                             verbose = TRUE, seed.use = 11L, ...) {
  if (sum(c(is.null(x = dims), is.null(x = features))) == 2) {
    stop("Please specify only one of the following arguments: dims, features")
  }
  if (!is.null(x = features)) {
    assay <- assay %||% DefaultAssay(object = object)
    data.use <- as_matrix(t(x = GetAssayData(object = object, slot = slot, assay = assay)[features, , drop = FALSE]))
    if (ncol(x = data.use) < n_components) {
      stop(
        "Please provide as many or more features than n_components: ",
        length(x = features),
        " features provided, ",
        n_components,
        " TriMap components requested",
        call. = FALSE
      )
    }
  } else if (!is.null(x = dims)) {
    data.use <- Embeddings(object[[reduction]])[, dims]
    assay <- DefaultAssay(object = object[[reduction]])
    if (length(x = dims) < n_components) {
      stop(
        "Please provide as many or more dims than n_components: ",
        length(x = dims),
        " dims provided, ",
        n_components,
        " TriMap components requested",
        call. = FALSE
      )
    }
  } else {
    stop("Please specify one of dims, features")
  }
  object[[reduction.name]] <- RunTriMap(
    object = data.use, assay = assay,
    n_components = n_components, n_inliers = n_inliers, n_outliers = n_outliers, n_random = n_random, distance_method = distance_method,
    lr = lr, n_iters = n_iters,
    apply_pca = apply_pca, opt_method = opt_method,
    reduction.key = reduction.key, verbose = verbose, seed.use = seed.use
  )
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:1494-1523 : RunTriMap.default ----
RunTriMap.default <- function(object, assay = NULL,
                              n_components = 2, n_inliers = 12, n_outliers = 4, n_random = 3, distance_method = "euclidean",
                              lr = 0.1, n_iters = 400,
                              apply_pca = TRUE, opt_method = "dbd",
                              reduction.key = "TriMap_", verbose = TRUE, seed.use = 11L, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }

  check_Python("trimap")
  trimap <- import("trimap")

  operator <- trimap$TRIMAP(
    n_dims = as.integer(n_components), n_inliers = as.integer(n_inliers), n_outliers = as.integer(n_outliers), n_random = as.integer(n_random), distance = distance_method,
    lr = lr, n_iters = as.integer(n_iters),
    apply_pca = apply_pca, opt_method = opt_method, verbose = verbose, ...
  )
  embedding <- operator$fit_transform(object)
  colnames(x = embedding) <- paste0(reduction.key, seq_len(ncol(x = embedding)))
  if (inherits(x = object, what = "dist")) {
    rownames(x = embedding) <- attr(object, "Labels")
  } else {
    rownames(x = embedding) <- rownames(object)
  }
  reduction <- CreateDimReducObject(
    embeddings = embedding,
    key = reduction.key, assay = assay, global = TRUE
  )
  return(reduction)
}

# ---- Seurat-function.R:1550-1552 : RunLargeVis ----
RunLargeVis <- function(object, ...) {
  UseMethod(generic = "RunLargeVis", object = object)
}

# ---- Seurat-function.R:1558-1612 : RunLargeVis.Seurat ----
RunLargeVis.Seurat <- function(object, reduction = "pca", dims = NULL, features = NULL,
                               assay = NULL, slot = "data",
                               perplexity = 50, n_neighbors = perplexity * 3, n_components = 2, metric = "euclidean",
                               n_epochs = -1, learning_rate = 1, scale = "maxabs", init = "lvrandom", init_sdev = NULL,
                               repulsion_strength = 7, negative_sample_rate = 5, nn_method = NULL, n_trees = 50,
                               search_k = 2 * n_neighbors * n_trees, n_threads = NULL, n_sgd_threads = 0, grain_size = 1,
                               kernel = "gauss", pca = NULL, pca_center = TRUE, pcg_rand = TRUE, fast_sgd = FALSE,
                               batch = FALSE, opt_args = NULL, epoch_callback = NULL, pca_method = NULL,
                               reduction.name = "largevis", reduction.key = "LargeVis_",
                               verbose = TRUE, seed.use = 11L, ...) {
  if (sum(c(is.null(x = dims), is.null(x = features))) == 3) {
    stop("Please specify only one of the following arguments: dims, features")
  }
  if (!is.null(x = features)) {
    assay <- assay %||% DefaultAssay(object = object)
    data.use <- as_matrix(t(x = GetAssayData(object = object, slot = slot, assay = assay)[features, , drop = FALSE]))
    if (ncol(x = data.use) < n_components) {
      stop(
        "Please provide as many or more features than n_components: ",
        length(x = features),
        " features provided, ",
        n_components,
        " LargeVis components requested",
        call. = FALSE
      )
    }
  } else if (!is.null(x = dims)) {
    data.use <- Embeddings(object[[reduction]])[, dims]
    assay <- DefaultAssay(object = object[[reduction]])
    if (length(x = dims) < n_components) {
      stop(
        "Please provide as many or more dims than n_components: ",
        length(x = dims),
        " dims provided, ",
        n_components,
        " LargeVis components requested",
        call. = FALSE
      )
    }
  } else {
    stop("Please specify one of dims, features")
  }
  object[[reduction.name]] <- RunLargeVis(
    object = data.use, assay = assay,
    perplexity = perplexity, n_neighbors = n_neighbors, n_components = n_components, metric = metric,
    n_epochs = n_epochs, learning_rate = learning_rate, scale = scale, init = init, init_sdev = init_sdev,
    repulsion_strength = repulsion_strength, negative_sample_rate = negative_sample_rate, nn_method = nn_method, n_trees = n_trees,
    search_k = search_k, n_threads = n_threads, n_sgd_threads = n_sgd_threads, grain_size = grain_size,
    kernel = kernel, pca = pca, pca_center = pca_center, pcg_rand = pcg_rand, fast_sgd = fast_sgd,
    batch = batch, opt_args = opt_args, epoch_callback = epoch_callback, pca_method = pca_method,
    reduction.key = reduction.key, verbose = verbose, seed.use = seed.use
  )
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:1618-1650 : RunLargeVis.default ----
RunLargeVis.default <- function(object, assay = NULL,
                                perplexity = 50, n_neighbors = perplexity * 3, n_components = 2, metric = "euclidean",
                                n_epochs = -1, learning_rate = 1, scale = "maxabs", init = "lvrandom", init_sdev = NULL,
                                repulsion_strength = 7, negative_sample_rate = 5, nn_method = NULL, n_trees = 50,
                                search_k = 2 * n_neighbors * n_trees, n_threads = NULL, n_sgd_threads = 0, grain_size = 1,
                                kernel = "gauss", pca = NULL, pca_center = TRUE, pcg_rand = TRUE, fast_sgd = FALSE,
                                batch = FALSE, opt_args = NULL, epoch_callback = NULL, pca_method = NULL,
                                reduction.key = "LargeVis_", verbose = TRUE, seed.use = 11L, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }

  embedding <- uwot::lvish(
    X = object, perplexity = perplexity, n_neighbors = n_neighbors, n_components = n_components, metric = metric,
    n_epochs = n_epochs, learning_rate = learning_rate, scale = scale, init = init, init_sdev = init_sdev,
    repulsion_strength = repulsion_strength, negative_sample_rate = negative_sample_rate, nn_method = nn_method, n_trees = n_trees,
    search_k = search_k, n_threads = n_threads, n_sgd_threads = n_sgd_threads, grain_size = grain_size,
    kernel = kernel, pca = pca, pca_center = pca_center, pcg_rand = pcg_rand, fast_sgd = fast_sgd,
    verbose = verbose, batch = batch, opt_args = opt_args, epoch_callback = epoch_callback, pca_method = pca_method,
    ...
  )
  colnames(x = embedding) <- paste0(reduction.key, seq_len(ncol(x = embedding)))
  if (inherits(x = object, what = "dist")) {
    rownames(x = embedding) <- attr(object, "Labels")
  } else {
    rownames(x = embedding) <- rownames(object)
  }
  reduction <- CreateDimReducObject(
    embeddings = embedding,
    key = reduction.key, assay = assay, global = TRUE
  )
  return(reduction)
}

# ---- Seurat-function.R:1678-1680 : RunFR ----
RunFR <- function(object, ...) {
  UseMethod(generic = "RunFR", object = object)
}

# ---- Seurat-function.R:1686-1738 : RunFR.Seurat ----
RunFR.Seurat <- function(object, reduction = NULL, dims = NULL, features = NULL,
                         assay = NULL, slot = "data",
                         graph = NULL, neighbor = NULL,
                         k.param = 20, ndim = 2, niter = 500,
                         reduction.name = "FR", reduction.key = "FR_",
                         verbose = TRUE, seed.use = 11L, ...) {
  if (sum(c(is.null(x = dims), is.null(x = features), is.null(neighbor), is.null(x = graph))) == 4) {
    stop("Please specify only one of the following arguments: dims, features, neighbor or graph")
  }
  if (!is.null(x = graph)) {
    if (!inherits(x = object[[graph]], what = "Graph")) {
      stop(
        "Please specify a Graph object name, ",
        "instead of the name of a ",
        class(object[[graph]]),
        " object",
        call. = FALSE
      )
    }
    data.use <- object[[graph]]
  } else if (!is.null(x = neighbor)) {
    if (!inherits(x = object[[neighbor]], what = "Neighbor")) {
      stop(
        "Please specify a Neighbor object name, ",
        "instead of the name of a ",
        class(object[[neighbor]]),
        " object",
        call. = FALSE
      )
    }
    data.use <- object[[neighbor]]
  } else if (!is.null(x = features)) {
    assay <- assay %||% DefaultAssay(object = object)
    data.use <- t(GetAssayData(object = object, slot = slot, assay = assay)[features, ])
    data.use <- FindNeighbors(data.use, k.param = k.param)[["snn"]]
  } else if (!is.null(x = dims)) {
    data.use <- Embeddings(object = object[[reduction]])
    if (max(dims) > ncol(x = data.use)) {
      stop("More dimensions specified in dims than have been computed")
    }
    data.use <- data.use[, dims]
    data.use <- FindNeighbors(data.use, k.param = k.param)[["snn"]]
  } else {
    stop("Please specify one of dims, features, neighbor, or graph")
  }
  object[[reduction.name]] <- RunFR(
    object = data.use, ndim = ndim, niter = niter,
    seed.use = seed.use, verbose = verbose, reduction.key = reduction.key,
    ...
  )
  object <- LogSeuratCommand(object = object)
  return(object)
}

# ---- Seurat-function.R:1745-1762 : RunFR.default ----
RunFR.default <- function(object, ndim = 2, niter = 500,
                          reduction.key = "FR_", verbose = TRUE, seed.use = 11L, ...) {
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
  }
  if (inherits(object, "Neighbor")) {
    object <- as.Graph(object)
  }
  g <- graph_from_adjacency_matrix(object, weighted = TRUE)
  embedding <- layout_with_fr(graph = g, dim = ndim, niter = niter, ...)
  colnames(x = embedding) <- paste0(reduction.key, seq_len(ncol(x = embedding)))
  rownames(x = embedding) <- rownames(object)
  reduction <- CreateDimReducObject(
    embeddings = embedding,
    key = reduction.key, assay = object@assay.used, global = TRUE
  )
  return(reduction)
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

# ---- utils.R:767-793 : invoke ----
invoke <- function(.fn, .args = list(), ..., .env = caller_env()) {
  args <- c(.args, list(...))
  .bury <- c(".fn", "")
  if (is_null(.bury) || !length(args)) {
    if (is_scalar_character(.fn)) {
      .fn <- env_get(.env, .fn, inherit = TRUE)
    }
    call <- call2(.fn, !!!args)
    return(.External2(rlang:::ffi_eval, call, .env))
  }
  if (!is_character(.bury, 2L)) {
    abort("`.bury` must be a character vector of length 2")
  }
  arg_prefix <- .bury[[2]]
  fn_nm <- .bury[[1]]
  buried_nms <- paste0(arg_prefix, seq_along(args))
  buried_args <- set_names(args, buried_nms)
  .env <- env(.env, !!!buried_args)
  args <- set_names(buried_nms, names(args))
  args <- syms(args)
  if (is_function(.fn)) {
    env_bind(.env, `:=`(!!fn_nm, .fn))
    .fn <- fn_nm
  }
  call <- call2(.fn, !!!args)
  .External2(rlang:::ffi_eval, call, .env)
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

