# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:2843-3044
# sha256(func-block)=67c20feb3df3158cee09a232aff58bedf80c1bbde62293e078393fb10258257a
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
CellDimPlot3D <- function(srt, group.by, reduction = NULL, dims = c(1, 2, 3), axis_labs = NULL,
                          palette = "Paired", palcolor = NULL, bg_color = "grey80", pt.size = 1.5,
                          cells.highlight = NULL, cols.highlight = "black", shape.highlight = "circle-open", sizes.highlight = 2,
                          lineages = NULL, lineages_palette = "Dark2", span = 0.75,
                          width = NULL, height = NULL, save = NULL, force = FALSE) {
  bg_color <- col2hex(bg_color)
  cols.highlight <- col2hex(cols.highlight)

  for (i in c(group.by)) {
    if (!i %in% colnames(srt@meta.data)) {
      stop(paste0(i, " is not in the meta.data of srt object."))
    }
    if (!is.factor(srt@meta.data[[i]])) {
      srt@meta.data[[i]] <- factor(srt@meta.data[[i]], levels = unique(srt@meta.data[[i]]))
    }
  }
  for (l in lineages) {
    if (!l %in% colnames(srt@meta.data)) {
      stop(paste0(l, " is not in the meta.data of srt object."))
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

  dat_dim <- srt@reductions[[reduction]]@cell.embeddings
  colnames(dat_dim) <- paste0(reduction_key, seq_len(ncol(dat_dim)))
  rownames(dat_dim) <- rownames(dat_dim) %||% colnames(srt@assays[[1]])
  dat_use <- cbind(dat_dim[colnames(srt@assays[[1]]), , drop = FALSE], srt@meta.data[colnames(srt@assays[[1]]), , drop = FALSE])
  nlev <- sapply(dat_use[, group.by, drop = FALSE], nlevels)
  nlev <- nlev[nlev > 100]
  if (length(nlev) > 0 && !isTRUE(force)) {
    warning(paste(names(nlev), sep = ","), " have more than 100 levels.", immediate. = TRUE)
    answer <- askYesNo("Are you sure to continue?", default = FALSE)
    if (!isTRUE(answer)) {
      return(invisible(NULL))
    }
  }
  if (!is.null(lineages)) {
    dat_lineages <- srt@meta.data[, unique(lineages), drop = FALSE]
    dat_use <- cbind(dat_use, dat_lineages[row.names(dat_use), , drop = FALSE])
  }
  dat_use[["group.by"]] <- dat_use[[group.by]]
  if (any(is.na(dat_use[[group.by]]))) {
    n <- as.character(dat_use[[group.by]])
    n[is.na(n)] <- "NA"
    dat_use[[group.by]] <- factor(n, levels = c(levels(dat_use[[group.by]]), "NA"))
  }

  dat_use[["color"]] <- dat_use[[group.by]]
  colors <- palette_scp(dat_use[["group.by"]], palette = palette, palcolor = palcolor, NA_color = bg_color, NA_keep = TRUE)

  dat_use[[paste0(reduction_key, dims[1], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[1])]]
  dat_use[[paste0(reduction_key, dims[2], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[2])]]
  dat_use[[paste0(reduction_key, dims[3], "All_cells")]] <- dat_use[[paste0(reduction_key, dims[3])]]
  cells.highlight_use <- cells.highlight
  if (isTRUE(cells.highlight_use)) {
    cells.highlight_use <- rownames(dat_use)[dat_use[[group.by]] != "NA"]
  }
  if (!is.null(cells.highlight_use)) {
    cells.highlight_use <- cells.highlight_use[cells.highlight_use %in% rownames(dat_use)]
    dat_use_highlight <- dat_use[cells.highlight_use, , drop = FALSE]
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
      "\ngroup.by:", dat_use[["group.by"]],
      "\ncolor:", dat_use[["color"]]
    ),
    type = "scatter3d",
    mode = "markers",
    color = dat_use[[group.by]],
    colors = colors,
    marker = list(size = pt.size),
    showlegend = TRUE,
    visible = TRUE
  )
  if (!is.null(cells.highlight_use)) {
    p <- add_trace(
      p = p,
      x = dat_use_highlight[[paste0(reduction_key, dims[1], "All_cells")]],
      y = dat_use_highlight[[paste0(reduction_key, dims[2], "All_cells")]],
      z = dat_use_highlight[[paste0(reduction_key, dims[3], "All_cells")]],
      text = paste0(
        "Cell:", rownames(dat_use_highlight),
        "\ngroup.by:", dat_use_highlight[["group.by"]],
        "\ncolor:", dat_use_highlight[["color"]]
      ),
      type = "scatter3d",
      mode = "markers",
      marker = list(size = sizes.highlight, color = cols.highlight, symbol = shape.highlight),
      name = "highlight",
      showlegend = TRUE,
      visible = TRUE
    )
  }
  if (!is.null(lineages)) {
    for (l in lineages) {
      dat_sub <- dat_use[!is.na(dat_use[[l]]), , drop = FALSE]
      dat_sub <- dat_sub[order(dat_sub[[l]]), , drop = FALSE]

      xlo <- loess(formula(paste(paste0(reduction_key, dims[1], "All_cells"), l, sep = "~")), data = dat_sub, span = span, degree = 2)
      ylo <- loess(formula(paste(paste0(reduction_key, dims[2], "All_cells"), l, sep = "~")), data = dat_sub, span = span, degree = 2)
      zlo <- loess(formula(paste(paste0(reduction_key, dims[3], "All_cells"), l, sep = "~")), data = dat_sub, span = span, degree = 2)
      dat_smooth <- data.frame(x = xlo$fitted, y = ylo$fitted, z = zlo$fitted)
      dat_smooth <- dat_smooth[dat_smooth[["x"]] <= max(dat_use[[paste0(reduction_key, dims[1], "All_cells")]], na.rm = TRUE) & dat_smooth[["x"]] >= min(dat_use[[paste0(reduction_key, dims[1], "All_cells")]], na.rm = TRUE), , drop = FALSE]
      dat_smooth <- dat_smooth[dat_smooth[["y"]] <= max(dat_use[[paste0(reduction_key, dims[2], "All_cells")]], na.rm = TRUE) & dat_smooth[["y"]] >= min(dat_use[[paste0(reduction_key, dims[2], "All_cells")]], na.rm = TRUE), , drop = FALSE]
      dat_smooth <- dat_smooth[dat_smooth[["z"]] <= max(dat_use[[paste0(reduction_key, dims[3], "All_cells")]], na.rm = TRUE) & dat_smooth[["z"]] >= min(dat_use[[paste0(reduction_key, dims[3], "All_cells")]], na.rm = TRUE), , drop = FALSE]
      dat_smooth <- unique(na.omit(dat_smooth))
      p <- add_trace(
        p = p,
        x = dat_smooth[, "x"],
        y = dat_smooth[, "y"],
        z = dat_smooth[, "z"],
        text = paste0(
          "Lineage:", l
        ),
        type = "scatter3d",
        mode = "lines",
        line = list(width = 6, color = palette_scp(x = lineages, palette = lineages_palette)[l], reverscale = FALSE),
        name = l,
        showlegend = TRUE,
        visible = TRUE
      )
    }
  }

  p <- layout(
    p = p,
    title = list(
      text = paste0("Total", " (nCells:", nrow(dat_use), ")"),
      font = list(size = 16, color = "black"),
      y = 0.95
    ),
    font = list(size = 12, color = "black"),
    showlegend = TRUE,
    legend = list(
      itemsizing = "constant",
      y = 0.5,
      x = 1,
      xanchor = "left",
      alpha = 1
    ),
    scene = list(
      xaxis = list(title = xlab, range = c(min(dat_use[[paste0(reduction_key, dims[1])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[1])]], na.rm = TRUE))),
      yaxis = list(title = ylab, range = c(min(dat_use[[paste0(reduction_key, dims[2])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[2])]], na.rm = TRUE))),
      zaxis = list(title = zlab, range = c(min(dat_use[[paste0(reduction_key, dims[3])]], na.rm = TRUE), max(dat_use[[paste0(reduction_key, dims[3])]], na.rm = TRUE))),
      aspectratio = list(x = 1, y = 1, z = 1)
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
