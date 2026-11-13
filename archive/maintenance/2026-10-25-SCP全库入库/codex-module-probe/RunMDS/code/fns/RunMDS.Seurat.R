# SCP 0.5.6 commit b9b0eb7a | source R/Seurat-function.R:195-220
# sha256(func-block)=dd758aeebc83d58419e1277ac5b9c3fbbf1f648f33dc804f6e47db704e71b018
# verbatim copy; read-only provenance
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
