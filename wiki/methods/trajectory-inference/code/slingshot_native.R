# Minimal runtime module extracted verbatim from SCP-local 0.5.6 (GPL (>= 3)).
# Source: https://github.com/zhanghao-njmu/SCP commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
# Roots: RunSlingshot
# Functions: prepare_params, make_long, geom_sankey, RunSlingshot, theme_scp, palette_scp, blendcolors, RGBA2RGB, Blend2Color, BlendRGBList, CellDimPlot, CellDimPlot3D, CellStatPlot, StatPlot, LineagePlot, PAGAPlot, GraphPlot, segementsDf, VelocityPlot, compute_velocity_on_grid, build_patchwork, patchworkGrob, as_grob, as_gtable, get_legend, add_grob, DefaultReduction, check_R, col2hex, as_matrix, capitalize
# Function bodies are copied from the pinned source without algorithm changes.
# Automatic installation is disabled by the caller. Local resources are loaded only by the caller.

# ---- ggsankey.R:8-34 : prepare_params ----
prepare_params <- function(...) {
  # Prepare aesthics for flow lines
  flow.aes <- list(...)
  removes <- names(flow.aes) %>%
    stringr::str_extract_all(., "(?<=flow.).*") %>%
    unlist()
  removes2 <- names(flow.aes) %>%
    stringr::str_subset(., "node") %>%
    unlist()
  flow.aes[c(removes, removes2)] <- NULL
  names(flow.aes) <- names(flow.aes) %>%
    stringr::str_replace_all("flow.", "")

  # Prepare aesthics for node boxes
  node.aes <- list(...)
  removes <- names(node.aes) %>%
    stringr::str_extract_all(., "(?<=node.).*") %>%
    unlist()
  removes2 <- names(node.aes) %>%
    stringr::str_subset(., "flow") %>%
    unlist()
  node.aes[c(removes, removes2)] <- NULL
  names(node.aes) <- names(node.aes) %>%
    stringr::str_replace_all(., "node.", "")

  return(list(flow.aes, node.aes))
}

