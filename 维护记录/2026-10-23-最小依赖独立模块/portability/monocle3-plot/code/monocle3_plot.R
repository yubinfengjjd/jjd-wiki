# Optional Monocle3 plotting layer. Consumes the core result or a Seurat
# object produced by run_trajectory_monocle3; never called by the core.

plot_monocle3 <- function(result, colour_by = c("partitions", "clusters"), point_size = 0.8) {
  for (package in c("ggplot2", "SingleCellExperiment")) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop("Missing R dependency: ", package, "; automatic installation is disabled", call. = FALSE)
    }
  }
  if (inherits(result, "Seurat")) result <- result@tools$Monocle3
  if (is.null(result$cds)) stop("result must contain the monocle3 cds", call. = FALSE)
  colour_by <- match.arg(colour_by)
  cds <- result$cds
  coords <- SingleCellExperiment::reducedDims(cds)[["UMAP"]]
  frame <- data.frame(
    cell = rownames(coords), x = coords[, 1], y = coords[, 2],
    value = as.character(if (colour_by == "partitions") result$partitions else result$clusters),
    stringsAsFactors = FALSE
  )
  ggplot2::ggplot(frame, ggplot2::aes(x = x, y = y, colour = value)) +
    ggplot2::geom_point(size = point_size) +
    ggplot2::coord_equal() +
    ggplot2::labs(colour = colour_by) +
    ggplot2::theme_bw()
}
