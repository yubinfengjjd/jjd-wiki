# Panel adapter: one native SCP CellStatPlot venn panel from a cell-level
# membership table. The interface table is read by render.R; this function only
# maps explicit columns and style parameters onto the native core.

get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

# Interface adapter: long (cell, set, member) -> wide logical membership.
# The upstream venn branch expects one column per set; the wiki interface keeps
# one row per cell x set. Validation is explicit so a missing pair cannot shrink
# a set silently.
venn_long_to_wide <- function(df, cell_col = "cell", set_col = "set",
                              member_col = "member", set_levels = NULL) {
  required <- c(cell_col, set_col, member_col)
  if (!all(required %in% names(df))) {
    stop("membership table needs columns: ", paste(required, collapse = ", "), call. = FALSE)
  }
  cells <- unique(as.character(df[[cell_col]]))
  sets <- if (is.null(set_levels)) unique(as.character(df[[set_col]])) else as.character(set_levels)
  if (anyNA(cells) || any(!nzchar(cells))) stop("cell ids cannot be NA or empty", call. = FALSE)
  if (anyNA(sets) || any(!nzchar(sets))) stop("set names cannot be NA or empty", call. = FALSE)
  if (anyDuplicated(sets)) stop("set levels must be unique", call. = FALSE)
  extra <- setdiff(unique(as.character(df[[set_col]])), sets)
  if (length(extra)) stop("sets missing from set_levels: ", paste(extra, collapse = ", "), call. = FALSE)
  keys <- paste(df[[cell_col]], df[[set_col]], sep = "\r")
  if (anyDuplicated(keys)) stop("duplicate cell x set rows", call. = FALSE)
  if (nrow(df) != length(cells) * length(sets)) {
    stop("membership table must have exactly one row per cell x set: expected ",
         length(cells) * length(sets), " rows, found ", nrow(df), call. = FALSE)
  }
  member <- df[[member_col]]
  if (is.logical(member)) member <- as.integer(member)
  if (!is.numeric(member) || anyNA(member) || !all(member %in% c(0, 1))) {
    stop("member only accepts 0 or 1", call. = FALSE)
  }
  long <- data.frame(cell = as.character(df[[cell_col]]),
                     set = factor(as.character(df[[set_col]]), levels = sets),
                     member = as.integer(member), stringsAsFactors = FALSE)
  wide <- reshape(long, idvar = "cell", timevar = "set", direction = "wide")
  names(wide) <- sub("^member\\.", "", names(wide))
  wide
}

venn_set_columns <- function(tab, style) {
  cell_col <- get_style(style, "cell_col", "cell")
  cols <- style$set_cols
  if (is.null(cols)) {
    cols <- setdiff(names(tab), cell_col)
  } else {
    cols <- unlist(cols, use.names = FALSE)
  }
  missing <- setdiff(cols, names(tab))
  if (length(missing)) {
    stop("set_cols not found in membership table: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  if (length(cols) < 2L) stop("A venn diagram needs at least 2 set columns", call. = FALSE)
  if (length(cols) > 7L) stop("ggVennDiagram supports at most 7 sets", call. = FALSE)
  if (anyDuplicated(cols)) stop("set_cols must be unique", call. = FALSE)
  as.character(cols)
}

prepare_membership <- function(tab, set_cols, cell_col = "cell") {
  if (!is.data.frame(tab)) stop("membership table must be a data.frame", call. = FALSE)
  if (cell_col %in% names(tab)) {
    if (anyDuplicated(tab[[cell_col]])) stop("cell ids must be unique", call. = FALSE)
    rownames(tab) <- as.character(tab[[cell_col]])
  }
  for (s in set_cols) {
    v <- tab[[s]]
    if (is.logical(v)) next
    if (is.factor(v)) v <- as.character(v)
    if (is.character(v) && all(toupper(v) %in% c("TRUE", "FALSE"))) {
      tab[[s]] <- toupper(v) == "TRUE"
    } else if (is.numeric(v) && all(v %in% c(0, 1))) {
      tab[[s]] <- v == 1
    } else {
      stop("membership column '", s, "' must be logical TRUE/FALSE", call. = FALSE)
    }
  }
  tab
}

plot_panel <- function(tables, style, scp = SCP_helpers) {
  if (!"membership" %in% names(tables)) stop("Missing table: membership", call. = FALSE)
  tab <- tables$membership
  set_cols <- venn_set_columns(tab, style)
  tab <- prepare_membership(tab, set_cols, get_style(style, "cell_col", "cell"))
  set_level <- get_style(style, "set_level", "TRUE")
  palette <- get_style(style, "palette", "Paired")
  palcolor <- get_style(style, "palcolor", NULL)
  native <- scp_venn_table(
    meta.data = tab[, set_cols, drop = FALSE],
    stat.by = set_cols,
    stat_level = set_level,
    palette = palette,
    palcolor = palcolor,
    seed = get_style(style, "seed", 11),
    scp = scp
  )
  plot_scp_venn(
    native,
    alpha = get_style(style, "alpha", 1),
    label.size = get_style(style, "label_size", 3.5),
    label.fg = get_style(style, "label_fg", "black"),
    label.bg = get_style(style, "label_bg", "white"),
    label.bg.r = get_style(style, "label_bg_r", 0.1),
    title = get_style(style, "title", NULL),
    subtitle = get_style(style, "subtitle", NULL),
    seed = get_style(style, "seed", 11)
  )
}

draw <- function(fig, rect, tables, style) {
  p <- plot_panel(tables, style)
  print(p)
  invisible(p)
}
