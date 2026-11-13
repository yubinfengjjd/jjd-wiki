# SCP 0.5.6 commit b9b0eb7a | source R/Seurat-function.R:227-253
# sha256(func-block)=f0536dcd357c0cd052a6cb79c75e9ae83c6c121fb1f181c930466f839b2f2379
# verbatim copy; read-only provenance
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
