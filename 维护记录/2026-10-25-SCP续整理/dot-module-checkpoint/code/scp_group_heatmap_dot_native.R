# Native SCP GroupHeatmap add_dot panel core, split into table and plotting
# halves.
#
# Source: SCP v0.5.6, R/SCP-plot.R, GroupHeatmap() (lines 7911-9036),
# commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
#
# Table half: scp_group_heatmap_matrix() (prepare/; needs Seurat + SCP_local,
# reference/capture side only) reproduces matrix_list and the internal
# mat_perc_list = fraction of cells with (lib-normalized) value > exp_cutoff.
#
# Plot half: plot_scp_group_heatmap_dot() copies the upstream add_dot path:
# one Heatmap per group.by variable, no split.by, no feature split, no
# cell/feature annotation, no add_violin, cluster_rows = cluster_columns =
# FALSE, fix = FALSE, add_dot = TRUE. The layer_fun body and the "Percent"
# point-size legend are verbatim upstream blocks; matrices and metadata come
# from tables instead of a Seurat object. Supported style switches:
# add_dot (must be TRUE here), add_reticle, reticle_color, dot_size_mm.
# flip / add_violin / feature_split / annotation branches are NOT implemented
# in this module and are rejected explicitly.

`%||%` <- function(x, y) if (is.null(x)) y else x

# Size helper copied from SCP-plot.R heatmap_rendersize().
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

