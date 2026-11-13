# Native SCP CellCorHeatmap core, split into table and plotting halves.
#
# Source: SCP v0.5.6, R/SCP-plot.R, CellCorHeatmap() (lines 9984-10888) and
# R/SCP-cell_annotation.R, RunKNNPredict() (lines 98-499), commit
# b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
#
# Table half: scp_cellcor_simil() reproduces CellCorHeatmap()'s similarity
# matrix preparation (RunKNNPredict -> distance_matrix -> t(1 - d) -> group
# subsetting), and scp_cellcor_long_table() writes it out without aggregation.
#
# Plot half: plot_scp_cellcor_heatmap() copies the ComplexHeatmap construction
# used by CellCorHeatmap() for the no-cell-annotation, no-fix-size path. Only
# namespace qualification and the documented compatibility patches below
# differ from the upstream drawing code.
#
# Documented compatibility patches (source side only, see PATCHES.md):
#   P1. RunKNNPredict() writes per-cell metadata columns from `match_best[query_index]`
#       whose names are group labels. SeuratObject >= 5.4 rejects metadata vectors
#       with no cell-name overlap. The wrapper applies `unname()` to the four
#       `srt_query[[paste0(prefix, ...)]] <- ...` assignments; values and cell
#       order are unchanged, and the distance matrix / similarity matrix are
#       not affected.
#   The plot half has no behavioral patch: matrices, levels, palettes, seed,
#   titles and device calls are identical to upstream.

`%||%` <- function(x, y) if (is.null(x)) y else x

.scp_cellcor_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# --- compatibility patch P1 ---------------------------------------------------
# Return a copy of RunKNNPredict() with `unname()` applied to the four
# per-cell metadata assignments. The exact four call sites are counted and the
# function aborts if upstream changes, so the patch cannot silently drift.
patch_knnpredict_metadata_names <- function(fun) {
  n_patched <- 0L
  walk <- function(expr) {
    if (!is.call(expr)) {
      return(expr)
    }
    if (identical(expr[[1]], as.name("<-")) && length(expr) == 3L &&
      is.call(expr[[2]]) && identical(expr[[2]][[1]], as.name("[[")) &&
      identical(expr[[2]][[2]], as.name("srt_query")) &&
      is.call(expr[[2]][[3]]) && identical(expr[[2]][[3]][[1]], as.name("paste0")) &&
      identical(expr[[2]][[3]][[2]], as.name("prefix"))) {
      expr[[3]] <- call("unname", expr[[3]])
      n_patched <<- n_patched + 1L
      return(expr)
    }
    for (i in seq_along(expr)[-1]) expr[i] <- list(walk(expr[[i]]))
    expr
  }
  body(fun) <- walk(body(fun))
  if (n_patched != 4L) {
    stop("RunKNNPredict compatibility patch expected 4 assignments, found ", n_patched, call. = FALSE)
  }
  fun
}

