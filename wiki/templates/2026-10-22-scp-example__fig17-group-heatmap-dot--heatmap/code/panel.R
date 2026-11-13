# Panel adapter: long group-heatmap table -> native SCP GroupHeatmap add_dot
# plot. Same long table as the ht1 template; `percent` is now consumed.
#
# This file is sourced into the module-private environment by core.R.
# Contract:
#   - row key = matrix x feature x group (unique, complete, no holes)
#   - value / percent must be numeric vectors; factor/character columns are
#     rejected (never silently coerced - as.numeric on a factor yields level
#     codes that would still pass finite checks)
#   - order columns are explicit bijections: matrix<->matrix_order globally,
#     group<->group_order within each matrix, feature<->feature_order globally
#     (one shared feature axis across matrices). Any identity with multiple
#     order values, any order value with multiple identities, or a feature
#     whose order differs between matrices is rejected, not resolved.
#   - order values must be finite positive integers (>= 1; non-contiguous is
#     allowed) - NA/Inf/fractions/non-positive values are rejected.
#   - matrix/feature/group key columns must be non-missing, non-empty
#     character strings; empty tables and duplicated column names are
#     rejected before any row-level check.
#   - percent is the per-cell threshold fraction in [0,1]; never derived,
#     filled, or rescaled.
# There is NO draw(fig, rect, ...) adapter: the module returns the native
# patchwork-wrapped gTree object and leaves composition to the caller
# (patchwork/grid). A print() of the whole figure is not rect-aware.

.ghdot_get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

.ghdot_check_numeric_col <- function(df, name) {
  if (!is.numeric(df[[name]])) {
    stop("Column `", name, "` must be numeric (got ", class(df[[name]])[1],
         "); factors/characters are rejected", call. = FALSE)
  }
}

.ghdot_check_order_col <- function(df, name) {
  .ghdot_check_numeric_col(df, name)
  x <- df[[name]]
  if (any(!is.finite(x))) {
    stop("Column `", name, "` must be finite, non-missing order values",
         call. = FALSE)
  }
  if (any(x != floor(x)) || any(x < 1)) {
    stop("Column `", name,
         "` must be positive integers starting at 1 (non-contiguous is allowed)",
         call. = FALSE)
  }
}

.ghdot_check_key_col <- function(df, name) {
  x <- df[[name]]
  if (!is.character(x)) {
    stop("Column `", name, "` must be character (got ", class(x)[1],
         "); factors/numbers are rejected, not coerced", call. = FALSE)
  }
  if (any(is.na(x) | !nzchar(x))) {
    stop("Column `", name, "` must be non-missing, non-empty strings",
         call. = FALSE)
  }
}

.ghdot_check_bijection <- function(id, ord, id_name, ord_name, ctx) {
  # id<->ord must be a bijection: one order per identity AND one identity
  # per order value. `pairs` are raw (identity, order) rows, already deduped
  # by the caller where appropriate.
  pairs <- unique(data.frame(id = id, ord = ord, stringsAsFactors = FALSE))
  dup_id <- pairs$id[duplicated(pairs$id)]
  if (length(dup_id)) {
    stop(ord_name, " ambiguity in ", ctx, ": ", id_name, " `",
         dup_id[1], "` maps to multiple order values", call. = FALSE)
  }
  dup_ord <- pairs$ord[duplicated(pairs$ord)]
  if (length(dup_ord)) {
    stop(ord_name, " ambiguity in ", ctx, ": order value `",
         dup_ord[1], "` is shared by multiple ", id_name, "s", call. = FALSE)
  }
  pairs
}

ghdot_build_matrices <- function(df, style = list()) {
  required <- c("matrix", "feature", "group", "value", "percent",
                "matrix_order", "group_order", "feature_order")
  if (!is.data.frame(df)) {
    stop("`heatmap` table must be a data.frame", call. = FALSE)
  }
  if (anyDuplicated(names(df))) {
    stop("Duplicate column names in `heatmap` table: ",
         paste(unique(names(df)[duplicated(names(df))]), collapse = ", "),
         call. = FALSE)
  }
  if (!all(required %in% names(df))) {
    stop("Missing required columns: ",
         paste(setdiff(required, names(df)), collapse = ", "), call. = FALSE)
  }
  if (nrow(df) == 0L) {
    stop("`heatmap` table has zero rows; refusing to claim an empty figure",
         call. = FALSE)
  }
  .ghdot_check_numeric_col(df, "value")
  .ghdot_check_numeric_col(df, "percent")
  for (name in c("matrix_order", "group_order", "feature_order")) {
    .ghdot_check_order_col(df, name)
  }
  for (name in c("matrix", "feature", "group")) {
    .ghdot_check_key_col(df, name)
  }

  # matrix <-> matrix_order: global bijection
  mo <- .ghdot_check_bijection(df$matrix, df$matrix_order, "matrix",
                               "matrix_order", "table")
  matrix_names <- mo$id[order(mo$ord)]

  # feature <-> feature_order: global bijection (shared feature axis)
  fe <- .ghdot_check_bijection(df$feature, df$feature_order, "feature",
                               "feature_order", "table")
  features <- fe$id[order(fe$ord)]

  matrices <- list()
  percent <- list()
  for (matrix_name in matrix_names) {
    sub <- df[df$matrix == matrix_name, , drop = FALSE]
    if (anyDuplicated(sub[, c("feature", "group")])) {
      stop("Duplicate feature x group rows in matrix ", matrix_name, call. = FALSE)
    }
    # group <-> group_order: bijection within this matrix
    gr <- .ghdot_check_bijection(sub$group, sub$group_order, "group",
                                 "group_order", paste0("matrix ", matrix_name))
    groups <- gr$id[order(gr$ord)]
    missing_feat <- setdiff(features, unique(sub$feature))
    if (length(missing_feat)) {
      stop("Matrix ", matrix_name, " is missing feature(s): ",
           paste(utils::head(missing_feat, 3), collapse = ", "),
           " (shared feature axis)", call. = FALSE)
    }
    mat <- matrix(NA_real_, nrow = length(features), ncol = length(groups),
                  dimnames = list(features, groups))
    perc <- mat
    for (i in seq_len(nrow(sub))) {
      mat[sub$feature[i], sub$group[i]] <- sub$value[i]
      perc[sub$feature[i], sub$group[i]] <- sub$percent[i]
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
  list(matrices = matrices, percent = percent, features = features)
}

ghdot_plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"heatmap" %in% names(tables)) stop("Missing table: heatmap")
  built <- ghdot_build_matrices(tables$heatmap, style)
  plot_scp_group_heatmap_dot(
    matrices = built$matrices,
    percent = built$percent,
    features = built$features,
    style = style,
    scp = scp
  )
}
