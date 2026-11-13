# Native SCP CellStatPlot core for plot_type pie/rose/trend/area/dot.
# Extracted from SCP v0.5.6 R/SCP-plot.R, commit
# b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>=3).
#
# The counting half of StatPlot() is scp_stat_table(); the plot half is
# plot_scp_stat(), whose ggplot construction is copied from the corresponding
# `plot_type` branches (lines ~4783-4958). scp_stat_meta() and
# scp_stat_values() share that plotting core. No SCP package is required.
#
# The only adaptation is the explicit endpoint-label merge for pie/rose polar
# axes, which reproduces what the upstream cell-level ggplot displays when the
# 0% and 100% breaks land on the same angle.

.scp_stat_default_env <- function() {
  for (nm in c("SCP_helpers", "SCP_local")) {
    if (exists(nm, envir = globalenv(), inherits = FALSE)) {
      return(get(nm, envir = globalenv(), inherits = FALSE))
    }
  }
  stop("Pass a local SCP helper environment via scp=; the SCP package is not required.", call. = FALSE)
}

.scp_stat_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# Table half of StatPlot() for one stat.by/group.by pair. `group.by = NULL`
# reproduces the upstream "All.groups" single empty level. No plotting.
scp_stat_table <- function(meta.data, stat.by, group.by = NULL,
                           stat_type = c("percent", "count"),
                           NA_stat = TRUE,
                           group_levels = NULL, stat_levels = NULL) {
  stat_type <- match.arg(stat_type)
  if (!is.data.frame(meta.data)) stop("meta.data must be a data.frame", call. = FALSE)
  if (length(stat.by) != 1L) stop("scp_stat_table supports exactly one stat.by", call. = FALSE)
  if (!stat.by %in% colnames(meta.data)) stop("stat.by not found in meta.data", call. = FALSE)
  md <- meta.data[, c(stat.by, if (!is.null(group.by)) group.by), drop = FALSE]
  if (is.null(group.by)) {
    group.by <- "All.groups"
    md[[group.by]] <- factor("")
  } else if (!group.by %in% colnames(md)) {
    stop("group.by not found in meta.data", call. = FALSE)
  }
  if (is.null(group_levels)) {
    group_levels <- if (is.factor(md[[group.by]])) levels(md[[group.by]]) else unique(as.character(md[[group.by]]))
  }
  if (is.null(stat_levels)) {
    stat_levels <- if (is.factor(md[[stat.by]])) levels(md[[stat.by]]) else unique(as.character(md[[stat.by]]))
  }
  group_levels <- as.character(group_levels)
  stat_levels <- as.character(stat_levels)
  if (anyNA(group_levels) || anyNA(stat_levels)) stop("group/stat levels cannot contain NA", call. = FALSE)
  if (anyDuplicated(group_levels) || anyDuplicated(stat_levels)) stop("group/stat levels must be unique", call. = FALSE)
  extra_groups <- setdiff(unique(as.character(md[[group.by]])), group_levels)
  extra_stats <- setdiff(unique(as.character(md[[stat.by]])), stat_levels)
  if (length(extra_groups)) stop("groups missing from group_levels: ", paste(extra_groups, collapse = ", "), call. = FALSE)
  if (length(extra_stats)) stop("stats missing from stat_levels: ", paste(extra_stats, collapse = ", "), call. = FALSE)

  md[[group.by]] <- factor(as.character(md[[group.by]]), levels = group_levels)
  md[[stat.by]] <- factor(as.character(md[[stat.by]]), levels = stat_levels)

  # Copied from StatPlot(): xtabs + dplyr, one group variable.
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

# Plot half: original StatPlot() ggplot construction for the selected type.
plot_scp_stat <- function(dat, type = c("pie", "rose", "trend", "area", "dot"),
                          group.by = "group", stat.by = "stat",
                          value.by = "value", stat_type = c("percent", "count"),
                          group_levels = NULL, stat_levels = NULL,
                          palette = "Paired", palcolor = NULL, alpha = 1,
                          bg_col = NULL, bg_palette = "Paired", bg_palcolor = NULL, bg_alpha = 0.2,
                          NA_color = "grey", NA_stat = TRUE, keep_empty = FALSE,
                          flip = FALSE, label = FALSE, label.size = 3.5,
                          label.fg = "black", label.bg = "white", label.bg.r = 0.1,
                          position = c("stack", "dodge"),
                          title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                          legend_title = NULL, merge_polar_endpoints = FALSE,
                          legend.position = "right", legend.direction = "vertical",
                          theme_use = "theme_scp", theme_args = list(),
                          seed = 11, scp = NULL) {
  type <- match.arg(type)
  stat_type <- match.arg(stat_type)
  position <- match.arg(position)
  set.seed(seed)
  if (is.null(scp)) scp <- .scp_stat_default_env()
  palette_scp <- .scp_stat_fun(scp, "palette_scp")
  theme_scp <- .scp_stat_fun(scp, "theme_scp")
  capitalize <- .scp_stat_fun(scp, "capitalize")

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

  stat_values <- stat_levels
  if (isTRUE(NA_stat) && anyNA(dat[[stat.by]])) stat_values <- c(stat_values, NA_character_)
  stat_factor <- factor(stat_values, levels = stat_levels, exclude = NULL)
  colors <- palette_scp(stat_factor, palette = palette, palcolor = palcolor, NA_color = NA_color, NA_keep = TRUE)
  colors_use <- colors[names(colors) %in% unique(as.character(dat[[stat.by]]))]
  if (anyNA(dat[[stat.by]]) && isTRUE(NA_stat)) colors_use <- c(colors_use, colors["NA"])

  aspect.ratio <- if (type %in% c("rose", "pie")) 1 else NULL
  if (isTRUE(flip)) {
    dat[[group.by]] <- factor(dat[[group.by]], levels = rev(levels(dat[[group.by]])))
    aspect.ratio <- if (type %in% c("rose", "pie")) 1 else NULL
  }

  # Upstream pre-plot position/scale selection.
  if (type == "dot") {
    position_use <- position_identity()
    scalex <- scale_x_discrete(drop = !keep_empty)
    scaley <- NULL
  } else if (position == "stack") {
    position_use <- position_stack(vjust = 0.5)
    scalex <- scale_x_discrete(drop = !keep_empty, expand = c(0, 0))
    percent_labels <- function(x) {
      lab <- scales::percent(x)
      if (length(x) > 1L && isTRUE(all.equal(min(x), 0)) && isTRUE(all.equal(max(x), 1))) {
        lab[1] <- paste0(lab[1], "/", lab[length(lab)])
        lab[length(lab)] <- ""
      }
      lab
    }
    y_labels <- if (stat_type == "count") scales::number else if (isTRUE(merge_polar_endpoints) && type %in% c("pie", "rose")) percent_labels else scales::percent
    scaley <- scale_y_continuous(
      labels = y_labels,
      expand = c(0, 0)
    )
  } else {
    if (type == "area") {
      position_use <- position_dodge2(width = 0.9, preserve = "total")
    } else {
      position_use <- position_dodge2(width = 0.9, preserve = "single")
    }
    scalex <- scale_x_discrete(drop = !keep_empty)
    scaley <- scale_y_continuous(
      limits = c(0, max(dat[[value.by]], na.rm = TRUE) * 1.1),
      labels = if (stat_type == "count") scales::number else scales::percent,
      expand = c(0, 0)
    )
  }
  if (position == "stack") {
    bg_layer <- NULL
  } else {
    # Original StatPlot(): dodge panels get alternating group backgrounds.
    if (is.null(bg_col)) {
      bg_data <- data.frame(group = group_levels, stringsAsFactors = FALSE)
      bg_pal <- bg_palcolor %||% rep(c("transparent", "grey85"), length(group_levels))
      bg_color <- palette_scp(factor(group_levels, levels = group_levels), palette = bg_palette, palcolor = bg_pal)
      bg_data[["x"]] <- as.numeric(factor(bg_data[["group"]], levels = group_levels))
      bg_data[["fill"]] <- unname(bg_color[bg_data[["group"]]])
    } else {
      bg_data <- unique(dat[, c(group.by, bg_col), drop = FALSE])
      names(bg_data) <- c("group", "bg")
      bg_data[["group"]] <- as.character(bg_data[["group"]])
      bg_data[["x"]] <- as.numeric(factor(bg_data[["group"]], levels = group_levels))
      bg_color <- palette_scp(factor(unique(as.character(bg_data[["bg"]])), levels = unique(as.character(bg_data[["bg"]]))), palette = bg_palette, palcolor = bg_palcolor)
      bg_data[["fill"]] <- unname(bg_color[as.character(bg_data[["bg"]])])
      bg_data <- bg_data[order(bg_data[["x"]]), , drop = FALSE]
    }
    bg_data[["xmin"]] <- ifelse(bg_data[["x"]] == min(bg_data[["x"]]), -Inf, bg_data[["x"]] - 0.5)
    bg_data[["xmax"]] <- ifelse(bg_data[["x"]] == max(bg_data[["x"]]), Inf, bg_data[["x"]] + 0.5)
    bg_data[["ymin"]] <- -Inf
    bg_data[["ymax"]] <- Inf
    bg_layer <- geom_rect(
      data = bg_data, xmin = bg_data[["xmin"]], xmax = bg_data[["xmax"]],
      ymin = bg_data[["ymin"]], ymax = bg_data[["ymax"]],
      fill = bg_data[["fill"]], alpha = bg_alpha, inherit.aes = FALSE
    )
  }

  if (type == "trend") {
    dat_area <- dat[rep(seq_len(nrow(dat)), each = 2), , drop = FALSE]
    dat_area[[group.by]] <- as.numeric(dat_area[[group.by]])
    dat_area[seq(1, nrow(dat_area), 2), group.by] <- dat_area[seq(1, nrow(dat_area), 2), group.by] - 0.3
    dat_area[seq(2, nrow(dat_area), 2), group.by] <- dat_area[seq(2, nrow(dat_area), 2), group.by] + 0.3
    p <- ggplot(dat, aes(x = .data[[group.by]], y = .data[[value.by]], fill = .data[[stat.by]])) +
      bg_layer +
      geom_area(
        data = dat_area, mapping = aes(x = .data[[group.by]], fill = .data[[stat.by]]),
        alpha = alpha / 2, color = "grey50", position = position_use
      ) +
      geom_col(aes(fill = .data[[stat.by]]),
        width = 0.6,
        color = "black",
        alpha = alpha,
        position = position_use
      ) +
      scalex +
      scaley
  }
  if (type == "rose") {
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
      coord_polar(theta = "x", start = ifelse(flip, pi / 2, 0))
  }
  if (type == "pie") {
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
  }
  if (type == "area") {
    p <- ggplot(dat, aes(x = .data[[group.by]], y = .data[[value.by]], group = .data[[stat.by]])) +
      bg_layer +
      geom_area(aes(fill = .data[[stat.by]]),
        color = "black",
        alpha = alpha,
        position = position_use
      ) +
      scalex +
      scaley
  }
  if (type == "dot") {
    p <- ggplot(dat, aes(x = .data[[group.by]], y = .data[[stat.by]])) +
      bg_layer +
      geom_point(aes(fill = .data[[stat.by]], size = .data[[value.by]]),
        color = "black",
        alpha = alpha,
        shape = 21,
        position = position_use
      ) +
      scalex +
      scale_size_area(name = capitalize(stat_type), max_size = 12) +
      guides(size = guide_legend(override.aes = list(fill = "grey30")))
  }

  if (isTRUE(label)) {
    if (type == "dot") {
      p <- p + geom_text_repel(
        aes(
          x = .data[[group.by]], y = .data[[stat.by]],
          label = if (stat_type == "count") .data[[value.by]] else paste0(round(.data[[value.by]] * 100, 1), "%")
        ),
        colour = label.fg, size = label.size,
        bg.color = label.bg, bg.r = label.bg.r,
        point.size = NA, max.overlaps = 100, min.segment.length = 0, force = 0,
        position = position_use
      )
    } else {
      p <- p + geom_text_repel(
        aes(
          label = if (stat_type == "count") .data[[value.by]] else paste0(round(.data[[value.by]] * 100, 1), "%"),
          y = .data[[value.by]]
        ),
        colour = label.fg, size = label.size,
        bg.color = label.bg, bg.r = label.bg.r,
        point.size = NA, max.overlaps = 100, min.segment.length = 0, force = 0,
        position = position_use
      )
    }
  }
  axis.text.x <- if (type %in% c("rose", "pie")) element_text() else element_text(angle = 45, hjust = 1, vjust = 1)
  title <- title %||% ""
  xlab <- xlab %||% if (group.by == "All.groups" && all(levels(dat[[group.by]]) == "")) "" else group.by
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
      panel.grid.major = if (type == "trend" & stat_type == "percent") element_blank() else element_line(colour = "grey80", linetype = 2)
    ) + guides(fill = guide_legend(
      title.hjust = 0,
      order = 1,
      override.aes = list(size = 4, color = "black", alpha = 1)
    ))
  if (isTRUE(flip) && !type %in% c("pie", "rose")) p <- p + coord_flip()
  p
}

