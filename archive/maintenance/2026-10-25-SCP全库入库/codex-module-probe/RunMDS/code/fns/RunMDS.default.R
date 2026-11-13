# SCP 0.5.6 commit b9b0eb7a | source R/Seurat-function.R:263-298
# sha256(func-block)=11c46e060b854d62c6dbdd3f32f820e48c4ee7c25262da412b004324cc5238b3
# verbatim copy; read-only provenance
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
