# Read-only excerpt from SCP v0.5.6 R/SCP-plot.R, CellCorHeatmap().
# Source: https://github.com/zhanghao-njmu/scp
# Commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
# Lines 10113-11019; the template core is a split copy, not this file.

CellCorHeatmap <- function(srt_query, srt_ref = NULL, bulk_ref = NULL,
                           query_group = NULL, ref_group = NULL,
                           query_assay = NULL, ref_assay = NULL,
                           query_reduction = NULL, ref_reduction = NULL,
                           query_dims = 1:30, ref_dims = 1:30,
                           query_collapsing = !is.null(query_group), ref_collapsing = TRUE,
                           features = NULL, features_type = c("HVF", "DE"), feature_source = "both", nfeatures = 2000,
                           DEtest_param = list(max.cells.per.ident = 200, test.use = "wilcox"),
                           DE_threshold = "p_val_adj < 0.05",
                           distance_metric = "cosine", k = 30,
                           filter_lowfreq = 0, prefix = "KNNPredict", exp_legend_title = NULL,
                           border = TRUE, flip = FALSE, limits = NULL,
                           cluster_rows = FALSE, cluster_columns = FALSE,
                           show_row_names = FALSE, show_column_names = FALSE, row_names_side = "left", column_names_side = "top", row_names_rot = 0, column_names_rot = 90,
                           row_title = NULL, column_title = NULL, row_title_side = "left", column_title_side = "top", row_title_rot = 90, column_title_rot = 0,
                           nlabel = 0, label_cutoff = 0, label_by = "row", label_size = 10,
                           heatmap_palette = "RdBu", heatmap_palcolor = NULL,
                           query_group_palette = "Paired", query_group_palcolor = NULL,
                           ref_group_palette = "simspec", ref_group_palcolor = NULL,
                           query_cell_annotation = NULL, query_cell_annotation_palette = "Paired", query_cell_annotation_palcolor = NULL, query_cell_annotation_params = if (flip) list(height = unit(10, "mm")) else list(width = unit(10, "mm")),
                           ref_cell_annotation = NULL, ref_cell_annotation_palette = "Paired", ref_cell_annotation_palcolor = NULL, ref_cell_annotation_params = if (flip) list(width = unit(10, "mm")) else list(height = unit(10, "mm")),
                           use_raster = NULL, raster_device = "png", raster_by_magick = FALSE, height = NULL, width = NULL, units = "inch",
                           seed = 11, ht_params = list()) {
  set.seed(seed)
  if (isTRUE(raster_by_magick)) {
    check_R("magick")
  }

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
    ref_group_palette <- query_group_palette
    ref_group_palcolor <- query_group_palcolor
    ref_cell_annotation <- query_cell_annotation
    ref_cell_annotation_palette <- query_cell_annotation_palette
    ref_cell_annotation_palcolor <- query_cell_annotation_palcolor
    ref_legend <- FALSE
  }
  if (!is.null(bulk_ref)) {
    srt_ref <- CreateSeuratObject(counts = bulk_ref, meta.data = data.frame(celltype = colnames(bulk_ref)), assay = "RNA")
    ref_group <- "CellType"
    ref_assay <- "RNA"
    ref_reduction <- NULL
    ref_collapsing <- FALSE
  }
  query_assay <- query_assay %||% DefaultAssay(srt_query)
  ref_assay <- ref_assay %||% DefaultAssay(srt_ref)
  other_params <- list(
    query_group = query_group, query_reduction = query_reduction, query_assay = query_assay, query_dims = query_dims, query_collapsing = query_collapsing,
    ref_group = ref_group, ref_reduction = ref_reduction, ref_assay = ref_assay, ref_dims = ref_dims, ref_collapsing = ref_collapsing
  )
  if (is.null(srt_query@tools[[paste0(prefix, "_classification")]][["distance_matrix"]]) ||
    !identical(other_params, srt_query@tools[[paste0(prefix, "_classification")]][["other_params"]])) {
    srt_query <- RunKNNPredict(
      srt_query = srt_query, srt_ref = srt_ref,
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
  exp_name <- exp_legend_title %||% simil_name

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

  if (!is.null(query_cell_annotation)) {
    if (length(query_cell_annotation_palette) == 1) {
      query_cell_annotation_palette <- rep(query_cell_annotation_palette, length(query_cell_annotation))
    }
    if (length(query_cell_annotation_palcolor) == 1) {
      query_cell_annotation_palcolor <- rep(query_cell_annotation_palcolor, length(query_cell_annotation))
    }
    npal <- unique(c(length(query_cell_annotation_palette), length(query_cell_annotation_palcolor), length(query_cell_annotation)))
    if (length(npal[npal != 0]) > 1) {
      stop("query_cell_annotation_palette and query_cell_annotation_palcolor must be the same length as query_cell_annotation")
    }
    if (any(!query_cell_annotation %in% c(colnames(srt_query@meta.data), rownames(srt_query[[query_assay]])))) {
      stop("query_cell_annotation: ", paste0(query_cell_annotation[!query_cell_annotation %in% c(colnames(srt_query@meta.data), rownames(srt_query[[query_assay]]))], collapse = ","), " is not in the Seurat object.")
    }
  }
  if (!is.null(ref_cell_annotation)) {
    if (length(ref_cell_annotation_palette) == 1) {
      ref_cell_annotation_palette <- rep(ref_cell_annotation_palette, length(ref_cell_annotation))
    }
    if (length(ref_cell_annotation_palcolor) == 1) {
      ref_cell_annotation_palcolor <- rep(ref_cell_annotation_palcolor, length(ref_cell_annotation))
    }
    npal <- unique(c(length(ref_cell_annotation_palette), length(ref_cell_annotation_palcolor), length(ref_cell_annotation)))
    if (length(npal[npal != 0]) > 1) {
      stop("ref_cell_annotation_palette and ref_cell_annotation_palcolor must be the same length as ref_cell_annotation")
    }
    if (any(!ref_cell_annotation %in% c(colnames(srt_ref@meta.data), rownames(srt_ref[[ref_assay]])))) {
      stop("ref_cell_annotation: ", paste0(ref_cell_annotation[!ref_cell_annotation %in% c(colnames(srt_ref@meta.data), rownames(srt_ref[[ref_assay]]))], collapse = ","), " is not in the Seurat object.")
    }
  }

  if (isTRUE(flip)) {
    cluster_rows_raw <- cluster_rows
    cluster_columns_raw <- cluster_columns
    cluster_rows <- cluster_columns_raw
    cluster_columns <- cluster_rows_raw
  }
  if (is.null(limits)) {
    colors <- colorRamp2(seq(min(simil_matrix, na.rm = TRUE), max(simil_matrix, na.rm = TRUE), length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
  } else {
    colors <- colorRamp2(seq(limits[1], limits[2], length = 100), palette_scp(palette = heatmap_palette, palcolor = heatmap_palcolor))
  }

  cell_metadata <- data.frame(
    row.names = c(paste0("query_", colnames(srt_query)), paste0("ref_", colnames(srt_ref))),
    cells = c(colnames(srt_query), colnames(srt_ref))
  )
  query_metadata <- cbind.data.frame(
    srt_query@meta.data[cell_metadata[["cells"]], c(query_group, intersect(query_cell_annotation, colnames(srt_query@meta.data))), drop = FALSE],
    as.data.frame(t(srt_query[[query_assay]]@data[intersect(query_cell_annotation, rownames(srt_query[[query_assay]])) %||% integer(), , drop = FALSE]))[cell_metadata[["cells"]], , drop = FALSE]
  )
  colnames(query_metadata) <- paste0("query_", colnames(query_metadata))
  ref_metadata <- cbind.data.frame(
    srt_ref@meta.data[cell_metadata[["cells"]], c(ref_group, intersect(ref_cell_annotation, colnames(srt_ref@meta.data))), drop = FALSE],
    as.data.frame(t(srt_ref[[ref_assay]]@data[intersect(ref_cell_annotation, rownames(srt_ref[[ref_assay]])) %||% integer(), , drop = FALSE]))[cell_metadata[["cells"]], , drop = FALSE]
  )
  colnames(ref_metadata) <- paste0("ref_", colnames(ref_metadata))
  cell_metadata <- cbind.data.frame(cell_metadata, cbind.data.frame(query_metadata, ref_metadata))

  lgd <- list()
  lgd[["ht"]] <- Legend(title = exp_name, col_fun = colors, border = TRUE)

  ha_query_list <- NULL
  if (query_group != "All.groups") {
    if (isFALSE(query_collapsing) && ((isFALSE(flip) & isTRUE(cluster_rows)) || (isTRUE(flip) & isTRUE(cluster_columns)))) {
      query_cell_annotation <- c(query_group, query_cell_annotation)
      query_cell_annotation_palette <- c(query_group_palette, query_cell_annotation_palette)
      query_cell_annotation_palcolor <- c(list(query_group_palcolor), query_cell_annotation_palcolor %||% list(NULL))
    } else {
      funbody <- paste0(
        "
        grid.rect(gp = gpar(fill = palette_scp(", paste0("c('", paste0(levels(srt_query[[query_group, drop = TRUE]]), collapse = "','"), "')"), ",palette = '", query_group_palette, "',palcolor=c(", paste0("'", paste0(query_group_palcolor, collapse = "','"), "'"), "))[nm]))
      "
      )
      funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
      eval(parse(text = paste("panel_fun <- function(index, nm) {", funbody, "}", sep = "")), envir = environment())

      anno <- list()
      if (isTRUE(query_collapsing)) {
        anno[[paste0(c("Query", query_group), collapse = ":")]] <- anno_block(
          align_to = split(seq_along(levels(cell_groups[["query_group"]])), levels(cell_groups[["query_group"]])),
          panel_fun = getFunction("panel_fun", where = environment()),
          which = ifelse(flip, "column", "row"),
          show_name = FALSE
        )
      } else {
        anno[[paste0(c("Query", query_group), collapse = ":")]] <- anno_block(
          align_to = split(seq_along(cell_groups[["query_group"]]), cell_groups[["query_group"]]),
          panel_fun = getFunction("panel_fun", where = environment()),
          which = ifelse(flip, "column", "row"),
          show_name = FALSE
        )
      }
      ha_cell_group <- do.call("HeatmapAnnotation", args = c(anno, which = ifelse(flip, "column", "row"), show_annotation_name = TRUE, annotation_name_side = ifelse(flip, "left", "bottom"), border = TRUE))
      ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- ha_cell_group
      lgd[[paste0(c("Query", query_group), collapse = ":")]] <- Legend(
        title = paste0(c("Query", query_group), collapse = ":"), labels = levels(srt_query[[query_group, drop = TRUE]]),
        legend_gp = gpar(fill = palette_scp(levels(srt_query[[query_group, drop = TRUE]]), palette = query_group_palette, palcolor = query_group_palcolor)), border = TRUE
      )
    }
  }

  ha_ref_list <- NULL
  if (ref_group != "All.groups") {
    if (isFALSE(ref_collapsing) && ((isFALSE(flip) & isTRUE(cluster_columns)) || (isTRUE(flip) & isTRUE(cluster_rows)))) {
      ref_cell_annotation <- c(ref_group, ref_cell_annotation)
      ref_cell_annotation_palette <- c(ref_group_palette, ref_cell_annotation_palette)
      ref_cell_annotation_palcolor <- c(list(ref_group_palcolor), ref_cell_annotation_palcolor %||% list(NULL))
    } else {
      funbody <- paste0(
        "
        grid.rect(gp = gpar(fill = palette_scp(", paste0("c('", paste0(levels(srt_ref[[ref_group, drop = TRUE]]), collapse = "','"), "')"), ",palette = '", ref_group_palette, "',palcolor=c(", paste0("'", paste0(ref_group_palcolor, collapse = "','"), "'"), "))[nm]))
      "
      )
      funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
      eval(parse(text = paste("panel_fun <- function(index, nm) {", funbody, "}", sep = "")), envir = environment())

      anno <- list()
      if (isTRUE(ref_collapsing)) {
        anno[[paste0(c("Ref", ref_group), collapse = ":")]] <- anno_block(
          align_to = split(seq_along(levels(cell_groups[["ref_group"]])), levels(cell_groups[["ref_group"]])),
          panel_fun = getFunction("panel_fun", where = environment()),
          which = ifelse(!flip, "column", "row"),
          show_name = FALSE
        )
      } else {
        anno[[paste0(c("Ref", ref_group), collapse = ":")]] <- anno_block(
          align_to = split(seq_along(cell_groups[["ref_group"]]), cell_groups[["ref_group"]]),
          panel_fun = getFunction("panel_fun", where = environment()),
          which = ifelse(!flip, "column", "row"),
          show_name = FALSE
        )
      }
      ha_cell_group <- do.call("HeatmapAnnotation", args = c(anno, which = ifelse(!flip, "column", "row"), show_annotation_name = TRUE, annotation_name_side = ifelse(!flip, "left", "bottom"), border = TRUE))
      ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- ha_cell_group
      lgd[[paste0(c("Ref", ref_group), collapse = ":")]] <- Legend(
        title = paste0(c("Ref", ref_group), collapse = ":"), labels = levels(srt_ref[[ref_group, drop = TRUE]]),
        legend_gp = gpar(fill = palette_scp(levels(srt_ref[[ref_group, drop = TRUE]]), palette = ref_group_palette, palcolor = ref_group_palcolor)), border = TRUE
      )
    }
  }

  if (!is.null(query_cell_annotation)) {
    query_subplots_list <- list()
    for (i in seq_along(query_cell_annotation)) {
      cellan <- query_cell_annotation[i]
      palette <- query_cell_annotation_palette[i]
      palcolor <- query_cell_annotation_palcolor[[i]]
      cell_anno <- cell_metadata[, paste0("query_", cellan)]
      names(cell_anno) <- rownames(cell_metadata)
      if (!is.numeric(cell_anno)) {
        if (is.logical(cell_anno)) {
          cell_anno <- factor(cell_anno, levels = c(TRUE, FALSE))
        } else if (!is.factor(cell_anno)) {
          cell_anno <- factor(cell_anno, levels = unique(cell_anno))
        }
        if (isTRUE(query_collapsing)) {
          subplots <- CellStatPlot(srt_query,
            flip = !flip,
            cells = gsub("query_", "", names(cell_groups[["query_group"]])), plot_type = "pie",
            group.by = query_group, stat.by = cellan,
            palette = palette, palcolor = palcolor,
            individual = TRUE, combine = FALSE
          )
          query_subplots_list[[paste0(cellan, ":", query_group)]] <- subplots
          graphics <- list()
          for (nm in names(subplots)) {
            funbody <- paste0(
              "
              g <- as_grob(query_subplots_list[['", cellan, ":", query_group, "']]", "[['", nm, "']] + theme_void() + theme(plot.title = element_blank(), plot.subtitle = element_blank(), legend.position = 'none'));
              g$name <- '", paste0(cellan, ":", query_group, "-", nm), "';
              grid.draw(g)
              "
            )
            funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
            eval(parse(text = paste("graphics[[nm]] <- function(x, y, w, h) {", funbody, "}", sep = "")), envir = environment())
          }
          x_nm <- sapply(strsplit(levels(cell_groups[["query_group"]]), " : "), function(x) {
            if (length(x) == 2) {
              paste0(c(query_group, x[1], x[2]), collapse = ":")
            } else {
              paste0(c(query_group, x[1], ""), collapse = ":")
            }
          })

          ha_cell <- list()
          ha_cell[[cellan]] <- anno_customize(
            x = x_nm,
            graphics = graphics,
            which = ifelse(flip, "column", "row"),
            border = TRUE,
            verbose = FALSE
          )
          anno_args <- c(ha_cell,
            which = ifelse(flip, "column", "row"),
            show_annotation_name = TRUE,
            annotation_name_side = ifelse(flip, "left", "bottom")
          )
          anno_args <- c(anno_args, query_cell_annotation_params[setdiff(names(query_cell_annotation_params), names(anno_args))])
          ha_query <- do.call(HeatmapAnnotation, args = anno_args)
          if (is.null(ha_query_list[[paste0(c("Query", query_group), collapse = ":")]])) {
            ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- ha_query
          } else {
            ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- c(ha_query_list[[paste0(c("Query", query_group), collapse = ":")]], ha_query)
          }
        } else {
          ha_cell <- list()
          ha_cell[[cellan]] <- anno_simple(
            x = as.character(cell_anno[paste0("query_", names(cell_groups[["query_group"]]))]),
            col = palette_scp(cell_anno, palette = palette, palcolor = palcolor),
            which = ifelse(flip, "column", "row"),
            na_col = "transparent",
            border = TRUE
          )
          anno_args <- c(ha_cell,
            which = ifelse(flip, "column", "row"),
            show_annotation_name = TRUE,
            annotation_name_side = ifelse(flip, "left", "bottom")
          )
          anno_args <- c(anno_args, query_cell_annotation_params[setdiff(names(query_cell_annotation_params), names(anno_args))])
          ha_query <- do.call(HeatmapAnnotation, args = anno_args)
          if (is.null(ha_query_list[[paste0(c("Query", query_group), collapse = ":")]])) {
            ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- ha_query
          } else {
            ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- c(ha_query_list[[paste0(c("Query", query_group), collapse = ":")]], ha_query)
          }
        }
        lgd[[paste0(c("Query", cellan), collapse = ":")]] <- Legend(
          title = paste0(c("Query", cellan), collapse = ":"), labels = levels(cell_anno),
          legend_gp = gpar(fill = palette_scp(cell_anno, palette = palette, palcolor = palcolor)), border = TRUE
        )
      } else {
        if (isTRUE(query_collapsing)) {
          subplots <- FeatureStatPlot(srt_query,
            assay = query_assay, slot = "data", flip = !flip,
            stat.by = cellan, cells = gsub("query_", "", names(cell_groups[["query_group"]])),
            group.by = query_group,
            palette = query_group_palette,
            palcolor = query_group_palcolor,
            fill.by = "group", same.y.lims = TRUE,
            individual = TRUE, combine = FALSE
          )
          query_subplots_list[[paste0(cellan, ":", query_group)]] <- subplots
          graphics <- list()
          for (nm in names(subplots)) {
            funbody <- paste0(
              "
              g <- as_grob(query_subplots_list[['", cellan, ":", query_group, "']]", "[['", nm, "']]  + facet_null() + theme_void() + theme(plot.title = element_blank(), plot.subtitle = element_blank(), legend.position = 'none'));
              g$name <- '", paste0(cellan, ":", query_group, "-", nm), "';
              grid.draw(g)
              "
            )
            funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
            eval(parse(text = paste("graphics[[nm]] <- function(x, y, w, h) {", funbody, "}", sep = "")), envir = environment())
          }
          x_nm <- sapply(strsplit(levels(cell_groups[["query_group"]]), " : "), function(x) {
            if (length(x) == 2) {
              paste0(c(cellan, query_group, x[1], x[2]), collapse = ":")
            } else {
              paste0(c(cellan, query_group, x[1], ""), collapse = ":")
            }
          })
          ha_cell <- list()
          ha_cell[[cellan]] <- anno_customize(
            x = x_nm,
            graphics = graphics,
            which = ifelse(flip, "column", "row"),
            border = TRUE,
            verbose = FALSE
          )
          anno_args <- c(ha_cell,
            which = ifelse(flip, "column", "row"),
            show_annotation_name = TRUE,
            annotation_name_side = ifelse(flip, "left", "bottom")
          )
          anno_args <- c(anno_args, query_cell_annotation_params[setdiff(names(query_cell_annotation_params), names(anno_args))])
          ha_query <- do.call(HeatmapAnnotation, args = anno_args)
          if (is.null(ha_query_list[[paste0(c("Query", query_group), collapse = ":")]])) {
            ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- ha_query
          } else {
            ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- c(ha_query_list[[paste0(c("Query", query_group), collapse = ":")]], ha_query)
          }
        } else {
          col_fun <- colorRamp2(
            breaks = seq(min(cell_anno, na.rm = TRUE), max(cell_anno, na.rm = TRUE), length = 100),
            colors = palette_scp(palette = palette, palcolor = palcolor)
          )
          ha_cell <- list()
          ha_cell[[cellan]] <- anno_simple(
            x = cell_anno[paste0("query_", names(cell_groups[["query_group"]]))],
            col = col_fun,
            which = ifelse(flip, "column", "row"),
            na_col = "transparent",
            border = TRUE
          )
          anno_args <- c(ha_cell,
            which = ifelse(flip, "column", "row"),
            show_annotation_name = TRUE,
            annotation_name_side = ifelse(flip, "left", "bottom")
          )
          anno_args <- c(anno_args, query_cell_annotation_params[setdiff(names(query_cell_annotation_params), names(anno_args))])
          ha_query <- do.call(HeatmapAnnotation, args = anno_args)
          if (is.null(ha_query_list[[paste0(c("Query", query_group), collapse = ":")]])) {
            ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- ha_query
          } else {
            ha_query_list[[paste0(c("Query", query_group), collapse = ":")]] <- c(ha_query_list[[paste0(c("Query", query_group), collapse = ":")]], ha_query)
          }
          lgd[[paste0(c("Query", cellan), collapse = ":")]] <- Legend(
            title = paste0(c("Query", cellan), collapse = ":"), col_fun = col_fun, border = TRUE
          )
        }
      }
    }
  }

  if (!is.null(ref_cell_annotation)) {
    ref_subplots_list <- list()
    for (i in seq_along(ref_cell_annotation)) {
      cellan <- ref_cell_annotation[i]
      palette <- ref_cell_annotation_palette[i]
      palcolor <- ref_cell_annotation_palcolor[[i]]
      cell_anno <- cell_metadata[, paste0("ref_", cellan)]
      names(cell_anno) <- rownames(cell_metadata)
      if (!is.numeric(cell_anno)) {
        if (is.logical(cell_anno)) {
          cell_anno <- factor(cell_anno, levels = c(TRUE, FALSE))
        } else if (!is.factor(cell_anno)) {
          cell_anno <- factor(cell_anno, levels = unique(cell_anno))
        }
        if (isTRUE(ref_collapsing)) {
          subplots <- CellStatPlot(srt_ref,
            flip = flip,
            cells = gsub("ref_", "", names(cell_groups[["ref_group"]])), plot_type = "pie",
            group.by = ref_group, stat.by = cellan,
            palette = palette, palcolor = palcolor,
            individual = TRUE, combine = FALSE
          )
          ref_subplots_list[[paste0(cellan, ":", ref_group)]] <- subplots
          graphics <- list()
          for (nm in names(subplots)) {
            funbody <- paste0(
              "
              g <- as_grob(ref_subplots_list[['", cellan, ":", ref_group, "']]", "[['", nm, "']] + theme_void() + theme(plot.title = element_blank(), plot.subtitle = element_blank(), legend.position = 'none'));
              g$name <- '", paste0(cellan, ":", ref_group, "-", nm), "';
              grid.draw(g)
              "
            )
            funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
            eval(parse(text = paste("graphics[[nm]] <- function(x, y, w, h) {", funbody, "}", sep = "")), envir = environment())
          }
          x_nm <- sapply(strsplit(levels(cell_groups[["ref_group"]]), " : "), function(x) {
            if (length(x) == 2) {
              paste0(c(ref_group, x[1], x[2]), collapse = ":")
            } else {
              paste0(c(ref_group, x[1], ""), collapse = ":")
            }
          })

          ha_cell <- list()
          ha_cell[[cellan]] <- anno_customize(
            x = x_nm,
            graphics = graphics,
            which = ifelse(!flip, "column", "row"),
            border = TRUE,
            verbose = FALSE
          )
          anno_args <- c(ha_cell,
            which = ifelse(!flip, "column", "row"),
            show_annotation_name = TRUE,
            annotation_name_side = ifelse(!flip, "left", "bottom")
          )
          anno_args <- c(anno_args, ref_cell_annotation_params[setdiff(names(ref_cell_annotation_params), names(anno_args))])
          ha_ref <- do.call(HeatmapAnnotation, args = anno_args)
          if (is.null(ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]])) {
            ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- ha_ref
          } else {
            ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- c(ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]], ha_ref)
          }
        } else {
          ha_cell <- list()
          ha_cell[[cellan]] <- anno_simple(
            x = as.character(cell_anno[paste0("ref_", names(cell_groups[["ref_group"]]))]),
            col = palette_scp(cell_anno, palette = palette, palcolor = palcolor),
            which = ifelse(!flip, "column", "row"),
            na_col = "transparent",
            border = TRUE
          )
          anno_args <- c(ha_cell,
            which = ifelse(!flip, "column", "row"),
            show_annotation_name = TRUE,
            annotation_name_side = ifelse(!flip, "left", "bottom")
          )
          anno_args <- c(anno_args, ref_cell_annotation_params[setdiff(names(ref_cell_annotation_params), names(anno_args))])
          ha_ref <- do.call(HeatmapAnnotation, args = anno_args)
          if (is.null(ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]])) {
            ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- ha_ref
          } else {
            ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- c(ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]], ha_ref)
          }
        }
        lgd[[paste0(c("Ref", cellan), collapse = ":")]] <- Legend(
          title = paste0(c("Ref", cellan), collapse = ":"), labels = levels(cell_anno),
          legend_gp = gpar(fill = palette_scp(cell_anno, palette = palette, palcolor = palcolor)), border = TRUE
        )
      } else {
        if (isTRUE(ref_collapsing)) {
          subplots <- FeatureStatPlot(srt_ref,
            assay = ref_assay, slot = "data", flip = flip,
            stat.by = cellan, cells = gsub("ref_", "", names(cell_groups[["ref_group"]])),
            group.by = ref_group,
            palette = ref_group_palette,
            palcolor = ref_group_palcolor,
            fill.by = "group", same.y.lims = TRUE,
            individual = TRUE, combine = FALSE
          )
          ref_subplots_list[[paste0(cellan, ":", ref_group)]] <- subplots
          graphics <- list()
          for (nm in names(subplots)) {
            funbody <- paste0(
              "
              g <- as_grob(ref_subplots_list[['", cellan, ":", ref_group, "']]", "[['", nm, "']]  + facet_null() + theme_void() + theme(plot.title = element_blank(), plot.subtitle = element_blank(), legend.position = 'none'));
              g$name <- '", paste0(cellan, ":", ref_group, "-", nm), "';
              grid.draw(g)
              "
            )
            funbody <- gsub(pattern = "\n", replacement = "", x = funbody)
            eval(parse(text = paste("graphics[[nm]] <- function(x, y, w, h) {", funbody, "}", sep = "")), envir = environment())
          }
          x_nm <- sapply(strsplit(levels(cell_groups[["ref_group"]]), " : "), function(x) {
            if (length(x) == 2) {
              paste0(c(cellan, ref_group, x[1], x[2]), collapse = ":")
            } else {
              paste0(c(cellan, ref_group, x[1], ""), collapse = ":")
            }
          })
          ha_cell <- list()
          ha_cell[[cellan]] <- anno_customize(
            x = x_nm,
            graphics = graphics,
            which = ifelse(!flip, "column", "row"),
            border = TRUE,
            verbose = FALSE
          )
          anno_args <- c(ha_cell,
            which = ifelse(!flip, "column", "row"),
            show_annotation_name = TRUE,
            annotation_name_side = ifelse(!flip, "left", "bottom")
          )
          anno_args <- c(anno_args, ref_cell_annotation_params[setdiff(names(ref_cell_annotation_params), names(anno_args))])
          ha_ref <- do.call(HeatmapAnnotation, args = anno_args)
          if (is.null(ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]])) {
            ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- ha_ref
          } else {
            ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- c(ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]], ha_ref)
          }
        } else {
          col_fun <- colorRamp2(
            breaks = seq(min(cell_anno, na.rm = TRUE), max(cell_anno, na.rm = TRUE), length = 100),
            colors = palette_scp(palette = palette, palcolor = palcolor)
          )
          ha_cell <- list()
          ha_cell[[cellan]] <- anno_simple(
            x = cell_anno[paste0("ref_", names(cell_groups[["ref_group"]]))],
            col = col_fun,
            which = ifelse(!flip, "column", "row"),
            na_col = "transparent",
            border = TRUE
          )
          anno_args <- c(ha_cell,
            which = ifelse(!flip, "column", "row"),
            show_annotation_name = TRUE,
            annotation_name_side = ifelse(!flip, "left", "bottom")
          )
          anno_args <- c(anno_args, ref_cell_annotation_params[setdiff(names(ref_cell_annotation_params), names(anno_args))])
          ha_ref <- do.call(HeatmapAnnotation, args = anno_args)
          if (is.null(ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]])) {
            ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- ha_ref
          } else {
            ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]] <- c(ha_ref_list[[paste0(c("Ref", ref_group), collapse = ":")]], ha_ref)
          }
          lgd[[paste0(c("Ref", cellan), collapse = ":")]] <- Legend(
            title = paste0(c("Ref", cellan), collapse = ":"), col_fun = col_fun, border = TRUE
          )
        }
      }
    }
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
    row_title = row_title %||% if (flip) paste0(c("Ref", ref_group), collapse = ":") else paste0(c("Query", query_group), collapse = ":"),
    row_title_side = row_title_side,
    column_title = column_title %||% if (flip) paste0(c("Query", query_group), collapse = ":") else paste0(c("Ref", ref_group), collapse = ":"),
    column_title_side = column_title_side,
    row_title_rot = row_title_rot,
    column_title_rot = column_title_rot,
    cluster_rows = cluster_rows,
    cluster_columns = cluster_columns,
    show_row_names = show_row_names,
    show_column_names = show_column_names,
    row_names_side = row_names_side,
    column_names_side = column_names_side,
    row_names_rot = row_names_rot,
    column_names_rot = column_names_rot,
    top_annotation = if (flip) ha_query_list[[1]] else ha_ref_list[[1]],
    left_annotation = if (flip) ha_ref_list[[1]] else ha_query_list[[1]],
    show_heatmap_legend = FALSE,
    border = border,
    use_raster = use_raster,
    raster_device = raster_device,
    raster_by_magick = raster_by_magick,
    width = if (is.numeric(width)) unit(width, units = units) else NULL,
    height = if (is.numeric(height)) unit(height, units = units) else NULL
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

  if (!is.null(width) || !is.null(height)) {
    fix <- TRUE
  } else {
    fix <- FALSE
  }
  rendersize <- heatmap_rendersize(
    width = width, height = height, units = units,
    ha_top_list = ha_ref_list, ha_left = ha_query_list[[1]], ha_right = NULL,
    ht_list = ht_list, legend_list = lgd, flip = flip
  )
  width_sum <- rendersize[["width_sum"]]
  height_sum <- rendersize[["height_sum"]]
  # cat("width:", width, "\n")
  # cat("height:", height, "\n")
  # cat("width_sum:", width_sum, "\n")
  # cat("height_sum:", height_sum, "\n")

  if (isTRUE(fix)) {
    fixsize <- heatmap_fixsize(
      width = width, width_sum = width_sum, height = height, height_sum = height_sum, units = units,
      ht_list = ht_list, legend_list = lgd
    )
    ht_width <- fixsize[["ht_width"]]
    ht_height <- fixsize[["ht_height"]]
    # cat("ht_width:", ht_width, "\n")
    # cat("ht_height:", ht_height, "\n")

    gTree <- grid.grabExpr(
      {
        draw(ht_list, annotation_legend_list = lgd)
      },
      width = ht_width,
      height = ht_height,
      wrap = TRUE,
      wrap.grobs = TRUE
    )
  } else {
    ht_width <- unit(width_sum, units = units)
    ht_height <- unit(height_sum, units = units)
    gTree <- grid.grabExpr(
      {
        draw(ht_list, annotation_legend_list = lgd)
      },
      width = ht_width,
      height = ht_height,
      wrap = TRUE,
      wrap.grobs = TRUE
    )
  }

  if (isTRUE(fix)) {
    p <- panel_fix_overall(gTree, width = as.numeric(ht_width), height = as.numeric(ht_height), units = units)
  } else {
    p <- wrap_plots(gTree)
  }

  return(list(
    plot = p,
    features = features,
    simil_matrix = simil_matrix,
    simil_name = simil_name,
    cell_metadata = cell_metadata
  ))
}

