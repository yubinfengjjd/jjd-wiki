# scp_tables.R
# Convert SCP/Seurat-derived tables to the wiki render interfaces.
# Base R only; no Seurat or SCP dependency. These functions do not train,
# re-cluster, re-score or re-test anything.

.scp_stop <- function(...) stop(..., call. = FALSE)

.scp_require_cols <- function(df, cols, arg) {
  missing <- setdiff(cols, names(df))
  if (length(missing)) {
    .scp_stop(arg, " is missing column(s): ", paste(missing, collapse = ", "))
  }
}

.scp_check_unique <- function(x, arg) {
  if (anyDuplicated(x)) .scp_stop(arg, " contains duplicated cell IDs")
}

.scp_check_no_na <- function(x, arg) {
  if (anyNA(x)) .scp_stop(arg, " contains NA")
}

# coords: data.frame with cell_id, umap_1, umap_2.
# meta:   data.frame with cell_id and group.
# Returns exactly cell_id, umap_1, umap_2, group.
scp_umap_groups <- function(coords, meta,
                            cell_id = "cell_id", group = "group",
                            umap_1 = "umap_1", umap_2 = "umap_2") {
  .scp_require_cols(coords, c(cell_id, umap_1, umap_2), "coords")
  .scp_require_cols(meta, c(cell_id, group), "meta")
  .scp_check_unique(coords[[cell_id]], "coords")
  .scp_check_unique(meta[[cell_id]], "meta")
  .scp_check_no_na(coords[[umap_1]], "coords[[umap_1]]")
  .scp_check_no_na(coords[[umap_2]], "coords[[umap_2]]")
  .scp_check_no_na(meta[[group]], "meta[[group]]")
  idx <- match(coords[[cell_id]], meta[[cell_id]])
  if (anyNA(idx)) {
    .scp_stop("coords contains cells absent from meta: ",
              paste(coords[[cell_id]][is.na(idx)], collapse = ", "))
  }
  data.frame(
    cell_id = coords[[cell_id]],
    umap_1 = as.numeric(coords[[umap_1]]),
    umap_2 = as.numeric(coords[[umap_2]]),
    group = as.character(meta[[group]][idx]),
    stringsAsFactors = FALSE
  )
}

# coords: data.frame with cell_id, umap_1, umap_2.
# expr:   either a long data.frame (cell_id, feature, value) or a wide
#         data.frame with cell_id plus one column per feature.
# meta:   data.frame with cell_id and group.
# Returns exactly cell_id, umap_1, umap_2, group, feature, value.
scp_umap_feature_long <- function(coords, expr, meta, features,
                                  cell_id = "cell_id", group = "group",
                                  umap_1 = "umap_1", umap_2 = "umap_2",
                                  feature_col = "feature", value_col = "value") {
  .scp_require_cols(coords, c(cell_id, umap_1, umap_2), "coords")
  .scp_require_cols(meta, c(cell_id, group), "meta")
  .scp_check_unique(coords[[cell_id]], "coords")
  .scp_check_unique(meta[[cell_id]], "meta")
  .scp_check_no_na(coords[[umap_1]], "coords[[umap_1]]")
  .scp_check_no_na(coords[[umap_2]], "coords[[umap_2]]")
  .scp_check_no_na(meta[[group]], "meta[[group]]")
  if (missing(features) || !length(features)) .scp_stop("features is empty")
  features <- as.character(features)

  if (all(c(feature_col, value_col) %in% names(expr))) {
    .scp_require_cols(expr, c(cell_id, feature_col, value_col), "expr")
    long <- expr[expr[[feature_col]] %in% features, c(cell_id, feature_col, value_col)]
    names(long) <- c("cell_id", "feature", "value")
    present <- unique(long$feature)
    if (!setequal(present, features)) {
      .scp_stop("expr does not contain all requested features; missing: ",
                paste(setdiff(features, present), collapse = ", "))
    }
  } else {
    .scp_require_cols(expr, c(cell_id, features), "expr")
    long <- do.call(rbind, lapply(features, function(f) {
      data.frame(
        cell_id = expr[[cell_id]],
        feature = f,
        value = expr[[f]],
        stringsAsFactors = FALSE
      )
    }))
  }
  .scp_check_no_na(long$value, "expr values")
  idx <- match(long$cell_id, coords[[cell_id]])
  if (anyNA(idx)) {
    .scp_stop("expr contains cells absent from coords: ",
              paste(unique(long$cell_id[is.na(idx)]), collapse = ", "))
  }
  gidx <- match(long$cell_id, meta[[cell_id]])
  if (anyNA(gidx)) {
    .scp_stop("expr contains cells absent from meta: ",
              paste(unique(long$cell_id[is.na(gidx)]), collapse = ", "))
  }
  out <- data.frame(
    cell_id = long$cell_id,
    umap_1 = as.numeric(coords[[umap_1]][idx]),
    umap_2 = as.numeric(coords[[umap_2]][idx]),
    group = as.character(meta[[group]][gidx]),
    feature = as.character(long$feature),
    value = as.numeric(long$value),
    stringsAsFactors = FALSE
  )
  out
}

