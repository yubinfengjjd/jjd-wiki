# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:2042-2815
# sha256(func-block)=37d172936c5f8be7798f4e09e7398b3d417cf4b374db1ac7595e53a29aad21a4
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
FeatureDimPlot <- function(srt, features, reduction = NULL, dims = c(1, 2), split.by = NULL, cells = NULL, slot = "data", assay = NULL,
                           show_stat = ifelse(identical(theme_use, "theme_blank"), FALSE, TRUE),
                           palette = ifelse(isTRUE(compare_features), "Set1", "Spectral"), palcolor = NULL,
                           pt.size = NULL, pt.alpha = 1, bg_cutoff = 0, bg_color = "grey80",
                           keep_scale = "feature", lower_quantile = 0, upper_quantile = 0.99, lower_cutoff = NULL, upper_cutoff = NULL,
                           add_density = FALSE, density_color = "grey80", density_filled = FALSE, density_filled_palette = "Greys", density_filled_palcolor = NULL,
                           cells.highlight = NULL, cols.highlight = "black", sizes.highlight = 1, alpha.highlight = 1, stroke.highlight = 0.5,
                           calculate_coexp = FALSE, compare_features = FALSE, color_blend_mode = c("blend", "average", "screen", "multiply"),
                           label = FALSE, label.size = 4, label.fg = "white", label.bg = "black", label.bg.r = 0.1,
                           label_insitu = FALSE, label_repel = FALSE, label_repulsion = 20,
                           label_point_size = 1, label_point_color = "black", label_segment_color = "black",
                           lineages = NULL, lineages_trim = c(0.01, 0.99), lineages_span = 0.75,
                           lineages_palette = "Dark2", lineages_palcolor = NULL, lineages_arrow = arrow(length = unit(0.1, "inches")),
                           lineages_linewidth = 1, lineages_line_bg = "white", lineages_line_bg_stroke = 0.5,
                           lineages_whiskers = FALSE, lineages_whiskers_linewidth = 0.5, lineages_whiskers_alpha = 0.5,
                           graph = NULL, edge_size = c(0.05, 0.5), edge_alpha = 0.1, edge_color = "grey40",
                           hex = FALSE, hex.linewidth = 0.5, hex.color = "grey90", hex.bins = 50, hex.binwidth = NULL,
                           raster = NULL, raster.dpi = c(512, 512),
                           aspect.ratio = 1, title = NULL, subtitle = NULL, xlab = NULL, ylab = NULL,
                           legend.position = "right", legend.direction = "vertical",
                           theme_use = "theme_scp", theme_args = list(),
                           combine = TRUE, nrow = NULL, ncol = NULL, byrow = TRUE, force = FALSE, seed = 11) {
  set.seed(seed)
  color_blend_mode <- match.arg(color_blend_mode)
  if (!is.null(keep_scale)) {
    keep_scale <- match.arg(keep_scale, choices = c("feature", "all"))
  }

  if (is.list(features)) {
    if (is.null(names(features))) {
      features <- unlist(features)
    } else {
      features <- setNames(unlist(features), nm = rep(names(features), sapply(features, length)))
    }
  }
  if (!inherits(features, "character")) {
    stop("'features' is not a character vectors")
  }

  assay <- assay %||% DefaultAssay(srt)
  if (is.null(split.by)) {
    split.by <- "All.groups"
    srt@meta.data[[split.by]] <- factor("")
  }
  for (i in c(split.by)) {
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

  feature_input <- features
  features <- unique(features)
  embeddings <- lapply(srt@reductions, function(x) colnames(x@cell.embeddings))
  embeddings <- setNames(rep(names(embeddings), sapply(embeddings, length)), nm = unlist(embeddings))
  features_drop <- features[!features %in% c(rownames(srt@assays[[assay]]), colnames(srt@meta.data), names(embeddings))]
  if (length(features_drop) > 0) {
    warning(paste0(features_drop, collapse = ","), " are not in the features of srt.", immediate. = TRUE)
    features <- features[!features %in% features_drop]
  }

  features_gene <- features[features %in% rownames(srt@assays[[assay]])]
  features_meta <- features[features %in% colnames(srt@meta.data)]
  features_embedding <- features[features %in% names(embeddings)]
  if (length(intersect(features_gene, features_meta)) > 0) {
    warning("Features appear in both gene names and metadata names: ", paste0(intersect(features_gene, features_meta), collapse = ","))
  }
  if (length(c(features_gene, features_meta, features_embedding)) == 0) {
    stop("There are no valid features present.")
  }

  if (isTRUE(calculate_coexp) && length(features_gene) > 0) {
    if (length(features_meta) > 0) {
      warning(paste(features_meta, collapse = ","), "is not used when calculating co-expression", immediate. = TRUE)
    }
    status <- check_DataType(srt, slot = slot, assay = assay)
    message("Data type detected in ", slot, " slot: ", status)
    if (status %in% c("raw_counts", "raw_normalized_counts")) {
      srt@meta.data[["CoExp"]] <- apply(slot(srt@assays[[assay]], slot)[features_gene, , drop = FALSE], 2, function(x) exp(mean(log(x))))
    } else if (status == "log_normalized_counts") {
      srt@meta.data[["CoExp"]] <- apply(expm1(slot(srt@assays[[assay]], slot)[features_gene, , drop = FALSE]), 2, function(x) log1p(exp(mean(log(x)))))
    } else {
      stop("Can not determine the data type.")
    }
    features <- c(features, "CoExp")
    features_meta <- c(features_meta, "CoExp")
  }

  if (length(features_gene) > 0) {
    if (all(rownames(srt@assays[[assay]]) %in% features_gene)) {
      dat_gene <- t(as_matrix(slot(srt@assays[[assay]], slot)))
    } else {
      dat_gene <- t(as_matrix(slot(srt@assays[[assay]], slot)[features_gene, , drop = FALSE]))
    }
  } else {
    dat_gene <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  if (length(features_meta) > 0) {
    dat_meta <- as_matrix(srt@meta.data[, features_meta, drop = FALSE])
  } else {
    dat_meta <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  if (length(features_embedding) > 0) {
    dat_embedding <- as_matrix(FetchData(srt, vars = features_embedding))
  } else {
    dat_embedding <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  dat_exp <- as_matrix(do.call(cbind, list(dat_gene, dat_meta, dat_embedding)))
  features <- unique(features[features %in% c(features_gene, features_meta, features_embedding)])

  if (!is.numeric(dat_exp) && !inherits(dat_exp, "Matrix")) {
    stop("'features' must be type of numeric variable.")
  }
  dat_exp[, features][dat_exp[, features] <= bg_cutoff] <- NA

  if (length(features) > 50 && !isTRUE(force)) {
    warning("More than 50 features to be plotted", immediate. = TRUE)
    answer <- askYesNo("Are you sure to continue?", default = FALSE)
    if (!isTRUE(answer)) {
      return(invisible(NULL))
    }
  }

  if (is.null(subtitle)) {
    if (!is.null(names(feature_input))) {
      subtitle <- setNames(names(feature_input), nm = feature_input)
    }
  } else {
    if (length(subtitle) == 1) {
      subtitle <- setNames(rep(subtitle, length(features)), nm = features)
    } else if (length(subtitle) == length(features)) {
      subtitle <- setNames(subtitle, nm = features)
    } else {
      stop(paste0("Subtitle length must be 1 or length of features(", length(features), ")"))
    }
  }

  reduction_key <- srt@reductions[[reduction]]@key
  dat_dim <- srt@reductions[[reduction]]@cell.embeddings
  colnames(dat_dim) <- paste0(reduction_key, seq_len(ncol(dat_dim)))
  rownames(dat_dim) <- rownames(dat_dim) %||% colnames(srt@assays[[1]])
  dat_sp <- srt@meta.data[, split.by, drop = FALSE]
  dat_use <- cbind(dat_dim, dat_sp[row.names(dat_dim), , drop = FALSE])
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

  if (!is.null(lineages)) {
    lineages_layers <- LineagePlot(srt,
      lineages = lineages, reduction = reduction, dims = dims,
      trim = lineages_trim, span = lineages_span,
      palette = lineages_palette, palcolor = lineages_palcolor, lineages_arrow = lineages_arrow,
      linewidth = lineages_linewidth, line_bg = lineages_line_bg, line_bg_stroke = lineages_line_bg_stroke,
      whiskers = lineages_whiskers, whiskers_linewidth = lineages_whiskers_linewidth, whiskers_alpha = lineages_whiskers_alpha,
      aspect.ratio = aspect.ratio, xlab = xlab, ylab = ylab,
      legend.position = legend.position, legend.direction = legend.direction,
      theme_use = theme_use, theme_args = theme_args,
      return_layer = TRUE
    )
    lineages_layers <- lineages_layers[!names(lineages_layers) %in% c("lab_layer", "theme_layer")]
  }

  plist <- list()
  xlab <- xlab %||% paste0(reduction_key, dims[1])
  ylab <- ylab %||% paste0(reduction_key, dims[2])
  if (identical(theme_use, "theme_blank")) {
    theme_args[["xlab"]] <- xlab
    theme_args[["ylab"]] <- ylab
  }

  if (isTRUE(compare_features) && length(features) > 1) {
    dat_all <- cbind(dat_use, dat_exp[row.names(dat_use), features, drop = FALSE])
    dat_split <- split.data.frame(dat_all, dat_all[[split.by]])
    plist <- lapply(levels(dat_sp[[split.by]]), function(s) {
      dat <- dat_split[[ifelse(split.by == "All.groups", 1, s)]][, , drop = FALSE]
      for (f in features) {
        if (any(is.infinite(dat[, f]))) {
          dat[, f][which(dat[, f] == max(dat[, f], na.rm = TRUE))] <- max(dat[, f][is.finite(dat[, f])], na.rm = TRUE)
          dat[, f][which(dat[, f] == min(dat[, f], na.rm = TRUE))] <- min(dat[, f][is.finite(dat[, f])], na.rm = TRUE)
        }
      }
      dat[["x"]] <- dat[[paste0(reduction_key, dims[1])]]
      dat[["y"]] <- dat[[paste0(reduction_key, dims[2])]]
      dat[, "split.by"] <- s
      dat[, "features"] <- paste(features, collapse = "|")
      subtitle_use <- paste0(subtitle, collapse = "|") %||% s
      colors <- palette_scp(features, type = "discrete", palette = palette, palcolor = palcolor)
      colors_list <- list()
      value_list <- list()
      pal_list <- list()
      temp_geom <- list()
      legend_list <- list()
      for (i in seq_along(colors)) {
        colors_list[[i]] <- palette_scp(dat[, names(colors)[i]], type = "continuous", NA_color = NA, NA_keep = TRUE, matched = TRUE, palcolor = c(adjcolors(colors[i], 0.1), colors[i]))
        pal_list[[i]] <- palette_scp(dat[, names(colors)[i]], type = "continuous", NA_color = NA, NA_keep = FALSE, matched = FALSE, palcolor = c(adjcolors(colors[i], 0.1), colors[i]))
        value_list[[i]] <- seq(min(dat[, names(colors)[i]], na.rm = TRUE), max(dat[, names(colors)[i]], na.rm = TRUE), length.out = 100)
        temp_geom[[i]] <- list(
          geom_point(data = dat, mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[[names(colors)[i]]]))
        )
        if (all(is.na(colors_list[[i]]))) {
          temp_geom[[i]] <- append(temp_geom[[i]], scale_colour_gradient(
            na.value = bg_color,
            guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0)
          ))
        } else if (length(colors_list[[i]]) == 1) {
          temp_geom[[i]] <- append(temp_geom[[i]], scale_colour_gradient(
            low = colors_list[[i]], na.value = bg_color,
            guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0)
          ))
        } else {
          temp_geom[[i]] <- append(temp_geom[[i]], scale_color_gradientn(
            colours = pal_list[[i]],
            values = rescale(value_list[[i]]), na.value = bg_color,
            guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0)
          ))
        }
        legend_list[[i]] <- get_legend(
          ggplot(dat, aes(x = .data[["x"]], y = .data[["y"]])) +
            temp_geom[[i]] +
            do.call(theme_use, theme_args) +
            theme(
              aspect.ratio = aspect.ratio,
              legend.position = legend.position,
              legend.direction = legend.direction
            )
        )
      }
      for (j in seq_len(nrow(dat))) {
        dat[j, "color_blend"] <- blendcolors(sapply(colors_list, function(x) x[j]), mode = color_blend_mode)
      }
      dat["color_value"] <- colSums(col2rgb(dat[, "color_blend"]))
      dat[rowSums(is.na(dat[, names(colors)])) == length(colors), "color_value"] <- NA
      dat <- dat[order(dat[, "color_value"], decreasing = TRUE, na.last = FALSE), , drop = FALSE]
      dat[rowSums(is.na(dat[, names(colors)])) == length(colors), "color_blend"] <- bg_color
      cells.highlight_use <- cells.highlight
      if (isTRUE(cells.highlight_use)) {
        cells.highlight_use <- rownames(dat)[dat[["color_blend"]] != bg_color]
      }
      if (!is.null(graph)) {
        net_mat <- as_matrix(graph)[rownames(dat), rownames(dat)]
        net_mat[net_mat == 0] <- NA
        net_mat[upper.tri(net_mat)] <- NA
        net_df <- melt(net_mat, na.rm = TRUE, stringsAsFactors = FALSE)
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
            color = density_color,
            inherit.aes = FALSE
          )
        }
      } else {
        density <- NULL
      }
      p <- ggplot(dat) +
        net +
        density +
        labs(title = title, subtitle = subtitle_use, x = xlab, y = ylab) +
        scale_x_continuous(limits = c(min(dat_use[, paste0(reduction_key, dims[1])], na.rm = TRUE), max(dat_use[, paste0(reduction_key, dims[1])], na.rm = TRUE))) +
        scale_y_continuous(limits = c(min(dat_use[, paste0(reduction_key, dims[2])], na.rm = TRUE), max(dat_use[, paste0(reduction_key, dims[2])], na.rm = TRUE)))
      if (split.by == "All.groups") {
        p <- p + facet_grid(. ~ features)
      } else {
        p <- p + facet_grid(split.by ~ features)
      }
      p <- p + do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          legend.position = "none",
          legend.direction = legend.direction
        )
      if (isTRUE(raster)) {
        p <- p + scattermore::geom_scattermore(
          data = dat[dat[, "color_blend"] == bg_color, , drop = FALSE],
          mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["color_blend"]]),
          pointsize = ceiling(pt.size), alpha = pt.alpha, pixels = raster.dpi
        ) +
          scattermore::geom_scattermore(
            data = dat[dat[, "color_blend"] != bg_color, , drop = FALSE],
            mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["color_blend"]]),
            pointsize = ceiling(pt.size), alpha = pt.alpha, pixels = raster.dpi
          ) +
          scale_color_identity() +
          new_scale_color()
      } else {
        p <- p + geom_point(
          mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["color_blend"]]),
          size = pt.size, alpha = pt.alpha
        ) +
          scale_color_identity() +
          new_scale_color()
      }

      if (!is.null(cells.highlight_use)) {
        cell_df <- subset(p$data, rownames(p$data) %in% cells.highlight_use)
        if (nrow(cell_df) > 0) {
          if (isTRUE(raster)) {
            p <- p + scattermore::geom_scattermore(
              data = cell_df, aes(x = .data[["x"]], y = .data[["y"]]), color = cols.highlight,
              pointsize = floor(sizes.highlight) + stroke.highlight, alpha = alpha.highlight, pixels = raster.dpi
            ) +
              scattermore::geom_scattermore(
                data = cell_df, aes(x = .data[["x"]], y = .data[["y"]], color = .data[["color_blend"]]),
                pointsize = floor(sizes.highlight), alpha = alpha.highlight, pixels = raster.dpi
              ) +
              scale_color_identity() +
              new_scale_color()
          } else {
            p <- p +
              geom_point(
                data = cell_df, aes(x = .data[["x"]], y = .data[["y"]]), color = cols.highlight,
                size = sizes.highlight + stroke.highlight, alpha = alpha.highlight
              ) +
              geom_point(
                data = cell_df, aes(x = .data[["x"]], y = .data[["y"]], color = .data[["color_blend"]]),
                size = sizes.highlight, alpha = alpha.highlight
              ) +
              scale_color_identity() +
              new_scale_color()
          }
        }
      }

      legend2 <- NULL
      if (isTRUE(label)) {
        label_df <- melt(p$data, measure.vars = features)
        label_df <- label_df %>%
          group_by(variable) %>%
          filter(value >= quantile(value[is.finite(value)], 0.95, na.rm = TRUE) & value <= quantile(value[is.finite(value)], 0.99, na.rm = TRUE)) %>%
          reframe(x = median(.data[["x"]]), y = median(.data[["y"]])) %>%
          as.data.frame()
        colnames(label_df)[1] <- "label"
        label_df <- label_df[!is.na(label_df[, "label"]), , drop = FALSE]
        label_df[, "rank"] <- seq_len(nrow(label_df))
        if (isTRUE(label_insitu)) {
          if (isTRUE(label_repel)) {
            p <- p + geom_point(
              data = label_df, mapping = aes(x = .data[["x"]], y = .data[["y"]]),
              color = label_point_color, size = label_point_size
            ) + geom_text_repel(
              data = label_df, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]], color = .data[["label"]]),
              fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
              point.size = label_point_size, max.overlaps = 100, force = label_repulsion,
              color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE, show.legend = FALSE
            )
          } else {
            p <- p + geom_text_repel(
              data = label_df, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["label"]], color = .data[["label"]]),
              fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
              point.size = NA, max.overlaps = 100, force = 0,
              color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE, show.legend = FALSE
            )
          }
          p <- p + scale_color_manual(
            name = "Label:",
            values = adjcolors(colors[label_df$label], 0.5),
            labels = label_df$label,
            na.value = bg_color
          )
        } else {
          if (isTRUE(label_repel)) {
            p <- p + geom_point(
              data = label_df, mapping = aes(x = .data[["x"]], y = .data[["y"]]),
              color = "black", size = pt.size + 1
            ) +
              geom_text_repel(
                data = label_df, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["rank"]], color = .data[["label"]]),
                fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
                point.size = pt.size + 1, max.overlaps = 100, force = label_repulsion,
                bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE, key_glyph = "point"
              )
          } else {
            p <- p + geom_text_repel(
              data = label_df, aes(x = .data[["x"]], y = .data[["y"]], label = .data[["rank"]], color = .data[["label"]]),
              fontface = "bold", min.segment.length = 0, segment.colour = label_segment_color,
              point.size = NA, max.overlaps = 100, force = 0,
              bg.color = label.bg, bg.r = label.bg.r, size = label.size, inherit.aes = FALSE, key_glyph = "point"
            )
          }
          p <- p + scale_color_manual(
            name = "Label:",
            values = adjcolors(colors[label_df$label], 0.5),
            labels = paste(label_df$rank, label_df$label, sep = ": "),
            na.value = bg_color
          ) +
            guides(colour = guide_legend(override.aes = list(color = colors[label_df$label]), order = 1)) +
            theme(legend.position = "none")
          legend2 <- get_legend(p +
            do.call(theme_use, theme_args) +
            theme(
              aspect.ratio = aspect.ratio,
              legend.position = legend.position,
              legend.direction = legend.direction
            ))
        }
      }

      legend_nrow <- min(ceiling(sqrt(length(legend_list))), 3)
      total <- length(legend_list)
      leg_list <- list()
      n <- 1
      for (i in 1:total) {
        if (i == 1 || is.null(leg)) {
          leg <- legend_list[[i]]
        } else {
          leg <- cbind(leg, legend_list[[i]])
        }
        if (i %% legend_nrow == 0) {
          leg_list[[n]] <- leg
          leg <- NULL
          n <- n + 1
        }
        if (i %% legend_nrow != 0 && i == total) {
          ncol_insert <- dim(leg_list[[n - 1]])[2] - dim(leg)[2]
          for (col_insert in 1:ncol_insert) {
            leg <- gtable_add_cols(leg, sum(leg_list[[n - 1]]$widths) / ncol_insert, -1)
          }
          leg_list[[n]] <- leg
        }
      }
      legend <- do.call(rbind, leg_list)
      if (!is.null(lineages)) {
        lineages_layers <- c(list(new_scale_color()), lineages_layers)
        suppressMessages({
          legend_curve <- get_legend(ggplot() +
            lineages_layers +
            theme_scp())
        })
        legend <- add_grob(legend, legend_curve, "top")
        p <- suppressMessages({
          p + lineages_layers + theme(legend.position = "none")
        })
      }

      gtable <- as_grob(p)
      gtable <- add_grob(gtable, legend, legend.position)
      if (!is.null(legend2)) {
        gtable <- add_grob(gtable, legend2, legend.position)
      }
      p <- wrap_plots(gtable)
      return(p)
    })
    names(plist) <- paste0(levels(dat_sp[[split.by]]), ":", paste0(features, collapse = "|"))
  } else {
    comb <- expand.grid(split = levels(dat_sp[[split.by]]), feature = features, stringsAsFactors = FALSE)
    rownames(comb) <- paste0(comb[["split"]], ":", comb[["feature"]])
    dat_all <- cbind(dat_use, dat_exp[row.names(dat_use), features, drop = FALSE])
    dat_split <- split.data.frame(dat_all, dat_all[[split.by]])
    colors <- palette_scp(type = "continuous", palette = palette, palcolor = palcolor)
    plist <- lapply(setNames(rownames(comb), rownames(comb)), function(i) {
      f <- comb[i, "feature"]
      s <- comb[i, "split"]
      dat <- dat_split[[ifelse(split.by == "All.groups", 1, s)]][, c(colnames(dat_use), f), drop = FALSE]
      if (any(is.infinite(dat[, f]))) {
        dat[, f][dat[, f] == max(dat[, f], na.rm = TRUE)] <- max(dat[, f][is.finite(dat[, f])], na.rm = TRUE)
        dat[, f][dat[, f] == min(dat[, f], na.rm = TRUE)] <- min(dat[, f][is.finite(dat[, f])], na.rm = TRUE)
      }
      dat[["x"]] <- dat[[paste0(reduction_key, dims[1])]]
      dat[["y"]] <- dat[[paste0(reduction_key, dims[2])]]
      dat[["value"]] <- dat[[f]]
      dat <- dat[order(dat[, "value"], method = "radix", decreasing = FALSE, na.last = FALSE), , drop = FALSE]
      dat[, "features"] <- f
      cells.highlight_use <- cells.highlight
      if (isTRUE(cells.highlight_use)) {
        cells.highlight_use <- rownames(dat)[!is.na(dat[["value"]])]
      }
      legend_list <- list()
      if (isTRUE(show_stat)) {
        subtitle_use <- subtitle[f] %||% paste0(s, " nPos:", sum(dat[["value"]] > 0, na.rm = TRUE), ", ", round(sum(dat[["value"]] > 0, na.rm = TRUE) / nrow(dat) * 100, 2), "%")
      } else {
        subtitle_use <- subtitle[f]
      }
      if (all(is.na(dat[["value"]]))) {
        colors_value <- rep(0, 100)
      } else {
        if (is.null(keep_scale)) {
          colors_value <- seq(lower_cutoff %||% quantile(dat[is.finite(dat[, "value"]), "value"], lower_quantile, na.rm = TRUE), upper_cutoff %||% quantile(dat[is.finite(dat[, "value"]), "value"], upper_quantile, na.rm = TRUE) + 0.001, length.out = 100)
        } else {
          if (keep_scale == "feature") {
            colors_value <- seq(lower_cutoff %||% quantile(dat_exp[is.finite(dat_exp[, f]), f], lower_quantile, na.rm = TRUE), upper_cutoff %||% quantile(dat_exp[is.finite(dat_exp[, f]), f], upper_quantile, na.rm = TRUE) + 0.001, length.out = 100)
          }
          if (keep_scale == "all") {
            all_values <- as_matrix(dat_exp[, features])
            colors_value <- seq(lower_cutoff %||% quantile(all_values[is.finite(all_values)], lower_quantile, na.rm = TRUE), upper_cutoff %||% quantile(all_values, upper_quantile, na.rm = TRUE) + 0.001, length.out = 100)
          }
        }
      }
      dat[which(dat[, "value"] > max(colors_value, na.rm = TRUE)), "value"] <- max(colors_value, na.rm = TRUE)
      dat[which(dat[, "value"] < min(colors_value, na.rm = TRUE)), "value"] <- min(colors_value, na.rm = TRUE)
      if (!is.null(graph)) {
        net_mat <- as_matrix(graph)[rownames(dat), rownames(dat)]
        net_mat[net_mat == 0] <- NA
        net_mat[upper.tri(net_mat)] <- NA
        net_df <- melt(net_mat, na.rm = TRUE, stringsAsFactors = FALSE)
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
            color = density_color,
            inherit.aes = FALSE
          )
        }
      } else {
        density <- NULL
      }
      p <- ggplot(dat) +
        net +
        density +
        labs(title = title, subtitle = subtitle_use, x = xlab, y = ylab) +
        scale_x_continuous(limits = c(min(dat_use[, paste0(reduction_key, dims[1])], na.rm = TRUE), max(dat_use[, paste0(reduction_key, dims[1])], na.rm = TRUE))) +
        scale_y_continuous(limits = c(min(dat_use[, paste0(reduction_key, dims[2])], na.rm = TRUE), max(dat_use[, paste0(reduction_key, dims[2])], na.rm = TRUE))) +
        do.call(theme_use, theme_args) +
        theme(
          aspect.ratio = aspect.ratio,
          legend.position = legend.position,
          legend.direction = legend.direction
        )
      if (isTRUE(raster)) {
        p <- p + scattermore::geom_scattermore(
          data = dat[is.na(dat[, "value"]), , drop = FALSE],
          mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["value"]]),
          pointsize = ceiling(pt.size), alpha = pt.alpha, pixels = raster.dpi
        ) +
          scattermore::geom_scattermore(
            data = dat[!is.na(dat[, "value"]), , drop = FALSE],
            mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["value"]]),
            pointsize = ceiling(pt.size), alpha = pt.alpha, pixels = raster.dpi
          )
      } else if (isTRUE(hex)) {
        check_R("hexbin")
        dat_na <- dat[is.na(dat[["value"]]), , drop = FALSE]
        dat_hex <- dat[!is.na(dat[["value"]]), , drop = FALSE]
        if (nrow(dat_na) > 0) {
          p <- p + geom_hex(
            data = dat[is.na(dat[["value"]]), , drop = FALSE],
            mapping = aes(x = .data[["x"]], y = .data[["y"]]),
            fill = bg_color, color = hex.color,
            linewidth = hex.linewidth, bins = hex.bins, binwidth = hex.binwidth
          )
        }
        if (nrow(dat_hex) > 0) {
          p <- p + stat_summary_hex(
            data = dat_hex,
            mapping = aes(x = .data[["x"]], y = .data[["y"]], z = .data[["value"]]),
            color = hex.color, linewidth = hex.linewidth, bins = hex.bins, binwidth = hex.binwidth
          )
          if (all(is.na(dat[["value"]]))) {
            p <- p + scale_fill_gradient(
              name = "", na.value = bg_color
            )
          } else {
            p <- p + scale_fill_gradientn(
              name = "", colours = colors, values = rescale(colors_value), limits = range(colors_value), na.value = bg_color
            )
          }
          p <- p + new_scale_fill()
        }
      } else {
        p <- p + geom_point(
          mapping = aes(x = .data[["x"]], y = .data[["y"]], color = .data[["value"]]),
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
                data = cell_df, aes(x = .data[["x"]], y = .data[["y"]], color = .data[["value"]]),
                pointsize = floor(sizes.highlight), alpha = alpha.highlight, pixels = raster.dpi
              )
          } else {
            p <- p +
              geom_point(
                data = cell_df, aes(x = .data[["x"]], y = .data[["y"]]), color = cols.highlight,
                size = sizes.highlight + stroke.highlight, alpha = alpha.highlight
              ) +
              geom_point(
                data = cell_df, aes(x = .data[["x"]], y = .data[["y"]], color = .data[["value"]]),
                size = sizes.highlight, alpha = alpha.highlight
              )
          }
        }
      }
      if (nrow(dat) > 0) {
        if (split.by == "All.groups") {
          p <- p + facet_grid(. ~ features)
        } else {
          p <- p + facet_grid(formula(paste0(split.by, "~features")))
        }
      }
      if (all(is.na(dat[["value"]]))) {
        p <- p + scale_colour_gradient(
          name = "", na.value = bg_color, aesthetics = c("color")
        )
      } else {
        p <- p + scale_color_gradientn(
          name = "", colours = colors, values = rescale(colors_value), limits = range(colors_value), na.value = bg_color, aesthetics = c("color")
        )
      }
      p <- p + guides(
        color = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0, order = 1)
      )
      p_base <- p

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
      if (isTRUE(label)) {
        label_df <- p$data %>%
          filter(value >= quantile(value[is.finite(value)], 0.95, na.rm = TRUE) & value <= quantile(value[is.finite(value)], 0.99, na.rm = TRUE)) %>%
          reframe(x = median(.data[["x"]]), y = median(.data[["y"]])) %>%
          as.data.frame()
        label_df[, "label"] <- f
        label_df[, "rank"] <- seq_len(nrow(label_df))
        if (isTRUE(label_repel)) {
          p <- p + annotate(
            geom = "point", x = label_df[["x"]], y = label_df[["y"]],
            color = "black", size = pt.size + 1
          ) + annotate(
            geom = GeomTextRepel, x = label_df[["x"]], y = label_df[["y"]], label = label_df[["label"]],
            fontface = "bold", min.segment.length = 0, segment.color = label_segment_color,
            point.size = pt.size + 1, max.overlaps = 100, force = label_repulsion,
            color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size
          )
        } else {
          p <- p + annotate(
            geom = GeomTextRepel, x = label_df[["x"]], y = label_df[["y"]], label = label_df[["label"]],
            fontface = "bold",
            point.size = NA, max.overlaps = 100, force = 0,
            color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size
          )
        }
      }
      if (length(legend_list) > 0) {
        legend_list <- legend_list[!sapply(legend_list, is.null)]
        legend_base <- get_legend(p_base)
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
  }

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
