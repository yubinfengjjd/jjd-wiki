# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:3066-3369
# sha256(func-block)=d40e453638b593332da1e4556db248039b5c170c7261a5c0b59df4cf82459331
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
FeatureDimPlot3D <- function(srt, features, reduction = NULL, dims = c(1, 2, 3), axis_labs = NULL,
                             split.by = NULL, slot = "data", assay = NULL,
                             calculate_coexp = FALSE,
                             pt.size = 1.5, cells.highlight = NULL, cols.highlight = "black", shape.highlight = "circle-open", sizes.highlight = 2,
                             width = NULL, height = NULL, save = NULL, force = FALSE) {
  cols.highlight <- col2hex(cols.highlight)

  if (is.list(features)) {
    features <- unlist(features)
  }
  if (!inherits(features, "character")) {
    stop("'features' is not a character vectors")
  }

  assay <- assay %||% DefaultAssay(srt)
  if (is.null(split.by)) {
    split.by <- "All.cells"
    srt@meta.data[[split.by]] <- factor("All.cells")
  }
  for (i in split.by) {
    if (!i %in% colnames(srt@meta.data)) {
      stop(paste0(i, " is not in the meta.data of srt object."))
    }
    if (!is.factor(srt@meta.data[[i]])) {
      srt@meta.data[[i]] <- factor(srt@meta.data[[i]], levels = unique(srt@meta.data[[i]]))
    }
  }
  if (is.null(reduction)) {
    reduction <- DefaultReduction(srt, min_dim = 3)
  } else {
    reduction <- DefaultReduction(srt, pattern = reduction, min_dim = 3)
  }
  if (!reduction %in% names(srt@reductions)) {
    stop(paste0(reduction, " is not in the srt reduction names."))
  }
  if (ncol(srt@reductions[[reduction]]@cell.embeddings) < 3) {
    stop("Reduction must be in three dimensions or higher.")
  }
  if (!is.null(cells.highlight) && !isTRUE(cells.highlight)) {
    if (!any(cells.highlight %in% colnames(srt@assays[[1]]))) {
      stop("No cells in 'cells.highlight' found in srt.")
    }
    if (!all(cells.highlight %in% colnames(srt@assays[[1]]))) {
      warning("Some cells in 'cells.highlight' not found in srt.", immediate. = TRUE)
    }
    cells.highlight <- intersect(cells.highlight, colnames(srt@assays[[1]]))
  }
  if (isTRUE(cells.highlight)) {
    cells.highlight <- colnames(srt@assays[[1]])
  }
  reduction_key <- srt@reductions[[reduction]]@key
  if (is.null(axis_labs) || length(axis_labs) != 3) {
    xlab <- paste0(reduction_key, dims[1])
    ylab <- paste0(reduction_key, dims[2])
    zlab <- paste0(reduction_key, dims[3])
  } else {
    xlab <- axis_labs[1]
    ylab <- axis_labs[2]
    zlab <- axis_labs[3]
  }
  if ((!is.null(save) && is.character(save) && nchar(save) > 0)) {
    check_R("htmlwidgets")
    if (!grepl(".html$", save)) {
      stop("'save' must be a string with .html as a suffix.")
    }
  }

  features <- unique(features)
  embeddings <- lapply(srt@reductions, function(x) colnames(x@cell.embeddings))
  embeddings <- setNames(rep(names(embeddings), sapply(embeddings, length)), nm = unlist(embeddings))
  features_drop <- features[!features %in% c(rownames(srt@assays[[assay]]), colnames(srt@meta.data), names(embeddings))]
  if (length(features_drop) > 0) {
    warning(paste0(features_drop, collapse = ","), " are not in the features of srt.", immediate. = TRUE)
    features <- features[!features %in% features_drop]
  }

  features_gene <- features[features %in% rownames(srt@assays[[assay]])]
  features_meta <- features[features %in% colnames(srt@meta.data)]
  features_embedding <- features[features %in% names(embeddings)]
  if (length(intersect(features_gene, features_meta)) > 0) {
    warning("Features appear in both gene names and metadata names: ", paste0(intersect(features_gene, features_meta), collapse = ","))
  }
  if (length(c(features_gene, features_meta, features_embedding)) == 0) {
    stop("There are no valid features present.")
  }

  if (isTRUE(calculate_coexp) && length(features_gene) > 0) {
    if (length(features_meta) > 0) {
      warning(paste(features_meta, collapse = ","), "is not used when calculating co-expression", immediate. = TRUE)
    }
    status <- check_DataType(srt, slot = slot, assay = assay)
    message("Data type detected in ", slot, " slot: ", status)
    if (status %in% c("raw_counts", "raw_normalized_counts")) {
      srt@meta.data[["CoExp"]] <- apply(slot(srt@assays[[assay]], slot)[features_gene, , drop = FALSE], 2, function(x) exp(mean(log(x))))
    } else if (status == "log_normalized_counts") {
      srt@meta.data[["CoExp"]] <- apply(expm1(slot(srt@assays[[assay]], slot)[features_gene, , drop = FALSE]), 2, function(x) log1p(exp(mean(log(x)))))
    } else {
      stop("Can not determine the data type.")
    }
    features <- c(features, "CoExp")
    features_meta <- c(features_meta, "CoExp")
  }

  if (length(features_gene) > 0) {
    if (all(rownames(srt@assays[[assay]]) %in% features_gene)) {
      dat_gene <- t(as_matrix(slot(srt@assays[[assay]], slot)))
    } else {
      dat_gene <- t(as_matrix(slot(srt@assays[[assay]], slot)[features_gene, , drop = FALSE]))
    }
  } else {
    dat_gene <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  if (length(features_meta) > 0) {
    dat_meta <- as_matrix(srt@meta.data[, features_meta, drop = FALSE])
  } else {
    dat_meta <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  if (length(features_embedding) > 0) {
    dat_embedding <- as_matrix(FetchData(srt, vars = features_embedding))
  } else {
    dat_embedding <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  dat_exp <- as_matrix(do.call(cbind, list(dat_gene, dat_meta, dat_embedding)))
  features <- unique(features[features %in% c(features_gene, features_meta, features_embedding)])

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

  dat_sp <- srt@meta.data[, split.by, drop = FALSE]
  dat_dim <- srt@reductions[[reduction]]@cell.embeddings
  colnames(dat_dim) <- paste0(reduction_key, seq_len(ncol(dat_dim)))
  rownames(dat_dim) <- rownames(dat_dim) %||% colnames(srt@assays[[1]])
  dat_use <- cbind(dat_exp, dat_dim[rownames(dat_exp), , drop = FALSE], dat_sp[rownames(dat_exp), , drop = FALSE])

  dat_use[[paste0(reduction_key, dims[1], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[1])]]
  dat_use[[paste0(reduction_key, dims[2], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[2])]]
  dat_use[[paste0(reduction_key, dims[3], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[3])]]
  for (i in levels(dat_use[[split.by]])) {
    dat_use[[paste0(reduction_key, dims[1], i)]] <- ifelse(dat_use[[split.by]] == i, dat_use[[paste0(reduction_key, dims[1])]], NA)
    dat_use[[paste0(reduction_key, dims[2], i)]] <- ifelse(dat_use[[split.by]] == i, dat_use[[paste0(reduction_key, dims[2])]], NA)
    dat_use[[paste0(reduction_key, dims[3], i)]] <- ifelse(dat_use[[split.by]] == i, dat_use[[paste0(reduction_key, dims[3])]], NA)
  }
  if (!is.null(cells.highlight)) {
    cells.highlight <- cells.highlight[cells.highlight %in% rownames(dat_use)]
    dat_use_highlight <- dat_use[cells.highlight, , drop = FALSE]
    for (i in levels(dat_use_highlight[[split.by]])) {
      dat_use_highlight[[paste0(reduction_key, dims[1], i)]] <- ifelse(dat_use_highlight[[split.by]] == i, dat_use_highlight[[paste0(reduction_key, dims[1])]], NA)
      dat_use_highlight[[paste0(reduction_key, dims[2], i)]] <- ifelse(dat_use_highlight[[split.by]] == i, dat_use_highlight[[paste0(reduction_key, dims[2])]], NA)
      dat_use_highlight[[paste0(reduction_key, dims[3], i)]] <- ifelse(dat_use_highlight[[split.by]] == i, dat_use_highlight[[paste0(reduction_key, dims[3])]], NA)
    }
  }

  p <- plot_ly(data = dat_use, width = width, height = height)
  p <- add_trace(
    p = p,
    data = dat_use,
    x = dat_use[[paste0(reduction_key, dims[1], "All_cells")]],
    y = dat_use[[paste0(reduction_key, dims[2], "All_cells")]],
    z = dat_use[[paste0(reduction_key, dims[3], "All_cells")]],
    text = paste0(
      "Cell:", rownames(dat_use),
      "\nExp:", round(dat_use[[features[1]]], 3)
    ),
    type = "scatter3d",
    mode = "markers",
    marker = list(
      color = dat_use[[features[1]]],
      colorbar = list(title = list(text = features[1], font = list(color = "black", size = 14)), len = 0.5),
      size = pt.size,
      showscale = TRUE
    ),
    name = "All_cells",
    showlegend = TRUE,
    visible = TRUE
  )

  if (!is.null(cells.highlight)) {
    p <- add_trace(
      p = p,
      x = dat_use_highlight[[paste0(reduction_key, dims[1], "All_cells")]],
      y = dat_use_highlight[[paste0(reduction_key, dims[2], "All_cells")]],
      z = dat_use_highlight[[paste0(reduction_key, dims[3], "All_cells")]],
      text = paste0(
        "Cell:", rownames(dat_use_highlight),
        "\nExp:", round(dat_use_highlight[[features[1]]], 3)
      ),
      type = "scatter3d",
      mode = "markers",
      marker = list(size = sizes.highlight, color = cols.highlight, symbol = shape.highlight),
      name = "highlight",
      showlegend = TRUE,
      visible = TRUE
    )
  }

  split_option <- list()
  genes_option <- list()
  for (i in 0:nlevels(dat_use[[split.by]])) {
    sp <- ifelse(i == 0, "All.cells", levels(dat_use[[split.by]])[i])
    ncells <- ifelse(i == 0, nrow(dat_use), table(dat_use[[split.by]])[sp])
    if (i != 0 && sp == "All.cells") {
      next
    }
    x <- list(dat_use[[paste0(reduction_key, dims[1], sp)]])
    y <- list(dat_use[[paste0(reduction_key, dims[2], sp)]])
    z <- list(dat_use[[paste0(reduction_key, dims[3], sp)]])
    name <- sp
    if (!is.null(cells.highlight)) {
      x <- c(x, list(dat_use_highlight[[paste0(reduction_key, dims[1], sp)]]))
      y <- c(y, list(dat_use_highlight[[paste0(reduction_key, dims[2], sp)]]))
      z <- c(z, list(dat_use_highlight[[paste0(reduction_key, dims[3], sp)]]))
      name <- c(sp, "highlight")
    }
    split_option[[i + 1]] <- list(
      method = "update",
      args = list(list(
        x = x,
        y = y,
        z = z,
        name = name,
        visible = TRUE
      ), list(title = list(
        text = paste0(sp, " (nCells:", ncells, ")"),
        font = list(size = 16, color = "black"),
        y = 0.95
      ))),
      label = sp
    )
  }
  for (j in seq_along(features)) {
    marker <- list(
      color = dat_use[[features[j]]],
      colorbar = list(title = list(text = features[j], font = list(color = "black", size = 14)), len = 0.5),
      size = pt.size,
      showscale = TRUE
    )

    if (!is.null(cells.highlight)) {
      marker <- list(marker, list(size = sizes.highlight, color = cols.highlight, symbol = shape.highlight))
    }
    genes_option[[j]] <- list(
      method = "update",
      args = list(list(
        text = list(paste0(
          "Cell:", rownames(dat_use),
          "\nExp:", round(dat_use[[features[j]]], 3)
        )),
        marker = marker
      )),
      label = features[j]
    )
  }

  p <- layout(
    p = p,
    title = list(
      text = paste0("All_cells", " (nCells:", nrow(dat_use), ")"),
      font = list(size = 16, color = "black"),
      y = 0.95
    ),
    showlegend = TRUE,
    legend = list(
      itemsizing = "constant",
      y = -0.2,
      x = 0.5,
      xanchor = "center"
    ),
    scene = list(
      xaxis = list(title = xlab, range = c(min(dat_use[[paste0(reduction_key, dims[1])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[1])]], na.rm = TRUE))),
      yaxis = list(title = ylab, range = c(min(dat_use[[paste0(reduction_key, dims[2])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[2])]], na.rm = TRUE))),
      zaxis = list(title = zlab, range = c(min(dat_use[[paste0(reduction_key, dims[3])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[3])]], na.rm = TRUE))),
      aspectratio = list(x = 1, y = 1, z = 1)
    ),
    updatemenus = list(
      list(
        y = 0.67,
        buttons = split_option
      ),
      list(
        y = 0.33,
        buttons = genes_option
      )
    ),
    autosize = FALSE
  )

  if ((!is.null(save) && is.character(save) && nchar(save) > 0)) {
    htmlwidgets::saveWidget(
      widget = as_widget(p),
      file = save
    )
    unlink(gsub("\\.html", "_files", save), recursive = TRUE)
  }

  return(p)
}
