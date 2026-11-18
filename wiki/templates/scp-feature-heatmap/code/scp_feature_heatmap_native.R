# Native SCP FeatureHeatmap core, split into table and plotting halves.
#
# Source: SCP v0.5.6, R/SCP-plot.R, FeatureHeatmap() (lines 9114-9978),
# commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
#
# Verified branch: one or more group.by variables, split.by = NULL,
# feature_split = NULL, n_split = NULL, cluster_rows/cluster_columns FALSE,
# cell_annotation = feature_annotation = NULL, anno_terms/anno_keys/
# anno_features = FALSE, flip = FALSE, width = height = NULL,
# ht_params = list(), use_raster = NULL.
#
# Table half: scp_feature_heatmap_table() reproduces the matrix_process() step
# of FeatureHeatmap() (lines 9356-9364) from a cell-level expression matrix.
# The drawn matrices are exported as a long table by scp_feature_heatmap_long().
#
# Plot half: plot_scp_feature_heatmap() copies the ComplexHeatmap construction
# used by FeatureHeatmap() lines 9376-9968. Compatibility changes are listed in
# PATCHES.md: matrices/annotations come from tables instead of a Seurat object,
# the enrichment call is skipped because all anno_* flags are FALSE (upstream
# returns res = NULL and ha_right unchanged in that case), and the fixed-size
# branch (heatmap_fixsize/panel_fix_overall) is not implemented.

`%||%` <- function(x, y) if (is.null(x)) y else x

# ---- table half -------------------------------------------------------------

# Copied verbatim from SCP v0.5.6 R/SCP-plot.R lines 7196-7226, GPL (>= 3).
fc_matrix <- function(matrix) {
  matrix / rowMeans(matrix)
}
zscore_matrix <- function(matrix, ...) {
  t(scale(t(matrix), ...))
}
log2fc_matrix <- function(matrix) {
  log2(matrix / rowMeans(matrix))
}
log1p_matrix <- function(matrix) {
  log1p(matrix)
}
matrix_process <- function(matrix, method = c("raw", "zscore", "fc", "log2fc", "log1p"), ...) {
  if (is.function(method)) {
    matrix_processed <- method(matrix, ...)
  } else if (method == "raw") {
    matrix_processed <- matrix
  } else if (method == "fc") {
    matrix_processed <- fc_matrix(matrix)
  } else if (method == "zscore") {
    matrix_processed <- zscore_matrix(matrix, ...)
  } else if (method == "log2fc") {
    matrix_processed <- log2fc_matrix(matrix)
  } else if (method == "log1p") {
    matrix_processed <- log1p_matrix(matrix)
  }
  if (!identical(dim(matrix_processed), dim(matrix))) {
    stop("The dimensions of the matrix are changed after processing")
  }
  return(matrix_processed)
}

# FeatureHeatmap() lines 9356-9364.
# mat_raw: numeric matrix (features x cells), rownames = features_unique.
# cell_groups: named list (one element per group.by variable); each element is a
#   named factor (names = cell, values = group level), already ordered by cell.
scp_feature_heatmap_table <- function(mat_raw, cell_groups, exp_method = "zscore") {
  mat_list <- list()
  for (cell_group in names(cell_groups)) {
    mat_tmp <- mat_raw[, names(cell_groups[[cell_group]]), drop = FALSE]
    mat_tmp <- matrix_process(mat_tmp, method = exp_method)
    mat_tmp[is.infinite(mat_tmp)] <- max(abs(mat_tmp[!is.infinite(mat_tmp)]), na.rm = TRUE) * ifelse(mat_tmp[is.infinite(mat_tmp)] > 0, 1, -1)
    mat_tmp[is.na(mat_tmp)] <- mean(mat_tmp, na.rm = TRUE)
    mat_list[[cell_group]] <- mat_tmp
  }
  mat_list
}