# ---- ggsankey.R:70-108 : make_long ----
make_long <- function(.df, ..., value = NULL) {
  if ("..r" %in% names(.df)) stop("The column name '..r' is not allowed")
  .vars <- dplyr::quos(...)

  if (!missing(value)) {
    value_var <- dplyr::enquo(value)
    out <- .df %>%
      dplyr::select(!!!.vars, value = !!value_var) %>%
      dplyr::mutate(..r = dplyr::row_number()) %>%
      tidyr::gather(x, node, -..r, -value) %>%
      dplyr::arrange(.data$..r) %>%
      dplyr::group_by(.data$..r) %>%
      dplyr::mutate(
        next_x = dplyr::lead(.data$x),
        next_node = dplyr::lead(.data$node)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(-..r) %>%
      dplyr::relocate(value, .after = dplyr::last_col())
  } else {
    out <- .df %>%
      dplyr::select(!!!.vars) %>%
      dplyr::mutate(..r = dplyr::row_number()) %>%
      tidyr::gather(x, node, -..r) %>%
      dplyr::arrange(.data$..r) %>%
      dplyr::group_by(.data$..r) %>%
      dplyr::mutate(
        next_x = dplyr::lead(.data$x),
        next_node = dplyr::lead(.data$node)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(-..r)
  }

  levels <- unique(out$x)

  out %>%
    dplyr::mutate(dplyr::across(c(x, next_x), ~ factor(., levels = levels)))
}

# ---- ggsankey.R:691-744 : geom_sankey ----
geom_sankey <- function(mapping = NULL,
                        data = NULL,
                        position = "identity",
                        na.rm = FALSE,
                        show.legend = NA,
                        space = NULL,
                        type = "sankey",
                        width = .1,
                        smooth = 8,
                        inherit.aes = TRUE,
                        ...) {
  params_list <- prepare_params(...)

  list(
    flow = ggplot2::layer(
      stat = StatSankeyFlow,
      data = data,
      mapping = mapping,
      geom = "polygon",
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = purrr::flatten(
        list(
          na.rm = na.rm,
          width = width,
          space = space,
          smooth = smooth,
          type = type,
          params_list[[1]]
        )
      )
    ),
    node = ggplot2::layer(
      stat = StatSankeyNode,
      data = data,
      mapping = mapping,
      geom = ggplot2::GeomRect,
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = purrr::flatten(
        list(
          na.rm = na.rm,
          width = width,
          space = space,
          smooth = smooth,
          type = type,
          params_list[[2]]
        )
      )
    )
  )
}

# ---- SCP-analysis.R:4307-4361 : RunSlingshot ----
RunSlingshot <- function(srt, group.by, reduction = NULL, dims = NULL, start = NULL, end = NULL, prefix = NULL,
                         reverse = FALSE, align_start = FALSE, show_plot = TRUE, lineage_palette = "Dark2", seed = 11, ...) {
  if (missing(group.by)) {
    stop("group.by is missing")
  }
  if (is.null(reduction)) {
    reduction <- DefaultReduction(srt)
  } else {
    reduction <- DefaultReduction(srt, pattern = reduction)
  }
  if (is.null(prefix)) {
    prefix <- ""
  } else {
    prefix <- paste0(prefix, "_")
  }
  srt_sub <- srt[, !is.na(srt[[group.by, drop = TRUE]])]
  if (is.null(dims)) {
    dims <- 1:2
  }

  set.seed(seed)
  sl <- slingshot(
    data = as.data.frame(srt_sub[[reduction]]@cell.embeddings[, dims]),
    clusterLabels = as.character(srt_sub[[group.by, drop = TRUE]]),
    start.clus = start, end.clus = end, ...
  )

  srt@tools[[paste("Slingshot", group.by, reduction, sep = "_")]] <- sl
  df <- as.data.frame(slingPseudotime(sl))
  colnames(df) <- paste0(prefix, colnames(df))
  if (isTRUE(reverse)) {
    if (isTRUE(align_start)) {
      df <- apply(df, 2, function(x) max(x, na.rm = TRUE) - x)
    } else {
      df <- max(df, na.rm = TRUE) - df
    }
  }
  srt <- AddMetaData(srt, metadata = df)
  srt <- AddMetaData(srt, metadata = slingBranchID(sl), col.name = paste0(prefix, "BranchID"))

  if (isTRUE(show_plot)) {
    if (ncol(srt[[reduction]]@cell.embeddings) == 2 || ncol(srt[[reduction]]@cell.embeddings) > 3) {
      # plot(srt[[reduction]]@cell.embeddings, col = palette_scp(srt[[group.by, drop = TRUE]], matched = TRUE), asp = 1, pch = 16)
      # lines(slingshot::SlingshotDataSet(sl), lwd = 2, type = "lineages", col = "black")
      # plot(srt[[reduction]]@cell.embeddings, col = palette_scp(srt[[group.by, drop = TRUE]], matched = TRUE), asp = 1, pch = 16)
      # lines(slingshot::SlingshotDataSet(sl), lwd = 3, col = 1:length(slingshot::SlingshotDataSet(sl)@lineages))
      p <- CellDimPlot(srt, group.by = group.by, reduction = reduction, dims = c(1, 2), lineages = colnames(df))
      print(p)
    } else if (ncol(srt[[reduction]]@cell.embeddings) == 3) {
      p <- CellDimPlot3D(srt, group.by = group.by, reduction = reduction, lineages = colnames(df))
      print(p)
    }
  }
  return(srt)
}

# ---- SCP-plot.R:16-60 : theme_scp ----
theme_scp <- function(aspect.ratio = NULL, base_size = 12, ...) {
  text_size_scale <- base_size / 12
  args1 <- list(
    aspect.ratio = aspect.ratio,
    text = element_text(size = 12 * text_size_scale, color = "black"),
    plot.title = element_text(size = 14 * text_size_scale, colour = "black", vjust = 1),
    plot.subtitle = element_text(size = 13 * text_size_scale, hjust = 0, margin = margin(b = 3)),
    plot.background = element_rect(fill = "white", color = "white"),
    axis.line = element_blank(),
    axis.title = element_text(size = 13 * text_size_scale, colour = "black"),
    axis.text = element_text(size = 12 * text_size_scale, colour = "black"),
    strip.text = element_text(size = 12.5 * text_size_scale, colour = "black", hjust = 0.5, margin = margin(3, 3, 3, 3)),
    strip.background = element_rect(fill = "transparent", linetype = 0),
    strip.switch.pad.grid = unit(-1, "pt"),
    strip.switch.pad.wrap = unit(-1, "pt"),
    strip.placement = "outside",
    legend.title = element_text(size = 12 * text_size_scale, colour = "black", hjust = 0),
    legend.text = element_text(size = 11 * text_size_scale, colour = "black"),
    legend.key = element_rect(fill = "transparent", color = "transparent"),
    legend.key.size = unit(10, "pt"),
    legend.background = element_blank(),
    panel.background = element_rect(fill = "white", color = "white"),
    panel.border = element_rect(fill = "transparent", colour = "black", linewidth = 1)
  )
  args2 <- as.list(match.call())[-1]
  call.envir <- parent.frame(1)
  args2 <- lapply(args2, function(arg) {
    if (is.symbol(arg)) {
      eval(arg, envir = call.envir)
    } else if (is.call(arg)) {
      eval(arg, envir = call.envir)
    } else {
      arg
    }
  })
  for (n in names(args2)) {
    args1[[n]] <- args2[[n]]
  }
  args <- args1[names(args1) %in% formalArgs(theme)]
  out <- do.call(
    what = theme,
    args = args
  )
  return(out)
}

# ---- SCP-plot.R:168-271 : palette_scp ----
palette_scp <- function(x, n = 100, palette = "Paired", palcolor = NULL, type = "auto",
                        matched = FALSE, reverse = FALSE, NA_keep = FALSE, NA_color = "grey80") {
  palette_list <- palette_list
  if (missing(x)) {
    x <- 1:n
    type <- "continuous"
  }
  if (!palette %in% names(palette_list)) {
    stop("The palette name (", palette, ") is invalid! You can check the available palette names with 'show_palettes()'. Or pass palette colors via the 'palcolor' parameter.")
  }
  if (is.list(palcolor)) {
    palcolor <- unlist(palcolor)
  }
  if (all(palcolor == "")) {
    palcolor <- palette_list[[palette]]
  }
  if (is.null(palcolor) || length(palcolor) == 0) {
    palcolor <- palette_list[[palette]]
  }
  if (!is.null(names(palcolor))) {
    if (all(x %in% names(palcolor))) {
      palcolor <- palcolor[intersect(names(palcolor), x)]
    }
  }
  pal_n <- length(palcolor)

  if (!type %in% c("auto", "discrete", "continuous")) {
    stop("'type' must be one of 'auto','discrete' and 'continuous'.")
  }
  if (type == "auto") {
    if (is.numeric(x)) {
      type <- "continuous"
    } else {
      type <- "discrete"
    }
  }

  if (type == "discrete") {
    if (!is.factor(x)) {
      x <- factor(x, levels = unique(x))
    }
    n_x <- nlevels(x)
    if (isTRUE(attr(palcolor, "type") == "continuous")) {
      color <- colorRampPalette(palcolor)(n_x)
    } else {
      color <- ifelse(rep(n_x, n_x) <= pal_n,
        palcolor[1:n_x],
        colorRampPalette(palcolor)(n_x)
      )
    }
    names(color) <- levels(x)
    if (any(is.na(x))) {
      color <- c(color, setNames(NA_color, "NA"))
    }
    if (isTRUE(matched)) {
      color <- color[x]
      color[is.na(color)] <- NA_color
    }
  } else if (type == "continuous") {
    if (!is.numeric(x) && all(!is.na(x))) {
      stop("'x' must be type of numeric when use continuous color palettes.")
    }
    if (all(is.na(x))) {
      values <- as.factor(rep(0, n))
    } else if (length(unique(na.omit(as.numeric(x)))) == 1) {
      values <- as.factor(rep(unique(na.omit(as.numeric(x))), n))
    } else {
      if (isTRUE(matched)) {
        values <- cut(x, breaks = seq(min(x, na.rm = TRUE), max(x, na.rm = TRUE), length.out = n + 1), include.lowest = TRUE)
      } else {
        values <- cut(1:100, breaks = seq(min(x, na.rm = TRUE), max(x, na.rm = TRUE), length.out = n + 1), include.lowest = TRUE)
      }
    }

    n_x <- nlevels(values)
    color <- ifelse(rep(n_x, n_x) <= pal_n,
      palcolor[1:n_x],
      colorRampPalette(palcolor)(n_x)
    )
    names(color) <- levels(values)
    if (any(is.na(x))) {
      color <- c(color, setNames(NA_color, "NA"))
    }
    if (isTRUE(matched)) {
      if (all(is.na(x))) {
        color <- NA_color
      } else if (length(unique(na.omit(x))) == 1) {
        color <- color[as.character(unique(na.omit(x)))]
        color[is.na(color)] <- NA_color
      } else {
        color <- color[as.character(values)]
        color[is.na(color)] <- NA_color
      }
    }
  }

  if (isTRUE(reverse)) {
    color <- rev(color)
  }
  if (!isTRUE(NA_keep)) {
    color <- color[names(color) != "NA"]
  }
  return(color)
}

# ---- SCP-plot.R:1026-1042 : blendcolors ----
blendcolors <- function(colors, mode = c("blend", "average", "screen", "multiply")) {
  mode <- match.arg(mode)
  colors <- colors[!is.na(colors)]
  if (length(colors) == 0) {
    return(NA)
  }
  if (length(colors) == 1) {
    return(colors)
  }
  rgb <- as.list(as.data.frame(col2rgb(colors) / 255))
  Clist <- lapply(rgb, function(x) {
    list(x, 1)
  })
  blend_color <- BlendRGBList(Clist, mode = mode)
  blend_color <- rgb(blend_color[1], blend_color[2], blend_color[3])
  return(blend_color)
}

# ---- SCP-plot.R:1044-1048 : RGBA2RGB ----
RGBA2RGB <- function(RGBA, BackGround = c(1, 1, 1)) {
  A <- RGBA[[length(RGBA)]]
  RGB <- RGBA[[-length(RGBA)]] * A + BackGround * (1 - A)
  return(RGB)
}

# ---- SCP-plot.R:1050-1074 : Blend2Color ----
Blend2Color <- function(C1, C2, mode = "blend") {
  c1 <- C1[[1]]
  c1a <- C1[[2]]
  c2 <- C2[[1]]
  c2a <- C2[[2]]
  A <- 1 - (1 - c1a) * (1 - c2a)
  if (A < 1.0e-6) {
    return(list(c(0, 0, 0), 1))
  }
  if (mode == "blend") {
    out <- (c1 * c1a + c2 * c2a * (1 - c1a)) / A
    A <- 1
  }
  if (mode == "average") {
    out <- (c1 + c2) / 2
    out[out > 1] <- 1
  }
  if (mode == "screen") {
    out <- 1 - (1 - c1) * (1 - c2)
  }
  if (mode == "multiply") {
    out <- c1 * c2
  }
  return(list(out, A))
}

# ---- SCP-plot.R:1076-1094 : BlendRGBList ----
BlendRGBList <- function(Clist, mode = "blend", RGB_BackGround = c(1, 1, 1)) {
  N <- length(Clist)
  ClistUse <- Clist
  while (N != 1) {
    temp <- ClistUse
    ClistUse <- list()
    for (C in temp[1:(length(temp) - 1)]) {
      c1 <- C[[1]]
      a1 <- C[[2]]
      c2 <- temp[[length(temp)]][[1]]
      a2 <- temp[[length(temp)]][[2]]
      ClistUse <- append(ClistUse, list(Blend2Color(C1 = list(c1, a1 * (1 - 1 / N)), C2 = list(c2, a2 * 1 / N), mode = mode)))
    }
    N <- length(ClistUse)
  }
  Result <- list(ClistUse[[1]][[1]], ClistUse[[1]][[2]])
  Result <- RGBA2RGB(Result, BackGround = RGB_BackGround)
  return(Result)
}

# ---- SCP-plot.R:1328-1851 : CellDimPlot ----
CellDimPlot <- function(srt, group.by, reduction = NULL, dims = c(1, 2), split.by = NULL, cells = NULL,
                        show_na = FALSE, show_stat = ifelse(identical(theme_use, "theme_blank"), FALSE, TRUE),
                        pt.size = NULL, pt.alpha = 1, palette = "Paired", palcolor = NULL, bg_color = "grey80",
                        label = FALSE, label.size = 4, label.fg = "white", label.bg = "black", label.bg.r = 0.1,
                        label_insitu = FALSE, label_repel = FALSE, label_repulsion = 20,
                        label_point_size = 1, label_point_color = "black", label_segment_color = "black",
                        cells.highlight = NULL, cols.highlight = "black", sizes.highlight = 1, alpha.highlight = 1, stroke.highlight = 0.5,
                        add_density = FALSE, density_color = "grey80", density_filled = FALSE, density_filled_palette = "Greys", density_filled_palcolor = NULL,
                        add_mark = FALSE, mark_type = c("hull", "ellipse", "rect", "circle"), mark_expand = unit(3, "mm"), mark_alpha = 0.1, mark_linetype = 1,
                        lineages = NULL, lineages_trim = c(0.01, 0.99), lineages_span = 0.75,
                        lineages_palette = "Dark2", lineages_palcolor = NULL, lineages_arrow = arrow(length = unit(0.1, "inches")),
                        lineages_linewidth = 1, lineages_line_bg = "white", lineages_line_bg_stroke = 0.5,
                        lineages_whiskers = FALSE, lineages_whiskers_linewidth = 0.5, lineages_whiskers_alpha = 0.5,
                        stat.by = NULL, stat_type = "percent", stat_plot_type = "pie", stat_plot_position = c("stack", "dodge"), stat_plot_size = 0.15,
                        stat_plot_palette = "Set1", stat_palcolor = NULL, stat_plot_alpha = 1, stat_plot_label = FALSE, stat_plot_label_size = 3,
                        graph = NULL, edge_size = c(0.05, 0.5), edge_alpha = 0.1, edge_color = "grey40",
                        paga = NULL, paga_type = "connectivities", paga_node_size = 4,
                        paga_edge_threshold = 0.01, paga_edge_size = c(0.2, 1), paga_edge_color = "grey40", paga_edge_alpha = 0.5,
                        paga_transition_threshold = 0.01, paga_transition_size = c(0.2, 1), paga_transition_color = "black", paga_transition_alpha = 1, paga_show_transition = FALSE,
                        velocity = NULL, velocity_plot_type = "raw", velocity_n_neighbors = ceiling(ncol(srt@assays[[1]]) / 50),
                        velocity_density = 1, velocity_smooth = 0.5, velocity_scale = 1, velocity_min_mass = 1, velocity_cutoff_perc = 5,
                        velocity_arrow_color = "black", velocity_arrow_angle = 20,
                        streamline_L = 5, streamline_minL = 1, streamline_res = 1, streamline_n = 15,
                        streamline_width = c(0, 0.8), streamline_alpha = 1, streamline_color = NULL, streamline_palette = "RdYlBu", streamline_palcolor = NULL,
                        streamline_bg_color = "white", streamline_bg_stroke = 0.5,
                        hex = FALSE, hex.linewidth = 0.5, hex.count = TRUE, hex.bins = 50, hex.binwidth = NULL,
                        raster = NULL, raster.dpi = c(512, 512),
                        aspect.ratio = 1, title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                        legend.position = "right", legend.direction = "vertical",
                        theme_use = "theme_scp", theme_args = list(),
                        combine = TRUE, nrow = NULL, ncol = NULL, byrow = TRUE, force = FALSE, seed = 11) {
  set.seed(seed)
  mark_type <- match.arg(mark_type)

  if (is.null(split.by)) {
    split.by <- "All.groups"
    srt@meta.data[[split.by]] <- factor("")
  }
  for (i in unique(c(group.by, split.by))) {
    if (!i %in% colnames(srt@meta.data)) {
      stop(paste0(i, " is not in the meta.data of srt object."))
    }
    if (!is.factor(srt@meta.data[[i]])) {
      srt@meta.data[[i]] <- factor(srt@meta.data[[i]], levels = unique(srt@meta.data[[i]]))
    }
    if (isTRUE(show_na) && any(is.na(srt@meta.data[[i]]))) {
      raw_levels <- unique(c(levels(srt@meta.data[[i]]), "NA"))
      srt@meta.data[[i]] <- as.character(srt@meta.data[[i]])
      srt@meta.data[[i]][is.na(srt@meta.data[[i]])] <- "NA"
      srt@meta.data[[i]] <- factor(srt@meta.data[[i]], levels = raw_levels)
    }
  }
  for (l in lineages) {
    if (!l %in% colnames(srt@meta.data)) {
      stop(paste0(l, " is not in the meta.data of srt object."))
    }
  }
  if (!is.null(graph) && !graph %in% names(srt@graphs)) {
    stop("Graph ", graph, " is not exist in the srt object.")
  }
  if (!is.null(graph)) {
    graph <- srt@graphs[[graph]]
  }
  if (is.null(reduction)) {
    reduction <- DefaultReduction(srt)
  } else {
    reduction <- DefaultReduction(srt, pattern = reduction)
  }
  if (!reduction %in% names(srt@reductions)) {
    stop(paste0(reduction, " is not in the srt reduction names."))
  }
  if (!is.null(cells.highlight) && !isTRUE(cells.highlight)) {
    if (!any(cells.highlight %in% colnames(srt@assays[[1]]))) {
      stop("No cells in 'cells.highlight' found in srt.")
    }
    if (!all(cells.highlight %in% colnames(srt@assays[[1]]))) {
      warning("Some cells in 'cells.highlight' not found in srt.", immediate. = TRUE)
    }
    cells.highlight <- intersect(cells.highlight, colnames(srt@assays[[1]]))
  }

  dat_meta <- srt@meta.data[, unique(c(group.by, split.by)), drop = FALSE]
  nlev <- sapply(dat_meta, nlevels)
  nlev <- nlev[nlev > 100]
  if (length(nlev) > 0 && !isTRUE(force)) {
    warning(paste(names(nlev), sep = ","), " have more than 100 levels.", immediate. = TRUE)
    answer <- askYesNo("Are you sure to continue?", default = FALSE)
    if (!isTRUE(answer)) {
      return(invisible(NULL))
    }
  }

  reduction_key <- srt@reductions[[reduction]]@key
  dat_dim <- srt@reductions[[reduction]]@cell.embeddings
  colnames(dat_dim) <- paste0(reduction_key, seq_len(ncol(dat_dim)))
  rownames(dat_dim) <- rownames(dat_dim) %||% colnames(srt@assays[[1]])
  dat_use <- cbind(dat_dim, dat_meta[row.names(dat_dim), , drop = FALSE])
  if (!is.null(cells)) {
    dat_use <- dat_use[intersect(rownames(dat_use), cells), , drop = FALSE]
  }
  if (is.null(pt.size)) {
    pt.size <- min(3000 / nrow(dat_use), 0.5)
  }
  raster <- raster %||% (nrow(dat_use) > 1e5)
  if (isTRUE(raster)) {
    check_R("exaexa/scattermore")
  }
  if (!is.null(x = raster.dpi)) {
    if (!is.numeric(x = raster.dpi) || length(x = raster.dpi) != 2) {
      stop("'raster.dpi' must be a two-length numeric vector")
    }
  }
  if (!is.null(stat.by)) {
    subplots <- CellStatPlot(srt,
      cells = cells,
      stat.by = stat.by, group.by = group.by, split.by = split.by,
      stat_type = stat_type, plot_type = stat_plot_type, position = stat_plot_position,
      palette = stat_plot_palette, palcolor = stat_palcolor, alpha = stat_plot_alpha,
      label = stat_plot_label, label.size = stat_plot_label_size,
      legend.position = "bottom", legend.direction = legend.direction,
      theme_use = theme_use, theme_args = theme_args,
      individual = TRUE, combine = FALSE
    )
  }
  if (!is.null(lineages)) {
    lineages_layers <- LineagePlot(srt,
      cells = cells,
      lineages = lineages, reduction = reduction, dims = dims,
      trim = lineages_trim, span = lineages_span,
      palette = lineages_palette, palcolor = lineages_palcolor, lineages_arrow = lineages_arrow,
      linewidth = lineages_linewidth, line_bg = lineages_line_bg, line_bg_stroke = lineages_line_bg_stroke,
      whiskers = lineages_whiskers, whiskers_linewidth = lineages_whiskers_linewidth, whiskers_alpha = lineages_whiskers_alpha,
      aspect.ratio = aspect.ratio, title = title, subtitle = subtitle, xlab = xlab, ylab = ylab,
      legend.position = "bottom", legend.direction = legend.direction,
      theme_use = theme_use, theme_args = theme_args,
      return_layer = TRUE
    )
    lineages_layers <- lineages_layers[!names(lineages_layers) %in% c("lab_layer", "theme_layer")]
  }
  if (!is.null(paga)) {
    if (split.by != "All.groups") {
      stop("paga can only plot on the non-split data")
    }
    paga_layers <- PAGAPlot(srt,
      cells = cells,
      paga = paga, type = paga_type, reduction = reduction, dims = dims,
      node_palette = palette, node_palcolor = palcolor, node_size = paga_node_size,
      edge_threshold = paga_edge_threshold, edge_size = paga_edge_size, edge_color = paga_edge_color, edge_alpha = paga_edge_alpha,
      transition_threshold = paga_transition_threshold, transition_size = paga_transition_size, transition_color = paga_transition_color, transition_alpha = paga_transition_alpha, show_transition = paga_show_transition,
      aspect.ratio = aspect.ratio, title = title, subtitle = subtitle, xlab = xlab, ylab = ylab,
      legend.position = "bottom", legend.direction = legend.direction,
      theme_use = theme_use, theme_args = theme_args,
      return_layer = TRUE
    )
    paga_layers <- paga_layers[!names(paga_layers) %in% c("lab_layer", "theme_layer")]
  }
  if (!is.null(velocity)) {
    if (split.by != "All.groups") {
      stop("velocity can only plot on the non-split data")
    }
    velocity_layers <- VelocityPlot(srt,
      cells = cells,
      reduction = reduction, dims = dims, velocity = velocity, plot_type = velocity_plot_type, group_by = group.by, group_palette = palette, group_palcolor = palcolor,
      n_neighbors = velocity_n_neighbors, density = velocity_density, smooth = velocity_smooth, scale = velocity_scale, min_mass = velocity_min_mass, cutoff_perc = velocity_cutoff_perc,
      arrow_color = velocity_arrow_color, arrow_angle = velocity_arrow_angle,
      streamline_L = streamline_L, streamline_minL = streamline_minL, streamline_res = streamline_res, streamline_n = streamline_n,
      streamline_width = streamline_width, streamline_alpha = streamline_alpha, streamline_color = streamline_color, streamline_palette = streamline_palette, streamline_palcolor = streamline_palcolor,
      streamline_bg_color = streamline_bg_color, streamline_bg_stroke = streamline_bg_stroke,
      aspect.ratio = aspect.ratio, title = title, subtitle = subtitle, xlab = xlab, ylab = ylab,
      legend.position = "bottom", legend.direction = legend.direction,
      theme_use = theme_void, theme_args = theme_args,
      return_layer = TRUE
    )
    velocity_layers <- velocity_layers[!names(velocity_layers) %in% c("lab_layer", "theme_layer")]
  }
  plist <- list()
  xlab <- xlab %||% paste0(reduction_key, dims[1])
  ylab <- ylab %||% paste0(reduction_key, dims[2])
  if (identical(theme_use, "theme_blank")) {
    theme_args[["xlab"]] <- xlab
    theme_args[["ylab"]] <- ylab
  }

  comb <- expand.grid(split = levels(dat_use[[split.by]]), group = group.by, stringsAsFactors = FALSE)
  rownames(comb) <- paste0(comb[["split"]], ":", comb[["group"]])
  plist <- lapply(setNames(rownames(comb), rownames(comb)), function(i) {
    g <- comb[i, "group"]
    s <- comb[i, "split"]
    colors <- palette_scp(levels(dat_use[[g]]), palette = palette, palcolor = palcolor, NA_keep = TRUE)
    dat <- dat_use
    cells_mask <- dat[[split.by]] != s
    # dat[[split.by]] <- NULL
    dat[[g]][cells_mask] <- NA
    legend_list <- list()
    labels_tb <- table(dat[[g]])
    labels_tb <- labels_tb[labels_tb != 0]
    cells.highlight_use <- cells.highlight
    if (isTRUE(cells.highlight_use)) {
      cells.highlight_use <- rownames(dat)[!is.na(dat[[g]])]
    }
    if (isTRUE(label_insitu)) {
      if (isTRUE(show_stat)) {
        label_use <- paste0(names(labels_tb), "(", labels_tb, ")")
      } else {
        label_use <- paste0(names(labels_tb))
      }
    } else {
      if (isTRUE(label)) {
        if (isTRUE(show_stat)) {
          label_use <- paste0(seq_along(labels_tb), ": ", names(labels_tb), "(", labels_tb, ")")
        } else {
          label_use <- paste0(seq_along(labels_tb), ": ", names(labels_tb))
        }
      } else {
        if (isTRUE(show_stat)) {
          label_use <- paste0(names(labels_tb), "(", labels_tb, ")")
        } else {
          label_use <- paste0(names(labels_tb))
        }
      }
    }
    dat[["x"]] <- dat[[paste0(reduction_key, dims[1])]]
    dat[["y"]] <- dat[[paste0(reduction_key, dims[2])]]
    dat[["group.by"]] <- dat[[g]]
    dat[, "split.by"] <- s
    dat <- dat[order(dat[, "group.by"], decreasing = FALSE, na.last = FALSE), , drop = FALSE]
    naindex <- which(is.na(dat[, "group.by"]))
    naindex <- ifelse(length(naindex) > 0, max(naindex), 1)
    dat <- dat[c(1:naindex, sample((min(naindex + 1, nrow(dat))):nrow(dat))), , drop = FALSE]
    if (isTRUE(show_stat)) {
      subtitle_use <- subtitle %||% paste0(s, " nCells:", sum(!is.na(dat[["group.by"]])))
    } else {
      subtitle_use <- subtitle
    }

    if (isTRUE(add_mark)) {
      mark_fun <- switch(mark_type,
        "ellipse" = "geom_mark_ellipse",
        "hull" = "geom_mark_hull",
        "rect" = "geom_mark_rect",
        "circle" = "geom_mark_circle"
      )
      mark <- list(
        do.call(
          mark_fun,
          list(
            data = dat[!is.na(dat[["group.by"]]), , drop = FALSE],
            mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["group.by"]], fill = .data[["group.by"]]),
            expand = mark_expand, alpha = mark_alpha, linetype = mark_linetype, show.legend = FALSE, inherit.aes = FALSE
          ),
        ),
        scale_fill_manual(values = colors[names(labels_tb)]),
        scale_color_manual(values = colors[names(labels_tb)]),
        new_scale_fill(),
        new_scale_color()
      )
    } else {
      mark <- NULL
    }

    if (!is.null(graph)) {
      net_mat <- as_matrix(graph)[rownames(dat), rownames(dat)]
      net_mat[net_mat == 0] <- NA
      net_mat[upper.tri(net_mat)] <- NA
      net_df <- reshape2::melt(net_mat, na.rm = TRUE, stringsAsFactors = FALSE)
      net_df[, "value"] <- as.numeric(net_df[, "value"])
      net_df[, "Var1"] <- as.character(net_df[, "Var1"])
      net_df[, "Var2"] <- as.character(net_df[, "Var2"])
      net_df[, "x"] <- dat[net_df[, "Var1"], "x"]
      net_df[, "y"] <- dat[net_df[, "Var1"], "y"]
      net_df[, "xend"] <- dat[net_df[, "Var2"], "x"]
      net_df[, "yend"] <- dat[net_df[, "Var2"], "y"]
      net <- list(
        geom_segment(
          data = net_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = value),
          color = edge_color, alpha = edge_alpha, show.legend = FALSE
        ),
        scale_linewidth_continuous(range = edge_size)
      )
    } else {
      net <- NULL
    }

    if (isTRUE(add_density)) {
      if (isTRUE(density_filled)) {
        filled_color <- palette_scp(palette = density_filled_palette, palcolor = density_filled_palcolor)
        density <- list(
          stat_density_2d(
            geom = "raster", aes(x = .data[["x"]], y = .data[["y"]], fill = after_stat(density)),
            contour = FALSE, inherit.aes = FALSE, show.legend = FALSE
          ),
          scale_fill_gradientn(name = "Density", colours = filled_color),
          new_scale_fill()
        )
      } else {
        density <- geom_density_2d(aes(x = .data[["x"]], y = .data[["y"]]),
          color = density_color, inherit.aes = FALSE, show.legend = FALSE
        )
      }
    } else {
      density <- NULL
    }

    p <- ggplot(dat) +
      mark +
      net +
      density +
      labs(title = title, subtitle = subtitle_use, x = xlab, y = ylab) +
      scale_x_continuous(limits = c(min(dat_dim[, paste0(reduction_key, dims[1])], na.rm = TRUE), max(dat_dim[, paste0(reduction_key, dims[1])], na.rm = TRUE))) +
      scale_y_continuous(limits = c(min(dat_dim[, paste0(reduction_key, dims[2])], na.rm = TRUE), max(dat_dim[, paste0(reduction_key, dims[2])], na.rm = TRUE))) +
      do.call(theme_use, theme_args) +
      theme(
        aspect.ratio = aspect.ratio,
        legend.position = legend.position,
        legend.direction = legend.direction
      )
    if (split.by != "All.groups") {
      p <- p + facet_grid(. ~ split.by)
    }

    if (isTRUE(raster)) {
      p <- p + scattermore::geom_scattermore(
        data = dat[is.na(dat[, "group.by"]), , drop = FALSE],
        mapping = aes(x = .data[["x"]], y = .data[["y"]]), color = bg_color,
        pointsize = ceiling(pt.size), alpha = pt.alpha, pixels = raster.dpi
      ) + scattermore::geom_scattermore(
        data = dat[!is.na(dat[, "group.by"]), , drop = FALSE],
        mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["group.by"]]),
        pointsize = ceiling(pt.size), alpha = pt.alpha, pixels = raster.dpi
      )
    } else if (isTRUE(hex)) {
      check_R("hexbin")
      if (isTRUE(hex.count)) {
        p <- p + geom_hex(
          mapping = aes(x = .data[["x"]], y = .data[["y"]], fill = .data[["group.by"]], color = .data[["group.by"]], alpha = after_stat(count)),
          linewidth = hex.linewidth, bins = hex.bins, binwidth = hex.binwidth
        )
      } else {
        p <- p + geom_hex(
          mapping = aes(x = .data[["x"]], y = .data[["y"]], fill = .data[["group.by"]], color = .data[["group.by"]]),
          linewidth = hex.linewidth, bins = hex.bins, binwidth = hex.binwidth
        )
      }
    } else {
      p <- p + geom_point(
        mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["group.by"]]),
        size = pt.size, alpha = pt.alpha
      )
    }

    if (!is.null(cells.highlight_use) && !isTRUE(hex)) {
      cell_df <- subset(p$data, rownames(p$data) %in% cells.highlight_use)
      if (nrow(cell_df) > 0) {
        if (isTRUE(raster)) {
          p <- p + scattermore::geom_scattermore(
            data = cell_df, aes(x = .data[["x"]], y = .data[["y"]]), color = cols.highlight,
            pointsize = floor(sizes.highlight) + stroke.highlight, alpha = alpha.highlight, pixels = raster.dpi
          ) +
            scattermore::geom_scattermore(
              data = cell_df, aes(x = .data[["x"]], y = .data[["y"]], color = .data[["group.by"]]),
              pointsize = floor(sizes.highlight), alpha = alpha.highlight, pixels = raster.dpi
            )
        } else {
          p <- p + geom_point(
            data = cell_df, aes(x = .data[["x"]], y = .data[["y"]]), color = cols.highlight,
            size = sizes.highlight + stroke.highlight, alpha = alpha.highlight
          ) +
            geom_point(
              data = cell_df, aes(x = .data[["x"]], y = .data[["y"]], color = .data[["group.by"]]),
              size = sizes.highlight, alpha = alpha.highlight
            )
        }
      }
    }
    p <- p + scale_color_manual(
      name = paste0(g, ":"),
      values = colors[names(labels_tb)],
      labels = label_use,
      na.value = bg_color,
      guide = guide_legend(
        title.hjust = 0,
        order = 1,
        override.aes = list(size = 4, alpha = 1)
      )
    ) + scale_fill_manual(
      name = paste0(g, ":"),
      values = colors[names(labels_tb)],
      labels = label_use,
      na.value = bg_color,
      guide = guide_legend(
        title.hjust = 0,
        order = 1
      )
    )
    p_base <- p

    if (!is.null(stat.by)) {
      coor_df <- aggregate(p$data[, c("x", "y")], by = list(p$data[["group.by"]]), FUN = median)
      colnames(coor_df)[1] <- "group"
      x_range <- diff(layer_scales(p)$x$range$range)
      y_range <- diff(layer_scales(p)$y$range$range)
      stat_plot <- subplots[paste0(g, ":", levels(dat[, "group.by"]), ":", s)]
      names(stat_plot) <- levels(dat[, "group.by"])

      stat_plot_list <- list()
      for (i in seq_len(nrow(coor_df))) {
        stat_plot_list[[i]] <- annotation_custom(as_grob(stat_plot[[coor_df[i, "group"]]] + theme_void() + theme(legend.position = "none")),
          xmin = coor_df[i, "x"] - x_range * stat_plot_size / 2, ymin = coor_df[i, "y"] - y_range * stat_plot_size / 2,
          xmax = coor_df[i, "x"] + x_range * stat_plot_size / 2, ymax = coor_df[i, "y"] + y_range * stat_plot_size / 2
        )
      }
      p <- p + stat_plot_list
      legend_list[["stat.by"]] <- get_legend(stat_plot[[coor_df[i, "group"]]] + theme(legend.position = "bottom"))
    }
    if (!is.null(lineages)) {
      lineages_layers <- c(list(new_scale_color()), lineages_layers)
      suppressMessages({
        legend_list[["lineages"]] <- get_legend(ggplot() +
          lineages_layers +
          theme_scp(
            legend.position = "bottom",
            legend.direction = legend.direction
          ))
      })
      p <- suppressWarnings({
        p + lineages_layers + theme(legend.position = "none")
      })
      if (is.null(legend_list[["lineages"]])) {
        legend_list["lineages"] <- list(NULL)
      }
    }
    if (!is.null(paga)) {
      paga_layers <- c(list(new_scale_color()), paga_layers)
      if (g != paga$groups) {
        suppressMessages({
          legend_list[["paga"]] <- get_legend(ggplot() +
            paga_layers +
            theme_scp(
              legend.position = "bottom",
              legend.direction = legend.direction
            ))
        })
      }
      p <- suppressWarnings({
        p + paga_layers + theme(legend.position = "none")
      })
      if (is.null(legend_list[["paga"]])) {
        legend_list["paga"] <- list(NULL)
      }
    }
    if (!is.null(velocity)) {
      velocity_layers <- c(list(new_scale_color()), list(new_scale("size")), velocity_layers)
      if (velocity_plot_type != "raw") {
        suppressMessages({
          legend_list[["velocity"]] <- get_legend(ggplot() +
            velocity_layers +
            theme_scp(
              legend.position = "bottom",
              legend.direction = legend.direction
            ))
        })
      }
      p <- suppressWarnings({
        p + velocity_layers + theme(legend.position = "none")
      })
      if (is.null(legend_list[["velocity"]])) {
        legend_list["velocity"] <- list(NULL)
      }
    }
    if (isTRUE(label)) {
      label_df <- aggregate(p$data[, c("x", "y")], by = list(p$data[["group.by"]]), FUN = median)
      colnames(label_df)[1] <- "label"
      label_df <- label_df[!is.na(label_df[, "label"]), , drop = FALSE]
      if (!isTRUE(label_insitu)) {
        label_df[, "label"] <- seq_len(nrow(label_df))
      }
      if (isTRUE(label_repel)) {
        p <- p + geom_point(
          data = label_df, mapping = aes(x = .data[["x"]], y = .data[["y"]]),
          color = label_point_color, size = label_point_size
        ) + geom_text_repel(
          data = label_df, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]]),
          fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
          point.size = label_point_size, max.overlaps = 100, force = label_repulsion,
          color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE
        )
      } else {
        p <- p + geom_text_repel(
          data = label_df, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]]),
          fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
          point.size = NA, max.overlaps = 100, force = 0,
          color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE
        )
      }
    }
    if (length(legend_list) > 0) {
      legend_list <- legend_list[!sapply(legend_list, is.null)]
      legend_base <- get_legend(p_base + theme_scp(
        legend.position = "bottom",
        legend.direction = legend.direction
      ))
      if (legend.direction == "vertical") {
        legend <- do.call(cbind, c(list(base = legend_base), legend_list))
      } else {
        legend <- do.call(rbind, c(list(base = legend_base), legend_list))
      }
      gtable <- as_grob(p + theme(legend.position = "none"))
      gtable <- add_grob(gtable, legend, legend.position)
      p <- wrap_plots(gtable)
    }
    return(p)
  })

  if (isTRUE(combine)) {
    if (length(plist) > 1) {
      plot <- wrap_plots(plotlist = plist, nrow = nrow, ncol = ncol, byrow = byrow)
    } else {
      plot <- plist[[1]]
    }
    return(plot)
  } else {
    return(plist)
  }
}