# avg_exp and pct_exp: long data.frames with group, feature, value.
# pct_scale = "percent" expects 0-100; "fraction" expects 0-1 and multiplies
# by 100 explicitly (recorded in the returned attribute).
scp_dotplot_long <- function(avg_exp, pct_exp,
                             group_col = "group", feature_col = "feature",
                             value_col = "value",
                             target_group = NULL,
                             pct_scale) {
  if (missing(pct_scale)) {
    .scp_stop("pct_scale must be explicitly 'percent' or 'fraction'; units are not inferred")
  }
  pct_scale <- match.arg(pct_scale, c("percent", "fraction"))
  .scp_require_cols(avg_exp, c(group_col, feature_col, value_col), "avg_exp")
  .scp_require_cols(pct_exp, c(group_col, feature_col, value_col), "pct_exp")
  if (anyDuplicated(paste(avg_exp[[group_col]], avg_exp[[feature_col]], sep = "\r"))) {
    .scp_stop("avg_exp has duplicated group/feature rows")
  }
  if (anyDuplicated(paste(pct_exp[[group_col]], pct_exp[[feature_col]], sep = "\r"))) {
    .scp_stop("pct_exp has duplicated group/feature rows")
  }
  key_avg <- paste(avg_exp[[group_col]], avg_exp[[feature_col]], sep = "\r")
  key_pct <- paste(pct_exp[[group_col]], pct_exp[[feature_col]], sep = "\r")
  if (!setequal(key_avg, key_pct)) {
    .scp_stop("avg_exp and pct_exp do not cover the same group/feature pairs; missing in pct_exp: ",
              paste(setdiff(key_avg, key_pct), collapse = "; "))
  }
  idx <- match(key_avg, key_pct)
  pct <- as.numeric(pct_exp[[value_col]][idx])
  if (anyNA(pct)) .scp_stop("pct_exp values contain NA or non-numeric values")
  if (pct_scale == "fraction") {
    if (any(pct < 0 | pct > 1, na.rm = TRUE)) {
      .scp_stop("pct_scale='fraction' requires values in [0, 1]")
    }
    pct <- pct * 100
  } else if (any(pct < 0 | pct > 100, na.rm = TRUE)) {
    .scp_stop("pct_scale='percent' requires values in [0, 100]")
  }
  out <- data.frame(
    group = as.character(avg_exp[[group_col]]),
    feature = as.character(avg_exp[[feature_col]]),
    avg_expression = as.numeric(avg_exp[[value_col]]),
    pct_expressed = pct,
    target_group = "",
    stringsAsFactors = FALSE
  )
  if (anyNA(out$avg_expression)) .scp_stop("avg_exp values contain NA or non-numeric values")
  if (!is.null(target_group)) {
    .scp_require_cols(target_group, c("feature", "target_group"), "target_group")
    if (anyDuplicated(target_group$feature)) .scp_stop("target_group has duplicated features")
    out$target_group <- as.character(target_group$target_group[match(out$feature, target_group$feature)])
    out$target_group[is.na(out$target_group)] <- ""
  }
  attr(out, "pct_scale") <- pct_scale
  out
}

# meta: one row per cell with celltype and group.
# value_col: one numeric column; call once per value (the interface has one
# value column, not a feature column).
scp_grouped_values <- function(meta, value_col,
                               celltype_col = "celltype", group_col = "group",
                               cell_id_col = "cell_id") {
  .scp_require_cols(meta, c(cell_id_col, celltype_col, group_col, value_col), "meta")
  .scp_check_unique(meta[[cell_id_col]], "meta")
  .scp_check_no_na(meta[[celltype_col]], "meta[[celltype_col]]")
  .scp_check_no_na(meta[[group_col]], "meta[[group_col]]")
  .scp_check_no_na(meta[[value_col]], "meta[[value_col]]")
  data.frame(
    celltype = as.character(meta[[celltype_col]]),
    group = as.character(meta[[group_col]]),
    value = as.numeric(meta[[value_col]]),
    stringsAsFactors = FALSE
  )
}

# meta: one row per cell with group and celltype.
# Returns group, celltype, proportion; each group sums to 1.
scp_cell_proportions <- function(meta, group_col = "group", celltype_col = "celltype") {
  .scp_require_cols(meta, c(group_col, celltype_col), "meta")
  .scp_check_no_na(meta[[group_col]], "meta[[group_col]]")
  .scp_check_no_na(meta[[celltype_col]], "meta[[celltype_col]]")
  tab <- table(meta[[group_col]], meta[[celltype_col]])
  df <- as.data.frame(tab, stringsAsFactors = FALSE)
  names(df) <- c("group", "celltype", "Freq")
  if (any(df$Freq == 0)) {
    .scp_stop("empty group/celltype combinations are present; drop or merge levels explicitly")
  }
  df$proportion <- ave(df$Freq, df$group, FUN = function(x) x / sum(x))
  df <- df[, c("group", "celltype", "proportion")]
  sums <- tapply(df$proportion, df$group, sum)
  if (any(abs(sums - 1) > 1e-8)) .scp_stop("proportions do not sum to 1 within a group")
  rownames(df) <- NULL
  df
}

# meta: one row per cell; returns cell, group, stat for render-cell-metadata.
# CellStatPlot pie/rose/trend/area/dot templates consume this table and run the
# original StatPlot counting step themselves.
scp_cell_metadata <- function(meta, group_col = "group", stat_col = "stat",
                              cell_col = NULL) {
  .scp_require_cols(meta, c(group_col, stat_col), "meta")
  .scp_check_no_na(meta[[group_col]], "meta[[group_col]]")
  .scp_check_no_na(meta[[stat_col]], "meta[[stat_col]]")
  cell <- if (is.null(cell_col)) rownames(meta) else meta[[cell_col]]
  if (is.null(cell)) cell <- as.character(seq_len(nrow(meta)))
  .scp_check_unique(cell, "cell ids")
  data.frame(
    cell = as.character(cell),
    group = as.character(meta[[group_col]]),
    stat = as.character(meta[[stat_col]]),
    stringsAsFactors = FALSE
  )
}

# Write a render interface CSV with the exact filename expected by render.
scp_write_interface <- function(df, interface, dir = ".") {
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  path <- file.path(dir, paste0(interface, ".csv"))
  utils::write.csv(df, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  invisible(path)
}