# Plot one GroupHeatmap add_dot panel from aggregated matrices.
# matrices/percent: named list (one element per group.by variable) of
# feature x group numeric matrices, already aggregated/transformed; percent is
# the per-group fraction of cells above exp_cutoff (0-1), NOT derivable from
# the zscore means in `matrices`.
# features: character vector in the desired row order (may contain duplicates;
# make.unique() is applied exactly as upstream).
plot_scp_group_heatmap_dot <- function(matrices, percent, features = NULL,
                                       style = list(), scp = SCP_helpers) {
  palette_scp <- .scp_heatmap_fun(scp, "palette_scp")

  add_dot <- isTRUE(style$add_dot %||% TRUE)
  if (!add_dot) {
    stop("This module implements only the add_dot=TRUE branch; use the ht1 heatmap template for add_dot=FALSE", call. = FALSE)
  }
  if (isTRUE(style$add_violin)) {
    stop("add_violin branch is not implemented in this module", call. = FALSE)
  }
  if (isTRUE(style$flip)) {
    stop("flip=TRUE is not implemented for the add_dot branch (upstream transposes mat_perc); flip not verified", call. = FALSE)
  }
  if (is.null(style$n_split) == FALSE || !is.null(style$feature_split) || !is.null(style$cell_annotation) || !is.null(style$feature_annotation)) {
    stop("feature_split/n_split/cell_annotation/feature_annotation are not implemented in this module", call. = FALSE)
  }
  add_reticle <- isTRUE(style$add_reticle)
  reticle_color <- style$reticle_color %||% "grey"
  dot_size <- if (!is.null(style$dot_size_mm)) {
    unit(as.numeric(style$dot_size_mm), "mm")
  } else {
    unit(8, "mm") # upstream default: dot_size = unit(8, "mm")
  }

  if (is.null(percent)) {
    stop("add_dot=TRUE requires `percent`: per-matrix fraction of cells with value > exp_cutoff (0-1)", call. = FALSE)
  }
  if (!is.list(percent) || !identical(names(percent), names(matrices))) {
    stop("percent must be a named list with the same matrix names as `matrices`", call. = FALSE)
  }
  for (nm in names(matrices)) {
    pm <- percent[[nm]]
    vm <- matrices[[nm]]
    if (is.null(pm) || !is.matrix(pm) || !identical(dim(pm), dim(vm)) ||
        !identical(rownames(pm), rownames(vm)) || !identical(colnames(pm), colnames(vm))) {
      stop("percent matrix for `", nm, "` must have the same dimnames as the value matrix", call. = FALSE)
    }
    if (any(!is.finite(pm))) {
      stop("percent matrix for `", nm, "` has non-finite values", call. = FALSE)
    }
    if (any(pm < 0 | pm > 1)) {
      stop("percent must be in [0, 1], not 0-100", call. = FALSE)
    }
  }

  if (is.null(features)) features <- rownames(matrices[[1]])
  if (is.null(names(matrices)) || any(!nzchar(names(matrices)))) {
    stop("matrices must be a named list of matrices", call. = FALSE)
  }
  group.by <- names(matrices)
  raw.group.by <- group.by
  features_unique <- make.unique(features)
  feature_metadata <- data.frame(
    row.names = features_unique,
    features = features,
    features_uique = features_unique,
    stringsAsFactors = FALSE
  )
  feature_metadata[, "duplicated"] <- feature_metadata[["features"]] %in% features[duplicated(features)]
  feature_metadata[["feature_split"]] <- NA

  cell_groups <- list()
  for (cell_group in group.by) {
    lev <- colnames(matrices[[cell_group]])
    cell_groups[[cell_group]] <- setNames(factor(lev, levels = lev), lev)
  }

  group_palette <- style$group_palette %||% "Paired"
  if (length(group_palette) == 1) group_palette <- rep(group_palette, length(group.by))
  if (length(group_palette) != length(group.by)) {
    stop("group_palette must have length 1 or length(group.by)", call. = FALSE)
  }
  group_palette <- setNames(group_palette, group.by)
  group_palcolor <- style$group_palcolor %||% NULL
  if (!is.null(group_palcolor) && !is.list(group_palcolor)) group_palcolor <- list(group_palcolor)

  feature_split_by <- style$feature_split_by %||% group.by
  if (any(!feature_split_by %in% group.by)) {
    stop("feature_split_by must be a subset of group.by", call. = FALSE)
  }

  exp_method <- style$exp_method %||% "zscore"
  limits <- style$limits %||% NULL
  heatmap_palette <- style$heatmap_palette %||% "RdBu"
  heatmap_palcolor <- style$heatmap_palcolor %||% NULL
  if (is.null(limits)) {
    if (exp_method %in% c("zscore", "log2fc")) {
      b <- ceiling(min(abs(quantile(do.call(cbind, matrices), c(0.01, 0.99), na.rm = TRUE)), na.rm = TRUE) * 2) / 2
      colors <- circlize::colorRamp2(seq(-b, b, length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
    } else {
      b <- quantile(do.call(cbind, matrices), c(0.01, 0.99), na.rm = TRUE)
      colors <- circlize::colorRamp2(seq(b[1], b[2], length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
    }
  } else {
    colors <- circlize::colorRamp2(seq(limits[1], limits[2], length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
  }

  exp_name <- style$exp_legend_title %||% "zscore(normalized counts)"
  lgd <- list()
  lgd[["ht"]] <- Legend(title = exp_name, col_fun = colors, border = TRUE)
  # Upstream add_dot point-size legend (verbatim block).
  lgd[["point"]] <- Legend(
    labels = paste0(seq(20, 100, length.out = 5), "%"),
    title = "Percent",
    type = "points",
    pch = 21,
    size = dot_size * seq(0.2, 1, length.out = 5),
    grid_height = dot_size * seq(0.2, 1, length.out = 5) * 0.8,
    grid_width = dot_size,
    legend_gp = gpar(fill = "grey30"),
    border = FALSE,
    background = "transparent",
    direction = "vertical"
  )

  ha_top_list <- NULL
  cluster_columns_list <- list()
  column_split_list <- list()
  for (i in seq_along(group.by)) {
    cell_group <- group.by[i]
    cluster_columns_list[[cell_group]] <- FALSE
    column_split_list[[cell_group]] <- NULL
    if (cell_group != "All.groups") {
      lev <- levels(cell_groups[[cell_group]])
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
        align_to = split(seq_along(lev), gsub(pattern = " : .*", replacement = "", x = lev)),
        panel_fun = getFunction("panel_fun", where = environment()),
        which = "column",
        show_name = FALSE
      )
      ha_cell_group <- do.call("HeatmapAnnotation", args = c(anno, which = "column", show_annotation_name = TRUE, annotation_name_side = "left", border = TRUE))
      ha_top_list[[cell_group]] <- ha_cell_group
    }
  }

  for (i in seq_along(raw.group.by)) {
    cell_group <- raw.group.by[i]
    if (cell_group != "All.groups") {
      lev <- levels(cell_groups[[cell_group]])
      palcolor <- if (is.null(group_palcolor)) NULL else group_palcolor[[i]]
      lgd[[cell_group]] <- Legend(
        title = cell_group, labels = lev,
        legend_gp = gpar(fill = palette_scp(lev, palette = group_palette[i], palcolor = palcolor)), border = TRUE
      )
    }
  }

  row_split <- NULL
  ha_left <- NULL
  cell_group <- group.by[1]
  ht_args <- list(
    matrix = matrices[[cell_group]],
    col = colors,
    row_split = row_split,
    column_split = column_split_list[[cell_group]],
    cluster_rows = FALSE,
    cluster_columns = cluster_columns_list[[cell_group]],
    cluster_row_slices = FALSE,
    cluster_column_slices = FALSE,
    use_raster = TRUE
  )
  ht_list <- do.call(Heatmap, args = ht_args)
  features_ordered <- rownames(matrices[[1]])[unlist(suppressWarnings(row_order(ht_list)))]
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
        side = "left",
        labels_gp = gpar(fontsize = label_size, col = label_color),
        link_gp = gpar(fontsize = label_size, col = label_color),
        which = "row"
      ),
      which = "row", show_annotation_name = FALSE
    )
    if (is.null(ha_left)) {
      ha_left <- ha_mark
    } else {
      ha_left <- c(ha_mark, ha_left)
    }
  }

  ht_list <- NULL
  for (cell_group in group.by) {
    left_annotation <- if (cell_group == group.by[1]) ha_left else NULL
    # Upstream layer_fun body for the add_dot branch (add_violin/add_bg not
    # implemented; add_reticle verbatim when enabled).
    funbody <- paste0(
      "grid.rect(x, y,
          width = width, height = height,
          gp = gpar(col = 'white', lwd = 1, fill = 'white')
        );",
      if (isTRUE(add_reticle)) {
        paste0("
        ind_mat = restore_matrix(j, i, x, y);
        ind_top = ind_mat[1,];
        ind_left = ind_mat[,1];
        for(col in seq_len(ncol(ind_mat))){
          grid.lines(x = unit(rep(x[ind_top[col]],each=2),'npc'),y = unit(c(0,1),'npc'),gp = gpar(col = '", reticle_color, "', lwd = 1.5));
        };
        for(row in seq_len(nrow(ind_mat))){
          grid.lines(x = unit(c(0,1),'npc'),y = unit(rep(y[ind_left[row]],each=2),'npc'),gp = gpar(col = '", reticle_color, "', lwd = 1.5));
        };
        ")
      },
      paste0("perc <- pindex(percent[['", cell_group, "']], i, j);
        grid.points(x, y,
          pch = 21,
          size = dot_size*perc,
          gp = gpar(col = 'black', lwd = 1, fill = fill)
        );
        ")
    )
    funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
    eval(parse(text = paste("layer_fun <- function(j, i, x, y, width, height, fill) {", funbody, "}", sep = "")), envir = environment())
    ht_args <- list(
      name = cell_group,
      matrix = matrices[[cell_group]],
      col = colors,
      layer_fun = getFunction("layer_fun", where = environment()),
      row_title = character(0),
      row_title_side = "left",
      column_title = ifelse(cell_group != "All.groups", cell_group, ""),
      column_title_side = "top",
      row_title_rot = 0,
      column_title_rot = 0,
      row_split = row_split,
      column_split = column_split_list[[cell_group]],
      cluster_rows = FALSE,
      cluster_columns = cluster_columns_list[[cell_group]],
      cluster_row_slices = FALSE,
      cluster_column_slices = FALSE,
      show_row_names = FALSE,
      show_column_names = FALSE,
      row_names_side = "right",
      column_names_side = "top",
      row_names_rot = 0,
      column_names_rot = 90,
      top_annotation = ha_top_list[[cell_group]],
      left_annotation = left_annotation,
      bottom_annotation = NULL,
      right_annotation = NULL,
      show_heatmap_legend = FALSE,
      border = TRUE,
      use_raster = NULL,
      raster_device = "png",
      raster_by_magick = FALSE,
      width = NULL,
      height = NULL
    )
    ht_list <- ht_list + do.call(Heatmap, args = ht_args)
  }

  rendersize <- heatmap_rendersize(
    width = NULL, height = NULL, units = "inch",
    ha_top_list = ha_top_list, ha_left = ha_left, ha_right = NULL,
    ht_list = ht_list, legend_list = lgd, flip = FALSE
  )
  ht_width <- unit(rendersize[["width_sum"]], units = "inch")
  ht_height <- unit(rendersize[["height_sum"]], units = "inch")
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
    matrix_list = matrices,
    percent_list = percent,
    feature_split = NULL,
    cell_groups = cell_groups,
    feature_metadata = feature_metadata
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