# ---- SCP-plot.R:2843-3044 : CellDimPlot3D ----
CellDimPlot3D <- function(srt, group.by, reduction = NULL, dims = c(1, 2, 3), axis_labs = NULL,
                          palette = "Paired", palcolor = NULL, bg_color = "grey80", pt.size = 1.5,
                          cells.highlight = NULL, cols.highlight = "black", shape.highlight = "circle-open", sizes.highlight = 2,
                          lineages = NULL, lineages_palette = "Dark2", span = 0.75,
                          width = NULL, height = NULL, save = NULL, force = FALSE) {
  bg_color <- col2hex(bg_color)
  cols.highlight <- col2hex(cols.highlight)

  for (i in c(group.by)) {
    if (!i %in% colnames(srt@meta.data)) {
      stop(paste0(i, " is not in the meta.data of srt object."))
    }
    if (!is.factor(srt@meta.data[[i]])) {
      srt@meta.data[[i]] <- factor(srt@meta.data[[i]], levels = unique(srt@meta.data[[i]]))
    }
  }
  for (l in lineages) {
    if (!l %in% colnames(srt@meta.data)) {
      stop(paste0(l, " is not in the meta.data of srt object."))
    }
  }
  if (is.null(reduction)) {
    reduction <- DefaultReduction(srt, min_dim = 3)
  } else {
    reduction <- DefaultReduction(srt, pattern = reduction, min_dim = 3)
  }
  if (!reduction %in% names(srt@reductions)) {
    stop(paste0(reduction, " is not in the srt reduction names."))
  }
  if (ncol(srt@reductions[[reduction]]@cell.embeddings) < 3) {
    stop("Reduction must be in three dimensions or higher.")
  }
  if (!is.null(cells.highlight) && !isTRUE(cells.highlight)) {
    if (!any(cells.highlight %in% colnames(srt@assays[[1]]))) {
      stop("No cells in 'cells.highlight' found in srt.")
    }
    if (!all(cells.highlight %in% colnames(srt@assays[[1]]))) {
      warning("Some cells in 'cells.highlight' not found in srt.", immediate. = TRUE)
    }
    cells.highlight <- intersect(cells.highlight, colnames(srt@assays[[1]]))
  }
  reduction_key <- srt@reductions[[reduction]]@key
  if (is.null(axis_labs) || length(axis_labs) != 3) {
    xlab <- paste0(reduction_key, dims[1])
    ylab <- paste0(reduction_key, dims[2])
    zlab <- paste0(reduction_key, dims[3])
  } else {
    xlab <- axis_labs[1]
    ylab <- axis_labs[2]
    zlab <- axis_labs[3]
  }
  if ((!is.null(save) && is.character(save) && nchar(save) > 0)) {
    check_R("htmlwidgets")
    if (!grepl(".html$", save)) {
      stop("'save' must be a string with .html as a suffix.")
    }
  }

  dat_dim <- srt@reductions[[reduction]]@cell.embeddings
  colnames(dat_dim) <- paste0(reduction_key, seq_len(ncol(dat_dim)))
  rownames(dat_dim) <- rownames(dat_dim) %||% colnames(srt@assays[[1]])
  dat_use <- cbind(dat_dim[colnames(srt@assays[[1]]), , drop = FALSE], srt@meta.data[colnames(srt@assays[[1]]), , drop = FALSE])
  nlev <- sapply(dat_use[, group.by, drop = FALSE], nlevels)
  nlev <- nlev[nlev > 100]
  if (length(nlev) > 0 && !isTRUE(force)) {
    warning(paste(names(nlev), sep = ","), " have more than 100 levels.", immediate. = TRUE)
    answer <- askYesNo("Are you sure to continue?", default = FALSE)
    if (!isTRUE(answer)) {
      return(invisible(NULL))
    }
  }
  if (!is.null(lineages)) {
    dat_lineages <- srt@meta.data[, unique(lineages), drop = FALSE]
    dat_use <- cbind(dat_use, dat_lineages[row.names(dat_use), , drop = FALSE])
  }
  dat_use[["group.by"]] <- dat_use[[group.by]]
  if (any(is.na(dat_use[[group.by]]))) {
    n <- as.character(dat_use[[group.by]])
    n[is.na(n)] <- "NA"
    dat_use[[group.by]] <- factor(n, levels = c(levels(dat_use[[group.by]]), "NA"))
  }

  dat_use[["color"]] <- dat_use[[group.by]]
  colors <- palette_scp(dat_use[["group.by"]], palette = palette, palcolor = palcolor, NA_color = bg_color, NA_keep = TRUE)

  dat_use[[paste0(reduction_key, dims[1], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[1])]]
  dat_use[[paste0(reduction_key, dims[2], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[2])]]
  dat_use[[paste0(reduction_key, dims[3], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[3])]]
  cells.highlight_use <- cells.highlight
  if (isTRUE(cells.highlight_use)) {
    cells.highlight_use <- rownames(dat_use)[dat_use[[group.by]] != "NA"]
  }
  if (!is.null(cells.highlight_use)) {
    cells.highlight_use <- cells.highlight_use[cells.highlight_use %in% rownames(dat_use)]
    dat_use_highlight <- dat_use[cells.highlight_use, , drop = FALSE]
  }

  p <- plot_ly(data = dat_use, width = width, height = height)
  p <- add_trace(
    p = p,
    data = dat_use,
    x = dat_use[[paste0(reduction_key, dims[1], "All_cells")]],
    y = dat_use[[paste0(reduction_key, dims[2], "All_cells")]],
    z = dat_use[[paste0(reduction_key, dims[3], "All_cells")]],
    text = paste0(
      "Cell:", rownames(dat_use),
      "\ngroup.by:", dat_use[["group.by"]],
      "\ncolor:", dat_use[["color"]]
    ),
    type = "scatter3d",
    mode = "markers",
    color = dat_use[[group.by]],
    colors = colors,
    marker = list(size = pt.size),
    showlegend = TRUE,
    visible = TRUE
  )
  if (!is.null(cells.highlight_use)) {
    p <- add_trace(
      p = p,
      x = dat_use_highlight[[paste0(reduction_key, dims[1], "All_cells")]],
      y = dat_use_highlight[[paste0(reduction_key, dims[2], "All_cells")]],
      z = dat_use_highlight[[paste0(reduction_key, dims[3], "All_cells")]],
      text = paste0(
        "Cell:", rownames(dat_use_highlight),
        "\ngroup.by:", dat_use_highlight[["group.by"]],
        "\ncolor:", dat_use_highlight[["color"]]
      ),
      type = "scatter3d",
      mode = "markers",
      marker = list(size = sizes.highlight, color = cols.highlight, symbol = shape.highlight),
      name = "highlight",
      showlegend = TRUE,
      visible = TRUE
    )
  }
  if (!is.null(lineages)) {
    for (l in lineages) {
      dat_sub <- dat_use[!is.na(dat_use[[l]]), , drop = FALSE]
      dat_sub <- dat_sub[order(dat_sub[[l]]), , drop = FALSE]

      xlo <- loess(formula(paste(paste0(reduction_key, dims[1], "All_cells"), l, sep = "~")), data = dat_sub, span = span, degree = 2)
      ylo <- loess(formula(paste(paste0(reduction_key, dims[2], "All_cells"), l, sep = "~")), data = dat_sub, span = span, degree = 2)
      zlo <- loess(formula(paste(paste0(reduction_key, dims[3], "All_cells"), l, sep = "~")), data = dat_sub, span = span, degree = 2)
      dat_smooth <- data.frame(x = xlo$fitted, y = ylo$fitted, z = zlo$fitted)
      dat_smooth <- dat_smooth[dat_smooth[["x"]] <= max(dat_use[[paste0(reduction_key, dims[1], "All_cells")]], na.rm = TRUE) & dat_smooth[["x"]] >= min(dat_use[[paste0(reduction_key, dims[1], "All_cells")]], na.rm = TRUE), , drop = FALSE]
      dat_smooth <- dat_smooth[dat_smooth[["y"]] <= max(dat_use[[paste0(reduction_key, dims[2], "All_cells")]], na.rm = TRUE) & dat_smooth[["y"]] >= min(dat_use[[paste0(reduction_key, dims[2], "All_cells")]], na.rm = TRUE), , drop = FALSE]
      dat_smooth <- dat_smooth[dat_smooth[["z"]] <= max(dat_use[[paste0(reduction_key, dims[3], "All_cells")]], na.rm = TRUE) & dat_smooth[["z"]] >= min(dat_use[[paste0(reduction_key, dims[3], "All_cells")]], na.rm = TRUE), , drop = FALSE]
      dat_smooth <- unique(na.omit(dat_smooth))
      p <- add_trace(
        p = p,
        x = dat_smooth[, "x"],
        y = dat_smooth[, "y"],
        z = dat_smooth[, "z"],
        text = paste0(
          "Lineage:", l
        ),
        type = "scatter3d",
        mode = "lines",
        line = list(width = 6, color = palette_scp(x = lineages, palette = lineages_palette)[l], reverscale = FALSE),
        name = l,
        showlegend = TRUE,
        visible = TRUE
      )
    }
  }

  p <- layout(
    p = p,
    title = list(
      text = paste0("Total", " (nCells:", nrow(dat_use), ")"),
      font = list(size = 16, color = "black"),
      y = 0.95
    ),
    font = list(size = 12, color = "black"),
    showlegend = TRUE,
    legend = list(
      itemsizing = "constant",
      y = 0.5,
      x = 1,
      xanchor = "left",
      alpha = 1
    ),
    scene = list(
      xaxis = list(title = xlab, range = c(min(dat_use[[paste0(reduction_key, dims[1])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[1])]], na.rm = TRUE))),
      yaxis = list(title = ylab, range = c(min(dat_use[[paste0(reduction_key, dims[2])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[2])]], na.rm = TRUE))),
      zaxis = list(title = zlab, range = c(min(dat_use[[paste0(reduction_key, dims[3])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[3])]], na.rm = TRUE))),
      aspectratio = list(x = 1, y = 1, z = 1)
    ),
    autosize = FALSE
  )

  if ((!is.null(save) && is.character(save) && nchar(save) > 0)) {
    htmlwidgets::saveWidget(
      widget = as_widget(p),
      file = save
    )
    unlink(gsub("\\.html", "_files", save), recursive = TRUE)
  }

  return(p)
}

