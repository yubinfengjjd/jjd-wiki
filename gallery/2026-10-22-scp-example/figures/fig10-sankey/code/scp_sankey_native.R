# Native SCP CellStatPlot core for plot_type = "sankey".
# Extracted from SCP v0.5.6 R/SCP-plot.R, commit
# b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
#
# CellStatPlot (lines 4463-4562) forwards meta.data to StatPlot (4564-5624);
# the sankey branch is lines 5072-5114. The table half below reproduces the
# upstream intermediates (factor levels, dat_use, colors, make_long() output,
# and the node/flow tables computed by StatSankeyNode/StatSankeyFlow). The plot
# half copies the upstream branch construction line for line, with namespace
# qualification and the three compatibility patches documented in PATCHES.md:
#
#   P1  legend <- do.call(cbind/rbind, legend_list)
#       -> do.call(cbind/rbind, lapply(legend_list, as_gtable))
#       Upstream passes a list matrix of grobs to add_grob(); gtable 0.3.6
#       rejects it ("`grobs` must be a single grob or a list of grobs, not a
#       list matrix"). as_gtable() wraps each guide-box grob into a gtable so
#       cbind/rbind dispatch to gtable_cbind/gtable_rbind. Legend content and
#       order are unchanged.
#   P2  p <- wrap_plots(gtable)
#       -> p <- wrap_plots(list(gtable))
#       patchwork 1.3.1 treats a bare gtable argument as a list matrix of
#       panels; list(gtable) marks it as one plot. Geometry is unchanged.
#   P3  get_legend() (in scp_helpers.R) skips zeroGrob guide-box placeholders.
#       ggplot2 >= 3.5 keeps guide-box-right/left/bottom/top/inside slots;
#       upstream takes the first "guide-box" match, which is an empty right
#       slot, so the legends disappear. P3 returns the first non-empty box.
#       Legend content, order, theme and grobs are unchanged.
#
# No custom ggplot is substituted. make_long(), geom_sankey(), the scales,
# theme_void()/theme_scp() and the legend construction are the upstream text.
# split.by is supported only for the default single "All.groups" split here;
# the multi-split wrap_plots() loop is not part of this template.

.scp_sankey_default_env <- function() {
  for (nm in c("SCP_helpers", "SCP_local")) {
    if (exists(nm, envir = globalenv(), inherits = FALSE)) {
      return(get(nm, envir = globalenv(), inherits = FALSE))
    }
  }
  stop("Pass a local SCP helper environment via scp=; the SCP package is not required.", call. = FALSE)
}

