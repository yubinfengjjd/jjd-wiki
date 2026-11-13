# Native SCP CellStatPlot core for plot_type = "upset".
# Extracted from SCP v0.5.6 R/SCP-plot.R, commit
# b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
#
# Table half: scp_upset_table() reproduces the upstream intermediate object that
# StatPlot() hands to ggplot() for this branch, identical() to the data stored
# in the upstream plot. It contains the downstream logical set columns, the
# single empty "All.groups" factor (group.by/split.by default), and the
# per-cell `intersection` list; the upstream loop that builds `intersection`
# (original lines 5046-5049) is kept verbatim here so the plot half can start
# from the same object. Upstream data preparation copied here: 4584-4589
# (group.by/split.by default), 4650-4668 (stat_level), 4683 (dat_all),
# 4693 (dat_split), 4979 (split loop). scp_upset_counts() returns the
# intersection counts that geom_bar(stat = "count") displays.
#
# Plot half: plot_scp_upset() is the upstream ggplot construction (original
# lines 5050-5070) copied line-for-line. Changes, all documented in PATCHES.md:
#   * check_R("ggupset") -> requireNamespace("ggupset", quietly = TRUE)
#   * the hard-coded fill palette "material-indigo" is exposed as `fill_palette`
#     with the same default (CellStatPlot's own `palette` argument is not used
#     by this branch upstream)
#   * CellStatPlot's `alpha` argument, unused by the upstream branch, is passed
#     to geom_bar; alpha = 1 is pixel-identical to the upstream default
#   * the local helpers palette_scp()/theme_scp() are used through `scp=`
# No custom ggplot is substituted.

.scp_upset_default_env <- function() {
  if (exists("SCP_helpers", envir = globalenv(), inherits = FALSE)) {
    return(get("SCP_helpers", envir = globalenv(), inherits = FALSE))
  }
  stop("Pass a local SCP helper environment via scp=; the SCP package is not required.", call. = FALSE)
}

.scp_upset_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# Interface adapter: long cell-level membership table (cell, set, member) to a
# wide logical data frame. Cell order is the order of first appearance, set
# order is `set_levels` (or first appearance). One row per cell; one column per
# set. The interface table is lossless: every cell x set pair must be present.
scp_upset_membership <- function(df, cell_col = "cell", set_col = "set",
                                 member_col = "member", set_levels = NULL) {
  if (!is.data.frame(df)) stop("membership table must be a data.frame", call. = FALSE)
  req <- c(cell_col, set_col, member_col)
  if (!all(req %in% names(df))) {
    stop("membership table is missing columns: ",
         paste(setdiff(req, names(df)), collapse = ", "), call. = FALSE)
  }
  cells <- unique(as.character(df[[cell_col]]))
  if (anyNA(cells) || any(!nzchar(cells))) stop("cell ids cannot be NA or empty", call. = FALSE)
  if (is.null(set_levels)) {
    set_levels <- unique(as.character(df[[set_col]]))
  }
  set_levels <- as.character(set_levels)
  if (anyNA(set_levels) || any(!nzchar(set_levels))) {
    stop("set names cannot be NA or empty", call. = FALSE)
  }
  if (anyDuplicated(set_levels)) stop("set_levels must be unique", call. = FALSE)
  extra <- setdiff(unique(as.character(df[[set_col]])), set_levels)
  if (length(extra)) {
    stop("sets missing from set_levels: ", paste(extra, collapse = ", "), call. = FALSE)
  }
  keys <- paste(df[[cell_col]], df[[set_col]], sep = "\r")
  if (anyDuplicated(keys)) stop("duplicate cell x set rows", call. = FALSE)
  if (nrow(df) != length(cells) * length(set_levels)) {
    stop("membership table must have exactly one row per cell x set: expected ",
         length(cells) * length(set_levels), " rows, found ", nrow(df), call. = FALSE)
  }
  member <- df[[member_col]]
  if (is.logical(member)) {
    member <- as.integer(member)
  }
  if (!is.numeric(member) && !is.integer(member)) {
    stop("member must be 0/1 or logical", call. = FALSE)
  }
  if (anyNA(member) || !all(member %in% c(0, 1))) {
    stop("member only accepts 0 or 1", call. = FALSE)
  }
  wide <- data.frame(cell = cells, stringsAsFactors = FALSE)
  for (s in set_levels) {
    sub <- df[as.character(df[[set_col]]) == s, , drop = FALSE]
    wide[[s]] <- as.logical(sub[[member_col]][match(cells, as.character(sub[[cell_col]]))])
  }
  rownames(wide) <- wide$cell
  wide$cell <- NULL
  wide
}