# ---- SCP-plot.R:4463-4490 : CellStatPlot ----
CellStatPlot <- function(srt, stat.by, group.by = NULL, split.by = NULL, bg.by = NULL, cells = NULL, flip = FALSE,
                         NA_color = "grey", NA_stat = TRUE, keep_empty = FALSE, individual = FALSE, stat_level = NULL,
                         plot_type = c("bar", "rose", "ring", "pie", "trend", "area", "dot", "sankey", "chord", "venn", "upset"),
                         stat_type = c("percent", "count"), position = c("stack", "dodge"),
                         palette = "Paired", palcolor = NULL, alpha = 1,
                         bg_palette = "Paired", bg_palcolor = NULL, bg_alpha = 0.2,
                         label = FALSE, label.size = 3.5, label.fg = "black", label.bg = "white", label.bg.r = 0.1,
                         aspect.ratio = NULL, title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                         legend.position = "right", legend.direction = "vertical",
                         theme_use = "theme_scp", theme_args = list(),
                         combine = TRUE, nrow = NULL, ncol = NULL, byrow = TRUE, force = FALSE, seed = 11) {
  cells <- cells %||% colnames(srt@assays[[1]])
  meta.data <- srt@meta.data[cells, , drop = FALSE]

  plot <- StatPlot(
    meta.data = meta.data, stat.by = stat.by, group.by = group.by, split.by = split.by, bg.by = bg.by, flip = flip,
    NA_color = NA_color, NA_stat = NA_stat, keep_empty = keep_empty, individual = individual, stat_level = stat_level,
    plot_type = plot_type, stat_type = stat_type, position = position,
    palette = palette, palcolor = palcolor, alpha = alpha,
    bg_palette = bg_palette, bg_palcolor = bg_palcolor, bg_alpha = bg_alpha,
    label = label, label.size = label.size, label.fg = label.fg, label.bg = label.bg, label.bg.r = label.bg.r,
    aspect.ratio = aspect.ratio, title = title, subtitle = subtitle, xlab = xlab, ylab = ylab,
    legend.position = legend.position, legend.direction = legend.direction,
    theme_use = theme_use, theme_args = theme_args,
    combine = combine, nrow = nrow, ncol = ncol, byrow = byrow, force = force, seed = seed
  )
  return(plot)
}

