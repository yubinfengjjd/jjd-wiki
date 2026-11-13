# Explicit Seurat clustering branch used by SCP Standard_SCP/Seurat_integrate.
# Source mapping: methods/scp-local-source/code/SCP-local/R/SCP-workflow.R
#   FindNeighbors + FindClusters (e.g. lines 1509-1510).
# The caller supplies an already embedded object; this function never
# normalizes, scales, integrates, or chooses a resolution.

run_seurat_clustering <- function(object, reduction = "pca", dims = 1:20,
                                  resolution = 0.8, algorithm = 1, seed = 11) {
  if (!inherits(object, "Seurat")) stop("object must be a Seurat object")
  if (!reduction %in% SeuratObject::Reductions(object)) {
    stop("reduction not found: ", reduction)
  }
  embedding <- SeuratObject::Embeddings(object, reduction)
  dims <- as.integer(dims)
  if (!length(dims) || anyNA(dims) || any(dims < 1) || max(dims) > ncol(embedding)) {
    stop("dims must be valid positive column indices of the reduction")
  }
  if (!is.numeric(resolution) || length(resolution) != 1 || !is.finite(resolution) || resolution <= 0) {
    stop("resolution must be one positive finite number")
  }
  set.seed(seed)
  object <- Seurat::FindNeighbors(object, reduction = reduction, dims = dims, verbose = FALSE)
  object <- Seurat::FindClusters(object, resolution = resolution, algorithm = algorithm, verbose = FALSE)
  data.frame(
    cell_id = colnames(object),
    cluster = as.character(SeuratObject::Idents(object)),
    reduction = reduction,
    resolution = resolution,
    stringsAsFactors = FALSE
  )
}
