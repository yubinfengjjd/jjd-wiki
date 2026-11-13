# Read-only excerpt from SCP v0.5.6 R/SCP-plot.R, CellDensityPlot().
# Source: https://github.com/zhanghao-njmu/scp
# Commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
# Lines 5679-5917; the template core is a split copy, not this file.

CellDensityPlot <- function(srt, features, group.by = NULL, split.by = NULL, assay = NULL, slot = "data",
                            flip = FALSE, reverse = FALSE, x_order = c("value", "rank"),
                            decreasing = NULL, palette = "Paired", palcolor = NULL,
                            cells = NULL, keep_empty = FALSE,
                            y.nbreaks = 4, y.min = NULL, y.max = NULL, same.y.lims = FALSE,
                            aspect.ratio = NULL, title = NULL, subtitle = NULL,
                            legend.position = "right", legend.direction = "vertical",
                            theme_use = "theme_scp", theme_args = list(),
                            combine = TRUE, nrow = NULL, ncol = NULL, byrow = TRUE, force = FALSE) {
  check_R("ggridges")
  assay <- assay %||% DefaultAssay(srt)
  x_order <- match.arg(x_order)
  if (is.null(features)) {
    stop("'features' must be provided.")
  }
  if (!inherits(features, "character")) {
    stop("'features' is not a character vectors")
  }
  if (is.null(group.by)) {
    group.by <- "All.groups"
    srt@meta.data[[group.by]] <- factor("")
  }
  if (is.null(split.by)) {
    split.by <- "All.groups"
    srt@meta.data[[split.by]] <- factor("")
  }
  if (group.by == split.by & group.by == "All.groups") {
    legend.position <- "none"
  }
  for (i in c(group.by, split.by)) {
    if (!i %in% colnames(srt@meta.data)) {
      stop(paste0(i, " is not in the meta.data of srt object."))
    }
    if (!is.factor(srt@meta.data[[i]])) {
      srt@meta.data[[i]] <- factor(srt@meta.data[[i]], levels = unique(srt@meta.data[[i]]))
    }
  }

  features <- unique(features)
  features_drop <- features[!features %in% c(rownames(srt@assays[[assay]]), colnames(srt@meta.data))]
  # print(colnames(srt@meta.data))
  if (length(features_drop) > 0) {
    warning(paste0(features_drop, collapse = ","), " are not in the features of srt.", immediate. = TRUE)
    features <- features[!features %in% features_drop]
  }

  features_gene <- features[features %in% rownames(srt@assays[[assay]])]
  features_meta <- features[features %in% colnames(srt@meta.data)]
  if (length(intersect(features_gene, features_meta)) > 0) {
    warning("Features appear in both gene names and metadata names: ", paste0(intersect(features_gene, features_meta), collapse = ","))
  }

  if (length(features_gene) > 0) {
    dat_gene <- t(slot(srt@assays[[assay]], slot)[features_gene, , drop = FALSE])
  } else {
    dat_gene <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  if (length(features_meta) > 0) {
    dat_meta <- as_matrix(srt@meta.data[, features_meta, drop = FALSE])
  } else {
    dat_meta <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  dat_exp <- cbind(dat_gene, dat_meta)
  features <- unique(features[features %in% c(features_gene, features_meta)])

  if (!is.numeric(dat_exp) && !inherits(dat_exp, "Matrix")) {
    stop("'features' must be type of numeric variable.")
  }
  if (length(features) > 50 && !isTRUE(force)) {
    warning("More than 50 features to be plotted", immediate. = TRUE)
    answer <- askYesNo("Are you sure to continue?", default = FALSE)
    if (!isTRUE(answer)) {
      return(invisible(NULL))
    }
  }

  dat_use <- cbind(dat_exp, srt@meta.data[row.names(dat_exp), c(group.by, split.by), drop = FALSE])
  if (!is.null(cells)) {
    dat_use <- dat_use[intersect(rownames(dat_use), cells), , drop = FALSE]
  }

  if (isTRUE(same.y.lims) && is.null(y.max)) {
    y.max <- max(as_matrix(dat_exp[, features])[is.finite(as_matrix(dat_exp[, features]))], na.rm = TRUE)
  }
  if (isTRUE(same.y.lims) && is.null(y.min)) {
    y.min <- min(as_matrix(dat_exp[, features])[is.finite(as_matrix(dat_exp[, features]))], na.rm = TRUE)
  }

  plist <- list()
  for (f in features) {
    for (g in group.by) {
      colors <- palette_scp(levels(dat_use[[g]]), palette = palette, palcolor = palcolor)
      for (s in levels(dat_use[[split.by]])) {
        dat <- dat_use[dat_use[[split.by]] == s, , drop = FALSE]
        if (any(is.infinite(dat[, f]))) {
          dat[, f][dat[, f] == max(dat[, f], na.rm = TRUE)] <- max(dat[, f][is.finite(dat[, f])], na.rm = TRUE)
          dat[, f][dat[, f] == min(dat[, f], na.rm = TRUE)] <- min(dat[, f][is.finite(dat[, f])], na.rm = TRUE)
        }
        dat[, "cell"] <- rownames(dat)
        if (x_order == "value") {
          dat[, "value"] <- dat[, f]
        } else {
          dat[, "value"] <- rank(dat[, f])
        }
        dat[, "features"] <- f
        dat[, "split.by"] <- s
        dat <- dat[!is.na(dat[[f]]), , drop = FALSE]
        # stat <- table(dat[[g]])
        # stat_drop <- names(which(stat <= 2))
        # if (length(stat_drop) > 0) {
        #   dat <- dat[!dat[[g]] %in% stat_drop, , drop = FALSE]
        # }
        y_max_use <- y.max %||% suppressWarnings(max(dat[, "value"][is.finite(x = dat[, "value"])], na.rm = TRUE))
        y_min_use <- y.min %||% suppressWarnings(min(dat[, "value"][is.finite(x = dat[, "value"])], na.rm = TRUE))

        if (!is.null(decreasing)) {
          levels <- dat %>%
            group_by_at(g) %>%
            summarise_at(.funs = median, .vars = f, na.rm = TRUE) %>%
            arrange_at(.vars = f, .funs = if (decreasing) desc else list()) %>%
            pull(g) %>%
            as.character()
          dat[["order"]] <- factor(dat[[g]], levels = levels)
        } else {
          dat[["order"]] <- factor(dat[[g]], levels = rev(levels(dat[[g]])))
        }
        if (flip) {
          dat[["order"]] <- factor(dat[[g]], levels = levels(dat[[g]]))
          aspect.ratio <- 1 / aspect.ratio
          if (length(aspect.ratio) == 0 || is.na(aspect.ratio)) {
            aspect.ratio <- NULL
          }
        }
        p <- ggplot(dat, aes(x = .data[["value"]], y = .data[["order"]], fill = .data[[g]])) +
          ggridges::geom_density_ridges()
        p <- p + scale_fill_manual(
          name = paste0(g, ":"),
          values = colors
        )
        y.trans <- ifelse(flip, "reverse", "identity")
        y.trans <- ifelse(reverse, setdiff(c("reverse", "identity"), y.trans), y.trans)

        limits <- if (y.trans == "reverse") c(y_max_use, y_min_use) else c(y_min_use, y_max_use)
        p <- p +
          scale_y_discrete(drop = !keep_empty, expand = c(0, 0)) +
          scale_x_continuous(
            limits = limits, trans = y.trans, n.breaks = y.nbreaks,
            expand = c(0, 0)
          )
        if (split.by != "All.groups") {
          p <- p + facet_grid(. ~ split.by)
        }
        p <- p + labs(title = title, subtitle = subtitle, x = f, y = g)
        if (isTRUE(flip)) {
          p <- p + do.call(theme_use, theme_args) +
            theme(
              aspect.ratio = aspect.ratio,
              strip.text.x = element_text(angle = 0),
              axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
              axis.ticks.x = element_line(),
              panel.grid.major.x = element_line(color = "grey", linetype = 2),
              legend.position = legend.position,
              legend.direction = legend.direction
            ) + coord_flip()
        } else {
          p <- p + do.call(theme_use, theme_args) +
            theme(
              aspect.ratio = aspect.ratio,
              strip.text.y = element_text(angle = 0),
              axis.text.x = element_text(),
              axis.text.y = element_text(hjust = 1),
              axis.ticks.y = element_line(),
              panel.grid.major.y = element_line(color = "grey", linetype = 2),
              legend.position = legend.position,
              legend.direction = legend.direction
            )
        }
        plist[[paste0(f, ":", g, ":", paste0(s, collapse = ","))]] <- p
      }
    }
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
  return(p)
}

#' LineagePlot
#'
#' Generate a lineage plot based on the pseudotime.
#'
#' @param srt An object of class Seurat.
#' @param lineages A character vector that specifies the lineages to be included. Typically, use the pseudotime of cells.
#' @param reduction An optional string specifying the dimensionality reduction method to use.
#' @param dims A numeric vector of length 2 specifying the dimensions to plot.
#' @param cells An optional character vector specifying the cells to include in the plot.
#' @param trim A numeric vector of length 2 specifying the quantile range of lineages to include in the plot.
#' @param span A numeric value specifying the span of the loess smoother.
#' @param palette A character string specifying the color palette to use for the lineages.
#' @param palcolor An optional string specifying the color for the palette.
#' @param lineages_arrow An arrow object specifying the arrow for lineages.
#' @param linewidth A numeric value specifying the linewidth for the lineages.
#' @param line_bg A character string specifying the color for the background lines.
#' @param line_bg_stroke A numeric value specifying the stroke width for the background lines.
#' @param whiskers A logical value indicating whether to include whiskers in the plot.
#' @param whiskers_linewidth A numeric value specifying the linewidth for the whiskers.
#' @param whiskers_alpha A numeric value specifying the transparency for the whiskers.
#' @param aspect.ratio A numeric value specifying the aspect ratio of the plot.
#' @param title An optional character string specifying the plot title.
#' @param subtitle An optional character string specifying the plot subtitle.
#' @param xlab An optional character string specifying the x-axis label.
#' @param ylab An optional character string specifying the y-axis label.
#' @param legend.position A character string specifying the position of the legend.
#' @param legend.direction A character string specifying the direction of the legend.
#' @param theme_use A character string specifying the theme to use for the plot.
#' @param theme_args A list of additional arguments to pass to the theme function.
#' @param return_layer A logical value indicating whether to return the plot as a layer.
#' @param seed An optional integer specifying the random seed for reproducibility.
#'
#' @seealso \code{\link{RunSlingshot}} \code{\link{CellDimPlot}}
#'
#' @examples
#' data("pancreas_sub")
#' pancreas_sub <- RunSlingshot(pancreas_sub, group.by = "SubCellType", reduction = "UMAP", show_plot = FALSE)
#' LineagePlot(pancreas_sub, lineages = paste0("Lineage", 1:3))
#' LineagePlot(pancreas_sub, lineages = paste0("Lineage", 1:3), whiskers = TRUE)
#' @importFrom Seurat Key Embeddings
#' @importFrom ggplot2 aes geom_path geom_segment labs
#' @importFrom grid arrow unit
#' @importFrom stats loess quantile
#' @export
