# Native SCP CellStatPlot core for plot_type = "chord".
# Extracted from SCP v0.5.6 R/SCP-plot.R, commit
# b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
#
# The table half is scp_chord_table(): it reproduces the upstream factor
# handling and the contingency matrix built in the chord branch of StatPlot()
# (lines 5117-5119). The plot half is plot_scp_chord(): it preserves the
# upstream circlize::chordDiagram() call (lines 5120-5126), the temporary
# recording device (lines 4962-4977) and recordPlot() (lines 5128, 5143-5147).
# Namespace qualification and the palette/device localization documented in
# PATCHES.md are the only changes; no custom ggplot is substituted.
#
# scp_chord_meta() joins the halves. scp_chord_linkage_wide() and
# scp_chord_long_meta() rebuild the same wide metadata from the
# `render-cell-linkage` long table used by the template.

.scp_chord_default_env <- function() {
  for (nm in c("SCP_helpers", "SCP_local")) {
    if (exists(nm, envir = globalenv(), inherits = FALSE)) {
      return(get(nm, envir = globalenv(), inherits = FALSE))
    }
  }
  stop("Pass a local SCP helper environment via scp=; the SCP package is not required.", call. = FALSE)
}

.scp_chord_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# Upstream StatPlot() converts every stat.by column to a factor when it is not
# one (lines 4617-4628); the chord branch then tabulates the two columns with
# useNA = "ifany" (line 5117). `stat_levels` is an optional named list of
# explicit levels (same role as StatPlot's factor levels from the object).
.scp_chord_prepare <- function(meta.data, stat.by, stat_levels = NULL) {
  if (!is.data.frame(meta.data)) stop("meta.data must be a data.frame", call. = FALSE)
  if (length(stat.by) != 2L) stop("plot_type 'chord' requires exactly two stat.by columns", call. = FALSE)
  if (anyNA(stat.by) || anyDuplicated(stat.by)) stop("stat.by must be two distinct column names", call. = FALSE)
  missing <- setdiff(stat.by, colnames(meta.data))
  if (length(missing)) stop("stat.by not found in meta.data: ", paste(missing, collapse = ", "), call. = FALSE)
  md <- meta.data[, stat.by, drop = FALSE]
  for (i in stat.by) {
    lv <- stat_levels[[i]]
    if (!is.null(lv)) {
      lv <- as.character(lv)
      if (anyNA(lv) || anyDuplicated(lv)) stop("stat_levels for ", i, " must be unique and non-NA", call. = FALSE)
      extra <- setdiff(unique(as.character(md[[i]])), lv)
      if (length(extra)) stop("values missing from stat_levels[['", i, "']]: ", paste(extra, collapse = ", "), call. = FALSE)
      md[[i]] <- factor(as.character(md[[i]]), levels = lv)
    } else if (!is.factor(md[[i]])) {
      md[[i]] <- factor(md[[i]], levels = unique(md[[i]]))
    }
  }
  md
}

# Table half: the upstream contingency matrix m (StatPlot lines 5117-5119).
# Rows are the first stat.by column, columns the second; an NA column is named
# "NA" exactly as upstream does.
scp_chord_table <- function(meta.data, stat.by, stat_levels = NULL) {
  md <- .scp_chord_prepare(meta.data, stat.by, stat_levels)
  M <- table(md[[stat.by[1]]], md[[stat.by[2]]], useNA = "ifany")
  m <- matrix(M, ncol = ncol(M), dimnames = dimnames(M))
  colnames(m)[is.na(colnames(m))] <- "NA"
  m
}

# Sector colors: upstream StatPlot() line 5116, unchanged except that
# palette_scp is taken from the local helper environment.
scp_chord_colors <- function(meta.data, stat.by, stat_levels = NULL,
                             palette = "Paired", palcolor = NULL,
                             NA_color = "grey", scp = NULL) {
  if (is.null(scp)) scp <- .scp_chord_default_env()
  palette_scp <- .scp_chord_fun(scp, "palette_scp")
  md <- .scp_chord_prepare(meta.data, stat.by, stat_levels)
  palette_scp(c(unique(unlist(lapply(md[, stat.by, drop = FALSE], levels))), NA),
    palette = palette, palcolor = palcolor, NA_keep = TRUE, NA_color = NA_color
  )
}