.scp_sankey_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# Pre-processing half of StatPlot() for plot_type = "sankey".
# Copied from StatPlot() lines 4575-4693, restricted to the single default
# split. stat_levels is the explicit-category-order hook used by the
# render-cell-linkage interface (named list, one character vector per stat.by).
scp_sankey_prepare <- function(meta.data, stat.by, group.by = NULL, split.by = NULL, bg.by = NULL,
                               stat_type = c("percent", "count"), stat_levels = NULL,
                               force = FALSE, seed = 11) {
  set.seed(seed)
  stat_type <- match.arg(stat_type)
  plot_type <- "sankey"
  if (nrow(meta.data) == 0) {
    stop("meta.data is empty.")
  }
  if (!is.data.frame(meta.data)) stop("meta.data must be a data.frame", call. = FALSE)
  if (length(stat.by) < 2L) stop("plot_type 'sankey' requires at least two stat.by columns", call. = FALSE)
  if (!all(stat.by %in% colnames(meta.data))) {
    stop("stat.by not found in meta.data: ",
         paste(setdiff(stat.by, colnames(meta.data)), collapse = ", "), call. = FALSE)
  }
  if (is.null(group.by)) {
    group.by <- "All.groups"
    meta.data[[group.by]] <- factor("")
  }
  if (is.null(split.by)) {
    split.by <- "All.groups"
    meta.data[[split.by]] <- factor("")
  }

  for (i in unique(c(group.by, split.by, bg.by))) {
    if (!i %in% colnames(meta.data)) {
      stop(paste0(i, " is not in the meta.data."))
    }
    if (!is.factor(meta.data[[i]])) {
      meta.data[[i]] <- factor(meta.data[[i]], levels = unique(meta.data[[i]]))
    }
  }
  for (i in unique(stat.by)) {
    if (!i %in% colnames(meta.data)) {
      stop(paste0(i, " is not in the meta.data."))
    }
    if (!is.factor(meta.data[[i]])) {
      meta.data[[i]] <- factor(meta.data[[i]], levels = unique(meta.data[[i]]))
    }
  }
  if (!is.null(stat_levels)) {
    if (is.null(names(stat_levels))) stop("stat_levels must be a named list", call. = FALSE)
    if (!setequal(names(stat_levels), stat.by)) {
      stop("stat_levels names must be exactly: ", paste(stat.by, collapse = ", "), call. = FALSE)
    }
    for (i in stat.by) {
      lv <- as.character(stat_levels[[i]])
      if (anyNA(lv) || anyDuplicated(lv)) stop("stat_levels for ", i, " must be unique and non-NA", call. = FALSE)
      observed <- unique(as.character(meta.data[[i]]))
      if (length(setdiff(observed, lv))) {
        stop("stat_levels for ", i, " missing categories: ",
             paste(setdiff(observed, lv), collapse = ", "), call. = FALSE)
      }
      if (length(setdiff(lv, observed))) {
        stop("stat_levels for ", i, " contains categories absent from the data: ",
             paste(setdiff(lv, observed), collapse = ", "), call. = FALSE)
      }
      meta.data[[i]] <- factor(as.character(meta.data[[i]]), levels = lv)
    }
  }

  if (any(group.by != "All.groups")) {
    warning("group.by is not used when plot sankey, chord, venn or upset", immediate. = TRUE)
  }
  if (stat_type == "percent") {
    warning("stat_type is forcibly set to 'count' when plot sankey, chord, venn or upset", immediate. = TRUE)
    stat_type <- "count"
  }
  dat_all <- meta.data[, unique(c(stat.by, group.by, split.by, bg.by)), drop = FALSE]
  nlev <- sapply(dat_all, nlevels)
  nlev <- nlev[nlev > 100]
  if (length(nlev) > 0 && !isTRUE(force)) {
    stop(paste(names(nlev), collapse = ","), " have more than 100 levels; pass force = TRUE to continue. ",
         "The interactive upstream prompt is not used in the template.", call. = FALSE)
  }
  dat_split <- split.data.frame(dat_all, dat_all[[split.by]])
  if (length(dat_split) > 1L) {
    stop("This native sankey core supports only the default single split (split.by = NULL); ",
         "the multi-split combination loop is not implemented.", call. = FALSE)
  }

  list(
    dat_all = dat_all,
    dat_use = dat_split[[1]],
    stat.by = stat.by,
    group.by = group.by,
    split.by = split.by,
    stat_type = stat_type
  )
}