# Long table of the matrices actually drawn: one row per matrix x feature x cell.
# Values are formatted with 17 significant digits so read.csv() round-trips the
# doubles exactly. Rows follow the drawn order (feature_order, cell_order).
scp_feature_heatmap_long <- function(matrices, cell_groups) {
  out <- list()
  for (i in seq_along(matrices)) {
    nm <- names(matrices)[i]
    mat <- matrices[[nm]]
    grp <- cell_groups[[nm]]
    cells <- colnames(mat)
    if (!identical(cells, names(grp))) {
      stop("cell_groups names must match matrix columns for ", nm, call. = FALSE)
    }
    lev <- levels(grp)
    df <- data.frame(
      matrix = rep(nm, length(mat)),
      feature = rep(rownames(mat), times = ncol(mat)),
      cell = rep(cells, each = nrow(mat)),
      group = rep(as.character(grp), each = nrow(mat)),
      value = sprintf("%.17g", as.vector(mat)),
      matrix_order = rep(i, length(mat)),
      feature_order = rep(seq_len(nrow(mat)), times = ncol(mat)),
      cell_order = rep(seq_len(ncol(mat)), each = nrow(mat)),
      group_order = rep(match(as.character(grp), lev), each = nrow(mat)),
      stringsAsFactors = FALSE
    )
    out[[nm]] <- df
  }
  do.call(rbind, out)
}

# ---- plot half --------------------------------------------------------------

# Size helper copied from SCP-plot.R heatmap_rendersize() (lines 7543-7606).
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
  list(width_sum = width_sum, height_sum = height_sum)
}

