# Panel adapter: long feature-heatmap table -> native SCP FeatureHeatmap plot.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

build_feature_matrices <- function(df, style) {
  required <- c("matrix", "feature", "cell", "group", "value",
                "matrix_order", "feature_order", "cell_order", "group_order")
  if (!all(required %in% names(df))) {
    stop("Missing required columns: ",
         paste(setdiff(required, names(df)), collapse = ", "), call. = FALSE)
  }
  if (anyNA(df[, required])) {
    stop("Required columns contain NA; value must be the drawn (transformed) expression",
         call. = FALSE)
  }
  matrix_names <- unique(df$matrix[order(df$matrix_order, seq_len(nrow(df)))])
  features <- unique(df$feature[order(df$feature_order, seq_len(nrow(df)))])
  matrices <- list()
  cell_groups <- list()
  group_levels <- list()
  for (nm in matrix_names) {
    sub <- df[df$matrix == nm, , drop = FALSE]
    if (anyDuplicated(sub[, c("feature", "cell")])) {
      stop("Duplicate feature x cell rows in matrix ", nm, call. = FALSE)
    }
    feats <- unique(sub$feature[order(sub$feature_order, seq_len(nrow(sub)))])
    if (!identical(feats, features)) {
      stop("All matrices must share the same feature set and feature_order", call. = FALSE)
    }
    ord <- unique(sub$cell_order)
    if (!identical(as.integer(sort(ord)), seq_along(ord))) {
      stop("cell_order must be 1..n within matrix ", nm, call. = FALSE)
    }
    cells <- sub$cell[match(ord, sub$cell_order)]
    if (anyDuplicated(cells)) {
      stop("Each cell must appear once per matrix (", nm, ")", call. = FALSE)
    }
    grp_tab <- unique(sub[, c("group", "group_order")])
    if (length(unique(grp_tab$group)) != nrow(grp_tab) ||
        length(unique(grp_tab$group_order)) != nrow(grp_tab)) {
      stop("Each group must map to one group_order in matrix ", nm, call. = FALSE)
    }
    grp_tab <- grp_tab[order(grp_tab$group_order), , drop = FALSE]
    lev <- as.character(grp_tab$group)

    mat <- matrix(NA_real_, nrow = length(feats), ncol = length(cells),
                  dimnames = list(feats, cells))
    for (r in seq_len(nrow(sub))) {
      mat[sub$feature[r], sub$cell[r]] <- as.numeric(sub$value[r])
    }
    if (anyNA(mat)) {
      stop("Matrix ", nm, " is missing feature x cell cells", call. = FALSE)
    }
    if (any(!is.finite(mat))) {
      stop("Matrix ", nm, " has non-finite values", call. = FALSE)
    }
    g <- sub$group[match(seq_along(cells), sub$cell_order)]
    f <- factor(g, levels = lev)
    names(f) <- cells
    matrices[[nm]] <- mat
    cell_groups[[nm]] <- f
    group_levels[[nm]] <- lev
  }
  list(matrices = matrices, cell_groups = cell_groups,
       features = features, group_levels = group_levels)
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"heatmap" %in% names(tables)) stop("Missing table: heatmap")
  built <- build_feature_matrices(tables$heatmap, style)
  if (!is.null(style$group_levels)) {
    gl <- style$group_levels
    if (is.null(names(gl))) {
      stop("style.group_levels must be a named list keyed by matrix", call. = FALSE)
    }
    built$group_levels <- lapply(names(built$matrices), function(nm) {
      vals <- gl[[nm]]
      if (is.null(vals)) {
        stop("style.group_levels is missing matrix ", nm, call. = FALSE)
      }
      vals <- as.character(vals)
      if (!all(unique(as.character(built$cell_groups[[nm]])) %in% vals)) {
        stop("style.group_levels must contain every observed group", call. = FALSE)
      }
      vals
    })
  }
  plot_scp_feature_heatmap(
    matrices = built$matrices,
    cell_groups = built$cell_groups,
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