# Table half of the sankey branch (lines 5072-5103).
# Returns the upstream intermediates: colors, per-dimension legend levels,
# dat_use after the NA -> "NA" recode, the make_long() linkage table, and the
# node/flow tables produced by the vendored StatSankeyNode/StatSankeyFlow
# setup_data functions. No plotting.
scp_sankey_table <- function(meta.data, stat.by, group.by = NULL, split.by = NULL, bg.by = NULL,
                             stat_type = c("percent", "count"), stat_levels = NULL,
                             palette = "Paired", palcolor = NULL, NA_color = "grey",
                             force = FALSE, seed = 11, scp = NULL) {
  if (is.null(scp)) scp <- .scp_sankey_default_env()
  palette_scp <- .scp_sankey_fun(scp, "palette_scp")
  make_long <- .scp_sankey_fun(scp, "make_long")
  StatSankeyNode <- .scp_sankey_fun(scp, "StatSankeyNode")
  StatSankeyFlow <- .scp_sankey_fun(scp, "StatSankeyFlow")

  prep <- scp_sankey_prepare(
    meta.data = meta.data, stat.by = stat.by, group.by = group.by,
    split.by = split.by, bg.by = bg.by, stat_type = stat_type,
    stat_levels = stat_levels, force = force, seed = seed
  )
  dat_all <- prep$dat_all
  dat_use <- prep$dat_use
  stat.by <- prep$stat.by

  colors <- palette_scp(c(unique(unlist(lapply(dat_all[, stat.by, drop = FALSE], levels))), NA),
                        palette = palette, palcolor = palcolor, NA_keep = TRUE, NA_color = NA_color)

  legend_levels <- list()
  for (l in stat.by) {
    legend_levels[[l]] <- levels(dat_use[[l]])
    if (any(is.na(dat_use[[l]]))) {
      raw_levels <- levels(dat_use[[l]])
      dat_use[[l]] <- as.character(dat_use[[l]])
      dat_use[[l]][is.na(dat_use[[l]])] <- "NA"
      dat_use[[l]] <- factor(dat_use[[l]], levels = c(raw_levels, "NA"))
    }
  }

  long <- suppressWarnings(make_long(dat_use, dplyr::all_of(stat.by)))

  # Layer data as seen by geom_sankey's two stats (single panel).
  layer <- long
  layer$fill <- layer$node
  layer$PANEL <- 1L
  layer$group <- 1L
  stat_params <- list(space = NULL, width = 0.1, type = "sankey", smooth = 8, na.rm = FALSE)
  nodes <- StatSankeyNode$setup_data(layer, stat_params)
  flows <- StatSankeyFlow$setup_data(layer, stat_params)

  list(
    stat.by = stat.by,
    stat_type = prep$stat_type,
    colors = colors,
    legend_levels = legend_levels,
    dat_use = dat_use,
    long = long,
    nodes = nodes,
    flows = flows
  )
}

# Plot half: upstream sankey construction (lines 5072-5114), with P1-P3.
plot_scp_sankey <- function(tab, alpha = 1,
                            legend.position = "right", legend.direction = "vertical",
                            theme_use = "theme_scp", theme_args = list(),
                            scp = NULL) {
  if (is.null(scp)) scp <- .scp_sankey_default_env()
  theme_scp <- .scp_sankey_fun(scp, "theme_scp")
  get_legend <- .scp_sankey_fun(scp, "get_legend")
  as_grob <- .scp_sankey_fun(scp, "as_grob")
  as_gtable <- .scp_sankey_fun(scp, "as_gtable")
  add_grob <- .scp_sankey_fun(scp, "add_grob")
  geom_sankey <- .scp_sankey_fun(scp, "geom_sankey")

  colors <- tab$colors
  legend_list <- list()
  for (l in tab$stat.by) {
    df <- data.frame(factor(tab$legend_levels[[l]], levels = tab$legend_levels[[l]]))
    colnames(df) <- l
    legend_list[[l]] <- get_legend(ggplot(data = df) +
      geom_col(aes(x = 1, y = 1, fill = .data[[l]]), color = "black") +
      scale_fill_manual(values = colors[tab$legend_levels[[l]]]) +
      guides(fill = guide_legend(
        title.hjust = 0,
        title.vjust = 0,
        order = 1,
        override.aes = list(size = 4, color = "black", alpha = 1)
      )) +
      theme_scp(
        legend.position = "bottom",
        legend.direction = legend.direction
      ))
  }
  if (legend.direction == "vertical") {
    legend <- do.call(cbind, lapply(legend_list, as_gtable))
  } else {
    legend <- do.call(rbind, lapply(legend_list, as_gtable))
  }
  dat <- tab$long
  dat$node <- factor(dat$node, levels = rev(names(colors)))
  p0 <- ggplot(dat, aes(x = x, next_x = next_x, node = node, next_node = next_node, fill = node)) +
    geom_sankey(color = "black", flow.alpha = alpha, show.legend = FALSE, na.rm = FALSE) +
    scale_fill_manual(values = colors, drop = FALSE) +
    scale_x_discrete(expand = c(0, 0.2)) +
    theme_void() +
    theme(axis.text.x = element_text())
  gtable <- as_grob(p0)
  gtable <- add_grob(gtable, legend, legend.position)
  p <- wrap_plots(list(gtable))
  attr(p, "scp_sankey_legend") <- legend
  p
}

