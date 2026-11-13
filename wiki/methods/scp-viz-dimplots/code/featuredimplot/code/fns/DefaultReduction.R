# SCP 0.5.6 commit b9b0eb7a | source R/SCP-workflow.R:1034-1084
# sha256(func-block)=666642a03046ed6da731362b29a7e3fde9a26d7414b244bac9776e7a2fbaf3ba
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
DefaultReduction <- function(srt, pattern = NULL, min_dim = 2, max_distance = 0.1) {
  if (length(srt@reductions) == 0) {
    stop("Unable to find any reductions.")
  }
  pattern_default <- c("umap", "tsne", "dm", "phate", "pacmap", "trimap", "largevis", "fr", "pca", "svd", "ica", "nmf", "mds", "glmpca")
  pattern_dim <- c("2D", "3D")
  reduc_all <- names(srt@reductions)
  reduc_all <- reduc_all[unlist(lapply(reduc_all, function(x) {
    dim(srt@reductions[[x]]@cell.embeddings)[2] >= min_dim
  }))]
  if (length(reduc_all) == 0) {
    stop("No dimensional reduction found in the srt object.")
  }
  if (length(reduc_all) == 1) {
    return(reduc_all)
  }
  if (is.null(pattern)) {
    if (("Default_reduction" %in% names(srt@misc))) {
      pattern <- srt@misc[["Default_reduction"]]
    } else {
      pattern <- pattern_default
    }
  }

  pattern <- c(pattern, paste0(pattern, min_dim, "D"))
  if (any(pattern %in% reduc_all)) {
    return(pattern[pattern %in% reduc_all][1])
  }
  index <- c(unlist(sapply(pattern, function(pat) {
    grep(pattern = pat, x = reduc_all, ignore.case = TRUE)
  })))
  if (length(index) > 0) {
    default_reduc <- reduc_all[index]
  } else {
    index <- c(unlist(sapply(pattern, function(pat) {
      agrep(pattern = pat, x = reduc_all, max.distance = max_distance, ignore.case = TRUE)
    })))
    if (length(index) > 0) {
      default_reduc <- reduc_all[index]
    } else {
      default_reduc <- reduc_all
    }
  }
  if (length(default_reduc) > 1) {
    default_reduc <- default_reduc[unlist(sapply(c(pattern_default, pattern_dim), function(pat) {
      grep(pattern = pat, x = default_reduc, ignore.case = TRUE)
    }))]
    default_reduc <- default_reduc[which.min(sapply(default_reduc, function(x) dim(srt@reductions[[x]])[2]))]
  }
  return(default_reduc)
}
