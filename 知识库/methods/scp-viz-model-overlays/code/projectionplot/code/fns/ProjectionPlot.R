# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:12511-12583
# sha256(func-block)=293b1a3e14d7812bde2d2aa12574c340e1c441d644e62e367bcb69c7c4144c12
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
ProjectionPlot <- function(srt_query, srt_ref,
                           query_group = NULL, ref_group = NULL,
                           query_reduction = "ref.embeddings", ref_reduction = srt_query[[query_reduction]]@misc[["reduction.model"]] %||% NULL,
                           query_param = list(palette = "Set1", cells.highlight = TRUE), ref_param = list(palette = "Paired"),
                           xlim = NULL, ylim = NULL, pt.size = 0.8, stroke.highlight = 0.5) {
  if (is.null(ref_reduction)) {
    stop("Please specify the ref_reduction.")
  }
  query_param[["show_stat"]] <- FALSE
  ref_param[["show_stat"]] <- FALSE

  if (is.null(xlim)) {
    ref_xlim <- range(srt_ref[[ref_reduction]]@cell.embeddings[, 1])
    query_xlim <- range(srt_query[[query_reduction]]@cell.embeddings[, 1])
    xlim <- range(c(ref_xlim, query_xlim))
  }
  if (is.null(ylim)) {
    ref_ylim <- range(srt_ref[[ref_reduction]]@cell.embeddings[, 2])
    query_ylim <- range(srt_query[[query_reduction]]@cell.embeddings[, 2])
    ylim <- range(c(ref_ylim, query_ylim))
  }

  p1 <- do.call(CellDimPlot, args = c(
    srt = srt_ref, reduction = ref_reduction, group.by = ref_group,
    ref_param
  )) +
    guides(color = guide_legend(title = paste0("Ref: ", ref_group), override.aes = list(size = 4)))
  p1legend <- get_legend(p1)
  # p1legend <- gtable_filter(ggplot_gtable(ggplot_build(p1)), "guide-box")


  p2 <- do.call(CellDimPlot, args = c(
    srt = srt_query, reduction = query_reduction, group.by = query_group,
    query_param
  )) +
    scale_x_continuous(limits = xlim) +
    scale_y_continuous(limits = ylim)
  p2data <- ggplot_build(p2)$data[[1]]
  color <- p2data$colour
  names(color) <- p2$data$group.by
  p2 <- p2 + guides(color = guide_legend(
    title = paste0("Query: ", query_group),
    override.aes = list(size = 4, shape = 21, color = "black", fill = na.omit(color[levels(p2$data$group.by)]))
  ))
  p2legend <- get_legend(p2)
  # p2legend <- gtable_filter(ggplot_gtable(ggplot_build(p2)), "guide-box")

  if (!is.null(p1legend) && !is.null(p2legend)) {
    legend <- cbind(p1legend, p2legend)
  } else {
    legend <- p1legend %||% p2legend
  }

  p3 <- p1 + new_scale_fill() + new_scale_color() +
    geom_point(
      data = p2data, aes(x = x, y = y), color = "black",
      size = pt.size + stroke.highlight
    ) +
    geom_point(
      data = p2data, aes(x = x, y = y, color = colour),
      size = pt.size
    ) +
    scale_color_identity() +
    facet_null() + theme(legend.position = "none")
  if (is.null(legend)) {
    return(p3)
  } else {
    gtable <- as_grob(p3)
    gtable <- add_grob(gtable, legend, "right")
    p <- wrap_plots(gtable)
    return(p)
  }
}