# Node/flow counts with their keys. StatSankeyNode/StatSankeyFlow drop the node
# keys from their setup_data output, so this helper recomputes the same counts
# (group_by x/node and x/node/next_x/next_node, dplyr::n()) and keeps the keys
# for QA tables. The values are checked against tab$nodes$freq and
# tab$flows$flow_freq in the build evidence.
scp_sankey_counts <- function(long) {
  if (!all(c("x", "node", "next_x", "next_node") %in% names(long))) {
    stop("long must contain x, node, next_x, next_node", call. = FALSE)
  }
  node_counts <- long %>%
    dplyr::group_by(.data$x, .data$node) %>%
    dplyr::summarise(freq = dplyr::n(), .groups = "drop") %>%
    dplyr::mutate(x = as.numeric(.data$x), node = as.character(.data$node), freq = as.integer(.data$freq)) %>%
    dplyr::select(x, node, freq) %>%
    as.data.frame()
  flow_counts <- long %>%
    dplyr::filter(!is.na(.data$next_node)) %>%
    dplyr::group_by(.data$x, .data$node, .data$next_x, .data$next_node) %>%
    dplyr::summarise(flow_freq = dplyr::n(), .groups = "drop") %>%
    dplyr::mutate(
      x = as.numeric(.data$x), node = as.character(.data$node),
      next_x = as.numeric(.data$next_x), next_node = as.character(.data$next_node),
      flow_freq = as.integer(.data$flow_freq)
    ) %>%
    dplyr::select(x, node, next_x, next_node, flow_freq) %>%
    as.data.frame()
  list(nodes = node_counts, flows = flow_counts)
}

# End-to-end native entry for the upstream call
# CellStatPlot(pancreas_sub, stat.by = c("CellType", "Phase"), plot_type = "sankey").
scp_sankey_meta <- function(meta.data, stat.by, group.by = NULL, split.by = NULL, bg.by = NULL,
                            stat_type = c("percent", "count"), stat_levels = NULL,
                            palette = "Paired", palcolor = NULL, alpha = 1, NA_color = "grey",
                            legend.position = "right", legend.direction = "vertical",
                            theme_use = "theme_scp", theme_args = list(),
                            force = FALSE, seed = 11, scp = NULL) {
  tab <- scp_sankey_table(
    meta.data = meta.data, stat.by = stat.by, group.by = group.by,
    split.by = split.by, bg.by = bg.by, stat_type = stat_type,
    stat_levels = stat_levels, palette = palette, palcolor = palcolor,
    NA_color = NA_color, force = force, seed = seed, scp = scp
  )
  plot_scp_sankey(
    tab, alpha = alpha,
    legend.position = legend.position, legend.direction = legend.direction,
    theme_use = theme_use, theme_args = theme_args, scp = scp
  )
}