# Size helper copied verbatim from SCP-plot.R (heatmap_rendersize).
heatmap_rendersize <- function(width, height, units, ha_top_list, ha_left, ha_right, ht_list, legend_list, flip) {
  width_annotation <- height_annotation <- 0
  if (isTRUE(flip)) {
    width_sum <- width[1] %||% convertWidth(unit(1, "in"), units, valueOnly = TRUE)
    height_sum <- sum(height %||% convertHeight(unit(1, "in"), units, valueOnly = TRUE))
    if (length(ha_top_list) > 0) {
      width_annotation <- convertWidth(unit(width_annotation, units) + width.HeatmapAnnotation(ha_top_list[[1]]), units, valueOnly = TRUE)
    }
    if (!is.null(ha_left)) {
      height_annotation <- convertHeight(unit(height_annotation, units) + height.HeatmapAnnotation(ha_left), units, valueOnly = TRUE)
    }
    if (!is.null(ha_right)) {
      height_annotation <- convertHeight(unit(height_annotation, units) + height.HeatmapAnnotation(ha_right), units, valueOnly = TRUE)
    }
  } else {
    width_sum <- sum(width %||% convertWidth(unit(1, "in"), units, valueOnly = TRUE))
    height_sum <- height[1] %||% convertHeight(unit(1, "in"), units, valueOnly = TRUE)
    if (length(ha_top_list) > 0) {
      height_annotation <- convertHeight(unit(height_annotation, units) + height.HeatmapAnnotation(ha_top_list[[1]]), units, valueOnly = TRUE)
    }
    if (!is.null(ha_left)) {
      width_annotation <- convertWidth(unit(width_annotation, units) + width.HeatmapAnnotation(ha_left), units, valueOnly = TRUE)
    }
    if (!is.null(ha_right)) {
      width_annotation <- convertWidth(unit(width_annotation, units) + width.HeatmapAnnotation(ha_right), units, valueOnly = TRUE)
    }
  }
  dend_width <- name_width <- NULL
  dend_height <- name_height <- NULL
  if (inherits(ht_list, "HeatmapList")) {
    for (nm in names(ht_list@ht_list)) {
      ht <- ht_list@ht_list[[nm]]
      dend_width <- max(ht@row_dend_param$width, dend_width)
      dend_height <- max(ht@column_dend_param$height, dend_height)
      name_width <- max(ht@row_names_param$max_width, name_width)
      name_height <- max(ht@column_names_param$max_height, name_height)
    }
  } else if (inherits(ht_list, "Heatmap")) {
    ht <- ht_list
    dend_width <- max(ht@row_dend_param$width, dend_width)
    dend_height <- max(ht@column_dend_param$height, dend_height)
    name_width <- max(ht@row_names_param$max_width, name_width)
    name_height <- max(ht@column_names_param$max_height, name_height)
  } else {
    stop("ht_list is not a class of HeatmapList or Heatmap.")
  }

  lgd_width <- convertWidth(unit(unlist(lapply(legend_list, width.Legends)), unitType(width.Legends(legend_list[[1]]))), unitTo = units, valueOnly = TRUE)
  width_sum <- convertWidth(unit(width_sum, units) +
    unit(width_annotation, units) +
    dend_width +
    name_width, units, valueOnly = TRUE) + sum(lgd_width)
  height_sum <- max(
    convertHeight(unit(height_sum, units) +
      unit(height_annotation, units) +
      dend_height +
      name_height, units, valueOnly = TRUE),
    convertHeight(unit(0.95, "npc"), units, valueOnly = TRUE)
  )
  return(list(width_sum = width_sum, height_sum = height_sum))
}

