# Panel adapter: one native SCP volcano panel from render-de-results.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

map_de_columns <- function(df, columns) {
  if (is.null(columns) || !length(columns)) return(df)
  columns <- unlist(columns)
  if (is.null(names(columns)) || any(!nzchar(names(columns)))) {
    stop("style.columns must map canonical names to source columns", call. = FALSE)
  }
  missing <- setdiff(unname(columns), names(df))
  if (length(missing)) {
    stop("Mapped columns not found: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  for (canonical in names(columns)) {
    if (!identical(canonical, columns[[canonical]])) {
      df[[canonical]] <- df[[columns[[canonical]]]]
    }
  }
  df
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"de" %in% names(tables)) stop("Missing table: de")
  if (!exists("scp_volcano_table", mode = "function")) {
    stop("Native volcano core not loaded; source code/core.R first", call. = FALSE)
  }
  df <- map_de_columns(as.data.frame(tables$de), style$columns)
  group_col <- get_style(style, "group_col", "group1")
  if (!group_col %in% names(df)) {
    stop("Group column not found: ", group_col, call. = FALSE)
  }
  # The upstream function requires dot-suffixed pct columns; the interface uses
  # underscores. Map without changing the caller's data frame.
  if (!"pct.1" %in% names(df) && "pct_1" %in% names(df)) df[["pct.1"]] <- df[["pct_1"]]
  if (!"pct.2" %in% names(df) && "pct_2" %in% names(df)) df[["pct.2"]] <- df[["pct_2"]]

  groups <- unique(as.character(df[[group_col]]))
  selected <- get_style(style, "group", NULL)
  if (is.null(selected)) {
    if (length(groups) != 1L) {
      stop("Select one group for a single-panel volcano; found: ",
           paste(groups, collapse = ", "), call. = FALSE)
    }
    selected <- groups[[1]]
  } else if (!selected %in% groups) {
    stop("Selected group not found: ", selected, call. = FALSE)
  }
  df <- df[as.character(df[[group_col]]) == selected, , drop = FALSE]
  if (!nrow(df)) stop("No rows for group: ", selected, call. = FALSE)

  required <- c("gene", "avg_log2FC", "pct.1", "pct.2", "p_val_adj")
  missing <- setdiff(required, names(df))
  if (length(missing)) {
    stop("Missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  if (anyNA(df[required]) || any(!nzchar(as.character(df$gene)))) {
    stop("gene and required numeric columns cannot contain NA/empty values", call. = FALSE)
  }
  for (column in c("avg_log2FC", "pct.1", "pct.2", "p_val_adj")) {
    if (!is.numeric(df[[column]]) || anyNA(df[[column]])) {
      stop(column, " must be numeric without NA/NaN", call. = FALSE)
    }
  }
  # Native VolcanoPlot keeps +/-Inf avg_log2FC in the source table (the Seurat
  # example contains five such genes); only the display x comes from diff_pct.
  for (column in c("pct.1", "pct.2", "p_val_adj")) {
    if (any(!is.finite(df[[column]]))) {
      stop(column, " must be finite", call. = FALSE)
    }
  }
  if (any(df$pct.1 < 0 | df$pct.1 > 1) || any(df$pct.2 < 0 | df$pct.2 > 1)) {
    stop("pct.1/pct.2 must be fractions in [0,1]", call. = FALSE)
  }
  if (any(df$p_val_adj <= 0 | df$p_val_adj > 1)) {
    stop("p_val_adj must be in (0,1]; -log10(0) is undefined", call. = FALSE)
  }
  if (anyDuplicated(df$gene)) {
    stop("Duplicate gene within the selected group", call. = FALSE)
  }

  de_threshold <- get_style(style, "de_threshold",
                            "avg_log2FC > 0 & p_val_adj < 0.05")
  x_metric <- get_style(style, "x_metric", "diff_pct")
  tab <- scp_volcano_table(
    df,
    group.by = group_col,
    DE_threshold = de_threshold,
    x_metric = x_metric
  )

  nlabel <- get_style(style, "nlabel", 8)
  features_label <- get_style(style, "features_label", NULL)
  labeled <- scp_volcano_labels(tab, group.by = group_col, nlabel = nlabel,
                                features_label = features_label)
  seed <- get_style(style, "seed", 1)
  set.seed(seed)
  p <- plot_scp_volcano(
    tab,
    group.by = group_col,
    x_metric = x_metric,
    palette = get_style(style, "palette", "RdBu"),
    palcolor = get_style(style, "palcolor", NULL),
    pt.size = get_style(style, "pt_size", 1),
    pt.alpha = get_style(style, "pt_alpha", 1),
    cols.highlight = get_style(style, "cols_highlight", "black"),
    sizes.highlight = get_style(style, "sizes_highlight", 1),
    alpha.highlight = get_style(style, "alpha_highlight", 1),
    stroke.highlight = get_style(style, "stroke_highlight", 0.5),
    nlabel = nlabel,
    features_label = features_label,
    label.fg = get_style(style, "label_fg", "black"),
    label.bg = get_style(style, "label_bg", "white"),
    label.bg.r = get_style(style, "label_bg_r", 0.1),
    label.size = get_style(style, "label_size", 4),
    aspect.ratio = get_style(style, "aspect_ratio", NULL),
    xlab = get_style(style, "xlab", NULL),
    ylab = get_style(style, "ylab", "-log10(p-adjust)"),
    theme_use = "theme_scp",
    scp = scp
  )
  attr(p, "label_table") <- labeled[labeled$label, c("gene", "label"), drop = FALSE]
  p
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