# Interface entry: render-cell-linkage long table -> wide cell x dimension
# table -> native sankey. The long table is validated, pivoted in explicit
# dimension order, and category levels are fixed before plotting.
scp_sankey_linkage_wide <- function(df, cell_col = "cell", dimension_col = "dimension",
                                    category_col = "category", dimension_order_col = "dimension_order",
                                    dimension_levels = NULL) {
  if (!is.data.frame(df)) stop("linkage must be a data.frame", call. = FALSE)
  req <- c(cell_col, dimension_col, category_col, dimension_order_col)
  if (!all(req %in% names(df))) {
    stop("missing columns: ", paste(setdiff(req, names(df)), collapse = ", "), call. = FALSE)
  }
  d <- data.frame(
    cell = as.character(df[[cell_col]]),
    dimension = as.character(df[[dimension_col]]),
    category = as.character(df[[category_col]]),
    order = suppressWarnings(as.numeric(df[[dimension_order_col]])),
    stringsAsFactors = FALSE
  )
  if (anyNA(d$cell) || anyNA(d$dimension) || anyNA(d$category) || anyNA(d$order)) {
    stop("cell, dimension, category and dimension_order cannot contain NA", call. = FALSE)
  }
  if (any(!is.finite(d$order)) || any(d$order != floor(d$order))) {
    stop("dimension_order must be whole numbers", call. = FALSE)
  }
  if (anyDuplicated(paste(d$cell, d$dimension, sep = "\r"))) {
    stop("duplicate cell x dimension rows; each cell must have exactly one category per dimension", call. = FALSE)
  }
  order_map <- unique(d[, c("dimension", "order")])
  if (anyDuplicated(order_map$dimension) || anyDuplicated(order_map$order)) {
    stop("each dimension must map to exactly one distinct dimension_order", call. = FALSE)
  }
  dimensions <- order_map$dimension[order(order_map$order)]
  if (!identical(sort(unique(d$order)), as.numeric(seq_along(dimensions)))) {
    stop("dimension_order must be contiguous starting at 1", call. = FALSE)
  }
  n_cells <- length(unique(d$cell))
  if (nrow(d) != n_cells * length(dimensions)) {
    stop("linkage must contain every cell x dimension combination exactly once (",
         n_cells, " cells x ", length(dimensions), " dimensions)", call. = FALSE)
  }
  cells <- unique(d$cell)
  if (is.null(dimension_levels)) {
    dimension_levels <- lapply(dimensions, function(k) unique(d$category[d$dimension == k]))
    names(dimension_levels) <- dimensions
  } else {
    if (is.null(names(dimension_levels))) stop("dimension_levels must be a named list", call. = FALSE)
    if (!setequal(names(dimension_levels), dimensions)) {
      stop("dimension_levels names must be exactly: ", paste(dimensions, collapse = ", "), call. = FALSE)
    }
    for (k in dimensions) {
      lv <- as.character(dimension_levels[[k]])
      observed <- unique(d$category[d$dimension == k])
      if (anyNA(lv) || anyDuplicated(lv)) stop("dimension_levels for ", k, " must be unique and non-NA", call. = FALSE)
      if (length(setdiff(observed, lv))) {
        stop("dimension_levels for ", k, " missing categories: ",
             paste(setdiff(observed, lv), collapse = ", "), call. = FALSE)
      }
      if (length(setdiff(lv, observed))) {
        stop("dimension_levels for ", k, " contains categories absent from the data: ",
             paste(setdiff(lv, observed), collapse = ", "), call. = FALSE)
      }
    }
  }
  wide <- data.frame(cell = cells, stringsAsFactors = FALSE)
  for (k in dimensions) {
    sub <- d[d$dimension == k, , drop = FALSE]
    idx <- match(cells, sub$cell)
    if (anyNA(idx)) stop("dimension ", k, " is missing cells: ",
                         paste(head(cells[is.na(idx)], 5), collapse = ", "), call. = FALSE)
    wide[[k]] <- factor(sub$category[idx], levels = dimension_levels[[k]])
  }
  list(wide = wide, dimensions = dimensions, levels = dimension_levels)
}

scp_sankey_linkage_plot <- function(df, cell_col = "cell", dimension_col = "dimension",
                                    category_col = "category", dimension_order_col = "dimension_order",
                                    dimension_levels = NULL, ...) {
  wide <- scp_sankey_linkage_wide(
    df, cell_col = cell_col, dimension_col = dimension_col,
    category_col = category_col, dimension_order_col = dimension_order_col,
    dimension_levels = dimension_levels
  )
  scp_sankey_meta(
    meta.data = wide$wide, stat.by = wide$dimensions,
    stat_levels = wide$levels, ...
  )
}