# --- table half ---------------------------------------------------------------
# Reproduce CellCorHeatmap()'s table preparation. srt_ref = NULL means the
# self-reference call: srt_ref <- srt_query and ref_group <- query_group.
# `scp` must contain RunKNNPredict, as_matrix and capitalize (SCP_local in the
# source run, SCP_helpers in the template when only plotting is needed).
scp_cellcor_simil <- function(srt_query, srt_ref = NULL, bulk_ref = NULL,
                              query_group = NULL, ref_group = NULL,
                              query_assay = NULL, ref_assay = NULL,
                              query_reduction = NULL, ref_reduction = NULL,
                              query_dims = 1:30, ref_dims = 1:30,
                              query_collapsing = !is.null(query_group),
                              ref_collapsing = TRUE,
                              features = NULL, features_type = c("HVF", "DE"),
                              feature_source = "both", nfeatures = 2000,
                              DEtest_param = list(max.cells.per.ident = 200, test.use = "wilcox"),
                              DE_threshold = "p_val_adj < 0.05",
                              distance_metric = "cosine", k = 30,
                              filter_lowfreq = 0, prefix = "KNNPredict",
                              seed = 11, force_recompute = TRUE,
                              scp = SCP_local) {
  set.seed(seed)
  RunKNNPredict <- .scp_cellcor_fun(scp, "RunKNNPredict")
  as_matrix <- .scp_cellcor_fun(scp, "as_matrix")
  capitalize <- .scp_cellcor_fun(scp, "capitalize")

  ref_legend <- TRUE
  simil_method <- c(
    "cosine", "pearson", "spearman", "correlation", "jaccard", "ejaccard", "dice", "edice",
    "hamman", "simple matching", "faith"
  )
  dist_method <- c(
    "euclidean", "chisquared", "kullback", "manhattan", "maximum", "canberra",
    "minkowski", "hamming"
  )
  if (is.null(srt_ref) && is.null(bulk_ref)) {
    srt_ref <- srt_query
    ref_group <- query_group
    ref_assay <- query_assay
    ref_reduction <- query_reduction
    ref_dims <- query_dims
    ref_collapsing <- query_collapsing
    ref_legend <- FALSE
  }
  query_assay <- query_assay %||% Seurat::DefaultAssay(srt_query)
  ref_assay <- ref_assay %||% Seurat::DefaultAssay(srt_ref)
  other_params <- list(
    query_group = query_group, query_reduction = query_reduction, query_assay = query_assay, query_dims = query_dims, query_collapsing = query_collapsing,
    ref_group = ref_group, ref_reduction = ref_reduction, ref_assay = ref_assay, ref_dims = ref_dims, ref_collapsing = ref_collapsing
  )
  cached <- srt_query@tools[[paste0(prefix, "_classification")]]
  if (isTRUE(force_recompute) ||
    is.null(cached[["distance_matrix"]]) ||
    !identical(other_params, cached[["other_params"]])) {
    srt_query <- RunKNNPredict(
      srt_query = srt_query, srt_ref = srt_ref, bulk_ref = bulk_ref,
      query_group = query_group, ref_group = ref_group,
      query_assay = query_assay, ref_assay = ref_assay,
      query_reduction = query_reduction, ref_reduction = ref_reduction, query_dims = query_dims, ref_dims = ref_dims,
      query_collapsing = query_collapsing, ref_collapsing = ref_collapsing,
      features = features, features_type = features_type, feature_source = feature_source, nfeatures = nfeatures,
      DEtest_param = DEtest_param,
      DE_threshold = DE_threshold,
      distance_metric = distance_metric, k = k,
      filter_lowfreq = filter_lowfreq, prefix = prefix,
      nn_method = "raw", return_full_distance_matrix = TRUE
    )
  }
  distance_matrix <- srt_query@tools[[paste0(prefix, "_classification")]][["distance_matrix"]]
  distance_metric <- srt_query@tools[[paste0(prefix, "_classification")]][["distance_metric"]]
  if (distance_metric %in% simil_method) {
    simil_matrix <- t(as_matrix(1 - distance_matrix))
    simil_name <- paste0(capitalize(distance_metric), " similarity")
  } else if (distance_metric %in% dist_method) {
    simil_matrix <- t(as_matrix(1 - distance_matrix / max(distance_matrix, na.rm = TRUE)))
    simil_name <- paste0("1-dist[", distance_metric, "]/max(dist[", distance_metric, "])")
  }
  simil_matrix[is.infinite(simil_matrix)] <- max(abs(simil_matrix[!is.infinite(simil_matrix)]), na.rm = TRUE) * ifelse(simil_matrix[is.infinite(simil_matrix)] > 0, 1, -1)
  simil_matrix[is.na(simil_matrix)] <- 0

  cell_groups <- list()
  if (is.null(query_group)) {
    srt_query@meta.data[["All.groups"]] <- factor("")
    query_group <- "All.groups"
  }
  if (is.null(ref_group)) {
    srt_ref@meta.data[["All.groups"]] <- factor("")
    ref_group <- "All.groups"
  }
  if (!is.factor(srt_query[[query_group, drop = TRUE]])) {
    srt_query@meta.data[[query_group]] <- factor(srt_query[[query_group, drop = TRUE]], levels = unique(srt_query[[query_group, drop = TRUE]]))
  }
  cell_groups[["query_group"]] <- unlist(lapply(levels(srt_query[[query_group, drop = TRUE]]), function(x) {
    cells_sub <- colnames(srt_query)[which(srt_query[[query_group, drop = TRUE]] == x)]
    out <- setNames(object = rep(x, length(cells_sub)), nm = cells_sub)
    return(out)
  }), use.names = TRUE)
  levels <- levels(srt_query[[query_group, drop = TRUE]])
  cell_groups[["query_group"]] <- factor(cell_groups[["query_group"]], levels = levels[levels %in% cell_groups[["query_group"]]])

  if (!is.factor(srt_ref[[ref_group, drop = TRUE]])) {
    srt_ref@meta.data[[ref_group]] <- factor(srt_ref[[ref_group, drop = TRUE]], levels = unique(srt_ref[[ref_group, drop = TRUE]]))
  }
  cell_groups[["ref_group"]] <- unlist(lapply(levels(srt_ref[[ref_group, drop = TRUE]]), function(x) {
    cells_sub <- colnames(srt_ref)[which(srt_ref[[ref_group, drop = TRUE]] == x)]
    out <- setNames(object = rep(x, length(cells_sub)), nm = cells_sub)
    return(out)
  }), use.names = TRUE)
  levels <- levels(srt_ref[[ref_group, drop = TRUE]])
  cell_groups[["ref_group"]] <- factor(cell_groups[["ref_group"]], levels = levels[levels %in% cell_groups[["ref_group"]]])

  if (isTRUE(query_collapsing)) {
    simil_matrix <- simil_matrix[levels(cell_groups[["query_group"]]), , drop = FALSE]
  } else {
    simil_matrix <- simil_matrix[names(cell_groups[["query_group"]]), , drop = FALSE]
  }
  if (isTRUE(ref_collapsing)) {
    simil_matrix <- simil_matrix[, levels(cell_groups[["ref_group"]]), drop = FALSE]
  } else {
    simil_matrix <- simil_matrix[, names(cell_groups[["ref_group"]]), drop = FALSE]
  }

  list(
    simil_matrix = simil_matrix,
    simil_name = simil_name,
    cell_groups = cell_groups,
    query_group = query_group,
    ref_group = ref_group,
    query_collapsing = query_collapsing,
    ref_collapsing = ref_collapsing,
    ref_legend = ref_legend
  )
}

