# Panel adapter: long group-heatmap table -> native SCP GroupHeatmap add_dot
# plot. Same long table as the ht1 template; `percent` is now consumed.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

build_matrices <- function(df, style) {
  required <- c("matrix", "feature", "group", "value", "percent",
                "matrix_order", "group_order", "feature_order")
  if (!all(required %in% names(df))) {
    stop("Missing required columns: ",
         paste(setdiff(required, names(df)), collapse = ", "), call. = FALSE)
  }
  features <- unique(df$feature[order(df$feature_order, seq_len(nrow(df)))])
  matrix_names <- unique(df$matrix[order(df$matrix_order, seq_len(nrow(df)))])
  matrices <- list()
  percent <- list()
  for (matrix_name in matrix_names) {
    sub <- df[df$matrix == matrix_name, , drop = FALSE]
    if (anyDuplicated(sub[, c("feature", "group")])) {
      stop("Duplicate feature x group rows in matrix ", matrix_name, call. = FALSE)
    }
    groups <- unique(sub$group[order(sub$group_order, seq_len(nrow(sub)))])
    mat <- matrix(NA_real_, nrow = length(features), ncol = length(groups),
                  dimnames = list(features, groups))
    perc <- mat
    for (i in seq_len(nrow(sub))) {
      mat[sub$feature[i], sub$group[i]] <- as.numeric(sub$value[i])
      perc[sub$feature[i], sub$group[i]] <- as.numeric(sub$percent[i])
    }
    if (anyNA(mat)) stop("Matrix ", matrix_name, " is missing feature x group cells", call. = FALSE)
    if (any(!is.finite(mat))) stop("Matrix ", matrix_name, " has non-finite values", call. = FALSE)
    if (anyNA(perc)) stop("Matrix ", matrix_name, " is missing percent cells; add_dot requires one percent per feature x group", call. = FALSE)
    if (any(!is.finite(perc))) stop("Matrix ", matrix_name, " has non-finite percent values", call. = FALSE)
    if (any(perc < 0 | perc > 1)) {
      stop("percent must be in [0, 1], not 0-100", call. = FALSE)
    }
    matrices[[matrix_name]] <- mat
    percent[[matrix_name]] <- perc
  }
  # Row identity must be consistent across matrices: upstream keeps one shared
  # feature axis; a feature missing in one matrix would silently drop cells.
  for (matrix_name in matrix_names) {
    if (!identical(rownames(matrices[[matrix_name]]), features)) {
      stop("Matrix ", matrix_name, " does not share the common feature axis", call. = FALSE)
    }
  }
  list(matrices = matrices, percent = percent, features = features)
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"heatmap" %in% names(tables)) stop("Missing table: heatmap")
  built <- build_matrices(tables$heatmap, style)
  plot_scp_group_heatmap_dot(
    matrices = built$matrices,
    percent = built$percent,
    features = built$features,
    style = style,
    scp = scp
  )
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p$plot)
  invisible(p$plot)
}
