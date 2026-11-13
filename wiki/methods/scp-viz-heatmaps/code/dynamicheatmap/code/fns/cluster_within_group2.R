# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7250-7292
# sha256(func-block)=abc1c75cc8a06d154a62596d03b8e8694917ccdc7be022967d918c6c07fbe004
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
cluster_within_group2 <- function(mat, factor) {
  check_R("dendextend")
  if (!is.factor(factor)) {
    factor <- factor(factor, levels = unique(factor))
  }
  dend_list <- list()
  order_list <- list()
  for (le in unique(levels(factor))) {
    m <- mat[, factor == le, drop = FALSE]
    if (ncol(m) == 1) {
      order_list[[le]] <- which(factor == le)
      dend_list[[le]] <- structure(which(factor == le),
        class = "dendrogram", leaf = TRUE, # height = 0,
        label = 1, members = 1
      )
    } else if (ncol(m) > 1) {
      hc1 <- hclust(as.dist(dist(t(m))))
      dend_list[[le]] <- as.dendrogram(hc1)
      order_list[[le]] <- which(factor == le)[order.dendrogram(dend_list[[le]])]
      dendextend::order.dendrogram(dend_list[[le]]) <- order_list[[le]]
    }
    attr(dend_list[[le]], ".class_label") <- le
  }
  parent <- as.dendrogram(hclust(as.dist(dist(t(sapply(
    order_list,
    function(x) rowMeans(mat[, x, drop = FALSE])
  ))))))
  dend_list <- lapply(dend_list, function(dend) {
    dendrapply(
      dend,
      function(node) {
        if (is.null(attr(node, "height"))) {
          attr(node, "height") <- 0
        }
        node
      }
    )
  })
  # print(sapply(dend_list, function(x) attr(x, "height")))
  dend <- merge_dendrogram(parent, dend_list)
  order.dendrogram(dend) <- unlist(order_list[order.dendrogram(parent)])
  return(dend)
}