# Table half of StatPlot() for plot_type = "upset" (original lines 4643-4660,
# 4676-4683, 4961, 5045-5050). `meta.data` must already carry one logical
# column per set (the wide form returned by scp_upset_membership()).
scp_upset_table <- function(meta.data, stat.by, stat_level = "TRUE") {
  if (!is.data.frame(meta.data)) stop("meta.data must be a data.frame", call. = FALSE)
  if (length(stat.by) < 2L) stop("upset needs at least two stat.by columns", call. = FALSE)
  if (!all(stat.by %in% colnames(meta.data))) {
    stop("stat.by missing from meta.data: ",
         paste(setdiff(stat.by, colnames(meta.data)), collapse = ", "), call. = FALSE)
  }
  # Upstream: group.by = split.by = NULL -> a single empty "All.groups" level.
  group.by <- "All.groups"
  split.by <- "All.groups"
  meta.data[[group.by]] <- factor("")
  meta.data[[split.by]] <- factor("")
  # Upstream: logical/factor columns are kept; anything else becomes a factor.
  for (i in unique(stat.by)) {
    if (!is.factor(meta.data[[i]]) && !is.logical(meta.data[[i]])) {
      meta.data[[i]] <- factor(meta.data[[i]], levels = unique(meta.data[[i]]))
    }
  }
  # Upstream stat_level handling for venn/upset.
  if (is.null(stat_level)) {
    stat_level <- lapply(stat.by, function(stat) {
      levels(meta.data[[stat]])[1] %||% sort(unique(meta.data[[stat]]))[1]
    })
  } else {
    if (length(stat_level) == 1) {
      stat_level <- rep(stat_level, length(stat.by))
    }
    if (length(stat_level) != length(stat.by)) {
      stop("'stat_level' must be of length 1 or the same length as 'stat.by'", call. = FALSE)
    }
  }
  if (is.null(names(stat_level))) {
    names(stat_level) <- stat.by
  }
  for (i in stat.by) {
    meta.data[[i]] <- meta.data[[i]] %in% stat_level[[i]]
  }
  dat_all <- meta.data[, unique(c(stat.by, group.by, split.by)), drop = FALSE]
  dat_split <- split.data.frame(dat_all, dat_all[[split.by]])
  # Single empty split level, same indexing as the upstream loop.
  dat_use <- dat_split[[ifelse(split.by == "All.groups", 1, levels(dat_all[[split.by]])[1])]]
  # Original lines 5046-5048: per-cell intersection list, kept verbatim.
  for (n in seq_len(nrow(dat_use))) {
    dat_use[["intersection"]][n] <- list(stat.by[unlist(dat_use[n, stat.by])])
  }
  # Original line 5049: drop cells outside every set.
  dat_use <- dat_use[sapply(dat_use[["intersection"]], length) > 0, , drop = FALSE]
  dat_use
}

# Counts shown by geom_bar(stat = "count"), ordered exactly as
# ggupset::scale_x_upset(order_by = "freq") does: table() sorts names
# alphabetically, then sort(decreasing = TRUE) keeps that order for ties.
scp_upset_counts <- function(dat) {
  if (!"intersection" %in% names(dat)) stop("dat must come from scp_upset_table()", call. = FALSE)
  keys <- vapply(dat[["intersection"]], function(x) paste(sort(x), collapse = " & "), character(1))
  tab <- table(keys)
  out <- data.frame(
    intersection = names(tab),
    count = as.integer(tab),
    degree = vapply(strsplit(names(tab), " & ", fixed = TRUE), length, integer(1)),
    stringsAsFactors = FALSE
  )
  rownames(out) <- NULL
  out[order(-out$count, out$intersection), , drop = FALSE]
}

# Plot half: original StatPlot() ggplot construction for plot_type = "upset".
plot_scp_upset <- function(dat, stat.by,
                           label.size = 3.5, label.fg = "black",
                           label.bg = "white", label.bg.r = 0.1,
                           alpha = 1, show.legend = FALSE,
                           title = NULL, subtitle = NULL, xlab = "",
                           fill_palette = "material-indigo",
                           seed = 11, scp = NULL) {
  set.seed(seed)
  if (is.null(scp)) scp <- .scp_upset_default_env()
  palette_scp <- .scp_upset_fun(scp, "palette_scp")
  theme_scp <- .scp_upset_fun(scp, "theme_scp")
  if (!requireNamespace("ggupset", quietly = TRUE)) {
    stop("Package 'ggupset' is required for plot_type = 'upset'.", call. = FALSE)
  }
  p <- ggplot(dat, aes(x = intersection)) +
    geom_bar(aes(fill = after_stat(count)), color = "black", width = 0.5, alpha = alpha, show.legend = show.legend) +
    geom_text_repel(aes(label = after_stat(count)),
      stat = "count",
      colour = label.fg, size = label.size,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100, force = 0,
      min.segment.length = 0, segment.colour = "black"
    ) +
    labs(title = title, subtitle = subtitle, x = xlab, y = "Intersection size") +
    ggupset::scale_x_upset(sets = stat.by, n_intersections = 20) +
    scale_fill_gradientn(colors = palette_scp(palette = fill_palette)) +
    theme_scp(
      aspect.ratio = 0.6,
      panel.grid.major = element_line(colour = "grey80", linetype = 2)
    ) +
    ggupset::theme_combmatrix(
      combmatrix.label.text = element_text(size = 12, color = "black"),
      combmatrix.label.extra_spacing = 6
    )
  p <- p + labs(title = title, subtitle = subtitle)
  p
}

# End-to-end entry matching the upstream CellStatPlot() call: a wide logical
# membership data frame plus the set order.
scp_upset_meta <- function(meta.data, stat.by, stat_level = "TRUE",
                           label.size = 3.5, label.fg = "black",
                           label.bg = "white", label.bg.r = 0.1,
                           alpha = 1, show.legend = FALSE,
                           title = NULL, subtitle = NULL, xlab = "",
                           fill_palette = "material-indigo",
                           seed = 11, scp = NULL) {
  dat <- scp_upset_table(meta.data, stat.by, stat_level = stat_level)
  plot_scp_upset(dat,
    stat.by = stat.by,
    label.size = label.size, label.fg = label.fg,
    label.bg = label.bg, label.bg.r = label.bg.r,
    alpha = alpha, show.legend = show.legend,
    title = title, subtitle = subtitle, xlab = xlab,
    fill_palette = fill_palette, seed = seed, scp = scp
  )
}
