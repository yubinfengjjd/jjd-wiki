# PROGENy pathway activity scoring and subcluster Z-score aggregation.
# Adapted from Cai et al., npj Precision Oncology 2026 (02_progeny_roe_cox.R).

run_progeny_pathway_activity <- function(
  expr_mat,
  meta_df,
  cell_col = "cell",
  group_col = "subcluster",
  organism = "Human",
  top = 100L,
  perm = 1L
) {
  if (!requireNamespace("progeny", quietly = TRUE)) {
    stop("Missing required R package: progeny")
  }
  if (!is.matrix(expr_mat)) {
    expr_mat <- as.matrix(expr_mat)
  }
  storage.mode(expr_mat) <- "numeric"

  for (col in c(cell_col, group_col)) {
    if (!(col %in% colnames(meta_df))) {
      stop("Missing column in meta_df: ", col)
    }
  }

  common_cells <- intersect(colnames(expr_mat), as.character(meta_df[[cell_col]]))
  if (length(common_cells) < 5L) {
    stop("Too few matched cells between expr_mat and meta_df")
  }
  expr_sub <- expr_mat[, common_cells, drop = FALSE]
  meta_sub <- meta_df[match(common_cells, as.character(meta_df[[cell_col]])), , drop = FALSE]

  # Compute per-cell PROGENy pathway activity scores (cells x pathways)
  raw_scores <- progeny::progeny(
    expr = expr_sub,
    scale = FALSE,
    organism = organism,
    top = as.integer(top),
    perm = as.integer(perm)
  )
  raw_scores <- as.matrix(raw_scores)

  # Standardize each pathway across cells (Z-score)
  z_scores <- apply(raw_scores, 2, function(v) {
    s <- stats::sd(v, na.rm = TRUE)
    if (is.na(s) || s < 1e-12) rep(0, length(v)) else (v - mean(v, na.rm = TRUE)) / s
  })
  rownames(z_scores) <- rownames(raw_scores)
  colnames(z_scores) <- colnames(raw_scores)

  # Aggregate mean pathway Z-score per subcluster/group
  groups <- as.character(meta_sub[[group_col]])
  uniq_groups <- sort(unique(groups))
  pathways <- colnames(z_scores)

  subcluster_mat <- matrix(NA_real_, nrow = length(uniq_groups), ncol = length(pathways),
                           dimnames = list(uniq_groups, pathways))
  for (g in uniq_groups) {
    idx <- which(groups == g)
    subcluster_mat[g, ] <- colMeans(z_scores[idx, , drop = FALSE], na.rm = TRUE)
  }

  cell_scores_df <- data.frame(
    cell = rownames(z_scores),
    group = groups,
    round(as.data.frame(z_scores, check.names = FALSE), 5),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  colnames(cell_scores_df)[2] <- group_col

  subcluster_df <- data.frame(
    group = rownames(subcluster_mat),
    round(as.data.frame(subcluster_mat, check.names = FALSE), 5),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  colnames(subcluster_df)[1] <- group_col

  list(
    cell_scores = cell_scores_df,
    subcluster_zscore = subcluster_df,
    n_pathways = ncol(z_scores)
  )
}
