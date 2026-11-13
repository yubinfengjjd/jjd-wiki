# SCP 0.5.6 commit b9b0eb7a | source R/Seurat-function.R:35-63
# sha256(func-block)=e62626c2b720804a9738e706a309016ee4a1176a9a8c221218dc4636201fbadb
# verbatim copy; read-only provenance
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