# Plot half: upstream StatPlot() chord branch. The temporary png recording
# device, dev.control(), par(mfrow), chordDiagram() arguments, circos.clear()
# and recordPlot() follow lines 4962-4977, 5115-5128 and 5143-5147. Only
# namespace qualification and parameterization of the documented chordDiagram
# arguments differ; defaults equal the upstream constants.
plot_scp_chord <- function(m, stat.by = NULL, colors,
                           nlev = 1L, nrow = NULL, ncol = NULL,
                           transparency = 0.2, link_lwd = 1, link_lty = 1, link_border = 1,
                           seed = 11) {
  if (!is.matrix(m)) stop("m must be a matrix", call. = FALSE)
  if (missing(colors) || is.null(colors)) stop("colors is required", call. = FALSE)
  if (!is.numeric(nlev) || length(nlev) != 1L || is.na(nlev) || nlev < 1) stop("nlev must be a positive number", call. = FALSE)
  if (!requireNamespace("circlize", quietly = TRUE)) {
    stop("Package 'circlize' is required for plot_type = 'chord'", call. = FALSE)
  }
  set.seed(seed)
  temp <- tempfile(fileext = "png")
  grDevices::png(temp)
  grDevices::dev.control("enable")
  if (is.null(nrow) && is.null(ncol)) {
    nrow <- ceiling(sqrt(nlev))
    ncol <- ceiling(nlev / nrow)
  }
  if (is.null(nrow)) {
    nrow <- ceiling(sqrt(ncol))
  }
  if (is.null(ncol)) {
    ncol <- ceiling(sqrt(nrow))
  }
  graphics::par(mfrow = c(nrow, ncol))
  circlize::chordDiagram(m,
    grid.col = colors,
    transparency = transparency,
    link.lwd = link_lwd,
    link.lty = link_lty,
    link.border = link_border
  )
  circlize::circos.clear()
  p <- grDevices::recordPlot()
  plot <- grDevices::recordPlot()
  invisible(grDevices::dev.off())
  unlink(temp)
  plot
}

# End-to-end metadata entry, same inputs as the upstream CellStatPlot example.
scp_chord_meta <- function(meta.data, stat.by, stat_levels = NULL,
                           palette = "Paired", palcolor = NULL, NA_color = "grey",
                           transparency = 0.2, link_lwd = 1, link_lty = 1, link_border = 1,
                           nlev = 1L, nrow = NULL, ncol = NULL, seed = 11, scp = NULL) {
  if (is.null(scp)) scp <- .scp_chord_default_env()
  m <- scp_chord_table(meta.data, stat.by, stat_levels = stat_levels)
  colors <- scp_chord_colors(meta.data, stat.by,
    stat_levels = stat_levels, palette = palette, palcolor = palcolor,
    NA_color = NA_color, scp = scp
  )
  plot_scp_chord(m,
    stat.by = stat.by, colors = colors, nlev = nlev, nrow = nrow, ncol = ncol,
    transparency = transparency, link_lwd = link_lwd, link_lty = link_lty,
    link_border = link_border, seed = seed
  )
}

# --- render-cell-linkage long-table adapter ---------------------------------