# Draw one FeatureHeatmap panel.
# matrices: named list (one element per group.by variable) of feature x cell
#   numeric matrices, already transformed (table half).
# cell_groups: named list of named factors (cell -> group level), same order as
#   the matrix columns.
# features: original feature names in row order (may contain duplicates;
#   make.unique() is applied exactly as upstream).
plot_scp_feature_heatmap <- function(matrices, cell_groups, features = NULL,
                                     style = list(), scp = SCP_helpers) {
  palette_scp <- .scp_heatmap_fun(scp, "palette_scp")
  if (is.null(features)) features <- rownames(matrices[[1]])
  if (is.null(names(matrices)) || any(!nzchar(names(matrices)))) {
    stop("matrices must be a named list of matrices", call. = FALSE)
  }
  group.by <- names(matrices)
  raw.group.by <- group.by

  # Unsupported FeatureHeatmap branches (documented in PATCHES.md).
  if (!is.null(style$split.by)) stop("split.by is not implemented in this template", call. = FALSE)
  if (!is.null(style$feature_split) || !is.null(style$n_split)) {
    stop("feature_split/n_split (row slices) are not implemented in this template", call. = FALSE)
  }
  if (!is.null(style$cell_annotation) || !is.null(style$feature_annotation)) {
    stop("cell_annotation/feature_annotation are not implemented in this template", call. = FALSE)
  }
  if (isTRUE(style$anno_terms) || isTRUE(style$anno_keys) || isTRUE(style$anno_features)) {
    stop("anno_terms/anno_keys/anno_features are not implemented in this template", call. = FALSE)
  }

  flip <- style$flip %||% FALSE
  cluster_rows <- style$cluster_rows %||% FALSE
  cluster_columns <- style$cluster_columns %||% FALSE
  cluster_row_slices <- style$cluster_row_slices %||% FALSE
  cluster_column_slices <- style$cluster_column_slices %||% FALSE
  border <- style$border %||% TRUE
  use_raster <- style$use_raster %||% NULL
  raster_device <- style$raster_device %||% "png"
  raster_by_magick <- style$raster_by_magick %||% FALSE
  width <- style$width %||% NULL
  height <- style$height %||% NULL
  units <- style$units %||% "inch"
  row_title <- style$row_title %||% NULL
  column_title <- style$column_title %||% NULL
  row_title_side <- style$row_title_side %||% "left"
  column_title_side <- style$column_title_side %||% "top"
  row_title_rot <- style$row_title_rot %||% 0
  column_title_rot <- style$column_title_rot %||% ifelse(flip, 90, 0)
  show_row_names <- style$show_row_names %||% FALSE
  show_column_names <- style$show_column_names %||% FALSE
  row_names_side <- style$row_names_side %||% ifelse(flip, "left", "right")
  column_names_side <- style$column_names_side %||% ifelse(flip, "bottom", "top")
  row_names_rot <- style$row_names_rot %||% 0
  column_names_rot <- style$column_names_rot %||% 90
  ht_params <- style$ht_params %||% list()

  if (isTRUE(flip)) {
    cluster_rows_raw <- cluster_rows
    cluster_columns_raw <- cluster_columns
    cluster_row_slices_raw <- cluster_row_slices
    cluster_column_slices_raw <- cluster_column_slices
    cluster_rows <- cluster_columns_raw
    cluster_columns <- cluster_rows_raw
    cluster_row_slices <- cluster_column_slices_raw
    cluster_column_slices <- cluster_row_slices_raw
  }

  features_unique <- make.unique(features)
  feature_metadata <- data.frame(
    row.names = features_unique,
    features = features,
    features_uique = features_unique,
    stringsAsFactors = FALSE
  )
  feature_metadata[, "duplicated"] <- feature_metadata[["features"]] %in% features[duplicated(features)]
  feature_metadata[["feature_split"]] <- NA

  group_palette <- style$group_palette %||% "Paired"
  if (length(group_palette) == 1) {
    group_palette <- rep(group_palette, length(group.by))
  }
  if (length(group_palette) != length(group.by)) {
    stop("'group_palette' must be the same length as 'group.by'", call. = FALSE)
  }
  group_palette <- setNames(group_palette, nm = group.by)
  raw.group_palette <- group_palette
  group_palcolor <- style$group_palcolor %||% NULL
  if (!is.null(group_palcolor) && !is.list(group_palcolor)) group_palcolor <- list(group_palcolor)

  # Group levels: observed levels by default; can be extended explicitly so an
  # empty factor level keeps upstream's palette positions.
  group_levels <- style$group_levels %||% NULL
  if (is.null(group_levels)) {
    group_levels <- lapply(cell_groups, levels)
  }
  for (i in seq_along(group.by)) {
    cell_group <- group.by[i]
    if (!identical(levels(cell_groups[[cell_group]]), as.character(group_levels[[i]]))) {
      cell_groups[[cell_group]] <- factor(
        as.character(cell_groups[[cell_group]]),
        levels = as.character(group_levels[[i]])
      )
      names(cell_groups[[cell_group]]) <- colnames(matrices[[cell_group]])
    }
  }

  feature_split_by <- group.by
  mat_list <- matrices
  mat_split <- do.call(cbind, mat_list[feature_split_by])

  exp_method <- style$exp_method %||% "zscore"
  limits <- style$limits %||% NULL
  heatmap_palette <- style$heatmap_palette %||% "RdBu"
  heatmap_palcolor <- style$heatmap_palcolor %||% NULL
  if (is.null(limits)) {
    if (!is.function(exp_method) && exp_method %in% c("zscore", "log2fc")) {
      b <- ceiling(min(abs(quantile(do.call(cbind, mat_list), c(0.01, 0.99), na.rm = TRUE)), na.rm = TRUE) * 2) / 2
      colors <- circlize::colorRamp2(seq(-b, b, length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
    } else {
      b <- quantile(do.call(cbind, mat_list), c(0.01, 0.99), na.rm = TRUE)
      colors <- circlize::colorRamp2(seq(b[1], b[2], length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
    }
  } else {
    colors <- circlize::colorRamp2(seq(limits[1], limits[2], length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
  }

  exp_name <- style$exp_legend_title %||% "zscore(normalized counts)"
  lgd <- list()
  lgd[["ht"]] <- Legend(title = exp_name, col_fun = colors, border = TRUE)

  cell_metadata <- data.frame(
    row.names = colnames(mat_list[[1]]),
    cells = colnames(mat_list[[1]]),
    stringsAsFactors = FALSE
  )
  for (cell_group in group.by) {
    cell_metadata[[cell_group]] <- as.character(cell_groups[[cell_group]])[rownames(cell_metadata)]
  }

  ha_top_list <- NULL
  cluster_columns_list <- list()
  column_split_list <- list()
  for (i in seq_along(group.by)) {
    cell_group <- group.by[i]
    cluster_columns_list[[cell_group]] <- cluster_columns
    column_split_list[[cell_group]] <- cell_groups[[cell_group]]
    if (isTRUE(cluster_column_slices)) {
      if (!isTRUE(cluster_columns)) {
        if (nlevels(column_split_list[[cell_group]]) == 1) {
          stop("cluster_column_slices=TRUE can not be used when there is only one group.")
        }
        dend <- cluster_within_group(mat_list[[cell_group]], column_split_list[[cell_group]])
        cluster_columns_list[[cell_group]] <- dend
        column_split_list[[cell_group]] <- length(unique(column_split_list[[cell_group]]))
      }
    }
    if (cell_group != "All.groups") {
      lev <- as.character(group_levels[[i]])
      palcolor <- if (is.null(group_palcolor)) NULL else group_palcolor[[i]]
      funbody <- paste0(
        "\ngrid.rect(gp = gpar(fill = palette_scp(",
        paste0("c('", paste0(lev, collapse = "','"), "')"),
        ",palette = '", group_palette[i], "',palcolor=c(",
        paste0("'", paste0(palcolor, collapse = "','"), "'"), "))[nm]))\n"
      )
      funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
      eval(parse(text = paste("panel_fun <- function(index, nm) {", funbody, "}", sep = "")), envir = environment())

      anno <- list()
      anno[[cell_group]] <- anno_block(
        align_to = split(seq_along(cell_groups[[cell_group]]), gsub(pattern = " : .*", replacement = "", x = cell_groups[[cell_group]])),
        panel_fun = getFunction("panel_fun", where = environment()),
        which = ifelse(flip, "row", "column"),
        show_name = FALSE
      )
      ha_cell_group <- do.call("HeatmapAnnotation", args = c(anno, which = ifelse(flip, "row", "column"), show_annotation_name = TRUE, annotation_name_side = ifelse(flip, "top", "left"), border = TRUE))
      ha_top_list[[cell_group]] <- ha_cell_group
    }
  }
  for (i in seq_along(raw.group.by)) {
    cell_group <- raw.group.by[i]
    if (cell_group != "All.groups") {
      lev <- as.character(group_levels[[i]])
      palcolor <- if (is.null(group_palcolor)) NULL else group_palcolor[[i]]
      lgd[[cell_group]] <- Legend(
        title = cell_group, labels = lev,
        legend_gp = gpar(fill = palette_scp(lev, palette = raw.group_palette[i], palcolor = palcolor)), border = TRUE
      )
    }
  }

  row_split <- NULL
  ha_left <- NULL
  cell_group <- group.by[1]
  ht_args <- list(
    name = cell_group,
    matrix = mat_list[[cell_group]],
    col = colors,
    row_split = row_split,
    column_split = column_split_list[[cell_group]],
    cluster_rows = cluster_rows,
    cluster_columns = cluster_columns_list[[cell_group]],
    cluster_row_slices = cluster_row_slices,
    cluster_column_slices = cluster_column_slices,
    use_raster = TRUE
  )
  ht_args <- c(ht_args, ht_params[setdiff(names(ht_params), names(ht_args))])
  ht_list <- do.call(Heatmap, args = ht_args)
  features_ordered <- rownames(mat_list[[1]])[unlist(suppressWarnings(row_order(ht_list)))]
  feature_metadata[["index"]] <- setNames(object = seq_along(features_ordered), nm = features_ordered)[rownames(feature_metadata)]

  nlabel <- style$nlabel %||% 20
  features_label <- style$features_label %||% NULL
  label_size <- style$label_size %||% 10
  label_color <- style$label_color %||% "black"
  if (is.null(features_label)) {
    if (nlabel > 0) {
      if (length(features) > nlabel) {
        index_from <- ceiling((length(features_ordered) / nlabel) / 2)
        index_to <- length(features_ordered)
        index <- unique(round(seq(from = index_from, to = index_to, length.out = nlabel)))
      } else {
        index <- seq_along(features_ordered)
      }
    } else {
      index <- NULL
    }
  } else {
    index <- which(features_ordered %in% features_label)
    drop <- setdiff(features_label, features_ordered)
    if (length(drop) > 0) {
      warning(paste0(paste0(drop, collapse = ","), "was not found in the features"), immediate. = TRUE)
    }
  }
  if (length(index) > 0) {
    ha_mark <- HeatmapAnnotation(
      gene = anno_mark(
        at = which(rownames(feature_metadata) %in% features_ordered[index]),
        labels = feature_metadata[which(rownames(feature_metadata) %in% features_ordered[index]), "features"],
        side = ifelse(flip, "top", "left"),
        labels_gp = gpar(fontsize = label_size, col = label_color),
        link_gp = gpar(fontsize = label_size, col = label_color),
        which = ifelse(flip, "column", "row")
      ),
      which = ifelse(flip, "column", "row"), show_annotation_name = FALSE
    )
    if (is.null(ha_left)) {
      ha_left <- ha_mark
    } else {
      ha_left <- c(ha_mark, ha_left)
    }
  }

  ha_right <- NULL
  # heatmap_enrichment() is omitted: with anno_terms/anno_keys/anno_features
  # all FALSE it returns res = NULL and ha_right unchanged (upstream lines
  # 9800-9814), so the drawn object is identical.

  ht_list <- NULL
  for (cell_group in group.by) {
    if (cell_group == group.by[1]) {
      left_annotation <- ha_left
    } else {
      left_annotation <- NULL
    }
    if (cell_group == group.by[length(group.by)]) {
      right_annotation <- ha_right
    } else {
      right_annotation <- NULL
    }

    ht_args <- list(
      name = cell_group,
      matrix = if (flip) t(mat_list[[cell_group]]) else mat_list[[cell_group]],
      col = colors,
      row_title = row_title %||% if (flip) ifelse(cell_group != "All.groups", cell_group, "") else character(0),
      row_title_side = row_title_side,
      column_title = column_title %||% if (flip) character(0) else ifelse(cell_group != "All.groups", cell_group, ""),
      column_title_side = column_title_side,
      row_title_rot = row_title_rot,
      column_title_rot = column_title_rot,
      row_split = if (flip) column_split_list[[cell_group]] else row_split,
      column_split = if (flip) row_split else column_split_list[[cell_group]],
      cluster_rows = if (flip) cluster_columns_list[[cell_group]] else cluster_rows,
      cluster_columns = if (flip) cluster_rows else cluster_columns_list[[cell_group]],
      cluster_row_slices = if (flip) cluster_column_slices else cluster_row_slices,
      cluster_column_slices = if (flip) cluster_row_slices else cluster_column_slices,
      show_row_names = show_row_names,
      show_column_names = show_column_names,
      row_names_side = row_names_side,
      column_names_side = column_names_side,
      row_names_rot = row_names_rot,
      column_names_rot = column_names_rot,
      top_annotation = if (flip) left_annotation else ha_top_list[[cell_group]],
      left_annotation = if (flip) ha_top_list[[cell_group]] else left_annotation,
      bottom_annotation = if (flip) right_annotation else NULL,
      right_annotation = if (flip) NULL else right_annotation,
      show_heatmap_legend = FALSE,
      border = border,
      use_raster = use_raster,
      raster_device = raster_device,
      raster_by_magick = raster_by_magick,
      width = if (is.numeric(width[cell_group])) unit(width[cell_group], units = units) else NULL,
      height = if (is.numeric(height[cell_group])) unit(height[cell_group], units = units) else NULL
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
  }

  if ((!is.null(row_split) && length(index) > 0) || !is.null(width) || !is.null(height)) {
    stop("The fixed-size heatmap branch (width/height/row_split with labels) is not implemented in this template.", call. = FALSE)
  }
  fix <- FALSE

  rendersize <- heatmap_rendersize(
    width = width, height = height, units = units,
    ha_top_list = ha_top_list, ha_left = ha_left, ha_right = ha_right,
    ht_list = ht_list, legend_list = lgd, flip = flip
  )
  width_sum <- rendersize[["width_sum"]]
  height_sum <- rendersize[["height_sum"]]

  ht_width <- unit(width_sum, units = units)
  ht_height <- unit(height_sum, units = units)
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
    matrix_list = mat_list,
    feature_split = NULL,
    cell_metadata = cell_metadata,
    feature_metadata = feature_metadata,
    enrichment = NULL
  )
}

.scp_heatmap_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}