# Lossless long table: one row per matrix cell, with the group annotation and
# display order actually drawn. No aggregation.
scp_cellcor_long_table <- function(fit) {
  mat <- fit$simil_matrix
  n_row <- nrow(mat)
  n_col <- ncol(mat)
  if (fit$query_collapsing) {
    row_group <- rownames(mat)
  } else {
    row_group <- as.character(fit$cell_groups[["query_group"]][rownames(mat)])
  }
  if (fit$ref_collapsing) {
    column_group <- colnames(mat)
  } else {
    column_group <- as.character(fit$cell_groups[["ref_group"]][colnames(mat)])
  }
  out <- expand.grid(
    row = rownames(mat), column = colnames(mat),
    stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE
  )
  out$similarity <- as.vector(mat)
  out$row_group <- rep(row_group, times = n_col)
  out$column_group <- rep(column_group, each = n_row)
  out$row_order <- rep(seq_len(n_row), times = n_col)
  out$column_order <- rep(seq_len(n_col), each = n_row)
  out[, c("row", "column", "similarity", "row_group", "column_group", "row_order", "column_order")]
}

# --- plot half ----------------------------------------------------------------
# Draw one CellCorHeatmap panel from an already computed similarity matrix.
# similarities: square or rectangular numeric matrix with row/column labels.
# row_groups/column_groups: factor (or character) giving the annotation group
# of each row/column, in display order.
plot_scp_cellcor_heatmap <- function(similarities, simil_name = "Cosine similarity",
                                     query_group = "query_group", ref_group = "ref_group",
                                     row_groups = NULL, column_groups = NULL,
                                     query_collapsing = TRUE, ref_collapsing = TRUE,
                                     ref_legend = FALSE,
                                     style = list(), scp = SCP_helpers) {
  palette_scp <- .scp_cellcor_fun(scp, "palette_scp")
  if (!is.matrix(similarities)) similarities <- as.matrix(similarities)
  if (is.null(rownames(similarities)) || is.null(colnames(similarities))) {
    stop("similarities must have row and column labels", call. = FALSE)
  }
  if (is.null(row_groups)) row_groups <- rownames(similarities)
  if (is.null(column_groups)) column_groups <- colnames(similarities)
  row_groups <- factor(as.character(row_groups), levels = unique(as.character(row_groups)))
  column_groups <- factor(as.character(column_groups), levels = unique(as.character(column_groups)))

  simil_matrix <- similarities
  flip <- style$flip %||% FALSE
  cluster_rows <- style$cluster_rows %||% FALSE
  cluster_columns <- style$cluster_columns %||% FALSE
  border <- style$border %||% TRUE
  exp_name <- style$exp_legend_title %||% simil_name
  heatmap_palette <- style$heatmap_palette %||% "RdBu"
  heatmap_palcolor <- style$heatmap_palcolor %||% NULL
  query_group_palette <- style$query_group_palette %||% "Paired"
  query_group_palcolor <- style$query_group_palcolor %||% NULL
  ref_group_palette <- style$ref_group_palette %||% "Paired"
  ref_group_palcolor <- style$ref_group_palcolor %||% NULL
  limits <- style$limits %||% NULL
  row_names_side <- style$row_names_side %||% "left"
  column_names_side <- style$column_names_side %||% "top"
  row_names_rot <- style$row_names_rot %||% 0
  column_names_rot <- style$column_names_rot %||% 90
  row_title_side <- style$row_title_side %||% "left"
  column_title_side <- style$column_title_side %||% "top"
  row_title_rot <- style$row_title_rot %||% 90
  column_title_rot <- style$column_title_rot %||% 0
  nlabel <- style$nlabel %||% 0
  label_cutoff <- style$label_cutoff %||% 0
  label_by <- style$label_by %||% "row"
  label_size <- style$label_size %||% 10
  ht_params <- style$ht_params %||% list()

  if (isTRUE(flip)) {
    cluster_rows_raw <- cluster_rows
    cluster_columns_raw <- cluster_columns
    cluster_rows <- cluster_columns_raw
    cluster_columns <- cluster_rows_raw
  }
  if (is.null(limits)) {
    colors <- circlize::colorRamp2(seq(min(simil_matrix, na.rm = TRUE), max(simil_matrix, na.rm = TRUE), length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
  } else {
    colors <- circlize::colorRamp2(seq(limits[1], limits[2], length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
  }

  lgd <- list()
  lgd[["ht"]] <- Legend(title = exp_name, col_fun = colors, border = TRUE)

  ha_query_list <- NULL
  {
    funbody <- paste0(
      "
        grid.rect(gp = gpar(fill = palette_scp(", paste0("c('", paste0(levels(row_groups), collapse = "','"), "')"), ",palette = '", query_group_palette, "',palcolor=c(", paste0("'", paste0(query_group_palcolor, collapse = "','"), "'"), "))[nm]))
      "
    )
    funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
    eval(parse(text = paste("panel_fun <- function(index, nm) {", funbody, "}", sep = "")), envir = environment())

    anno <- list()
    if (isTRUE(query_collapsing)) {
      anno[[paste0(c("Query", query_group), collapse = ":")]] <- anno_block(
        align_to = split(seq_along(levels(row_groups)), levels(row_groups)),
        panel_fun = getFunction("panel_fun", where = environment()),
        which = ifelse(flip, "column", "row"),
        show_name = FALSE
      )
    } else {
      anno[[paste0(c("Query", query_group), collapse = ":")]] <- anno_block(
        align_to = split(seq_along(row_groups), row_groups),
        panel_fun = getFunction("panel_fun", where = environment()),
        which = ifelse(flip, "column", "row"),
        show_name = FALSE
      )
    }
    ha_cell_group <- do.call("HeatmapAnnotation", args = c(anno, which = ifelse(flip, "column", "row"), show_annotation_name = TRUE, annotation_name_side = ifelse(flip, "left", "bottom"), border = TRUE))
    ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- ha_cell_group
    lgd[[paste0(c("Query", query_group), collapse = ":")]] <- Legend(
      title = paste0(c("Query", query_group), collapse = ":"), labels = levels(row_groups),
      legend_gp = gpar(fill = palette_scp(levels(row_groups), palette = query_group_palette, palcolor = query_group_palcolor)), border = TRUE
    )
  }

  ha_ref_list <- NULL
  {
    funbody <- paste0(
      "
        grid.rect(gp = gpar(fill = palette_scp(", paste0("c('", paste0(levels(column_groups), collapse = "','"), "')"), ",palette = '", ref_group_palette, "',palcolor=c(", paste0("'", paste0(ref_group_palcolor, collapse = "','"), "'"), "))[nm]))
      "
    )
    funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
    eval(parse(text = paste("panel_fun <- function(index, nm) {", funbody, "}", sep = "")), envir = environment())

    anno <- list()
    if (isTRUE(ref_collapsing)) {
      anno[[paste0(c("Ref", ref_group), collapse = ":")]] <- anno_block(
        align_to = split(seq_along(levels(column_groups)), levels(column_groups)),
        panel_fun = getFunction("panel_fun", where = environment()),
        which = ifelse(!flip, "column", "row"),
        show_name = FALSE
      )
    } else {
      anno[[paste0(c("Ref", ref_group), collapse = ":")]] <- anno_block(
        align_to = split(seq_along(column_groups), column_groups),
        panel_fun = getFunction("panel_fun", where = environment()),
        which = ifelse(!flip, "column", "row"),
        show_name = FALSE
      )
    }
    ha_cell_group <- do.call("HeatmapAnnotation", args = c(anno, which = ifelse(!flip, "column", "row"), show_annotation_name = TRUE, annotation_name_side = ifelse(!flip, "left", "bottom"), border = TRUE))
    ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- ha_cell_group
    lgd[[paste0(c("Ref", ref_group), collapse = ":")]] <- Legend(
      title = paste0(c("Ref", ref_group), collapse = ":"), labels = levels(column_groups),
      legend_gp = gpar(fill = palette_scp(levels(column_groups), palette = ref_group_palette, palcolor = ref_group_palcolor)), border = TRUE
    )
  }

  if (!isTRUE(ref_legend)) {
    lgd <- lgd[grep("Ref", names(lgd), invert = TRUE)]
  }

  layer_fun <- function(j, i, x, y, w, h, fill) {
    if (nlabel > 0) {
      if (flip) {
        mat <- t(simil_matrix)
      } else {
        mat <- simil_matrix
      }
      value <- pindex(mat, i, j)
      ind_mat <- restore_matrix(j, i, x, y)

      inds <- NULL
      if (label_by %in% c("row", "both")) {
        for (row in 1:nrow(ind_mat)) {
          ind <- ind_mat[row, ]
          ind <- ind[which(value[ind] >= max(c(sort(value[ind], decreasing = TRUE)[nlabel]), na.rm = TRUE) & value[ind] >= label_cutoff)]
          inds <- c(inds, ind)
        }
      }
      if (label_by %in% c("column", "both")) {
        for (column in 1:ncol(ind_mat)) {
          ind <- ind_mat[, column]
          ind <- ind[which(value[ind] >= max(c(sort(value[ind], decreasing = TRUE)[nlabel]), na.rm = TRUE) & value[ind] >= label_cutoff)]
          inds <- c(inds, ind)
        }
      }
      if (label_by == "both") {
        inds <- inds[duplicated(inds)]
      }
      if (length(inds) > 0) {
        theta <- seq(pi / 8, 2 * pi, length.out = 16)
        lapply(theta, function(i) {
          x_out <- x[inds] + unit(cos(i) * label_size / 30, "mm")
          y_out <- y[inds] + unit(sin(i) * label_size / 30, "mm")
          grid.text(round(value[inds], 2), x = x_out, y = y_out, gp = gpar(fontsize = label_size, col = "white"))
        })
        grid.text(round(value[inds], 2), x[inds], y[inds], gp = gpar(fontsize = label_size, col = "black"))
      }
    }
  }

  ht_list <- NULL
  ht_args <- list(
    name = exp_name,
    matrix = if (flip) t(simil_matrix) else simil_matrix,
    col = colors,
    layer_fun = layer_fun,
    row_title = style$row_title %||% if (flip) paste0(c("Ref", ref_group), collapse = ":") else paste0(c("Query", query_group), collapse = ":"),
    row_title_side = row_title_side,
    column_title = style$column_title %||% if (flip) paste0(c("Query", query_group), collapse = ":") else paste0(c("Ref", ref_group), collapse = ":"),
    column_title_side = column_title_side,
    row_title_rot = row_title_rot,
    column_title_rot = column_title_rot,
    cluster_rows = cluster_rows,
    cluster_columns = cluster_columns,
    show_row_names = style$show_row_names %||% FALSE,
    show_column_names = style$show_column_names %||% FALSE,
    row_names_side = row_names_side,
    column_names_side = column_names_side,
    row_names_rot = row_names_rot,
    column_names_rot = column_names_rot,
    top_annotation = if (flip) ha_query_list[[1]] else ha_ref_list[[1]],
    left_annotation = if (flip) ha_ref_list[[1]] else ha_query_list[[1]],
    show_heatmap_legend = FALSE,
    border = border,
    use_raster = style$use_raster %||% NULL,
    raster_device = style$raster_device %||% "png",
    raster_by_magick = style$raster_by_magick %||% FALSE,
    width = NULL,
    height = NULL
  )
  if (any(names(ht_params) %in% names(ht_args))) {
    warning("ht_params: ", paste0(intersect(names(ht_params), names(ht_args)), collapse = ","), " were duplicated and will not be used.", immediate. = TRUE)
  }
  ht_args <- c(ht_args, ht_params[setdiff(names(ht_params), names(ht_args))])
  if (isTRUE(flip)) {
    if (is.null(ht_list)) {
      ht_list <- do.call(Heatmap, args = ht_args)
    } else {
      ht_list <- ht_list %v% do.call(Heatmap, args = ht_args)
    }
  } else {
    ht_list <- ht_list + do.call(Heatmap, args = ht_args)
  }

  rendersize <- heatmap_rendersize(
    width = NULL, height = NULL, units = "inch",
    ha_top_list = ha_ref_list, ha_left = ha_query_list[[1]], ha_right = NULL,
    ht_list = ht_list, legend_list = lgd, flip = flip
  )
  width_sum <- rendersize[["width_sum"]]
  height_sum <- rendersize[["height_sum"]]
  ht_width <- unit(width_sum, units = "inch")
  ht_height <- unit(height_sum, units = "inch")
  gTree <- grid.grabExpr(
    {
      ComplexHeatmap::draw(ht_list, annotation_legend_list = lgd)
    },
    width = ht_width,
    height = ht_height,
    wrap = TRUE,
    wrap.grobs = TRUE
  )
  p <- wrap_plots(gTree)

  list(
    plot = p,
    simil_matrix = simil_matrix,
    simil_name = simil_name,
    width_sum = width_sum,
    height_sum = height_sum
  )
}
