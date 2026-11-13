# Explicit Seurat anchor label-transfer branch of SCP RunSeuratMap.
# Source mapping: methods/scp-local-source/code/SCP-local/R/SCP-projection.R
#   FindTransferAnchors + TransferData. This branch returns labels and scores;
#   it does not project cells into the reference UMAP, which is a separate
#   RunKNNMap/UMAP-model branch and is not claimed here.

run_reference_label_transfer <- function(query, reference, ref_group_col,
                                         dims = 1:20, k_anchor = 5,
                                         k_score = 30, k_weight = 50, seed = 11) {
  if (!inherits(query, "Seurat") || !inherits(reference, "Seurat")) {
    stop("query and reference must be Seurat objects")
  }
  if (!is.character(ref_group_col) || length(ref_group_col) != 1 ||
      !ref_group_col %in% colnames(reference[[]])) {
    stop("ref_group_col must name one reference metadata column")
  }
  labels <- reference[[ref_group_col]][, 1]
  if (anyNA(labels)) stop("reference labels contain NA")
  if (!"pca" %in% SeuratObject::Reductions(reference)) {
    reference <- Seurat::NormalizeData(reference, verbose = FALSE)
    reference <- Seurat::FindVariableFeatures(reference, verbose = FALSE)
    reference <- Seurat::ScaleData(reference, verbose = FALSE)
    reference <- Seurat::RunPCA(reference, npcs = max(dims), verbose = FALSE)
  }
  if (max(dims) > ncol(SeuratObject::Embeddings(reference, "pca"))) {
    stop("dims exceed available reference PCs")
  }
  set.seed(seed)
  anchors <- Seurat::FindTransferAnchors(
    reference = reference, query = query, dims = dims,
    reference.reduction = "pca", reduction = "pcaproject",
    k.anchor = k_anchor, k.score = k_score, verbose = FALSE
  )
  predictions <- Seurat::TransferData(
    anchorset = anchors, refdata = labels, dims = dims,
    k.weight = min(k_weight, ncol(query)), verbose = FALSE
  )
  score_cols <- grep("^prediction.score\\.", colnames(predictions), value = TRUE)
  scores <- as.matrix(predictions[, score_cols, drop = FALSE])
  top <- apply(scores, 1, max)
  second <- if (ncol(scores) > 1) apply(scores, 1, function(x) sort(x, decreasing = TRUE)[2]) else rep(NA_real_, nrow(scores))
  list(
    table = data.frame(
      cell_id = rownames(predictions),
      predicted_id = as.character(predictions$predicted.id),
      max_score = top,
      margin = top - second,
      stringsAsFactors = FALSE
    ),
    scores = data.frame(cell_id = rownames(predictions), scores,
                        check.names = FALSE, stringsAsFactors = FALSE),
    anchors = nrow(anchors@anchors)
  )
}