# Validate the long table and resolve the two dimensions (their order) and the
# category levels. Each cell must have exactly one row per dimension.
.scp_chord_linkage_dims <- function(linkage, cell_col, dimension_col, category_col,
                                    dimension_order_col, dimension_order = NULL,
                                    category_levels = NULL) {
  if (!is.data.frame(linkage)) stop("linkage must be a data.frame", call. = FALSE)
  if (nrow(linkage) == 0) stop("linkage is empty", call. = FALSE)
  req <- c(cell_col, dimension_col, category_col, dimension_order_col)
  if (anyDuplicated(req)) stop("cell/dimension/category/dimension_order columns must be distinct", call. = FALSE)
  missing <- setdiff(req, names(linkage))
  if (length(missing)) stop("linkage is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  cells <- as.character(linkage[[cell_col]])
  dims_raw <- as.character(linkage[[dimension_col]])
  cats <- as.character(linkage[[category_col]])
  ords <- suppressWarnings(as.numeric(linkage[[dimension_order_col]]))
  if (anyNA(cells)) stop("cell column contains NA", call. = FALSE)
  if (anyNA(dims_raw)) stop("dimension column contains NA", call. = FALSE)
  if (anyNA(cats)) stop("category column contains NA", call. = FALSE)
  if (anyNA(ords)) stop("dimension_order must be numeric and non-NA", call. = FALSE)
  present <- unique(dims_raw)
  ord_by_dim <- tapply(ords, dims_raw, function(x) {
    u <- unique(x)
    if (length(u) != 1L) stop("dimension_order must be a single number per dimension", call. = FALSE)
    u
  })
  if (!is.null(dimension_order)) {
    dimension_order <- as.character(dimension_order)
    if (length(dimension_order) != length(present) || !setequal(dimension_order, present)) {
      stop("style.dimension_order must list exactly the observed dimensions: ", paste(present, collapse = ", "), call. = FALSE)
    }
    dims <- dimension_order
  } else {
    first <- match(present, dims_raw)
    dims <- present[order(as.numeric(ord_by_dim[present]), first)]
  }
  if (length(dims) != 2L) {
    stop("plot_type 'chord' requires exactly two dimensions; found ", length(dims), ": ", paste(dims, collapse = ", "), call. = FALSE)
  }
  key <- paste(cells, dims_raw, sep = "\r")
  if (anyDuplicated(key)) stop("duplicate cell x dimension rows in the linkage table", call. = FALSE)
  cell_sets <- lapply(dims, function(d) unique(cells[dims_raw == d]))
  if (!setequal(cell_sets[[1]], cell_sets[[2]])) {
    only1 <- length(setdiff(cell_sets[[1]], cell_sets[[2]]))
    only2 <- length(setdiff(cell_sets[[2]], cell_sets[[1]]))
    stop("each cell must have one row per dimension; ", only1, " cell(s) lack '", dims[2],
      "' and ", only2, " lack '", dims[1], "'", call. = FALSE)
  }
  if (!is.null(category_levels)) {
    if (!is.list(category_levels)) stop("style.category_levels must be a named list", call. = FALSE)
    extra_dims <- setdiff(names(category_levels), dims)
    if (length(extra_dims)) stop("category_levels names not in dimensions: ", paste(extra_dims, collapse = ", "), call. = FALSE)
    for (d in names(category_levels)) {
      lv <- as.character(category_levels[[d]])
      if (anyNA(lv) || anyDuplicated(lv)) stop("category_levels[['", d, "']] must be unique and non-NA", call. = FALSE)
      extra <- setdiff(unique(cats[dims_raw == d]), lv)
      if (length(extra)) stop("categories missing from category_levels[['", d, "']]: ", paste(extra, collapse = ", "), call. = FALSE)
    }
  }
  list(dims = dims, cells = cells, dims_raw = dims_raw, cats = cats)
}

# Rebuild the wide cell-level metadata (one factor column per dimension) from
# the long linkage table. Levels preserve the explicit category order.
scp_chord_linkage_wide <- function(linkage, cell_col = "cell", dimension_col = "dimension",
                                   category_col = "category", dimension_order_col = "dimension_order",
                                   dimension_order = NULL, category_levels = NULL) {
  info <- .scp_chord_linkage_dims(linkage, cell_col, dimension_col, category_col,
    dimension_order_col,
    dimension_order = dimension_order, category_levels = category_levels
  )
  cells <- unique(info$cells)
  wide <- data.frame(row.names = cells, stringsAsFactors = FALSE)
  for (d in info$dims) {
    idx <- which(info$dims_raw == d)
    pos <- match(cells, info$cells[idx])
    if (anyNA(pos)) stop("internal error: incomplete cell coverage for dimension ", d, call. = FALSE)
    vals <- info$cats[idx][pos]
    lv <- category_levels[[d]]
    if (is.null(lv)) lv <- unique(info$cats[info$dims_raw == d])
    wide[[d]] <- factor(vals, levels = as.character(lv))
  }
  list(meta = wide, stat.by = info$dims, levels = lapply(info$dims, function(d) levels(wide[[d]])))
}

# Size summary used by the adaptive renderer: drawn sector count and the
# longest sector label after explicit category levels are applied.
scp_chord_linkage_summary <- function(linkage, cell_col = "cell", dimension_col = "dimension",
                                      category_col = "category", dimension_order_col = "dimension_order",
                                      dimension_order = NULL, category_levels = NULL) {
  info <- .scp_chord_linkage_dims(linkage, cell_col, dimension_col, category_col,
    dimension_order_col,
    dimension_order = dimension_order, category_levels = category_levels
  )
  cats_per_dim <- lapply(info$dims, function(d) {
    lv <- category_levels[[d]]
    if (is.null(lv)) unique(info$cats[info$dims_raw == d]) else as.character(lv)
  })
  all_cats <- unique(unlist(cats_per_dim, use.names = FALSE))
  list(
    dimensions = info$dims, n_dimensions = length(info$dims),
    n_sectors = length(all_cats), max_label_chars = max(c(0L, nchar(all_cats))),
    n_cells = length(unique(info$cells)), n_rows = nrow(linkage)
  )
}

# End-to-end long-table entry used by the template.
scp_chord_long_meta <- function(linkage, cell_col = "cell", dimension_col = "dimension",
                                category_col = "category", dimension_order_col = "dimension_order",
                                dimension_order = NULL, category_levels = NULL,
                                palette = "Paired", palcolor = NULL, NA_color = "grey",
                                transparency = 0.2, link_lwd = 1, link_lty = 1, link_border = 1,
                                nlev = 1L, nrow = NULL, ncol = NULL, seed = 11, scp = NULL) {
  w <- scp_chord_linkage_wide(linkage,
    cell_col = cell_col, dimension_col = dimension_col, category_col = category_col,
    dimension_order_col = dimension_order_col, dimension_order = dimension_order,
    category_levels = category_levels
  )
  scp_chord_meta(w$meta,
    stat.by = w$stat.by, stat_levels = NULL,
    palette = palette, palcolor = palcolor, NA_color = NA_color,
    transparency = transparency, link_lwd = link_lwd, link_lty = link_lty,
    link_border = link_border, nlev = nlev, nrow = nrow, ncol = ncol,
    seed = seed, scp = scp
  )
}