# ---- SCP-plot.R:4564-5159 : StatPlot ----
StatPlot <- function(meta.data, stat.by, group.by = NULL, split.by = NULL, bg.by = NULL, flip = FALSE,
                     NA_color = "grey", NA_stat = TRUE, keep_empty = FALSE, individual = FALSE, stat_level = NULL,
                     plot_type = c("bar", "rose", "ring", "pie", "trend", "area", "dot", "sankey", "chord", "venn", "upset"),
                     stat_type = c("percent", "count"), position = c("stack", "dodge"),
                     palette = "Paired", palcolor = NULL, alpha = 1,
                     bg_palette = "Paired", bg_palcolor = NULL, bg_alpha = 0.2,
                     label = FALSE, label.size = 3.5, label.fg = "black", label.bg = "white", label.bg.r = 0.1,
                     aspect.ratio = NULL, title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                     legend.position = "right", legend.direction = "vertical",
                     theme_use = "theme_scp", theme_args = list(),
                     combine = TRUE, nrow = NULL, ncol = NULL, byrow = TRUE, force = FALSE, seed = 11) {
  set.seed(seed)

  stat_type <- match.arg(stat_type)
  plot_type <- match.arg(plot_type)
  position <- match.arg(position)

  if (nrow(meta.data) == 0) {
    stop("meta.data is empty.")
  }
  if (is.null(group.by)) {
    group.by <- "All.groups"
    xlab <- ""
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
  bg_map <- NULL
  if (!is.null(bg.by)) {
    for (g in group.by) {
      df_table <- table(meta.data[[g]], meta.data[[bg.by]])
      if (max(rowSums(df_table > 0), na.rm = TRUE) > 1) {
        stop("'group.by' must be a part of 'bg.by'")
      } else {
        bg_map[[g]] <- setNames(colnames(df_table)[apply(df_table, 1, function(x) which(x > 0))], rownames(df_table))
      }
    }
  } else {
    for (g in group.by) {
      bg_map[[g]] <- setNames(levels(meta.data[[g]]), levels(meta.data[[g]]))
    }
  }
  for (i in unique(stat.by)) {
    if (!i %in% colnames(meta.data)) {
      stop(paste0(i, " is not in the meta.data."))
    }
    if (plot_type %in% c("venn", "upset")) {
      if (!is.factor(meta.data[[i]]) && !is.logical(meta.data[[i]])) {
        meta.data[[i]] <- factor(meta.data[[i]], levels = unique(meta.data[[i]]))
      }
    } else if (!is.factor(meta.data[[i]])) {
      meta.data[[i]] <- factor(meta.data[[i]], levels = unique(meta.data[[i]]))
    }
  }

  if (length(stat.by) >= 2) {
    if (!plot_type %in% c("sankey", "chord", "venn", "upset")) {
      stop("plot_type must be one of 'sankey', 'chord', 'venn' and 'upset' whtn multiple 'stat.by' provided.")
    }
    if (length(stat.by) > 2 && plot_type == "chord") {
      stop("'stat.by' can only be a vector of length 2 when 'plot_type' is 'chord'.")
    }
    if (length(stat.by) > 7 && plot_type == "venn") {
      stop("'stat.by' can only be a vector of length <= 7 when 'plot_type' is 'venn'.")
    }
  }
  levels <- unique(unlist(lapply(meta.data[, stat.by, drop = FALSE], function(x) {
    if (is.factor(x)) {
      return(levels(x))
    }
    if (is.logical(x)) {
      return(as.character(unique(x)))
    }
  })))

  if (plot_type %in% c("venn", "upset")) {
    if (is.null(stat_level)) {
      stat_level <- lapply(stat.by, function(stat) {
        levels(meta.data[[stat]])[1] %||% sort(unique(meta.data[[stat]]))[1]
      })
      message("stat_level is set to ", paste0(stat_level, collapse = ","))
    } else {
      if (length(stat_level) == 1) {
        stat_level <- rep(stat_level, length(stat.by))
      }
      if (length(stat_level) != length(stat.by)) {
        stop("'stat_level' must be of length 1 or the same length as 'stat.by'")
      }
    }
    if (is.null(names(stat_level))) {
      names(stat_level) <- stat.by
    }
    for (i in stat.by) {
      meta.data[[i]] <- meta.data[[i]] %in% stat_level[[i]]
    }
  }

  if (plot_type %in% c("rose", "ring", "pie")) {
    aspect.ratio <- 1
  }

  if (any(group.by != "All.groups") && plot_type %in% c("sankey", "chord", "venn", "upset")) {
    warning("group.by is not used when plot sankey, chord, venn or upset", immediate. = TRUE)
  }
  if (stat_type == "percent" && plot_type %in% c("sankey", "chord", "venn", "upset")) {
    warning("stat_type is forcibly set to 'count' when plot sankey, chord, venn or upset", immediate. = TRUE)
    stat_type <- "count"
  }
  dat_all <- meta.data[, unique(c(stat.by, group.by, split.by, bg.by)), drop = FALSE]
  nlev <- sapply(dat_all, nlevels)
  nlev <- nlev[nlev > 100]
  if (length(nlev) > 0 && !isTRUE(force)) {
    warning(paste(names(nlev), sep = ","), " have more than 100 levels.", immediate. = TRUE)
    answer <- askYesNo("Are you sure to continue?", default = FALSE)
    if (!isTRUE(answer)) {
      return(invisible(NULL))
    }
  }
  dat_split <- split.data.frame(dat_all, dat_all[[split.by]])

  plist <- list()
  if (plot_type %in% c("bar", "rose", "ring", "pie", "trend", "area", "dot")) {
    xlab <- xlab %||% group.by
    ylab <- ylab %||% ifelse(stat_type == "count", "Count", "Percentage")
    if (identical(theme_use, "theme_blank")) {
      theme_args[["xlab"]] <- xlab
      theme_args[["ylab"]] <- ylab
      if (plot_type %in% c("rose", "ring", "pie")) {
        theme_args[["add_coord"]] <- FALSE
      }
    }
    colors <- palette_scp(dat_all[[stat.by]], palette = palette, palcolor = palcolor, NA_color = NA_color, NA_keep = TRUE)

    comb_list <- list()
    comb <- expand.grid(stat_name = stat.by, group_name = group.by, stringsAsFactors = FALSE)
    if (isTRUE(individual)) {
      for (g in group.by) {
        comb_list[[g]] <- merge(comb, expand.grid(
          group_name = g, group_element = levels(dat_all[[g]]),
          split_name = levels(dat_all[[split.by]]), stringsAsFactors = FALSE
        ),
        by = "group_name"
        )
      }
    } else {
      for (g in group.by) {
        comb_list[[g]] <- merge(comb, expand.grid(
          group_name = g, group_element = list(levels(dat_all[[g]])),
          split_name = levels(dat_all[[split.by]]), stringsAsFactors = FALSE
        ),
        by = "group_name"
        )
      }
    }
    comb <- do.call(rbind, comb_list)
    rownames(comb) <- paste0(
      comb[["group_name"]], ":",
      sapply(comb[["group_element"]], function(x) paste0(x, collapse = ",")), ":",
      comb[["split_name"]]
    )

    plist <- lapply(setNames(rownames(comb), rownames(comb)), function(i) {
      stat.by <- comb[i, "stat_name"]
      sp <- comb[i, "split_name"]
      g <- comb[i, "group_name"]
      single_group <- comb[[i, "group_element"]]
      colors_use <- colors[names(colors) %in% dat_split[[ifelse(split.by == "All.groups", 1, sp)]][[stat.by]]]
      if (any(is.na(dat_split[[ifelse(split.by == "All.groups", 1, sp)]][[stat.by]])) && isTRUE(NA_stat)) {
        colors_use <- c(colors_use, colors["NA"])
      }
      if (stat_type == "percent") {
        dat_use <- dat_split[[ifelse(split.by == "All.groups", 1, sp)]] %>%
          xtabs(formula = paste0("~", stat.by, "+", g), addNA = NA_stat) %>%
          as.data.frame() %>%
          group_by(across(all_of(g)), .drop = FALSE) %>%
          mutate(groupn = sum(Freq)) %>%
          group_by(across(all_of(c(stat.by, g))), .drop = FALSE) %>%
          mutate(value = Freq / groupn) %>%
          as.data.frame()
      } else {
        dat_use <- dat_split[[ifelse(split.by == "All.groups", 1, sp)]] %>%
          xtabs(formula = paste0("~", stat.by, "+", g), addNA = NA_stat) %>%
          as.data.frame() %>%
          mutate(value = Freq)
      }
      dat <- dat_use[dat_use[[g]] %in% single_group, , drop = FALSE]
      dat[[g]] <- factor(dat[[g]], levels = levels(dat[[g]])[levels(dat[[g]]) %in% dat[[g]]])
      dat <- dat[!is.na(dat[["value"]]), , drop = FALSE]
      if (!is.null(bg.by)) {
        bg <- bg.by
        bg_color <- palette_scp(levels(dat_all[[bg]]), palette = bg_palette, palcolor = bg_palcolor)
      } else {
        bg <- g
        bg_color <- palette_scp(levels(dat_all[[bg]]), palcolor = bg_palcolor %||% rep(c("transparent", "grey85"), nlevels(dat_all[[bg]])))
      }

      if (isTRUE(flip)) {
        dat[[g]] <- factor(dat[[g]], levels = rev(levels(dat[[g]])))
        aspect.ratio <- 1 / aspect.ratio
        if (length(aspect.ratio) == 0 || is.na(aspect.ratio)) {
          aspect.ratio <- NULL
        }
      }
      if (plot_type == "ring") {
        dat[[g]] <- factor(dat[[g]], levels = c("   ", levels(dat[[g]])))
        dat <- rbind(dat, dat[nrow(dat) + 1, , drop = FALSE])
        dat[nrow(dat), g] <- "   "
      }
      if (plot_type == "dot") {
        position_use <- position_identity()
        scalex <- scale_x_discrete(drop = !keep_empty)
      } else {
        if (position == "stack") {
          position_use <- position_stack(vjust = 0.5)
          scalex <- scale_x_discrete(drop = !keep_empty, expand = c(0, 0))
          scaley <- scale_y_continuous(
            labels = if (stat_type == "count") scales::number else scales::percent,
            expand = c(0, 0)
          )
        } else if (position == "dodge") {
          if (plot_type == "area") {
            position_use <- position_dodge2(width = 0.9, preserve = "total")
          } else {
            position_use <- position_dodge2(width = 0.9, preserve = "single")
          }
          scalex <- scale_x_discrete(drop = !keep_empty)
          scaley <- scale_y_continuous(
            limits = c(0, max(dat[["value"]], na.rm = TRUE) * 1.1),
            labels = if (stat_type == "count") scales::number else scales::percent,
            expand = c(0, 0)
          )
        }
      }
      if (position == "stack") {
        bg_layer <- NULL
      } else {
        bg_data <- na.omit(unique(dat[, g, drop = FALSE]))
        bg_data[["x"]] <- as.numeric(bg_data[[g]])
        bg_data[["xmin"]] <- ifelse(bg_data[["x"]] == min(bg_data[["x"]]), -Inf, bg_data[["x"]] - 0.5)
        bg_data[["xmax"]] <- ifelse(bg_data[["x"]] == max(bg_data[["x"]]), Inf, bg_data[["x"]] + 0.5)
        bg_data[["ymin"]] <- -Inf
        bg_data[["ymax"]] <- Inf
        bg_data[["fill"]] <- bg_color[bg_map[[g]][as.character(bg_data[[g]])]]
        bg_layer <- geom_rect(data = bg_data, xmin = bg_data[["xmin"]], xmax = bg_data[["xmax"]], ymin = bg_data[["ymin"]], ymax = bg_data[["ymax"]], fill = bg_data[["fill"]], alpha = bg_alpha, inherit.aes = FALSE)
      }

      if (plot_type == "bar") {
        p <- ggplot(dat, aes(x = .data[[g]], y = value, group = .data[[stat.by]])) +
          bg_layer +
          geom_col(aes(fill = .data[[stat.by]]),
            width = 0.8,
            color = "black",
            alpha = alpha,
            position = position_use
          ) +
          scalex +
          scaley
      }
      if (plot_type == "trend") {
        dat_area <- dat[rep(seq_len(nrow(dat)), each = 2), , drop = FALSE]
        dat_area[[g]] <- as.numeric(dat_area[[g]])
        dat_area[seq(1, nrow(dat_area), 2), g] <- dat_area[seq(1, nrow(dat_area), 2), g] - 0.3
        dat_area[seq(2, nrow(dat_area), 2), g] <- dat_area[seq(2, nrow(dat_area), 2), g] + 0.3
        p <- ggplot(dat, aes(x = .data[[g]], y = value, fill = .data[[stat.by]])) +
          bg_layer +
          geom_area(
            data = dat_area, mapping = aes(x = .data[[g]], fill = .data[[stat.by]]),
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
      if (plot_type == "rose") {
        p <- ggplot(dat, aes(x = .data[[g]], y = value, group = .data[[stat.by]])) +
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
      if (plot_type == "ring" || plot_type == "pie") {
        p <- ggplot(dat, aes(x = .data[[g]], y = value, group = .data[[stat.by]])) +
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
      if (plot_type == "area") {
        p <- ggplot(dat, aes(x = .data[[g]], y = value, group = .data[[stat.by]])) +
          bg_layer +
          geom_area(aes(fill = .data[[stat.by]]),
            color = "black",
            alpha = alpha,
            position = position_use
          ) +
          scalex +
          scaley
      }
      if (plot_type == "dot") {
        p <- ggplot(dat, aes(x = .data[[g]], y = .data[[stat.by]])) +
          bg_layer +
          geom_point(aes(fill = .data[[stat.by]], size = value),
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
        if (plot_type == "dot") {
          p <- p + geom_text_repel(
            aes(
              x = .data[[g]], y = .data[[stat.by]],
              label = if (stat_type == "count") value else paste0(round(value * 100, 1), "%"),
            ),
            colour = label.fg, size = label.size,
            bg.color = label.bg, bg.r = label.bg.r,
            point.size = NA, max.overlaps = 100, min.segment.length = 0, force = 0,
            position = position_use
          )
        } else {
          p <- p + geom_text_repel(
            aes(
              label = if (stat_type == "count") value else paste0(round(value * 100, 1), "%"),
              y = value
            ),
            colour = label.fg, size = label.size,
            bg.color = label.bg, bg.r = label.bg.r,
            point.size = NA, max.overlaps = 100, min.segment.length = 0, force = 0,
            position = position_use
          )
        }
      }
      if (plot_type %in% c("rose")) {
        # angle <- 360 / (2 * pi) * rev(seq(pi / nlevels(dat[[g]]), 2 * pi - pi / nlevels(dat[[g]]), len = nlevels(dat[[g]])))
        # axis.text.x <- element_text(angle = angle)
        axis.text.x <- element_text()
      } else if (plot_type %in% c("ring", "pie")) {
        axis.text.x <- element_text()
      } else {
        axis.text.x <- element_text(angle = 45, hjust = 1, vjust = 1)
      }
      title <- title %||% sp
      p <- p + labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
        scale_fill_manual(
          name = paste0(stat.by, ":"), values = colors_use, na.value = colors_use["NA"], drop = FALSE,
          limits = names(colors_use), na.translate = T
        ) +
        do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          axis.text.x = axis.text.x,
          legend.position = legend.position,
          legend.direction = legend.direction,
          panel.grid.major = if (plot_type == "trend" & stat_type == "percent") element_blank() else element_line(colour = "grey80", linetype = 2)
        ) + guides(fill = guide_legend(
          title.hjust = 0,
          order = 1,
          override.aes = list(size = 4, color = "black", alpha = 1)
        ))
      if (isTRUE(flip) && !plot_type %in% c("pie", "rose")) {
        p <- p + coord_flip()
      }
      return(p)
    })
  } else if (plot_type %in% c("chord", "sankey", "venn", "upset")) {
    colors <- palette_scp(stat.by, palette = palette, palcolor = palcolor)
    if (plot_type == "chord" && isTRUE(combine)) {
      temp <- tempfile(fileext = "png")
      png(temp)
      dev.control("enable")
      nlev <- nlevels(dat_all[[split.by]])
      if (is.null(nrow) && is.null(ncol)) {
        nrow <- ceiling(sqrt(nlev))
        ncol <- ceiling(nlev / nrow)
      }
      if (is.null(nrow)) {
        nrow <- ceiling(sqrt(ncol))
      }
      if (is.null(ncol)) {
        ncol <- ceiling(sqrt(nrow))
      }
      par(mfrow = c(nrow, ncol))
    }
    for (sp in levels(dat_all[[split.by]])) {
      dat_use <- dat_split[[ifelse(split.by == "All.groups", 1, sp)]]
      if (plot_type == "venn") {
        check_R(c("ggVennDiagram", "sf"))
        dat_list <- as.list(dat_use[, stat.by])
        dat_list <- lapply(setNames(names(dat_list), names(dat_list)), function(x) {
          lg <- dat_list[[x]]
          names(lg) <- rownames(dat_use)
          cellkeep <- names(lg)[lg]
          return(cellkeep)
        })
        venn <- ggVennDiagram::Venn(dat_list)
        data <- ggVennDiagram::process_data(venn)
        dat_venn_region <- ggVennDiagram::venn_region(data)
        idname <- dat_venn_region[["name"]][dat_venn_region[["name"]] %in% stat.by]
        names(idname) <- dat_venn_region[["id"]][dat_venn_region[["name"]] %in% stat.by]
        idcomb <- strsplit(dat_venn_region[["id"]], split = "")
        colorcomb <- lapply(idcomb, function(x) colors[idname[as.character(x)]])
        dat_venn_region[["colors"]] <- sapply(colorcomb, function(x) blendcolors(x, mode = "blend"))
        dat_venn_region[["label"]] <- paste0(
          dat_venn_region[["count"]], "\n",
          round(dat_venn_region[["count"]] / sum(dat_venn_region[["count"]]) * 100, 1), "%"
        )
        dat_venn_setedge <- ggVennDiagram::venn_setedge(data)
        dat_venn_setedge[["colors"]] <- colors[dat_venn_setedge[["name"]]]
        dat_venn_setlabel <- ggVennDiagram::venn_setlabel(data)
        dat_title <- as.data.frame(do.call(rbind, dat_venn_setlabel$geometry))
        colnames(dat_title) <- c("x", "y")
        dat_title[["label"]] <- paste0(
          dat_venn_setlabel[["name"]], "\n",
          "(", sapply(dat_list, length)[dat_venn_setlabel[["name"]]], ")"
        )
        dat_stat <- as.data.frame(do.call(rbind, lapply(dat_venn_region$geometry, function(x) sf::st_centroid(x))))
        colnames(dat_stat) <- c("x", "y")
        dat_stat[["label"]] <- dat_venn_region[["label"]]
        p <- ggplot() +
          geom_sf(data = dat_venn_region, aes(fill = colors), alpha = alpha) +
          geom_sf(data = dat_venn_setedge, aes(color = colors), size = 1) +
          geom_text_repel(
            data = dat_title, aes(label = label, x = x, y = y),
            fontface = "bold",
            colour = label.fg, size = label.size + 0.5,
            bg.color = label.bg, bg.r = label.bg.r,
            point.size = NA, max.overlaps = 100, force = 0,
            min.segment.length = 0, segment.colour = "black"
          ) +
          geom_text_repel(
            data = dat_stat, aes(label = label, x = x, y = y),
            colour = label.fg, size = label.size,
            bg.color = label.bg, bg.r = label.bg.r,
            point.size = NA, max.overlaps = 100, force = 0,
            min.segment.length = 0, segment.colour = "black"
          ) +
          scale_fill_identity() +
          scale_color_identity() +
          theme(
            plot.title = element_text(hjust = 0.5),
            plot.background = element_blank(),
            panel.background = element_blank(),
            axis.title.y = element_blank(),
            axis.text = element_blank(),
            axis.ticks = element_blank()
          )
        p <- p + labs(x = sp, title = title, subtitle = subtitle)
      }
      if (plot_type == "upset") {
        check_R("ggupset")
        for (n in seq_len(nrow(dat_use))) {
          dat_use[["intersection"]][n] <- list(stat.by[unlist(dat_use[n, stat.by])])
        }
        dat_use <- dat_use[sapply(dat_use[["intersection"]], length) > 0, , drop = FALSE]
        p <- ggplot(dat_use, aes(x = intersection)) +
          geom_bar(aes(fill = after_stat(count)), color = "black", width = 0.5, show.legend = FALSE) +
          geom_text_repel(aes(label = after_stat(count)),
            stat = "count",
            colour = label.fg, size = label.size,
            bg.color = label.bg, bg.r = label.bg.r,
            point.size = NA, max.overlaps = 100, force = 0,
            min.segment.length = 0, segment.colour = "black"
          ) +
          labs(title = title, subtitle = subtitle, x = sp, y = "Intersection size") +
          ggupset::scale_x_upset(sets = stat.by, n_intersections = 20) +
          scale_fill_gradientn(colors = palette_scp(palette = "material-indigo")) +
          theme_scp(
            aspect.ratio = 0.6,
            panel.grid.major = element_line(colour = "grey80", linetype = 2)
          ) +
          ggupset::theme_combmatrix(
            combmatrix.label.text = element_text(size = 12, color = "black"),
            combmatrix.label.extra_spacing = 6
          )
        p <- p + labs(title = title, subtitle = subtitle)
      }
      if (plot_type == "sankey") {
        colors <- palette_scp(c(unique(unlist(lapply(dat_all[, stat.by, drop = FALSE], levels))), NA), palette = palette, palcolor = palcolor, NA_keep = TRUE, NA_color = NA_color)
        legend_list <- list()
        for (l in stat.by) {
          df <- data.frame(factor(levels(dat_use[[l]]), levels = levels(dat_use[[l]])))
          colnames(df) <- l
          legend_list[[l]] <- get_legend(ggplot(data = df) +
            geom_col(aes(x = 1, y = 1, fill = .data[[l]]), color = "black") +
            scale_fill_manual(values = colors[levels(dat_use[[l]])]) +
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
          if (any(is.na(dat_use[[l]]))) {
            raw_levels <- levels(dat_use[[l]])
            dat_use[[l]] <- as.character(dat_use[[l]])
            dat_use[[l]][is.na(dat_use[[l]])] <- "NA"
            dat_use[[l]] <- factor(dat_use[[l]], levels = c(raw_levels, "NA"))
          }
        }
        if (legend.direction == "vertical") {
          legend <- do.call(cbind, legend_list)
        } else {
          legend <- do.call(rbind, legend_list)
        }
        dat <- suppressWarnings(make_long(dat_use, all_of(stat.by)))
        dat$node <- factor(dat$node, levels = rev(names(colors)))
        p0 <- ggplot(dat, aes(x = x, next_x = next_x, node = node, next_node = next_node, fill = node)) +
          geom_sankey(color = "black", flow.alpha = alpha, show.legend = FALSE, na.rm = FALSE) +
          scale_fill_manual(values = colors, drop = FALSE) +
          scale_x_discrete(expand = c(0, 0.2)) +
          theme_void() +
          theme(axis.text.x = element_text())
        gtable <- as_grob(p0)
        gtable <- add_grob(gtable, legend, legend.position)
        p <- wrap_plots(gtable)
      }
      if (plot_type == "chord") {
        colors <- palette_scp(c(unique(unlist(lapply(dat_all[, stat.by, drop = FALSE], levels))), NA), palette = palette, palcolor = palcolor, NA_keep = TRUE, NA_color = NA_color)
        M <- table(dat_use[[stat.by[1]]], dat_use[[stat.by[2]]], useNA = "ifany")
        m <- matrix(M, ncol = ncol(M), dimnames = dimnames(M))
        colnames(m)[is.na(colnames(m))] <- "NA"
        chordDiagram(m,
          grid.col = colors,
          transparency = 0.2,
          link.lwd = 1,
          link.lty = 1,
          link.border = 1
        )
        circos.clear()
        p <- recordPlot()

        # library(grid)
        # library(gridBase)
        # plot.new()
        # pushViewport(
        #   viewport(x = 0.5, y = 0.5, width = unit(1, "snpc"), height = unit(1, "snpc"), just = c("left", "center"))
        # )
        # par(omi = gridOMI(), new = TRUE)
        # chord()
      }

      plist[[sp]] <- p
    }
  }
  if (isTRUE(combine) && plot_type == "chord") {
    plot <- recordPlot()
    dev.off()
    unlink(temp)
    return(plot)
  }
  if (isTRUE(combine) && plot_type != "chord") {
    if (length(plist) > 1) {
      plot <- wrap_plots(plotlist = plist, nrow = nrow, ncol = ncol, byrow = byrow)
    } else {
      plot <- plist[[1]]
    }
    return(plot)
  } else {
    return(plist)
  }
}

# ---- SCP-plot.R:5918-6030 : LineagePlot ----
LineagePlot <- function(srt, lineages, reduction = NULL, dims = c(1, 2), cells = NULL,
                        trim = c(0.01, 0.99), span = 0.75,
                        palette = "Dark2", palcolor = NULL, lineages_arrow = arrow(length = unit(0.1, "inches")),
                        linewidth = 1, line_bg = "white", line_bg_stroke = 0.5,
                        whiskers = FALSE, whiskers_linewidth = 0.5, whiskers_alpha = 0.5,
                        aspect.ratio = 1, title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                        legend.position = "right", legend.direction = "vertical",
                        theme_use = "theme_scp", theme_args = list(),
                        return_layer = FALSE, seed = 11) {
  set.seed(seed)

  if (is.null(reduction)) {
    reduction <- DefaultReduction(srt)
  } else {
    reduction <- DefaultReduction(srt, pattern = reduction)
  }
  if (!reduction %in% names(srt@reductions)) {
    stop(paste0(reduction, " is not in the srt reduction names."))
  }

  reduction_key <- srt@reductions[[reduction]]@key
  dat_dim <- srt@reductions[[reduction]]@cell.embeddings
  colnames(dat_dim) <- paste0(reduction_key, seq_len(ncol(dat_dim)))
  rownames(dat_dim) <- rownames(dat_dim) %||% colnames(srt@assays[[1]])
  dat_lineages <- srt@meta.data[, unique(lineages), drop = FALSE]
  dat <- cbind(dat_dim, dat_lineages[row.names(dat_dim), , drop = FALSE])
  dat[, "cell"] <- rownames(dat)
  if (!is.null(cells)) {
    dat <- dat[intersect(rownames(dat), cells), , drop = FALSE]
  }

  xlab <- xlab %||% paste0(reduction_key, dims[1])
  ylab <- ylab %||% paste0(reduction_key, dims[2])
  if (identical(theme_use, "theme_blank")) {
    theme_args[["xlab"]] <- xlab
    theme_args[["ylab"]] <- ylab
  }

  colors <- palette_scp(lineages, palette = palette, palcolor = palcolor)
  axes <- paste0(reduction_key, dims)
  fitted_list <- lapply(lineages, function(l) {
    trim_pass <- dat[[l]] > quantile(dat[[l]], trim[1], na.rm = TRUE) & dat[[l]] < quantile(dat[[l]], trim[2], na.rm = TRUE)
    na_pass <- !is.na(dat[[l]])
    index <- which(trim_pass & na_pass)
    index <- index[order(dat[index, l])]
    dat_sub <- dat[index, , drop = FALSE]
    # if (is.null(weights)) {
    weights_used <- rep(1, nrow(dat_sub))
    # } else {
    # weights_used <- dat_sub[[weights]]
    # }
    fitted <- lapply(axes, function(x) {
      loess(formula(paste(x, l, sep = "~")), weights = weights_used, data = dat_sub, span = span, degree = 2)$fitted
    })
    names(fitted) <- axes
    fitted[["index"]] <- index
    return(fitted)
  })
  names(fitted_list) <- lineages

  curve_layer <- lapply(lineages, function(l) {
    dat_smooth <- as.data.frame(fitted_list[[l]])
    colnames(dat_smooth) <- c(paste0("Axis_", 1:(ncol(dat_smooth) - 1)), "index")
    dat_smooth[, "Lineages"] <- factor(l, levels = lineages)
    dat_smooth <- unique(na.omit(dat_smooth))
    curve <- list()
    if (isTRUE(whiskers)) {
      dat_smooth[, "raw_Axis_1"] <- dat[dat_smooth[, "index"], axes[1]]
      dat_smooth[, "raw_Axis_2"] <- dat[dat_smooth[, "index"], axes[2]]
      curve <- c(curve, geom_segment(
        data = dat_smooth, mapping = aes(x = Axis_1, y = Axis_2, xend = raw_Axis_1, yend = raw_Axis_2, color = Lineages),
        linewidth = whiskers_linewidth, alpha = whiskers_alpha,
        show.legend = TRUE, inherit.aes = FALSE
      ))
    }
    curve <- c(
      curve,
      geom_path(
        data = dat_smooth, mapping = aes(x = Axis_1, y = Axis_2), color = line_bg,
        linewidth = linewidth + line_bg_stroke, arrow = lineages_arrow,
        show.legend = TRUE, inherit.aes = FALSE
      ),
      geom_path(
        data = dat_smooth, mapping = aes(x = Axis_1, y = Axis_2, color = Lineages),
        linewidth = linewidth, arrow = lineages_arrow,
        show.legend = TRUE, inherit.aes = FALSE
      )
    )
    return(curve)
  })
  curve_layer <- c(unlist(curve_layer), list(scale_color_manual(values = colors)))

  lab_layer <- list(labs(title = title, subtitle = subtitle, x = xlab, y = ylab))
  theme_layer <- list(do.call(theme_use, theme_args) +
    theme(
      aspect.ratio = aspect.ratio,
      legend.position = legend.position,
      legend.direction = legend.direction
    ))

  if (isTRUE(return_layer)) {
    return(list(
      curve_layer = curve_layer,
      lab_layer = lab_layer,
      theme_layer = theme_layer
    ))
  } else {
    return(ggplot() +
      curve_layer +
      lab_layer +
      theme_layer)
  }
}

# ---- SCP-plot.R:6121-6214 : PAGAPlot ----
PAGAPlot <- function(srt, paga = srt@misc$paga, type = "connectivities",
                     reduction = NULL, dims = c(1, 2), cells = NULL, show_transition = FALSE,
                     node_palette = "Paired", node_palcolor = NULL, node_size = 4, node_alpha = 1,
                     node_highlight = NULL, node_highlight_color = "red",
                     label = FALSE, label.size = 3.5, label.fg = "white", label.bg = "black", label.bg.r = 0.1,
                     label_insitu = FALSE, label_repel = FALSE, label_repulsion = 20,
                     label_point_size = 1, label_point_color = "black", label_segment_color = "black",
                     edge_threshold = 0.01, edge_line = c("straight", "curved"), edge_line_curvature = 0.3, edge_line_angle = 90,
                     edge_size = c(0.2, 1), edge_color = "grey40", edge_alpha = 0.5,
                     edge_shorten = 0, edge_offset = 0, edge_highlight = NULL, edge_highlight_color = "red",
                     transition_threshold = 0.01, transition_line = c("straight", "curved"), transition_line_curvature = 0.3, transition_line_angle = 90,
                     transition_size = c(0.2, 1), transition_color = "black", transition_alpha = 1,
                     transition_arrow_type = "closed", transition_arrow_angle = 20, transition_arrow_length = unit(0.02, "npc"),
                     transition_shorten = 0.05, transition_offset = 0, transition_highlight = NULL, transition_highlight_color = "red",
                     aspect.ratio = 1, title = "PAGA", subtitle = NULL, xlab = NULL, ylab = NULL,
                     legend.position = "right", legend.direction = "vertical",
                     theme_use = "theme_scp", theme_args = list(),
                     return_layer = FALSE) {
  if (is.null(paga)) {
    stop("Cannot find the paga result.")
  }
  if (type == "connectivities_tree") {
    use_triangular <- "both"
    edge_threshold <- 0
  } else {
    use_triangular <- "upper"
  }
  connectivities <- paga[[type]]
  transition <- paga[["transitions_confidence"]]
  groups <- paga[["groups"]]
  if (!is.factor(srt@meta.data[[groups]])) {
    srt@meta.data[[groups]] <- factor(srt@meta.data[[groups]])
  }
  if (nlevels(srt@meta.data[[groups]]) != nrow(connectivities)) {
    stop("nlevels in ", groups, " is not identical with the group in paga")
  }
  if (is.null(reduction)) {
    reduction <- DefaultReduction(srt)
  } else {
    reduction <- DefaultReduction(srt, pattern = reduction)
  }
  if (!reduction %in% names(srt@reductions)) {
    stop(paste0(reduction, " is not in the srt reduction names."))
  }
  reduction_key <- srt@reductions[[reduction]]@key
  dat_dim <- as.data.frame(srt@reductions[[reduction]]@cell.embeddings)
  colnames(dat_dim) <- paste0(reduction_key, seq_len(ncol(dat_dim)))
  rownames(dat_dim) <- rownames(dat_dim) %||% colnames(srt@assays[[1]])
  dat_dim <- dat_dim[, paste0(reduction_key, dims)]
  dat_dim[[groups]] <- srt@meta.data[rownames(dat_dim), groups]
  dat <- aggregate(dat_dim[, paste0(reduction_key, dims)], by = list(dat_dim[[groups]]), FUN = median)
  colnames(dat)[1] <- groups
  rownames(dat) <- dat[[groups]]
  dat[["GroupSize"]] <- as.numeric(table(dat_dim[[groups]])[rownames(dat)])
  colnames(connectivities) <- rownames(connectivities) <- rownames(dat)
  if (!is.null(transition)) {
    colnames(transition) <- rownames(transition) <- rownames(dat)
  }
  if (!isTRUE(show_transition)) {
    transition <- NULL
  } else if (isTRUE(show_transition) && is.null(transition)) {
    warning("transitions_confidence need to be calculated first.", immediate. = TRUE)
  }
  xlab <- xlab %||% paste0(reduction_key, dims[1])
  ylab <- ylab %||% paste0(reduction_key, dims[2])

  if (!is.null(cells)) {
    dat <- dat[intersect(rownames(dat), cells), , drop = FALSE]
    connectivities <- connectivities[rownames(dat), rownames(dat)]
  }

  out <- GraphPlot(
    node = dat, edge = as_matrix(connectivities), node_coord = paste0(reduction_key, dims),
    node_group = groups, node_palette = node_palette, node_palcolor = node_palcolor, node_size = node_size, node_alpha = node_alpha,
    node_highlight = node_highlight, node_highlight_color = node_highlight_color,
    label = label, label.size = label.size, label.fg = label.fg, label.bg = label.bg, label.bg.r = label.bg.r,
    label_insitu = label_insitu, label_repel = label_repel, label_repulsion = label_repulsion,
    label_point_size = label_point_size, label_point_color = label_point_color, label_segment_color = label_segment_color,
    edge_threshold = edge_threshold, use_triangular = use_triangular,
    edge_line = edge_line, edge_line_curvature = edge_line_curvature, edge_line_angle = edge_line_angle, edge_size = edge_size, edge_color = edge_color, edge_alpha = edge_alpha,
    edge_shorten = edge_shorten, edge_offset = edge_offset,
    edge_highlight = edge_highlight, edge_highlight_color = edge_highlight_color,
    transition = transition, transition_threshold = transition_threshold, transition_line = transition_line, transition_line_curvature = transition_line_curvature, transition_line_angle = transition_line_angle,
    transition_color = transition_color, transition_size = transition_size, transition_alpha = transition_alpha,
    transition_arrow_type = transition_arrow_type, transition_arrow_angle = transition_arrow_angle, transition_arrow_length = transition_arrow_length,
    transition_shorten = transition_shorten, transition_offset = transition_offset,
    transition_highlight = transition_highlight, transition_highlight_color = transition_highlight_color,
    aspect.ratio = aspect.ratio, title = title, subtitle = subtitle, xlab = xlab, ylab = ylab,
    legend.position = legend.position, legend.direction = legend.direction,
    theme_use = theme_use, theme_args = theme_args,
    return_layer = return_layer
  )
  return(out)
}

# ---- SCP-plot.R:6287-6631 : GraphPlot ----
GraphPlot <- function(node, edge, transition = NULL,
                      node_coord = c("x", "y"), node_group = NULL, node_palette = "Paired", node_palcolor = NULL, node_size = 4, node_alpha = 1,
                      node_highlight = NULL, node_highlight_color = "red",
                      label = FALSE, label.size = 3.5, label.fg = "white", label.bg = "black", label.bg.r = 0.1,
                      label_insitu = FALSE, label_repel = FALSE, label_repulsion = 20,
                      label_point_size = 1, label_point_color = "black", label_segment_color = "black",
                      edge_threshold = 0.01, use_triangular = c("upper", "lower", "both"), edge_line = c("straight", "curved"), edge_line_curvature = 0.3, edge_line_angle = 90,
                      edge_color = "grey40", edge_size = c(0.2, 1), edge_alpha = 0.5,
                      edge_shorten = 0, edge_offset = 0, edge_highlight = NULL, edge_highlight_color = "red",
                      transition_threshold = 0.01, transition_line = c("straight", "curved"), transition_line_curvature = 0.3, transition_line_angle = 90,
                      transition_color = "black", transition_size = c(0.2, 1), transition_alpha = 1,
                      transition_arrow_type = "closed", transition_arrow_angle = 20, transition_arrow_length = unit(0.02, "npc"),
                      transition_shorten = 0.05, transition_offset = 0, transition_highlight = NULL, transition_highlight_color = "red",
                      aspect.ratio = 1, title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                      legend.position = "right", legend.direction = "vertical",
                      theme_use = "theme_scp", theme_args = list(),
                      return_layer = FALSE) {
  use_triangular <- match.arg(use_triangular)
  edge_line <- match.arg(edge_line)
  transition_line <- match.arg(transition_line)
  if (!is.data.frame(node)) {
    stop("'node' must be a data.frame object.")
  }
  if (!is.matrix(edge)) {
    stop("'edge' must be a matrix object.")
  }
  if (!identical(nrow(edge), ncol(edge))) {
    stop("nrow and ncol is not identical in edge matrix")
  }
  if (!identical(nrow(edge), nrow(node))) {
    stop("nrow is not identical between edge and node.")
  }
  if (!identical(rownames(edge), rownames(node))) {
    warning("rownames of node is not identical with edge matrix. They will correspond according to the order.", immediate. = TRUE)
    colnames(edge) <- rownames(edge) <- rownames(node) <- rownames(node) %||% colnames(edge) %||% rownames(edge)
  }
  if (!all(node_coord %in% colnames(node))) {
    stop("Cannot find the node_coord ", paste(node_coord[!node_coord %in% colnames(node)], collapse = ","), " in the node column")
  }
  if (!is.null(transition)) {
    if (!identical(nrow(transition), nrow(node))) {
      stop("nrow is not identical between transition and node.")
    }
    if (!identical(rownames(transition), rownames(node))) {
      warning("rownames of node is not identical with transition matrix. They will correspond according to the order.", immediate. = TRUE)
      colnames(transition) <- rownames(transition) <- rownames(node) <- rownames(node) %||% colnames(transition) %||% rownames(transition)
    }
  }
  if (identical(theme_use, "theme_blank")) {
    theme_args[["xlab"]] <- xlab
    theme_args[["ylab"]] <- ylab
  }

  node <- as.data.frame(node)
  node[["x"]] <- node[[node_coord[1]]]
  node[["y"]] <- node[[node_coord[2]]]
  node[["node_name"]] <- rownames(node)
  node_group <- node_group %||% "node_name"
  node_size <- node_size %||% 5
  node_alpha <- node_alpha %||% 1
  if (!node_group %in% colnames(node)) {
    node[["node_group"]] <- node_group
  } else {
    node[["node_group"]] <- node[[node_group]]
  }
  if (!is.factor(node[["node_group"]])) {
    node[["node_group"]] <- factor(node[["node_group"]], levels = unique(node[["node_group"]]))
  }
  if (!node_size %in% colnames(node)) {
    if (!is.numeric(node_size)) {
      node_size <- 5
    }
    node[["node_size"]] <- node_size
    scale_size <- scale_size_identity()
  } else {
    node[["node_size"]] <- node[[node_size]]
    if (is.numeric(node[[node_size]])) {
      scale_size <- scale_size_continuous(name = node_size)
    } else {
      scale_size <- scale_size_discrete()
    }
  }
  if (!node_alpha %in% colnames(node)) {
    if (!is.numeric(node_alpha)) {
      node_alpha <- 1
    }
    node[["node_alpha"]] <- node_alpha
    scale_alpha <- scale_alpha_identity()
  } else {
    node[["node_alpha"]] <- node[[node_alpha]]
    if (is.numeric(node[[node_alpha]])) {
      scale_alpha <- scale_alpha_continuous()
    } else {
      scale_alpha <- scale_alpha_discrete()
    }
  }

  if (isTRUE(label) && !isTRUE(label_insitu)) {
    label_use <- paste0(1:nlevels(node[["node_group"]]), ": ", levels(node[["node_group"]]))
  } else {
    label_use <- levels(node[["node_group"]])
  }
  global_size <- sqrt(max(node[["x"]], na.rm = TRUE)^2 + max(node[["y"]], na.rm = TRUE)^2)

  edge[edge <= edge_threshold] <- NA
  if (use_triangular == "upper") {
    edge[lower.tri(edge)] <- NA
  } else if (use_triangular == "lower") {
    edge[upper.tri(edge)] <- NA
  }
  edge_df <- melt(edge, na.rm = TRUE, stringsAsFactors = FALSE)
  if (nrow(edge_df) == 0) {
    edge_layer <- NULL
  } else {
    colnames(edge_df) <- c("from", "to", "size")
    edge_df[, "from"] <- as.character(edge_df[, "from"])
    edge_df[, "to"] <- as.character(edge_df[, "to"])
    edge_df[, "size"] <- as.numeric(edge_df[, "size"])
    edge_df[, "x"] <- node[edge_df[, "from"], "x"]
    edge_df[, "y"] <- node[edge_df[, "from"], "y"]
    edge_df[, "xend"] <- node[edge_df[, "to"], "x"]
    edge_df[, "yend"] <- node[edge_df[, "to"], "y"]
    rownames(edge_df) <- edge_df[, "edge_name"] <- paste0(edge_df[, "from"], "-", edge_df[, "to"])
    edge_df <- segementsDf(edge_df, global_size * edge_shorten, global_size * edge_shorten, global_size * edge_offset)

    linetype <- ifelse(is.null(transition), 1, 2)
    if (edge_line == "straight") {
      edge_layer <- list(
        geom_segment(
          data = edge_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
          lineend = "round", linejoin = "mitre", linetype = linetype, color = edge_color, alpha = edge_alpha,
          inherit.aes = FALSE, show.legend = FALSE
        )
      )
      if (!is.null(edge_highlight)) {
        edge_df_highlight <- edge_df[edge_df[["edge_name"]] %in% edge_highlight, , drop = FALSE]
        edge_layer <- c(
          edge_layer,
          list(
            geom_segment(
              data = edge_df_highlight, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
              lineend = "round", linejoin = "mitre", linetype = linetype, color = edge_highlight_color, alpha = 1,
              inherit.aes = FALSE, show.legend = FALSE
            )
          )
        )
      }
    } else {
      edge_layer <- list(
        geom_curve(
          data = edge_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
          curvature = edge_line_curvature, angle = edge_line_angle,
          lineend = "round", linetype = linetype, color = edge_color, alpha = edge_alpha,
          inherit.aes = FALSE, show.legend = FALSE
        )
      )
      if (!is.null(edge_highlight)) {
        edge_df_highlight <- edge_df[edge_df[["edge_name"]] %in% edge_highlight, , drop = FALSE]
        edge_layer <- c(
          edge_layer,
          list(
            geom_curve(
              data = edge_df_highlight, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
              curvature = edge_line_curvature, angle = edge_line_angle,
              lineend = "round", linetype = linetype, color = edge_highlight_color, alpha = 1,
              inherit.aes = FALSE, show.legend = FALSE
            )
          )
        )
      }
    }
    edge_layer <- c(edge_layer, list(
      scale_linewidth_continuous(range = range(edge_size), guide = "none"),
      new_scale("linewidth")
    ))
  }

  if (!is.null(transition)) {
    trans2 <- trans1 <- as_matrix(transition)
    trans1[lower.tri(trans1)] <- 0
    trans2[upper.tri(trans2)] <- 0
    trans <- t(trans1) - trans2
    trans[abs(trans) <= transition_threshold] <- NA
    trans_df <- melt(trans, na.rm = TRUE, stringsAsFactors = FALSE)
    if (nrow(trans_df) == 0) {
      trans_layer <- NULL
    } else {
      trans_df <- as.data.frame(t(apply(trans_df, 1, function(x) {
        if (as.numeric(x[3]) < 0) {
          return(c(x[c(2, 1)], -as.numeric(x[3])))
        } else {
          return(x)
        }
      })))
      colnames(trans_df) <- c("from", "to", "size")
      trans_df[, "from"] <- as.character(trans_df[, "from"])
      trans_df[, "to"] <- as.character(trans_df[, "to"])
      trans_df[, "size"] <- as.numeric(trans_df[, "size"])
      trans_df[, "x"] <- node[trans_df[, "from"], "x"]
      trans_df[, "y"] <- node[trans_df[, "from"], "y"]
      trans_df[, "xend"] <- node[trans_df[, "to"], "x"]
      trans_df[, "yend"] <- node[trans_df[, "to"], "y"]
      rownames(trans_df) <- trans_df[, "trans_name"] <- paste0(trans_df[, "from"], "-", trans_df[, "to"])
      trans_df <- segementsDf(trans_df, global_size * transition_shorten, global_size * transition_shorten, global_size * transition_offset)

      if (transition_line == "straight") {
        trans_layer <- list(
          geom_segment(
            data = trans_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
            arrow = arrow(angle = transition_arrow_angle, type = transition_arrow_type, length = transition_arrow_length),
            lineend = "round", linejoin = "mitre", color = transition_color, alpha = transition_alpha,
            inherit.aes = FALSE, show.legend = FALSE
          )
        )
        if (!is.null(transition_highlight)) {
          trans_df_highlight <- trans_df[trans_df[["trans_name"]] %in% transition_highlight, , drop = FALSE]
          trans_layer <- c(
            trans_layer,
            list(
              geom_segment(
                data = trans_df_highlight, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
                arrow = arrow(angle = transition_arrow_angle, type = transition_arrow_type, length = transition_arrow_length),
                lineend = "round", linejoin = "mitre", color = transition_highlight_color, alpha = 1,
                inherit.aes = FALSE, show.legend = FALSE
              )
            )
          )
        }
      } else {
        trans_layer <- list(
          geom_curve(
            data = trans_df, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
            arrow = arrow(angle = transition_arrow_angle, type = transition_arrow_type, length = transition_arrow_length),
            curvature = transition_line_curvature, angle = transition_line_angle,
            lineend = "round", color = transition_color, alpha = transition_alpha,
            inherit.aes = FALSE, show.legend = FALSE
          )
        )
        if (!is.null(edge_highlight)) {
          trans_df_highlight <- trans_df[trans_df[["trans_name"]] %in% transition_highlight, , drop = FALSE]
          trans_layer <- c(
            trans_layer,
            list(
              geom_curve(
                data = trans_df_highlight, mapping = aes(x = x, y = y, xend = xend, yend = yend, linewidth = size),
                arrow = arrow(angle = transition_arrow_angle, type = transition_arrow_type, length = transition_arrow_length),
                curvature = transition_line_curvature, angle = transition_line_angle,
                lineend = "round", color = transition_highlight_color, alpha = 1,
                inherit.aes = FALSE, show.legend = FALSE
              )
            )
          )
        }
      }
      trans_layer <- c(trans_layer, list(
        scale_linewidth_continuous(range = range(transition_size), guide = "none"),
        new_scale("linewidth")
      ))
    }
  } else {
    trans_layer <- NULL
  }

  node_layer <- list(
    geom_point(data = node, aes(x = x, y = y, size = node_size * 1.2), color = "black", show.legend = FALSE, inherit.aes = FALSE),
    geom_point(data = node, aes(x = x, y = y, size = node_size, color = node_group, alpha = node_alpha), inherit.aes = FALSE)
  )
  if (!is.null(node_highlight)) {
    node_highlight <- node[node[["node_name"]] %in% node_highlight, , drop = FALSE]
    node_layer <- c(
      node_layer,
      list(
        geom_point(data = node_highlight, aes(x = x, y = y, size = node_size * 1.3), color = node_highlight_color, show.legend = FALSE, inherit.aes = FALSE),
        geom_point(data = node_highlight, aes(x = x, y = y, size = node_size, color = node_group, alpha = node_alpha), inherit.aes = FALSE)
      )
    )
  }
  node_layer <- c(node_layer, list(
    scale_color_manual(
      name = node_group, values = palette_scp(node[["node_group"]], palette = node_palette, palcolor = node_palcolor), labels = label_use,
      guide = guide_legend(
        title.hjust = 0,
        order = 1,
        override.aes = list(size = 4, alpha = 1)
      )
    ),
    scale_size,
    scale_alpha
  ))

  if (isTRUE(label)) {
    if (isTRUE(label_insitu)) {
      node[, "label"] <- node[["node_group"]]
    } else {
      node[, "label"] <- as.numeric(node[["node_group"]])
    }
    if (isTRUE(label_repel)) {
      label_layer <- list(geom_point(
        data = node, mapping = aes(x = .data[["x"]], y = .data[["y"]]),
        color = label_point_color, size = label_point_size, inherit.aes = FALSE
      ), geom_text_repel(
        data = node, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]]),
        fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
        point.size = label_point_size, max.overlaps = 100, force = label_repulsion,
        color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE
      ))
    } else {
      label_layer <- list(geom_text_repel(
        data = node, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]]),
        fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
        point.size = NA, max.overlaps = 100, force = 0,
        color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE
      ))
    }
  } else {
    label_layer <- NULL
  }

  lab_layer <- list(labs(title = title, subtitle = subtitle, x = xlab, y = ylab))
  theme_layer <- list(do.call(theme_use, theme_args) +
    theme(
      aspect.ratio = aspect.ratio,
      legend.position = legend.position,
      legend.direction = legend.direction
    ))

  if (isTRUE(return_layer)) {
    return(list(
      edge_layer = edge_layer,
      trans_layer = trans_layer,
      node_layer = node_layer,
      label_layer = label_layer,
      lab_layer = lab_layer,
      theme_layer = theme_layer
    ))
  } else {
    return(ggplot() +
      edge_layer +
      trans_layer +
      node_layer +
      label_layer +
      lab_layer +
      theme_layer)
  }
}

