# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:3524-3718
# sha256(func-block)=e7e4ee7a9f7ee8f95b2c57b827de54d258701869499ea7897ac385c114168120
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
FeatureStatPlot <- function(srt, stat.by, group.by = NULL, split.by = NULL, bg.by = NULL, plot.by = c("group", "feature"), fill.by = c("group", "feature", "expression"),
                            cells = NULL, slot = "data", assay = NULL, keep_empty = FALSE, individual = FALSE,
                            plot_type = c("violin", "box", "bar", "dot", "col"),
                            palette = "Paired", palcolor = NULL, alpha = 1,
                            bg_palette = "Paired", bg_palcolor = NULL, bg_alpha = 0.2,
                            add_box = FALSE, box_color = "black", box_width = 0.1, box_ptsize = 2,
                            add_point = FALSE, pt.color = "grey30", pt.size = NULL, pt.alpha = 1, jitter.width = 0.4, jitter.height = 0.1,
                            add_trend = FALSE, trend_color = "black", trend_linewidth = 1, trend_ptsize = 2,
                            add_stat = c("none", "mean", "median"), stat_color = "black", stat_size = 1, stat_stroke = 1, stat_shape = 25,
                            add_line = NULL, line_color = "red", line_size = 1, line_type = 1,
                            cells.highlight = NULL, cols.highlight = "red", sizes.highlight = 1, alpha.highlight = 1,
                            calculate_coexp = FALSE,
                            same.y.lims = FALSE, y.min = NULL, y.max = NULL, y.trans = "identity", y.nbreaks = 5,
                            sort = FALSE, stack = FALSE, flip = FALSE,
                            comparisons = NULL, ref_group = NULL, pairwise_method = "wilcox.test",
                            multiplegroup_comparisons = FALSE, multiple_method = "kruskal.test",
                            sig_label = c("p.signif", "p.format"), sig_labelsize = 3.5,
                            aspect.ratio = NULL, title = NULL, subtitle = NULL, xlab = NULL, ylab = "Expression level",
                            legend.position = "right", legend.direction = "vertical",
                            theme_use = "theme_scp", theme_args = list(),
                            combine = TRUE, nrow = NULL, ncol = NULL, byrow = TRUE, force = FALSE, seed = 11) {
  if (is.null(group.by)) {
    group.by <- "All.groups" # avoid having the same name with split.by. split.by will be All.groups by default
    xlab <- "All groups"
    srt[[group.by]] <- factor("All groups")
  }

  meta.data <- srt@meta.data
  meta.data[["cells"]] <- rownames(meta.data)
  assay <- assay %||% DefaultAssay(srt)
  exp.data <- slot(srt@assays[[assay]], slot)
  plot.by <- match.arg(plot.by)

  if (plot.by == "feature") {
    if (length(group.by) > 1) {
      stop("The 'group.by' must have a length of 1 when 'plot.by' is set to 'feature'")
    }
    if (!is.null(bg.by)) {
      message("'bg.by' is invalid when plot.by is set to 'feature'")
    }
    message("Setting 'group.by' to 'Features' as 'plot.by' is set to 'feature'")
    srt@assays[setdiff(names(srt@assays), assay)] <- NULL
    meta.reshape <- FetchData(srt, vars = c(stat.by, group.by, split.by), cells = cells %||% rownames(meta.data), slot = slot)
    meta.reshape[["cells"]] <- rownames(meta.reshape)
    meta.reshape <- melt(meta.reshape, measure.vars = stat.by, variable.name = "Features", value.name = "Stat.by")
    rownames(meta.reshape) <- paste0(meta.reshape[["cells"]], "-", meta.reshape[["Features"]])
    exp.data <- matrix(0, nrow = 1, ncol = nrow(meta.reshape), dimnames = list("Stat.by", rownames(meta.reshape)))
    plist <- list()
    for (g in unique(meta.reshape[[group.by]])) {
      if (length(rownames(meta.reshape)[meta.reshape[[group.by]] == g]) > 0) {
        meta.use <- meta.reshape
        meta.use[[group.by]] <- NULL
        colnames(meta.use)[colnames(meta.use) == "Stat.by"] <- g
        p <- ExpressionStatPlot(
          exp.data = exp.data, meta.data = meta.use, stat.by = g, group.by = "Features", split.by = split.by, bg.by = NULL, plot.by = "group", fill.by = fill.by,
          cells = rownames(meta.reshape)[meta.reshape[[group.by]] == g], keep_empty = keep_empty, individual = individual,
          plot_type = plot_type,
          palette = palette, palcolor = palcolor, alpha = alpha,
          bg_palette = bg_palette, bg_palcolor = bg_palcolor, bg_alpha = bg_alpha,
          add_box = add_box, box_color = box_color, box_width = box_width, box_ptsize = box_ptsize,
          add_point = add_point, pt.color = pt.color, pt.size = pt.size, pt.alpha = pt.alpha, jitter.width = jitter.width, jitter.height = jitter.height,
          add_trend = add_trend, trend_color = trend_color, trend_linewidth = trend_linewidth, trend_ptsize = trend_ptsize,
          add_stat = add_stat, stat_color = stat_color, stat_size = stat_size, stat_stroke = stat_stroke, stat_shape = stat_shape,
          add_line = add_line, line_color = line_color, line_size = line_size, line_type = line_type,
          cells.highlight = cells.highlight, cols.highlight = cols.highlight, sizes.highlight = sizes.highlight, alpha.highlight = alpha.highlight,
          calculate_coexp = calculate_coexp,
          same.y.lims = same.y.lims, y.min = y.min, y.max = y.max, y.trans = y.trans, y.nbreaks = y.nbreaks,
          sort = sort, stack = stack, flip = flip,
          comparisons = comparisons, ref_group = ref_group, pairwise_method = pairwise_method,
          multiplegroup_comparisons = multiplegroup_comparisons, multiple_method = multiple_method,
          sig_label = sig_label, sig_labelsize = sig_labelsize,
          aspect.ratio = aspect.ratio, title = title, subtitle = subtitle, xlab = xlab, ylab = ylab,
          legend.position = legend.position, legend.direction = legend.direction,
          theme_use = theme_use, theme_args = theme_args,
          force = force, seed = seed
        )
        plist <- append(plist, p)
      }
    }
    group.by <- "Features"
  } else {
    plist <- ExpressionStatPlot(
      exp.data = exp.data, meta.data = meta.data, stat.by = stat.by, group.by = group.by, split.by = split.by, bg.by = bg.by, plot.by = "group", fill.by = fill.by,
      cells = cells, keep_empty = keep_empty, individual = individual,
      plot_type = plot_type,
      palette = palette, palcolor = palcolor, alpha = alpha,
      bg_palette = bg_palette, bg_palcolor = bg_palcolor, bg_alpha = bg_alpha,
      add_box = add_box, box_color = box_color, box_width = box_width, box_ptsize = box_ptsize,
      add_point = add_point, pt.color = pt.color, pt.size = pt.size, pt.alpha = pt.alpha, jitter.width = jitter.width, jitter.height = jitter.height,
      add_trend = add_trend, trend_color = trend_color, trend_linewidth = trend_linewidth, trend_ptsize = trend_ptsize,
      add_stat = add_stat, stat_color = stat_color, stat_size = stat_size, stat_stroke = stat_stroke, stat_shape = stat_shape,
      add_line = add_line, line_color = line_color, line_size = line_size, line_type = line_type,
      cells.highlight = cells.highlight, cols.highlight = cols.highlight, sizes.highlight = sizes.highlight, alpha.highlight = alpha.highlight,
      calculate_coexp = calculate_coexp,
      same.y.lims = same.y.lims, y.min = y.min, y.max = y.max, y.trans = y.trans, y.nbreaks = y.nbreaks,
      sort = sort, stack = stack, flip = flip,
      comparisons = comparisons, ref_group = ref_group, pairwise_method = pairwise_method,
      multiplegroup_comparisons = multiplegroup_comparisons, multiple_method = multiple_method,
      sig_label = sig_label, sig_labelsize = sig_labelsize,
      aspect.ratio = aspect.ratio, title = title, subtitle = subtitle, xlab = xlab, ylab = ylab,
      legend.position = legend.position, legend.direction = legend.direction,
      theme_use = theme_use, theme_args = theme_args,
      force = force, seed = seed
    )
  }

  plist_stack <- list()
  if (isTRUE(stack) && length(stat.by) > 1 && isFALSE(individual)) {
    for (g in group.by) {
      plist_g <- plist[sapply(strsplit(names(plist), ":"), function(x) x[2]) == g]
      legend <- get_legend(plist_g[[1]])
      if (isTRUE(flip)) {
        lab <- textGrob(label = ifelse(is.null(ylab), "Expression level", ylab), hjust = 0.5)
        plist_g <- lapply(seq_along(plist_g), FUN = function(i) {
          p <- plist_g[[i]]
          if (i != 1) {
            suppressWarnings(p <- p + theme(
              legend.position = "none",
              panel.grid = element_blank(),
              plot.title = element_blank(),
              plot.subtitle = element_blank(),
              axis.title = element_blank(),
              axis.text.y = element_blank(),
              axis.text.x = element_text(vjust = c(1, 0)),
              axis.ticks.length.y = unit(0, "pt"),
              plot.margin = unit(c(0, -0.5, 0, 0), "mm")
            ))
          } else {
            suppressWarnings(p <- p + theme(
              legend.position = "none",
              panel.grid = element_blank(),
              axis.title.x = element_blank(),
              axis.text.x = element_text(vjust = c(1, 0)),
              axis.ticks.length.y = unit(0, "pt"),
              plot.margin = unit(c(0, -0.5, 0, 0), "mm")
            ))
          }
          return(as_grob(p))
        })
        gtable <- do.call(cbind, plist_g)
        gtable <- add_grob(gtable, lab, "bottom", clip = "off")
        gtable <- add_grob(gtable, legend, legend.position)
      } else {
        lab <- textGrob(label = ifelse(is.null(ylab), "Expression level", ylab), rot = 90, hjust = 0.5)
        plist_g <- lapply(seq_along(plist_g), FUN = function(i) {
          p <- plist_g[[i]]
          if (i != length(plist_g)) {
            suppressWarnings(p <- p + theme(
              legend.position = "none",
              panel.grid = element_blank(),
              axis.title = element_blank(),
              axis.text.x = element_blank(),
              axis.text.y = element_text(vjust = c(0, 1)),
              axis.ticks.length.x = unit(0, "pt"),
              plot.margin = unit(c(-0.5, 0, 0, 0), "mm")
            ))
            if (i == 1) {
              p <- p + theme(plot.title = element_blank(), plot.subtitle = element_blank())
            }
          } else {
            suppressWarnings(p <- p + theme(
              legend.position = "none",
              panel.grid = element_blank(),
              axis.title.y = element_blank(),
              axis.text.y = element_text(vjust = c(0, 1)),
              axis.ticks.length.x = unit(0, "pt"),
              plot.margin = unit(c(-0.5, 0, 0, 0), "mm")
            ))
          }
          return(as_grob(p))
        })
        gtable <- do.call(rbind, plist_g)
        gtable <- add_grob(gtable, lab, "left", clip = "off")
        gtable <- add_grob(gtable, legend, legend.position)
      }
      gtable <- gtable_add_padding(gtable, unit(c(1, 1, 1, 1), units = "cm"))
      plot <- wrap_plots(gtable)
      plist_stack[[g]] <- plot
    }
  }

  if (length(plist_stack) > 0) {
    plist <- plist_stack
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
