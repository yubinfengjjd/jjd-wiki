# SCP 0.5.6 commit b9b0eb7a | source R/Seurat-function.R:70-100
# sha256(func-block)=5604991e7e78be4961eb45570d0f3cca5b90dfd5a9ce0df6f3e4761a0a936a51
# verbatim copy; read-only provenance
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
