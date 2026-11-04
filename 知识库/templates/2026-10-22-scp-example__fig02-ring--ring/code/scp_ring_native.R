# Native SCP ring core, extracted from SCP v0.5.6 R/SCP-plot.R
# commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>=3).
#
# This file does not re-implement SCP geometry. The ggplot construction below
# is copied from the `plot_type == "ring"` branch of StatPlot(); the counting
# step is split into scp_ring_table(), and plot_scp_ring() consumes that table.
# scp_ring_meta() and scp_ring_proportions() share plot_scp_ring().
#
# Dependency: an environment containing theme_scp() and palette_scp(), passed
# via `scp`; defaults to SCP_helpers or SCP_local in globalenv. The SCP package
# is not required.

.scp_default_env <- function() {
  for (nm in c("SCP_helpers", "SCP_local")) {
    if (exists(nm, envir = globalenv(), inherits = FALSE)) {
      return(get(nm, envir = globalenv(), inherits = FALSE))
    }
  }
  stop("Pass a local SCP helper environment via scp=; the SCP package is not required.", call. = FALSE)
}

.scp_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# Table-producing half of StatPlot for one stat.by/group.by pair.
# Returns the tidy cell table used by the ring branch (before the blank ring
# row is added by the plot half). No plotting occurs here.
scp_ring_table <- function(meta.data, stat.by, group.by,
                           stat_type = c("percent", "count"),
                           NA_stat = TRUE,
                           group_levels = NULL, stat_levels = NULL) {
  stat_type <- match.arg(stat_type)
  if (!is.data.frame(meta.data)) stop("meta.data must be a data.frame", call. = FALSE)
  if (length(stat.by) != 1L || length(group.by) != 1L) {
    stop("scp_ring_table supports exactly one stat.by and one group.by", call. = FALSE)
  }
  if (!all(c(stat.by, group.by) %in% colnames(meta.data))) {
    stop("stat.by/group.by not found in meta.data", call. = FALSE)
  }
  md <- meta.data[, c(stat.by, group.by), drop = FALSE]
  if (is.null(group_levels)) {
    if (is.factor(md[[group.by]])) group_levels <- levels(md[[group.by]]) else group_levels <- unique(as.character(md[[group.by]]))
  }
  if (is.null(stat_levels)) {
    if (is.factor(md[[stat.by]])) stat_levels <- levels(md[[stat.by]]) else stat_levels <- unique(as.character(md[[stat.by]]))
  }
  group_levels <- as.character(group_levels)
  stat_levels <- as.character(stat_levels)
  if (anyNA(group_levels) || anyNA(stat_levels)) stop("group/stat levels cannot contain NA", call. = FALSE)
  if (anyDuplicated(group_levels) || anyDuplicated(stat_levels)) stop("group/stat levels must be unique", call. = FALSE)

  # StatPlot's factor conversion, with explicit levels preserved.
  md[[group.by]] <- factor(as.character(md[[group.by]]), levels = group_levels)
  md[[stat.by]] <- factor(as.character(md[[stat.by]]), levels = stat_levels)

  # Copied counting logic from StatPlot() (xtabs + dplyr), one group.
  dat_use <- md %>%
    xtabs(formula = paste0("~", stat.by, "+", group.by), addNA = NA_stat) %>%
    as.data.frame()
  if (stat_type == "percent") {
    dat_use <- dat_use %>%
      group_by(across(all_of(group.by)), .drop = FALSE) %>%
      mutate(groupn = sum(Freq)) %>%
      group_by(across(all_of(c(stat.by, group.by))), .drop = FALSE) %>%
      mutate(value = Freq / groupn) %>%
      as.data.frame()
  } else {
    dat_use <- dat_use %>% mutate(value = Freq)
  }
  dat <- dat_use[dat_use[[group.by]] %in% group_levels, , drop = FALSE]
  dat[[group.by]] <- factor(dat[[group.by]], levels = levels(dat[[group.by]])[levels(dat[[group.by]]) %in% dat[[group.by]]])
  dat <- dat[!is.na(dat[["value"]]), , drop = FALSE]

  attr(dat, "group.by") <- group.by
  attr(dat, "stat.by") <- stat.by
  attr(dat, "stat_type") <- stat_type
  attr(dat, "group_levels") <- group_levels
  attr(dat, "stat_levels") <- stat_levels
  dat
}