# ---- SCP-plot.R:6666-6683 : segementsDf ----
segementsDf <- function(data, shorten_start, shorten_end, offset) {
  data$dx <- data$xend - data$x
  data$dy <- data$yend - data$y
  data$dist <- sqrt(data$dx^2 + data$dy^2)
  data$px <- data$dx / data$dist
  data$py <- data$dy / data$dist

  data$x <- data$x + data$px * shorten_start
  data$y <- data$y + data$py * shorten_start
  data$xend <- data$xend - data$px * shorten_end
  data$yend <- data$yend - data$py * shorten_end
  data$x <- data$x - data$py * offset
  data$xend <- data$xend - data$py * offset
  data$y <- data$y + data$px * offset
  data$yend <- data$yend + data$px * offset

  return(data)
}

# ---- SCP-plot.R:6745-6945 : VelocityPlot ----
VelocityPlot <- function(srt, reduction, dims = c(1, 2), cells = NULL, velocity = "stochastic", plot_type = c("raw", "grid", "stream"),
                         group_by = NULL, group_palette = "Paired", group_palcolor = NULL,
                         n_neighbors = ceiling(ncol(srt@assays[[1]]) / 50), density = 1, smooth = 0.5, scale = 1, min_mass = 1, cutoff_perc = 5,
                         arrow_angle = 20, arrow_color = "black",
                         streamline_L = 5, streamline_minL = 1, streamline_res = 1, streamline_n = 15,
                         streamline_width = c(0, 0.8), streamline_alpha = 1, streamline_color = NULL, streamline_palette = "RdYlBu", streamline_palcolor = NULL,
                         streamline_bg_color = "white", streamline_bg_stroke = 0.5,
                         aspect.ratio = 1, title = "Cell velocity", subtitle = NULL, xlab = NULL, ylab = NULL,
                         legend.position = "right", legend.direction = "vertical",
                         theme_use = "theme_scp", theme_args = list(),
                         return_layer = FALSE, seed = 11) {
  set.seed(seed)

  plot_type <- match.arg(plot_type)
  check_R("metR")

  if (!reduction %in% names(srt@reductions)) {
    stop(paste0(reduction, " is not in the srt reduction names."))
  }
  V_reduction <- paste0(velocity, "_", reduction)
  if (!V_reduction %in% names(srt@reductions)) {
    stop("Cannot find the velocity embedding ", V_reduction, ".")
  }
  X_emb <- srt@reductions[[reduction]]@cell.embeddings[, dims]
  V_emb <- srt@reductions[[V_reduction]]@cell.embeddings[, dims]
  if (!is.null(cells)) {
    X_emb <- X_emb[intersect(rownames(X_emb), cells), , drop = FALSE]
    V_emb <- V_emb[intersect(rownames(V_emb), cells), , drop = FALSE]
  }

  reduction_key <- srt@reductions[[reduction]]@key
  xlab <- xlab %||% paste0(reduction_key, dims[1])
  ylab <- ylab %||% paste0(reduction_key, dims[2])
  if (identical(theme_use, "theme_blank")) {
    theme_args[["xlab"]] <- xlab
    theme_args[["ylab"]] <- ylab
  }

  if (plot_type == "raw") {
    if (!is.null(density) && (density > 0 && density < 1)) {
      s <- ceiling(density * nrow(X_emb))
      ix_choice <- sample(seq_len(nrow(X_emb)), size = s, replace = FALSE)
      X_emb <- X_emb[ix_choice, ]
      V_emb <- V_emb[ix_choice, ]
    }
    if (!is.null(scale)) {
      V_emb <- V_emb * scale
    }
    df_field <- cbind.data.frame(X_emb, V_emb)
    colnames(df_field) <- c("x", "y", "u", "v")
    df_field[["length"]] <- sqrt(df_field[["u"]]^2 + df_field[["v"]]^2)
    global_size <- sqrt(max(df_field[["x"]], na.rm = TRUE)^2 + max(df_field[["y"]], na.rm = TRUE)^2)
    df_field[["length_perc"]] <- df_field[["length"]] / global_size

    if (!is.null(group_by)) {
      df_field[["group_by"]] <- srt@meta.data[rownames(df_field), group_by, drop = TRUE]
      velocity_layer <- list(
        geom_segment(
          data = df_field, aes(x = x, y = y, xend = x + u, yend = y + v, color = group_by),
          arrow = arrow(length = unit(df_field[["length_perc"]], "npc"), type = "closed", angle = arrow_angle),
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        scale_color_manual(
          name = group_by, values = palette_scp(df_field[["group_by"]], palette = group_palette, palcolor = group_palcolor),
          guide = guide_legend(title.hjust = 0, order = 1, override.aes = list(linewidth = 2, alpha = 1))
        )
      )
    } else {
      velocity_layer <- list(
        geom_segment(
          data = df_field, aes(x = x, y = y, xend = x + u, yend = y + v),
          color = arrow_color,
          arrow = arrow(length = unit(df_field[["length_perc"]], "npc"), type = "closed", angle = arrow_angle),
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        )
      )
    }
  }
  if (plot_type == "grid") {
    res <- compute_velocity_on_grid(X_emb, V_emb,
      density = density, smooth = smooth, n_neighbors = n_neighbors,
      min_mass = min_mass, scale = scale
    )
    X_grid <- res$X_grid
    V_grid <- res$V_grid

    df_field <- cbind.data.frame(X_grid, V_grid)
    colnames(df_field) <- c("x", "y", "u", "v")
    df_field[["length"]] <- sqrt(df_field[["u"]]^2 + df_field[["v"]]^2)
    global_size <- sqrt(max(df_field[["x"]], na.rm = TRUE)^2 + max(df_field[["y"]], na.rm = TRUE)^2)
    df_field[["length_perc"]] <- df_field[["length"]] / global_size
    velocity_layer <- list(
      geom_segment(
        data = df_field, aes(x = x, y = y, xend = x + u, yend = y + v),
        color = arrow_color,
        arrow = arrow(length = unit(df_field[["length_perc"]], "npc"), type = "closed", angle = arrow_angle),
        lineend = "round", linejoin = "mitre", inherit.aes = FALSE
      )
    )
  }
  if (plot_type == "stream") {
    check_R("metR")
    res <- compute_velocity_on_grid(X_emb, V_emb,
      density = density, smooth = smooth, n_neighbors = n_neighbors,
      min_mass = min_mass, scale = 1, cutoff_perc = cutoff_perc,
      adjust_for_stream = TRUE
    )
    X_grid <- res$X_grid
    V_grid <- res$V_grid

    # if (!is.null(density) && (density > 0 & density < 1)) {
    #   s <- ceiling(density * ncol(X_grid))
    #   ix_choice <- sample(1:ncol(X_grid), size = s, replace = FALSE)
    #   X_grid <- X_grid[, ix_choice]
    #   V_grid <- V_grid[, ix_choice, ix_choice]
    # }

    df_field <- expand.grid(X_grid[1, ], X_grid[2, ])
    colnames(df_field) <- c("x", "y")
    u <- melt(t(V_grid[1, , ]))
    v <- melt(t(V_grid[2, , ]))
    df_field[, "u"] <- u$value
    df_field[, "v"] <- v$value
    df_field[is.na(df_field)] <- 0

    if (!is.null(streamline_color)) {
      velocity_layer <- list(
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, size = max(streamline_width, na.rm = TRUE) + streamline_bg_stroke, color = streamline_bg_color, alpha = streamline_alpha,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, size = max(streamline_width, na.rm = TRUE), color = streamline_color, alpha = streamline_alpha,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, linetype = 0, color = arrow_color,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        )
      )
    } else {
      velocity_layer <- list(
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, size = max(streamline_width, na.rm = TRUE) + streamline_bg_stroke, color = streamline_bg_color, alpha = streamline_alpha,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v, size = after_stat(step), color = sqrt(after_stat(dx)^2 + after_stat(dy)^2)),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, alpha = streamline_alpha,
          arrow = NULL, lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        metR::geom_streamline(
          data = df_field, aes(x = x, y = y, dx = u, dy = v),
          L = streamline_L, min.L = streamline_minL, res = streamline_res,
          n = streamline_n, linetype = 0, color = arrow_color,
          arrow.type = "closed", arrow.angle = arrow_angle,
          lineend = "round", linejoin = "mitre", inherit.aes = FALSE
        ),
        scale_color_gradientn(
          name = "Velocity", colors = palette_scp(palette = streamline_palette, palcolor = streamline_palcolor),
          guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0, order = 1)
        ),
        scale_size(range = range(streamline_width), guide = "none")
      )
    }
  }

  lab_layer <- list(labs(title = title, subtitle = subtitle, x = xlab, y = ylab))
  theme_layer <- list(do.call(theme_use, theme_args) + theme(
    aspect.ratio = aspect.ratio,
    legend.position = legend.position,
    legend.direction = legend.direction
  ))

  if (isTRUE(return_layer)) {
    return(list(
      velocity_layer = velocity_layer,
      lab_layer = lab_layer,
      theme_layer = theme_layer
    ))
  } else {
    return(ggplot() +
      velocity_layer +
      lab_layer +
      lab_layer +
      theme_layer)
  }
}

