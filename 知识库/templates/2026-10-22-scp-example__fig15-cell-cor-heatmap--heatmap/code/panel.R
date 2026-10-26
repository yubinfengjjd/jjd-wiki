# Panel adapter: one native SCP CellCorHeatmap panel from a long similarity
# matrix table. render.R reads the interface CSV; this function only rebuilds
# the matrix and calls the native plot half. No similarity is recomputed.

get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

rebuild_correlation_matrix <- function(df) {
  req <- c("row", "column", "similarity", "row_group", "column_group",
           "row_order", "column_order")
  if (!all(req %in% names(df))) {
    stop("correlation table is missing columns: ",
         paste(setdiff(req, names(df)), collapse = ", "), call. = FALSE)
  }
  rows <- unique(as.character(df$row[order(df$row_order, seq_len(nrow(df)))]))
  cols <- unique(as.character(df$column[order(df$column_order, seq_len(nrow(df)))]))
  if (anyNA(rows) || anyNA(cols) || any(!nzchar(rows)) || any(!nzchar(cols))) {
    stop("row/column labels cannot be NA or empty", call. = FALSE)
  }
  if (nrow(df) != length(rows) * length(cols)) {
    stop("correlation table must have exactly one row per row x column: expected ",
         length(rows) * length(cols), " rows, found ", nrow(df), call. = FALSE)
  }
  keys <- paste(df$row, df$column, sep = "\r")
  if (anyDuplicated(keys)) stop("duplicate row x column rows", call. = FALSE)
  mat <- matrix(NA_real_, nrow = length(rows), ncol = length(cols),
                dimnames = list(rows, cols))
  for (i in seq_len(nrow(df))) {
    mat[as.character(df$row[i]), as.character(df$column[i])] <- as.numeric(df$similarity[i])
  }
  if (anyNA(mat)) stop("correlation matrix is incomplete", call. = FALSE)
  if (any(!is.finite(mat))) stop("similarity must be finite", call. = FALSE)

  row_groups <- df$row_group[match(rows, df$row)]
  col_groups <- df$column_group[match(cols, df$column)]
  if (anyNA(row_groups) || anyNA(col_groups)) {
    stop("row_group/column_group must be present for every label", call. = FALSE)
  }
  list(matrix = mat, row_groups = row_groups, column_groups = col_groups)
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"correlation" %in% names(tables)) stop("Missing table: correlation", call. = FALSE)
  fit <- rebuild_correlation_matrix(tables$correlation)
  native <- plot_scp_cellcor_heatmap(
    similarities = fit$matrix,
    simil_name = get_style(style, "simil_name", "Cosine similarity"),
    query_group = get_style(style, "query_group", "query_group"),
    ref_group = get_style(style, "ref_group", "ref_group"),
    row_groups = fit$row_groups,
    column_groups = fit$column_groups,
    query_collapsing = get_style(style, "query_collapsing", TRUE),
    ref_collapsing = get_style(style, "ref_collapsing", TRUE),
    ref_legend = get_style(style, "ref_legend", FALSE),
    style = style,
    scp = scp
  )
  native$plot
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
