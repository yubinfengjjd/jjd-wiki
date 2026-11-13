# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:1328-1851
# sha256(func-block)=df09f87078e661756e237a1960d7444728b71c94b355f07a41f1f1246e1ec0ba
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
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