# ---- SCP-plot.R:6963-7039 : compute_velocity_on_grid ----
compute_velocity_on_grid <- function(X_emb, V_emb,
                                     density = NULL, smooth = NULL, n_neighbors = NULL, min_mass = NULL,
                                     scale = 1, adjust_for_stream = FALSE, cutoff_perc = NULL) {
  n_obs <- nrow(X_emb)
  n_dim <- ncol(X_emb)

  density <- density %||% 1
  smooth <- smooth %||% 0.5
  n_neighbors <- n_neighbors %||% ceiling(n_obs / 50)
  min_mass <- min_mass %||% 1
  cutoff_perc <- cutoff_perc %||% 5

  grs <- list()
  for (dim_i in 1:n_dim) {
    m <- min(X_emb[, dim_i], na.rm = TRUE)
    M <- max(X_emb[, dim_i], na.rm = TRUE)
    # m <- m - 0.01 * abs(M - m)
    # M <- M + 0.01 * abs(M - m)
    gr <- seq(m, M, length.out = ceiling(50 * density))
    grs <- c(grs, list(gr))
  }
  X_grid <- as_matrix(expand.grid(grs))

  d <- dist(
    x = as.sparse(X_emb),
    y = as.sparse(X_grid),
    method = "euclidean",
    use_nan = TRUE
  )
  neighbors <- t(as_matrix(apply(d, 2, function(x) order(x, decreasing = FALSE)[1:n_neighbors])))
  dists <- t(as_matrix(apply(d, 2, function(x) x[order(x, decreasing = FALSE)[1:n_neighbors]])))

  # ggplot() +
  #   annotate(geom = "point", x = X_grid[, 1], y = X_grid[, 2]) +
  #   annotate(geom = "point", x = X_grid[1, 1], y = X_grid[1, 2], color = "blue") +
  #   annotate(geom = "point", x = X_grid[neighbors[1, ], 1], y = X_grid[neighbors[1, ], 2], color = "red")

  weight <- dnorm(dists, sd = mean(sapply(grs, function(g) g[2] - g[1])) * smooth)
  p_mass <- p_mass_V <- rowSums(weight)
  p_mass_V[p_mass_V < 1] <- 1

  # qplot(dists[,1],weight[,1])
  # qplot(py$dists[,1],py$weight[,1])

  neighbors_emb <- array(V_emb[neighbors, seq_len(ncol(V_emb))],
    dim = c(dim(neighbors), dim(V_emb)[2])
  )
  V_grid <- apply((neighbors_emb * c(weight)), c(1, 3), sum)
  V_grid <- V_grid / p_mass_V

  # qplot(V_grid[,1],V_grid[,2])
  # qplot(py$V_grid[,1],py$V_grid[,2])

  if (isTRUE(adjust_for_stream)) {
    X_grid <- matrix(c(unique(X_grid[, 1]), unique(X_grid[, 2])), nrow = 2, byrow = TRUE)
    ns <- floor(sqrt(length(V_grid[, 1])))
    V_grid <- reticulate::array_reshape(t(V_grid), c(2, ns, ns))

    mass <- sqrt(apply(V_grid**2, c(2, 3), sum))
    min_mass <- 10**(min_mass - 6) # default min_mass = 1e-5
    min_mass[min_mass > max(mass, na.rm = TRUE) * 0.9] <- max(mass, na.rm = TRUE) * 0.9
    cutoff <- reticulate::array_reshape(mass, dim = c(ns, ns)) < min_mass

    length <- t(apply(apply(abs(neighbors_emb), c(1, 3), mean), 1, sum))
    length <- reticulate::array_reshape(length, dim = c(ns, ns))
    cutoff <- cutoff | length < quantile(length, cutoff_perc / 100)
    V_grid[1, , ][cutoff] <- NA
  } else {
    min_mass <- min_mass * quantile(p_mass, 0.99) / 100
    X_grid <- X_grid[p_mass > min_mass, ]
    V_grid <- V_grid[p_mass > min_mass, ]
    if (!is.null(scale)) {
      V_grid <- V_grid * scale
    }
  }
  return(list(X_grid = X_grid, V_grid = V_grid))
}

