# CNS-style pathway heatmap: rows = pathways, columns = celltype x condition,
# column splits by cell type, bottom condition annotation, row clustering.
# Draws to the current device; does not read files or save.

`%||%` <- function(a, b) if (!is.null(a)) a else b

plot_pathway_heatmap_cns <- function(
    mat,
    celltype,
    sample_anno1 = NULL,
    sample_anno2 = NULL,
    column_order = NULL,
    heatmap_name = "Mean score",
    scale_rows = FALSE,
    celltype_order = NULL,
    anno1_name = NULL,
    anno2_name = NULL,
    anno1_colors = NULL,
    anno2_colors = NULL,
    col_fun = NULL,
    value_limits = NULL,
    cluster_rows = TRUE,
    cluster_columns = FALSE,
    show_panel_label = FALSE,
    panel_label = "A",
    show_row_names = TRUE,
    show_column_names = FALSE,
    row_names_fontsize = 11,
    column_names_fontsize = 9,
    column_title_fontsize = 12,
    column_title_rot = 0,
    heatmap_width = grid::unit(12, "cm"),
    heatmap_height = grid::unit(5.2, "cm"),
    legend_side = "left",
    annotation_legend_side = "left",
    border = TRUE,
    panel_fill = "#FFFFFF"
) {
  mat <- as.matrix(mat)
  if (is.null(rownames(mat))) stop("`mat` must have row names, usually pathway names.")
  if (is.null(colnames(mat))) stop("`mat` must have column names.")
  cn <- colnames(mat)

  if (is.null(names(celltype))) {
    stop("`celltype` must be a named vector; names(celltype) must match colnames(mat).")
  }
  has_anno1 <- !is.null(sample_anno1)
  has_anno2 <- !is.null(sample_anno2)
  if (has_anno1 && is.null(names(sample_anno1))) {
    stop("`sample_anno1` must be a named vector.")
  }
  if (has_anno2 && is.null(names(sample_anno2))) {
    stop("`sample_anno2` must be a named vector.")
  }

  if (is.null(column_order)) {
    if (is.null(celltype_order)) celltype_order <- unique(celltype[cn])
    column_order <- cn[order(match(celltype[cn], celltype_order))]
  } else {
    column_order <- intersect(column_order, cn)
  }
  mat <- mat[, column_order, drop = FALSE]
  celltype <- celltype[column_order]
  if (has_anno1) sample_anno1 <- sample_anno1[column_order]
  if (has_anno2) sample_anno2 <- sample_anno2[column_order]

  if (any(is.na(celltype))) stop("Some columns lack celltype annotation.")
  if (has_anno1 && any(is.na(sample_anno1))) stop("Some columns lack sample_anno1 annotation.")
  if (has_anno2 && any(is.na(sample_anno2))) stop("Some columns lack sample_anno2 annotation.")
  if (is.null(celltype_order)) celltype_order <- unique(celltype)
  column_split <- factor(celltype, levels = celltype_order)

  if (isTRUE(scale_rows)) {
    mat <- t(scale(t(mat)))
    mat[is.na(mat)] <- 0
  }

  if (is.null(col_fun)) {
    if (isTRUE(scale_rows)) {
      max_abs <- max(abs(mat), na.rm = TRUE)
      if (!is.finite(max_abs) || max_abs == 0) max_abs <- 1
      col_fun <- circlize::colorRamp2(
        c(-max_abs, 0, max_abs),
        c("#08306B", "#F7F7F7", "#B2182B")
      )
      legend_at <- c(-round(max_abs, 2), 0, round(max_abs, 2))
    } else {
      if (is.null(value_limits)) value_limits <- range(mat, na.rm = TRUE)
      mid_value <- mean(value_limits)
      col_fun <- circlize::colorRamp2(
        c(value_limits[1], mid_value, value_limits[2]),
        c("#08306B", "#F7F7F7", "#B2182B")
      )
      legend_at <- pretty(value_limits, n = 4)
    }
  } else {
    legend_at <- pretty(range(mat, na.rm = TRUE), n = 4)
  }

  bottom_ha <- NULL
  if (has_anno1 || has_anno2) {
    anno_df <- data.frame(row.names = cn)
    anno_col_list <- list()
    anno_legend_list <- list()

    if (has_anno1) {
      if (is.null(anno1_colors)) {
        anno1_levels <- unique(sample_anno1)
        default_cols_1 <- c("#E7B4C7", "#CFE1F2", "#BFD3E6", "#F4CAE4", "#CCEBC5")
        anno1_colors <- stats::setNames(default_cols_1[seq_along(anno1_levels)], anno1_levels)
      }
      anno_df$anno1 <- factor(sample_anno1, levels = names(anno1_colors))
      anno_col_list$anno1 <- anno1_colors
      anno_legend_list$anno1 <- list(
        title = anno1_name %||% "Group",
        title_gp = grid::gpar(fontsize = 9),
        labels_gp = grid::gpar(fontsize = 8)
      )
    }

    if (has_anno2) {
      if (is.null(anno2_colors)) {
        anno2_levels <- unique(sample_anno2)
        default_cols_2 <- c("#7A52A1", "#D7CF2A", "#5DA5DA", "#F17CB0", "#60BD68", "#F2A000")
        anno2_colors <- stats::setNames(default_cols_2[seq_along(anno2_levels)], anno2_levels)
      }
      anno_df$anno2 <- factor(sample_anno2, levels = names(anno2_colors))
      anno_col_list$anno2 <- anno2_colors
      anno_legend_list$anno2 <- list(
        title = anno2_name %||% "Sample",
        title_gp = grid::gpar(fontsize = 9),
        labels_gp = grid::gpar(fontsize = 8)
      )
    }

    bottom_ha <- ComplexHeatmap::HeatmapAnnotation(
      df = anno_df,
      col = anno_col_list,
      which = "column",
      show_annotation_name = FALSE,
      simple_anno_size = grid::unit(0.28, "cm"),
      gap = grid::unit(0.7, "mm"),
      annotation_legend_param = anno_legend_list
    )
  }

  ht <- ComplexHeatmap::Heatmap(
    mat,
    name = heatmap_name,
    col = col_fun,
    cluster_rows = cluster_rows,
    cluster_columns = cluster_columns,
    show_row_dend = cluster_rows,
    show_column_dend = FALSE,
    row_dend_side = "left",
    row_names_side = "right",
    show_row_names = show_row_names,
    show_column_names = show_column_names,
    row_names_gp = grid::gpar(fontsize = row_names_fontsize, fontface = "italic"),
    column_names_gp = grid::gpar(fontsize = column_names_fontsize),
    column_names_rot = 90,
    column_split = column_split,
    cluster_column_slices = FALSE,
    column_title_gp = grid::gpar(fontsize = column_title_fontsize, fontface = "plain"),
    column_title_rot = column_title_rot,
    column_gap = grid::unit(1.1, "mm"),
    bottom_annotation = bottom_ha,
    border = border,
    rect_gp = grid::gpar(col = "#D9D9D9", lwd = 0.55),
    heatmap_legend_param = list(
      title = heatmap_name,
      direction = "vertical",
      at = legend_at,
      labels = as.character(legend_at),
      legend_height = grid::unit(3.2, "cm"),
      title_gp = grid::gpar(fontsize = 10),
      labels_gp = grid::gpar(fontsize = 9)
    ),
    width = heatmap_width,
    height = heatmap_height
  )

  ht <- ComplexHeatmap::draw(
    ht,
    heatmap_legend_side = legend_side,
    annotation_legend_side = annotation_legend_side,
    merge_legends = FALSE
  )

  if (isTRUE(show_panel_label)) {
    ComplexHeatmap::decorate_heatmap_body(heatmap_name, {
      grid::grid.text(
        panel_label,
        x = grid::unit(-1.25, "cm"),
        y = grid::unit(1, "npc") + grid::unit(0.85, "cm"),
        gp = grid::gpar(fontsize = 16, fontface = "bold")
      )
    })
  }

  invisible(ht)
}
