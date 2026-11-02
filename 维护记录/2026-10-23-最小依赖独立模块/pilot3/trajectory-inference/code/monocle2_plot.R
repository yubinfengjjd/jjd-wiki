# Optional Monocle2 plotting layer. It consumes the core result (or a Seurat
# object produced by run_trajectory_monocle2) and is never called by the
# analysis core. Requires ggplot2 and igraph only when this entry is used.
#
# This is a local plotting helper, not the original SCP CellDimPlot stack.

plot_monocle2 <- function(result, point_size = 1, label = TRUE, seed = 11) {
  for (package in c("ggplot2", "igraph")) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop("Missing R dependency: ", package, "; automatic installation is disabled", call. = FALSE)
    }
  }
  if (inherits(result, "Seurat")) {
    result <- result@tools$Monocle2
  }
  if (is.null(result$cds)) stop("result must contain the monocle2 cds", call. = FALSE)
  cds <- result$cds
  if (identical(cds@dim_reduce_type, "ICA")) {
    coords <- t(cds@reducedDimS)
  } else {
    coords <- t(cds@reducedDimK)
  }
  colnames(coords) <- c("x", "y")
  frame <- data.frame(cell = rownames(coords), x = coords[, 1], y = coords[, 2],
                      State = as.character(cds[["State"]]), stringsAsFactors = FALSE)
  edges <- igraph::as_data_frame(cds@minSpanningTree)
  edges$x <- coords[edges$from, 1]
  edges$y <- coords[edges$from, 2]
  edges$xend <- coords[edges$to, 1]
  edges$yend <- coords[edges$to, 2]
  set.seed(seed)
  plot <- ggplot2::ggplot(frame, ggplot2::aes(x = x, y = y, colour = State)) +
    ggplot2::geom_segment(data = edges, ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
                          inherit.aes = FALSE, colour = "grey35") +
    ggplot2::geom_point(size = point_size) +
    ggplot2::coord_equal() +
    ggplot2::theme_bw()
  if (isTRUE(label)) {
    centers <- stats::aggregate(cbind(x, y) ~ State, data = frame, FUN = stats::median)
    plot <- plot + ggplot2::geom_text(data = centers, ggplot2::aes(label = State),
                                      inherit.aes = FALSE, vjust = -0.5)
  }
  plot
}