#' Heatmap plot for dynamic features along lineages
#'
#' @inheritParams GroupHeatmap
#' @param srt A Seurat object.
#' @param lineages A character vector specifying the lineages to plot.
#' @param features A character vector specifying the features to plot. By default, this parameter is set to NULL, and the dynamic features will be determined by the parameters  \code{min_expcells}, \code{r.sq}, \code{dev.expl}, \code{padjust} and \code{num_intersections}.
#' @param use_fitted A logical indicating whether to use fitted values. Default is FALSE.
#' @param border A logical indicating whether to add a border to the heatmap. Default is TRUE.
#' @param flip A logical indicating whether to flip the heatmap. Default is FALSE.
#' @param min_expcells A numeric value specifying the minimum number of expected cells. Default is 20.
#' @param r.sq A numeric value specifying the R-squared threshold. Default is 0.2.
#' @param dev.expl A numeric value specifying the deviance explained threshold. Default is 0.2.
#' @param padjust A numeric value specifying the p-value adjustment threshold. Default is 0.05.
#' @param num_intersections This parameter is a numeric vector used to determine the number of intersections among lineages. It helps in selecting which dynamic features will be used. By default, when this parameter is set to NULL, all dynamic features that pass the specified threshold will be used for each lineage.
#' @param cell_density A numeric value is used to define the cell density within each cell bin. By default, this parameter is set to 1, which means that all cells will be included within each cell bin.
#' @param cell_bins A numeric value specifying the number of cell bins. Default is 100.
#' @param order_by A character vector specifying the order of the heatmap. Default is "peaktime".
#' @param family A character specifying the model used to calculate the dynamic features if needed. By default, this parameter is set to NULL, and the appropriate family will be automatically determined.
#' @param cluster_features_by A character vector specifying which lineage to use when clustering features. By default, this parameter is set to NULL, which means that all lineages will be used.
#' @param pseudotime_label A numeric vector specifying the pseudotime label. Default is NULL.
#' @param pseudotime_label_color A character string specifying the pseudotime label color. Default is "black".
#' @param pseudotime_label_linetype A numeric value specifying the pseudotime label line type. Default is 2.
#' @param pseudotime_label_linewidth A numeric value specifying the pseudotime label line width. Default is 3.
#' @param pseudotime_palette A character vector specifying the color palette to use for pseudotime.
#' @param pseudotime_palcolor A list specifying the colors to use for the pseudotime in the heatmap.
#' @param separate_annotation A character vector of names of annotations to be displayed in separate annotation blocks. Each name should match a column name in the metadata of the Seurat object.
#' @param separate_annotation_palette A character vector specifying the color palette to use for separate annotations.
#' @param separate_annotation_palcolor A list specifying the colors to use for each level of the separate annotations.
#' @param separate_annotation_params A list of other parameters to be passed to the HeatmapAnnotation function when creating the separate annotation blocks.
#' @param reverse_ht A logical indicating whether to reverse the heatmap. Default is NULL.
#'
#' @seealso \code{\link{RunDynamicFeatures}} \code{\link{RunDynamicEnrichment}}
#'
#' @examples
#' data("pancreas_sub")
#' pancreas_sub <- RunSlingshot(pancreas_sub, group.by = "SubCellType", reduction = "UMAP")
#' pancreas_sub <- RunDynamicFeatures(pancreas_sub, lineages = c("Lineage1", "Lineage2"), n_candidates = 200)
#' ht1 <- DynamicHeatmap(
#'   srt = pancreas_sub,
#'   lineages = "Lineage1",
#'   n_split = 5,
#'   split_method = "kmeans-peaktime",
#'   cell_annotation = "SubCellType"
#' )
#' ht1$plot
#' panel_fix(ht1$plot, raster = TRUE, dpi = 50)
#'
#' ht2 <- DynamicHeatmap(
#'   srt = pancreas_sub,
#'   lineages = "Lineage1",
#'   features = c("Sox9", "Neurod2", "Isl1", "Rbp4", "Pyy", "S_score", "G2M_score"),
#'   cell_annotation = "SubCellType"
#' )
#' ht2$plot
#' panel_fix(ht2$plot, height = 5, width = 5, raster = TRUE, dpi = 50)
#'
#' ht3 <- DynamicHeatmap(
#'   srt = pancreas_sub,
#'   lineages = c("Lineage1", "Lineage2"),
#'   n_split = 5,
#'   split_method = "kmeans",
#'   cluster_rows = TRUE,
#'   cell_annotation = "SubCellType"
#' )
#' ht3$plot
#'
#' pancreas_sub <- AnnotateFeatures(pancreas_sub, species = "Mus_musculus", db = c("TF", "CSPA"))
#' ht4 <- DynamicHeatmap(
#'   srt = pancreas_sub,
#'   lineages = c("Lineage1", "Lineage2"),
#'   reverse_ht = "Lineage1",
#'   use_fitted = TRUE,
#'   n_split = 6,
#'   split_method = "mfuzz",
#'   heatmap_palette = "viridis",
#'   cell_annotation = c("SubCellType", "Phase", "G2M_score"),
#'   cell_annotation_palette = c("Paired", "simspec", "Purples"),
#'   separate_annotation = list("SubCellType", c("Nnat", "Irx1")),
#'   separate_annotation_palette = c("Paired", "Set1"),
#'   separate_annotation_params = list(height = unit(10, "mm")),
#'   feature_annotation = c("TF", "CSPA"),
#'   feature_annotation_palcolor = list(c("gold", "steelblue"), c("forestgreen")),
#'   pseudotime_label = 25,
#'   pseudotime_label_color = "red"
#' )
#' ht4$plot
#'
#' ht5 <- DynamicHeatmap(
#'   srt = pancreas_sub,
#'   lineages = c("Lineage1", "Lineage2"),
#'   reverse_ht = "Lineage1",
#'   use_fitted = TRUE,
#'   n_split = 6,
#'   split_method = "mfuzz",
#'   heatmap_palette = "viridis",
#'   cell_annotation = c("SubCellType", "Phase", "G2M_score"),
#'   cell_annotation_palette = c("Paired", "simspec", "Purples"),
#'   separate_annotation = list("SubCellType", c("Nnat", "Irx1")),
#'   separate_annotation_palette = c("Paired", "Set1"),
#'   separate_annotation_params = list(width = unit(10, "mm")),
#'   feature_annotation = c("TF", "CSPA"),
#'   feature_annotation_palcolor = list(c("gold", "steelblue"), c("forestgreen")),
#'   pseudotime_label = 25,
#'   pseudotime_label_color = "red",
#'   flip = TRUE, column_title_rot = 45
#' )
#' ht5$plot
#'
#' ht6 <- DynamicHeatmap(
#'   srt = pancreas_sub,
#'   lineages = c("Lineage1", "Lineage2"),
#'   reverse_ht = "Lineage1",
#'   cell_annotation = "SubCellType",
#'   n_split = 5, split_method = "mfuzz",
#'   species = "Mus_musculus", db = "GO_BP",
#'   anno_terms = TRUE, anno_keys = TRUE, anno_features = TRUE
#' )
#' ht6$plot
#'
#' @importFrom Seurat GetAssayData NormalizeData DefaultAssay
#' @importFrom circlize colorRamp2
#' @importFrom ComplexHeatmap Heatmap Legend HeatmapAnnotation anno_empty anno_mark anno_simple anno_textbox draw decorate_heatmap_body width.HeatmapAnnotation height.HeatmapAnnotation width.Legends height.Legends decorate_annotation row_order %v%
#' @importFrom stats kmeans sd
#' @importFrom patchwork wrap_plots
#' @importFrom grid gpar grid.lines grid.text unit
#' @importFrom gtable gtable_add_padding
#' @importFrom Matrix t
#' @importFrom dplyr %>% filter group_by arrange desc across mutate reframe distinct n .data
#' @importFrom proxyC dist
#' @export