# End-to-end metadata entry, same inputs as the upstream CellStatPlot examples.
scp_stat_meta <- function(meta.data, stat.by, group.by = NULL,
                          type = c("pie", "rose", "trend", "area", "dot"),
                          stat_type = c("percent", "count"),
                          NA_stat = TRUE, group_levels = NULL, stat_levels = NULL,
                          palette = "Paired", palcolor = NULL, ...,
                          seed = 11, scp = NULL) {
  type <- match.arg(type)
  tab <- scp_stat_table(meta.data, stat.by, group.by,
    stat_type = stat_type, NA_stat = NA_stat,
    group_levels = group_levels, stat_levels = stat_levels
  )
  plot_scp_stat(tab,
    type = type,
    group.by = attr(tab, "group.by"), stat.by = attr(tab, "stat.by"), value.by = "value",
    stat_type = attr(tab, "stat_type"),
    group_levels = attr(tab, "group_levels"), stat_levels = attr(tab, "stat_levels"),
    palette = palette, palcolor = palcolor, ..., seed = seed, scp = scp
  )
}

# Independent table entry: group/stat/value, zero-filled grid, proportion check.
scp_stat_values <- function(df, group_col = "group", stat_col = "celltype",
                            value_col = "proportion",
                            type = c("pie", "rose", "trend", "area", "dot"),
                            stat_type = c("percent", "count"),
                            group_levels = NULL, stat_levels = NULL,
                            palette = "Paired", palcolor = NULL, ...,
                            seed = 11, scp = NULL) {
  type <- match.arg(type)
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
  plot_scp_stat(
    dat = m, type = type, group.by = "group", stat.by = "stat", value.by = "value",
    stat_type = stat_type, group_levels = group_levels, stat_levels = stat_levels,
    palette = palette, palcolor = palcolor, ...,
    seed = seed, scp = scp
  )
}