# Table-consuming half: original StatPlot ring ggplot construction.
# `dat` must contain one row per observed group x stat combination.
plot_scp_ring <- function(dat, group.by = "group", stat.by = "stat",
                          value.by = "value", stat_type = c("percent", "count"),
                          group_levels = NULL, stat_levels = NULL,
                          palette = "Paired", palcolor = NULL, alpha = 1,
                          NA_color = "grey", NA_stat = TRUE, keep_empty = FALSE,
                          flip = FALSE, label = FALSE, label.size = 3.5,
                          label.fg = "black", label.bg = "white", label.bg.r = 0.1,
                          position = c("stack", "dodge"),
                          title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                          legend_title = NULL, merge_polar_endpoints = TRUE,
                          legend.position = "right", legend.direction = "vertical",
                          theme_use = "theme_scp", theme_args = list(),
                          seed = 11, scp = NULL) {
  # StatPlot() calls set.seed(seed) before building; geom_text_repel uses it.
  set.seed(seed)
  stat_type <- match.arg(stat_type)
  position <- match.arg(position)
  if (is.null(scp)) scp <- .scp_default_env()
  palette_scp <- .scp_fun(scp, "palette_scp")
  theme_scp <- .scp_fun(scp, "theme_scp")
  if (is.null(group_levels)) group_levels <- if (is.factor(dat[[group.by]])) levels(dat[[group.by]]) else unique(as.character(dat[[group.by]]))
  if (is.null(stat_levels)) stat_levels <- if (is.factor(dat[[stat.by]])) levels(dat[[stat.by]]) else unique(as.character(dat[[stat.by]]))
  group_levels <- as.character(group_levels)
  stat_levels <- as.character(stat_levels)
  dat <- as.data.frame(dat)
  dat[[group.by]] <- factor(as.character(dat[[group.by]]), levels = group_levels)
  dat[[stat.by]] <- factor(as.character(dat[[stat.by]]), levels = stat_levels)
  dat[[value.by]] <- as.numeric(dat[[value.by]])
  if (anyNA(dat[[value.by]])) stop("value column contains NA", call. = FALSE)
  dat <- dat[!is.na(dat[[value.by]]), , drop = FALSE]

  # Original color construction: palette over the stat variable in dat_all.
  # `stat_values` is an explicit factor including NA when NA_stat is TRUE.
  stat_values <- stat_levels
  if (isTRUE(NA_stat) && anyNA(dat[[stat.by]])) stat_values <- c(stat_values, NA_character_)
  stat_factor <- factor(stat_values, levels = stat_levels, exclude = NULL)
  colors <- palette_scp(stat_factor, palette = palette, palcolor = palcolor, NA_color = NA_color, NA_keep = TRUE)
  colors_use <- colors[names(colors) %in% unique(as.character(dat[[stat.by]]))]
  if (anyNA(dat[[stat.by]]) && isTRUE(NA_stat)) colors_use <- c(colors_use, colors["NA"])

  aspect.ratio <- 1
  if (isTRUE(flip)) {
    dat[[group.by]] <- factor(dat[[group.by]], levels = rev(levels(dat[[group.by]])))
    aspect.ratio <- 1
  }

  # Original ring spacing: add an empty x level and duplicate the last row.
  dat[[group.by]] <- factor(dat[[group.by]], levels = c("   ", levels(dat[[group.by]])))
  dat <- rbind(dat, dat[nrow(dat) + 1, , drop = FALSE])
  dat[nrow(dat), group.by] <- "   "

  # Upstream's cell-level plot lets the 0% and 100% theta labels collide at
  # the top of the polar panel. A table-level ggplot object does not merge
  # them, so merge the duplicated endpoints explicitly to preserve the
  # upstream display (pixel-matched against the 8x6 / 150 dpi source).
  percent_labels <- function(x) {
    lab <- scales::percent(x)
    if (length(x) > 1L && isTRUE(all.equal(min(x), 0)) && isTRUE(all.equal(max(x), 1))) {
      lab[1] <- paste0(lab[1], "/", lab[length(lab)])
      lab[length(lab)] <- ""
    }
    lab
  }
  y_labels <- if (stat_type == "count") scales::number else if (isTRUE(merge_polar_endpoints)) percent_labels else scales::percent
  if (position == "stack") {
    position_use <- position_stack(vjust = 0.5)
    scalex <- scale_x_discrete(drop = !keep_empty, expand = c(0, 0))
    scaley <- scale_y_continuous(
      labels = y_labels,
      expand = c(0, 0)
    )
  } else {
    position_use <- position_dodge2(width = 0.9, preserve = "single")
    scalex <- scale_x_discrete(drop = !keep_empty)
    scaley <- scale_y_continuous(
      limits = c(0, max(dat[[value.by]], na.rm = TRUE) * 1.1),
      labels = y_labels,
      expand = c(0, 0)
    )
  }
  bg_layer <- NULL

  p <- ggplot(dat, aes(x = .data[[group.by]], y = .data[[value.by]], group = .data[[stat.by]])) +
    bg_layer +
    geom_col(aes(fill = .data[[stat.by]]),
      width = 0.8,
      color = "black",
      alpha = alpha,
      position = position_use
    ) +
    scalex +
    scaley +
    coord_polar(theta = "y", start = ifelse(flip, pi / 2, 0))

  if (isTRUE(label)) {
    p <- p + geom_text_repel(
      aes(
        label = if (stat_type == "count") .data[[value.by]] else paste0(round(.data[[value.by]] * 100, 1), "%"),
        y = .data[[value.by]]
      ),
      colour = label.fg, size = label.size,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100, min.segment.length = 0, force = 1,
      position = position_use
    )
  }
  axis.text.x <- element_text()
  title <- title %||% ""
  xlab <- xlab %||% group.by
  ylab <- ylab %||% ifelse(stat_type == "count", "Count", "Percentage")
  legend_title <- legend_title %||% paste0(stat.by, ":")
  p <- p + labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    scale_fill_manual(
      name = legend_title, values = colors_use, na.value = colors_use["NA"], drop = FALSE,
      limits = names(colors_use), na.translate = TRUE
    ) +
    do.call(theme_scp, theme_args) +
    theme(
      aspect.ratio = aspect.ratio,
      axis.text.x = axis.text.x,
      legend.position = legend.position,
      legend.direction = legend.direction,
      panel.grid.major = element_line(colour = "grey80", linetype = 2)
    ) + guides(fill = guide_legend(
      title.hjust = 0,
      order = 1,
      override.aes = list(size = 4, color = "black", alpha = 1)
    ))
  if (isTRUE(flip)) p <- p + coord_flip()
  p
}