# ---- SCP-plot.R:14602-14695 : build_patchwork ----
build_patchwork <- function(x, guides = "auto", BPPARAM = BiocParallel::SerialParam()) {
  x$layout <- modifyList(patchwork:::default_layout, x$layout[!vapply(x$layout, is.null, logical(1))])

  guides <- if (guides == "collect" && x$layout$guides != "keep") {
    "collect"
  } else {
    x$layout$guides
  }
  # bpprogressbar(BPPARAM) <- TRUE
  gt <- bplapply(x$plots, patchwork:::plot_table, guides = guides, BPPARAM = BPPARAM)
  fixed_asp <- vapply(gt, function(x) isTRUE(x$respect), logical(1))
  guide_grobs <- unlist(lapply(gt, `[[`, "collected_guides"), recursive = FALSE)
  gt <- bplapply(gt, patchwork:::simplify_gt, BPPARAM = BPPARAM)
  gt <- patchwork:::add_insets(gt)
  if (is.null(x$layout$design)) {
    if (is.null(x$layout$ncol) && !is.null(x$layout$widths) && length(x$layout$widths) > 1) {
      x$layout$ncol <- length(x$layout$widths)
    }
    if (is.null(x$layout$nrow) && !is.null(x$layout$heights) && length(x$layout$heights) > 1) {
      x$layout$nrow <- length(x$layout$heights)
    }
    dims <- wrap_dims(length(gt), nrow = x$layout$nrow, ncol = x$layout$ncol)
    x$layout$design <- patchwork:::create_design(dims[2], dims[1], x$layout$byrow)
  } else {
    dims <- c(
      max(x$layout$design$b),
      max(x$layout$design$r)
    )
  }

  TABLE_COLS <- patchwork:::TABLE_COLS
  TABLE_ROWS <- patchwork:::TABLE_ROWS
  PANEL_ROW <- patchwork:::PANEL_ROW
  PANEL_COL <- patchwork:::PANEL_COL

  gt_new <- gtable(
    unit(rep(0, TABLE_COLS * dims[2]), "null"),
    unit(rep(0, TABLE_ROWS * dims[1]), "null")
  )
  design <- as.data.frame(unclass(x$layout$design))
  if (nrow(design) < length(gt)) {
    warning("Too few patch areas to hold all plots. Dropping plots", call. = FALSE)
    gt <- gt[seq_len(nrow(design))]
    fixed_asp <- fixed_asp[seq_len(nrow(design))]
  } else {
    design <- design[seq_along(gt), ]
  }
  if (any(design$t < 1)) design$t[design$t < 1] <- 1
  if (any(design$l < 1)) design$l[design$l < 1] <- 1
  if (any(design$b > dims[1])) design$b[design$b > dims[1]] <- dims[1]
  if (any(design$r > dims[2])) design$r[design$r > dims[2]] <- dims[2]
  max_z <- lapply(gt, function(x) max(x$layout$z))
  max_z <- c(0, cumsum(max_z))
  gt_new$layout <- do.call(rbind, lapply(seq_along(gt), function(i) {
    loc <- design[i, ]
    lay <- gt[[i]]$layout
    lay$name <- paste0(lay$name, "-", i)
    lay$t <- lay$t + ifelse(lay$t <= PANEL_ROW, (loc$t - 1) * TABLE_ROWS, (loc$b - 1) * TABLE_ROWS)
    lay$l <- lay$l + ifelse(lay$l <= PANEL_COL, (loc$l - 1) * TABLE_COLS, (loc$r - 1) * TABLE_COLS)
    lay$b <- lay$b + ifelse(lay$b < PANEL_ROW, (loc$t - 1) * TABLE_ROWS, (loc$b - 1) * TABLE_ROWS)
    lay$r <- lay$r + ifelse(lay$r < PANEL_COL, (loc$l - 1) * TABLE_COLS, (loc$r - 1) * TABLE_COLS)
    lay$z <- lay$z + max_z[i]
    lay
  }))
  table_dimensions <- patchwork:::table_dims(
    lapply(gt, `[[`, "widths"),
    lapply(gt, `[[`, "heights"),
    design,
    dims[2],
    dims[1]
  )
  gt_new$grobs <- patchwork:::set_grob_sizes(gt, table_dimensions$widths, table_dimensions$heights, design)
  gt_new$widths <- table_dimensions$widths
  gt_new$heights <- table_dimensions$heights
  widths <- rep(x$layout$widths, length.out = dims[2])
  heights <- rep(x$layout$heights, length.out = dims[1])
  gt_new <- patchwork:::set_panel_dimensions(gt_new, gt, widths, heights, fixed_asp, design)
  if (x$layout$guides == "collect") {
    guide_grobs <- patchwork:::collapse_guides(guide_grobs)
    if (length(guide_grobs) != 0) {
      theme <- x$annotation$theme
      if (!attr(theme, "complete")) {
        theme <- theme_get() + theme
      }
      guide_grobs <- patchwork:::assemble_guides(guide_grobs, theme)
      gt_new <- patchwork:::attach_guides(gt_new, guide_grobs, theme)
    }
  } else {
    gt_new$collected_guides <- guide_grobs
  }

  class(gt_new) <- c("gtable_patchwork", class(gt_new))
  gt_new
}

# ---- SCP-plot.R:14698-14706 : patchworkGrob ----
patchworkGrob <- function(x, BPPARAM = BiocParallel::SerialParam(), ...) {
  annotation <- modifyList(patchwork:::default_annotation, x$patches$annotation[!vapply(x$patches$annotation, is.null, logical(1))])
  x <- patchwork:::recurse_tags(x, annotation$tag_levels, annotation$tag_prefix, annotation$tag_suffix, annotation$tag_sep)$patches
  plot <- patchwork:::get_patches(x)
  gtable <- build_patchwork(plot, BPPARAM = BPPARAM)
  gtable <- patchwork:::annotate_table(gtable, annotation)
  class(gtable) <- setdiff(class(gtable), "gtable_patchwork")
  gtable
}

# ---- SCP-plot.R:14710-14720 : as_grob ----
as_grob <- function(plot, ...) {
  if (inherits(plot, "gList")) {
    grobTree(plot)
  } else if (inherits(plot, "patchwork")) {
    patchworkGrob(plot, ...)
  } else if (inherits(plot, "ggplot")) {
    ggplotGrob(plot)
  } else {
    warning("Cannot convert object of class ", paste0(class(plot), collapse = ","), " into a grob.")
  }
}

# ---- SCP-plot.R:14724-14741 : as_gtable ----
as_gtable <- function(plot, ...) {
  if (inherits(plot, "gtable")) {
    return(plot)
  }
  if (inherits(plot, "grob")) {
    u <- unit(1, "null")
    gt <- gtable_col(NULL, list(plot), u, u)
    gt$layout$clip <- "inherit"
    return(gt)
  } else {
    grob <- as_grob(plot, ...)
    if (inherits(grob, "gtable")) {
      return(grob)
    } else {
      return(as_gtable(grob, ...))
    }
  }
}

# ---- SCP-plot.R:14743-14751 : get_legend ----
get_legend <- function(plot) {
  plot <- as_gtable(plot)
  grob_names <- plot$layout$name
  grobs <- plot$grobs
  grobIndex <- which(grepl("guide-box", grob_names))
  grobIndex <- grobIndex[1]
  matched_grobs <- grobs[[grobIndex]]
  return(matched_grobs)
}

# ---- SCP-plot.R:14755-14794 : add_grob ----
add_grob <- function(gtable, grob, position = c("top", "bottom", "left", "right", "none"), space = NULL, clip = "on") {
  position <- match.arg(position)
  if (position == "none" || is.null(grob)) {
    return(gtable)
  }

  if (is.null(space)) {
    if (is.gtable(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- sum(grob$heights)
      } else {
        space <- sum(grob$widths)
      }
    } else if (is.grob(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- grobHeight(grob)
      } else {
        space <- grobWidth(grob)
      }
    }
  }

  if (position == "top") {
    gtable <- gtable_add_rows(gtable, space, 0)
    gtable <- gtable_add_grob(gtable, grob, t = 1, l = mean(gtable$layout[grepl(pattern = "panel", x = gtable$layout$name), "l"]), clip = clip)
  }
  if (position == "bottom") {
    gtable <- gtable_add_rows(gtable, space, -1)
    gtable <- gtable_add_grob(gtable, grob, t = dim(gtable)[1], l = mean(gtable$layout[grepl(pattern = "panel", x = gtable$layout$name), "l"]), clip = clip)
  }
  if (position == "left") {
    gtable <- gtable_add_cols(gtable, space, 0)
    gtable <- gtable_add_grob(gtable, grob, t = mean(gtable$layout[grep("panel", gtable$layout$name), "t"]), l = 1, clip = clip)
  }
  if (position == "right") {
    gtable <- gtable_add_cols(gtable, space, -1)
    gtable <- gtable_add_grob(gtable, grob, t = mean(gtable$layout[grep("panel", gtable$layout$name), "t"]), l = dim(gtable)[2], clip = clip)
  }
  return(gtable)
}

# ---- SCP-workflow.R:1034-1084 : DefaultReduction ----
DefaultReduction <- function(srt, pattern = NULL, min_dim = 2, max_distance = 0.1) {
  if (length(srt@reductions) == 0) {
    stop("Unable to find any reductions.")
  }
  pattern_default <- c("umap", "tsne", "dm", "phate", "pacmap", "trimap", "largevis", "fr", "pca", "svd", "ica", "nmf", "mds", "glmpca")
  pattern_dim <- c("2D", "3D")
  reduc_all <- names(srt@reductions)
  reduc_all <- reduc_all[unlist(lapply(reduc_all, function(x) {
    dim(srt@reductions[[x]]@cell.embeddings)[2] >= min_dim
  }))]
  if (length(reduc_all) == 0) {
    stop("No dimensional reduction found in the srt object.")
  }
  if (length(reduc_all) == 1) {
    return(reduc_all)
  }
  if (is.null(pattern)) {
    if (("Default_reduction" %in% names(srt@misc))) {
      pattern <- srt@misc[["Default_reduction"]]
    } else {
      pattern <- pattern_default
    }
  }

  pattern <- c(pattern, paste0(pattern, min_dim, "D"))
  if (any(pattern %in% reduc_all)) {
    return(pattern[pattern %in% reduc_all][1])
  }
  index <- c(unlist(sapply(pattern, function(pat) {
    grep(pattern = pat, x = reduc_all, ignore.case = TRUE)
  })))
  if (length(index) > 0) {
    default_reduc <- reduc_all[index]
  } else {
    index <- c(unlist(sapply(pattern, function(pat) {
      agrep(pattern = pat, x = reduc_all, max.distance = max_distance, ignore.case = TRUE)
    })))
    if (length(index) > 0) {
      default_reduc <- reduc_all[index]
    } else {
      default_reduc <- reduc_all
    }
  }
  if (length(default_reduc) > 1) {
    default_reduc <- default_reduc[unlist(sapply(c(pattern_default, pattern_dim), function(pat) {
      grep(pattern = pat, x = default_reduc, ignore.case = TRUE)
    }))]
    default_reduc <- default_reduc[which.min(sapply(default_reduc, function(x) dim(srt@reductions[[x]])[2]))]
  }
  return(default_reduc)
}

# ---- utils.R:558-617 : check_R ----
check_R <- function(packages, install_methods = c("BiocManager::install", "install.packages", "devtools::install_github"), lib = .libPaths()[1], force = FALSE) {
  status_list <- list()
  for (pkg in packages) {
    version <- NULL
    if (grepl("/", pkg)) {
      # github package
      pkg_name <- strsplit(pkg, split = "/|@|==", perl = TRUE)[[1]][[2]]
    } else {
      pkg_name <- strsplit(pkg, split = "@|==", perl = TRUE)[[1]][[1]]
      if (length(strsplit(pkg, split = "@|==", perl = TRUE)[[1]]) > 1) {
        version <- strsplit(pkg, split = "@|==", perl = TRUE)[[1]][[2]]
      }
    }
    dest <- gsub("@.*|==.*|>=.*", "", pkg)
    if (is.null(version)) {
      force_update <- isTRUE(force)
    } else {
      force_update <- isTRUE(packageVersion(pkg_name) < package_version(version)) || isTRUE(force)
    }
    if (!suppressPackageStartupMessages(requireNamespace(pkg_name, quietly = TRUE)) || isTRUE(force_update)) {
      message("Install package: \"", pkg_name, "\" ...")
      status_list[[pkg]] <- FALSE
      i <- 1
      while (isFALSE(status_list[[pkg]])) {
        tryCatch(expr = {
          if (grepl("BiocManager", install_methods[i])) {
            if (!requireNamespace("BiocManager", quietly = TRUE)) {
              install.packages("BiocManager", lib = lib)
            }
            eval(str2lang(paste0(install_methods[i], "(\"", dest, "\", lib=\"", lib, "\", update = FALSE, upgrade = \"never\", ask = FALSE, force = TRUE)")))
          } else if (grepl("devtools", install_methods[i])) {
            if (!requireNamespace("devtools", quietly = TRUE)) {
              install.packages("devtools", lib = lib)
            }
            if (!requireNamespace("withr", quietly = TRUE)) {
              install.packages("withr", lib = lib)
            }
            eval(str2lang(paste0("withr::with_libpaths(new = \"", lib, "\", ", install_methods[i], "(\"", dest, "\", upgrade = \"never\", force = TRUE))")))
          } else {
            eval(str2lang(paste0(install_methods[i], "(\"", dest, "\", lib=\"", lib, "\", force = TRUE)")))
          }
        }, error = function(e) {
          status_list[[pkg]] <- FALSE
        })
        status_list[[pkg]] <- requireNamespace(pkg_name, quietly = TRUE)
        i <- i + 1
        if (i > length(install_methods)) {
          break
        }
      }
    } else {
      status_list[[pkg]] <- TRUE
    }
  }
  out <- sapply(status_list, isTRUE)
  out <- out[!out]
  if (length(out) > 0) {
    stop("Failed to install the package(s): ", paste0(names(out), collapse = ","), ". Please install manually.")
  }
}

# ---- utils.R:755-758 : col2hex ----
col2hex <- function(cname) {
  colMat <- col2rgb(cname)
  rgb(red = colMat[1, ] / 255, green = colMat[2, ] / 255, blue = colMat[3, ] / 255)
}

# ---- utils.R:831-841 : as_matrix ----
as_matrix <- function(x) {
  if (!inherits(matrix, "dgCMatrix")) {
    return(as.matrix(x))
  } else {
    row_pos <- x@i
    col_pos <- findInterval(seq_along(x@x) - 1, x@p[-1])
    out <- asMatrix(rp = row_pos, cp = col_pos, z = x@x, nrows = x@Dim[1], ncols = x@Dim[2])
    attr(out, "dimnames") <- list(x@Dimnames[[1]], x@Dimnames[[2]])
    return(out)
  }
}

# ---- utils.R:852-870 : capitalize ----
capitalize <- function(x, force_tolower = FALSE) {
  if (is.null(x)) {
    return(NULL)
  }
  if (inherits(x, "factor")) {
    x <- as.character(x)
  }
  if (!inherits(x, "character")) {
    stop("x must be the type of character.")
  }
  if (isTRUE(force_tolower)) {
    x <- paste(toupper(substr(x, 1, 1)), tolower(substr(x, 2, nchar(x))), sep = "")
  } else {
    first_word <- sapply(strsplit(x, "\\s|-"), function(s) s[1])
    index <- which(first_word == tolower(first_word))
    x[index] <- paste(toupper(substr(x[index], 1, 1)), substr(x[index], 2, nchar(x[index])), sep = "")
  }
  return(x)
}