# End-to-end native cell-metadata entry (same inputs as the upstream example).
scp_ring_meta <- function(meta.data, stat.by, group.by,
                          stat_type = c("percent", "count"),
                          NA_stat = TRUE, group_levels = NULL, stat_levels = NULL,
                          palette = "Paired", palcolor = NULL, ...,
                          seed = 11, scp = NULL) {
  tab <- scp_ring_table(meta.data, stat.by, group.by,
    stat_type = stat_type, NA_stat = NA_stat,
    group_levels = group_levels, stat_levels = stat_levels
  )
  plot_scp_ring(tab,
    group.by = group.by, stat.by = stat.by, value.by = "value",
    stat_type = attr(tab, "stat_type"),
    group_levels = attr(tab, "group_levels"), stat_levels = attr(tab, "stat_levels"),
    palette = palette, palcolor = palcolor, ..., seed = seed,
    scp = scp
  )
}

# Independent table entry: group/celltype/proportion (or count) table.
# Missing group x stat combinations are completed with 0 explicitly, matching
# xtabs(.drop = FALSE), and validated before plotting.
scp_ring_proportions <- function(df, group_col = "group", stat_col = "celltype",
                                 value_col = "proportion",
                                 stat_type = c("percent", "count"),
                                 group_levels = NULL, stat_levels = NULL,
                                 palette = "Paired", palcolor = NULL,
                                 title = NULL, xlab = NULL, ylab = NULL,
                                 legend_title = NULL, ...,
                                 seed = 11, scp = NULL) {
  stat_type <- match.arg(stat_type)
  req <- c(group_col, stat_col, value_col)
  if (!all(req %in% names(df))) stop("missing columns: ", paste(setdiff(req, names(df)), collapse = ", "), call. = FALSE)
  d <- data.frame(
    group = as.character(df[[group_col]]),
    stat = as.character(df[[stat_col]]),
    value = as.numeric(df[[value_col]]),
    stringsAsFactors = FALSE
  )
  if (anyNA(d$group) || anyNA(d$stat) || anyNA(d$value)) stop("group/stat/value cannot contain NA", call. = FALSE)
  if (any(!is.finite(d$value)) || any(d$value < 0)) stop("value must be finite and non-negative", call. = FALSE)
  if (is.null(group_levels)) group_levels <- unique(d$group)
  if (is.null(stat_levels)) stat_levels <- unique(d$stat)
  group_levels <- as.character(group_levels)
  stat_levels <- as.character(stat_levels)
  if (anyDuplicated(group_levels) || anyDuplicated(stat_levels)) {
    stop("group/stat levels must be unique", call. = FALSE)
  }
  extra_groups <- setdiff(unique(d$group), group_levels)
  extra_stats <- setdiff(unique(d$stat), stat_levels)
  if (length(extra_groups)) {
    stop("groups missing from group_levels: ", paste(extra_groups, collapse = ", "), call. = FALSE)
  }
  if (length(extra_stats)) {
    stop("categories missing from stat_levels: ", paste(extra_stats, collapse = ", "), call. = FALSE)
  }
  if (anyDuplicated(d[c("group", "stat")])) stop("duplicate group x stat rows", call. = FALSE)
  grid <- expand.grid(group = group_levels, stat = stat_levels, stringsAsFactors = FALSE)
  m <- merge(grid, d, by = c("group", "stat"), all.x = TRUE)
  m$value[is.na(m$value)] <- 0
  if (stat_type == "percent") {
    sums <- tapply(m$value, m$group, sum)
    if (any(abs(sums - 1) > 1e-8)) stop("each group's proportions must sum to 1", call. = FALSE)
  }
  m <- m[order(match(m$group, group_levels), match(m$stat, stat_levels)), , drop = FALSE]
  rownames(m) <- NULL
  plot_scp_ring(
    dat = m, group.by = "group", stat.by = "stat", value.by = "value",
    stat_type = stat_type, group_levels = group_levels, stat_levels = stat_levels,
    palette = palette, palcolor = palcolor,
    title = title, xlab = xlab %||% group_col, ylab = ylab,
    legend_title = legend_title %||% paste0(stat_col, ":"), ...,
    seed = seed, scp = scp
  )
}
