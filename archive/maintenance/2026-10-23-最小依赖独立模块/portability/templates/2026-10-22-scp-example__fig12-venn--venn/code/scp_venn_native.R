# Native SCP CellStatPlot venn core.
# Extracted from SCP v0.5.6 R/SCP-plot.R, commit
# b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>=3).
#
# Table half: scp_venn_table() reproduces the StatPlot() venn data path
#   (generic preamble lines 4575-4693 + lines 4981-5001): stat_level
#   handling, per-set cell lists, ggVennDiagram::Venn/process_data,
#   region counts, region colours (blendcolors), and region labels.
# Plot half: plot_scp_venn() reproduces the venn ggplot construction
#   (lines 5002-5042) line-for-line, with only namespace qualification and
#   the documented ggVennDiagram >= 1.4/1.5.7 compatibility patch (see
#   PATCHES.md). It is not a custom ggplot rewrite.
#
# No SCP package is required. palette_scp/blendcolors come from the local
# scp_helpers.R environment.

if (!exists("%||%", mode = "function")) {
  `%||%` <- function(x, y) if (is.null(x)) y else x
}

.scp_venn_default_env <- function() {
  for (nm in c("SCP_helpers", "SCP_local")) {
    if (exists(nm, envir = globalenv(), inherits = FALSE)) {
      return(get(nm, envir = globalenv(), inherits = FALSE))
    }
  }
  stop("Pass a local SCP helper environment via scp=; the SCP package is not required.", call. = FALSE)
}

.scp_venn_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# Split one region's closed edge path into polygon rings. The shape data store
# one closed ring per id in the representative 2-7 set shapes; this also keeps
# working if a region is stored as several closed rings.
.scp_venn_rings <- function(m) {
  if (nrow(m) < 3L) stop("region edge has fewer than 3 points", call. = FALSE)
  starts <- 1L
  if (nrow(m) > 3L) {
    for (i in 2:(nrow(m) - 1L)) {
      if (all(m[i, ] == m[1, ])) {
        starts <- c(starts, i)
        m <- m[-(1:(i - 1L)), , drop = FALSE]
        break
      }
    }
  }
  if (!all(m[1, ] == m[nrow(m), ])) m <- rbind(m, m[1, ])
  list(m)
}

# PATCH 1 (ggVennDiagram >= 1.4): venn_region() returns a plain data.frame and
# no longer carries an sf geometry column (sf support was removed in 1.4).
# Rebuild the same polygons from process_data()$regionEdge so that the upstream
# geom_sf() construction can be kept. Coordinates are the package's own shape
# coordinates; st_centroid() of these polygons equals venn_region label
# coordinates exactly (see PATCHES.md, proof).
scp_venn_region_sf <- function(venn_data, regions = NULL) {
  if (!requireNamespace("sf", quietly = TRUE)) stop("Package 'sf' is required", call. = FALSE)
  if (is.null(regions)) {
    regions <- as.data.frame(ggVennDiagram::venn_region(venn_data), stringsAsFactors = FALSE)
  } else {
    regions <- as.data.frame(regions, stringsAsFactors = FALSE)
  }
  edge <- venn_data$regionEdge
  ids <- unique(edge$id)
  geom <- lapply(regions$id, function(id) {
    m <- as.matrix(edge[edge$id == id, c("X", "Y"), drop = FALSE])
    rings <- .scp_venn_rings(m)
    if (length(rings) == 1L && all(rings[[1]][1, ] == rings[[1]][nrow(rings[[1]]), ])) {
      sf::st_polygon(list(rings[[1]]))
    } else {
      sf::st_multipolygon(lapply(rings, function(r) list(r)))
    }
  })
  sf::st_sf(regions, geometry = sf::st_sfc(geom))
}

# PATCH 2 (ggVennDiagram >= 1.4): venn_setedge() no longer returns sf geometry
# and (>= 1.5.7) no longer carries a `name` column. Rebuild one LINESTRING per
# set and attach `name` from venn_setlabel() by id, as required by the upstream
# lookup colors[dat_venn_setedge[["name"]]].
scp_venn_setedge_sf <- function(venn_data, colors) {
  if (!requireNamespace("sf", quietly = TRUE)) stop("Package 'sf' is required", call. = FALSE)
  edge <- venn_data$setEdge
  setlabel <- as.data.frame(ggVennDiagram::venn_setlabel(venn_data), stringsAsFactors = FALSE)
  ids <- unique(edge$id)
  name <- setlabel$name[match(ids, setlabel$id)]
  geom <- lapply(ids, function(id) {
    sf::st_linestring(as.matrix(edge[edge$id == id, c("X", "Y"), drop = FALSE]))
  })
  out <- sf::st_sf(
    data.frame(id = ids, name = name, stringsAsFactors = FALSE),
    geometry = sf::st_sfc(geom)
  )
  out[["colors"]] <- colors[out[["name"]]]
  out
}

# venn_setlabel() in 1.5.7 keeps X/Y columns but no sf geometry. Rebuild POINT
# geometry so the upstream do.call(rbind, dat_venn_setlabel$geometry) line is
# preserved. Coordinates are the package's own label coordinates.
scp_venn_setlabel_sf <- function(venn_data) {
  if (!requireNamespace("sf", quietly = TRUE)) stop("Package 'sf' is required", call. = FALSE)
  setlabel <- as.data.frame(ggVennDiagram::venn_setlabel(venn_data), stringsAsFactors = FALSE)
  geom <- lapply(seq_len(nrow(setlabel)), function(i) sf::st_point(c(setlabel$X[i], setlabel$Y[i])))
  sf::st_sf(setlabel, geometry = sf::st_sfc(geom))
}

# Table half. Mirrors StatPlot(): generic venn preamble, per-set cell lists,
# Venn()/process_data(), region counts/percent labels/colours. `group.by` and
# `split.by` accept the upstream defaults (NULL -> "All.groups"); the returned
# object records the single split level used by the venn branch.
scp_venn_table <- function(meta.data, stat.by, group.by = NULL, split.by = NULL,
                           stat_level = NULL, NA_stat = TRUE, force = FALSE,
                           palette = "Paired", palcolor = NULL, seed = 11,
                           scp = NULL) {
  if (!is.data.frame(meta.data)) stop("meta.data must be a data.frame", call. = FALSE)
  if (nrow(meta.data) == 0) stop("meta.data is empty.", call. = FALSE)
  stat.by <- as.character(stat.by)
  if (length(stat.by) < 2L) stop("plot_type 'venn' needs at least 2 stat.by columns", call. = FALSE)
  if (length(stat.by) > 7L) stop("'stat.by' can only be a vector of length <= 7 when 'plot_type' is 'venn'.", call. = FALSE)
  missing_cols <- setdiff(stat.by, colnames(meta.data))
  if (length(missing_cols)) stop(paste0(missing_cols, collapse = ", "), " is not in the meta.data.", call. = FALSE)

  md <- as.data.frame(meta.data)
  if (is.null(group.by)) {
    group.by <- "All.groups"
    md[[group.by]] <- factor("")
  }
  if (is.null(split.by)) {
    split.by <- "All.groups"
    md[[split.by]] <- factor("")
  }
  for (i in unique(c(group.by, split.by))) {
    if (!i %in% colnames(md)) stop(paste0(i, " is not in the meta.data."), call. = FALSE)
    if (!is.factor(md[[i]])) md[[i]] <- factor(md[[i]], levels = unique(md[[i]]))
  }
  for (i in unique(stat.by)) {
    if (!i %in% colnames(md)) stop(paste0(i, " is not in the meta.data."), call. = FALSE)
    if (!is.factor(md[[i]]) && !is.logical(md[[i]])) {
      md[[i]] <- factor(md[[i]], levels = unique(md[[i]]))
    }
  }

  if (length(stat.by) > 7L) stop("too many sets", call. = FALSE)

  # Upstream stat_level handling (lines 4650-4670).
  if (is.null(stat_level)) {
    stat_level <- lapply(stat.by, function(stat) {
      levels(md[[stat]])[1] %||% sort(unique(md[[stat]]))[1]
    })
    message("stat_level is set to ", paste0(stat_level, collapse = ","))
  } else {
    if (length(stat_level) == 1L) stat_level <- rep(stat_level, length(stat.by))
    if (length(stat_level) != length(stat.by)) {
      stop("'stat_level' must be of length 1 or the same length as 'stat.by'", call. = FALSE)
    }
  }
  if (is.null(names(stat_level))) names(stat_level) <- stat.by
  for (i in stat.by) {
    md[[i]] <- md[[i]] %in% stat_level[[i]]
  }

  if (any(group.by != "All.groups")) {
    warning("group.by is not used when plot sankey, chord, venn or upset", immediate. = TRUE)
  }

  dat_all <- md[, unique(c(stat.by, group.by, split.by)), drop = FALSE]
  nlev <- sapply(dat_all, nlevels)
  nlev <- nlev[nlev > 100]
  if (length(nlev) > 0 && !isTRUE(force)) {
    stop(paste(names(nlev), collapse = ","), " have more than 100 levels; pass force = TRUE to continue.", call. = FALSE)
  }
  dat_split <- split.data.frame(dat_all, dat_all[[split.by]])
  split_levels <- levels(dat_all[[split.by]])
  if (length(split_levels) != 1L) {
    stop("The native venn core supports one split level; got ", length(split_levels), call. = FALSE)
  }
  sp <- split_levels[1]
  dat_use <- dat_split[[ifelse(split.by == "All.groups", 1, sp)]]

  if (is.null(scp)) scp <- .scp_venn_default_env()
  palette_scp <- .scp_venn_fun(scp, "palette_scp")
  blendcolors <- .scp_venn_fun(scp, "blendcolors")

  # Upstream lines 4961 and 4982-5001, verbatim except the check_R call.
  colors <- palette_scp(stat.by, palette = palette, palcolor = palcolor)
  if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
    stop("Package 'ggVennDiagram' is required", call. = FALSE)
  }
  if (!requireNamespace("sf", quietly = TRUE)) stop("Package 'sf' is required", call. = FALSE)
  dat_list <- as.list(dat_use[, stat.by])
  dat_list <- lapply(setNames(names(dat_list), names(dat_list)), function(x) {
    lg <- dat_list[[x]]
    names(lg) <- rownames(dat_use)
    cellkeep <- names(lg)[lg]
    return(cellkeep)
  })
  venn <- ggVennDiagram::Venn(dat_list)
  venn_data <- ggVennDiagram::process_data(venn)
  dat_venn_region <- ggVennDiagram::venn_region(venn_data)
  idname <- dat_venn_region[["name"]][dat_venn_region[["name"]] %in% stat.by]
  names(idname) <- dat_venn_region[["id"]][dat_venn_region[["name"]] %in% stat.by]
  idcomb <- strsplit(dat_venn_region[["id"]], split = "")
  colorcomb <- lapply(idcomb, function(x) colors[idname[as.character(x)]])
  dat_venn_region[["colors"]] <- sapply(colorcomb, function(x) blendcolors(x, mode = "blend"))
  dat_venn_region[["label"]] <- paste0(
    dat_venn_region[["count"]], "\n",
    round(dat_venn_region[["count"]] / sum(dat_venn_region[["count"]]) * 100, 1), "%"
  )
  dat_venn_setlabel <- ggVennDiagram::venn_setlabel(venn_data)
  dat_venn_setedge <- ggVennDiagram::venn_setedge(venn_data)

  regions <- as.data.frame(dat_venn_region, stringsAsFactors = FALSE)
  sets <- data.frame(
    id = dat_venn_setlabel[["id"]],
    name = dat_venn_setlabel[["name"]],
    size = as.integer(sapply(dat_list, length)[dat_venn_setlabel[["name"]]]),
    stringsAsFactors = FALSE
  )
  set_labels <- as.data.frame(dat_venn_setlabel, stringsAsFactors = FALSE)

  out <- list(
    regions = regions,
    sets = sets,
    set_labels = set_labels,
    dat_list = dat_list,
    venn_data = venn_data,
    colors = colors,
    split_level = sp,
    stat.by = stat.by,
    group.by = group.by,
    split.by = split.by,
    n_cells = nrow(dat_use),
    seed = seed
  )
  class(out) <- "scp_venn"
  out
}

# Plot half: original StatPlot() venn ggplot construction (lines 5002-5042).
plot_scp_venn <- function(tab, alpha = 1,
                          label.size = 3.5, label.fg = "black", label.bg = "white", label.bg.r = 0.1,
                          title = NULL, subtitle = NULL, seed = 11) {
  if (!inherits(tab, "scp_venn")) stop("tab must be a scp_venn object from scp_venn_table()", call. = FALSE)
  set.seed(seed)

  dat_venn_region <- scp_venn_region_sf(tab$venn_data, tab$regions)
  dat_venn_setedge <- scp_venn_setedge_sf(tab$venn_data, tab$colors)
  dat_venn_setlabel <- scp_venn_setlabel_sf(tab$venn_data)
  dat_title <- as.data.frame(do.call(rbind, dat_venn_setlabel$geometry))
  colnames(dat_title) <- c("x", "y")
  dat_title[["label"]] <- paste0(
    dat_venn_setlabel[["name"]], "\n",
    "(", sapply(tab$dat_list, length)[dat_venn_setlabel[["name"]]], ")"
  )
  dat_stat <- as.data.frame(do.call(rbind, lapply(dat_venn_region$geometry, function(x) sf::st_centroid(x))))
  colnames(dat_stat) <- c("x", "y")
  dat_stat[["label"]] <- tab$regions[["label"]]
  p <- ggplot() +
    geom_sf(data = dat_venn_region, aes(fill = colors), alpha = alpha) +
    geom_sf(data = dat_venn_setedge, aes(color = colors), size = 1) +
    geom_text_repel(
      data = dat_title, aes(label = label, x = x, y = y),
      fontface = "bold",
      colour = label.fg, size = label.size + 0.5,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100, force = 0,
      min.segment.length = 0, segment.colour = "black"
    ) +
    geom_text_repel(
      data = dat_stat, aes(label = label, x = x, y = y),
      colour = label.fg, size = label.size,
      bg.color = label.bg, bg.r = label.bg.r,
      point.size = NA, max.overlaps = 100, force = 0,
      min.segment.length = 0, segment.colour = "black"
    ) +
    scale_fill_identity() +
    scale_color_identity() +
    theme(
      plot.title = element_text(hjust = 0.5),
      plot.background = element_blank(),
      panel.background = element_blank(),
      axis.title.y = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank()
    )
  p <- p + labs(x = tab$split_level, title = title, subtitle = subtitle)
  p
}

# End-to-end entry from cell-level metadata (same inputs as CellStatPlot).
scp_venn_meta <- function(meta.data, stat.by, group.by = NULL, split.by = NULL,
                          stat_level = NULL, NA_stat = TRUE, force = FALSE,
                          stat_type = c("percent", "count"),
                          palette = "Paired", palcolor = NULL, alpha = 1,
                          label.size = 3.5, label.fg = "black", label.bg = "white", label.bg.r = 0.1,
                          title = NULL, subtitle = NULL, seed = 11, scp = NULL) {
  stat_type <- match.arg(stat_type)
  if (stat_type == "percent") {
    warning("stat_type is forcibly set to 'count' when plot sankey, chord, venn or upset", immediate. = TRUE)
  }
  tab <- scp_venn_table(
    meta.data = meta.data, stat.by = stat.by, group.by = group.by, split.by = split.by,
    stat_level = stat_level, NA_stat = NA_stat, force = force,
    palette = palette, palcolor = palcolor, seed = seed, scp = scp
  )
  plot_scp_venn(
    tab, alpha = alpha, label.size = label.size, label.fg = label.fg,
    label.bg = label.bg, label.bg.r = label.bg.r,
    title = title, subtitle = subtitle, seed = seed
  )
}

# Aggregated QA table: one row per intersection (region), same order and values
# as the region table used by the plot.
scp_venn_intersections <- function(tab) {
  if (!inherits(tab, "scp_venn")) stop("tab must be a scp_venn object", call. = FALSE)
  data.frame(
    id = tab$regions$id,
    sets = tab$regions$name,
    count = as.integer(tab$regions$count),
    percent = round(tab$regions$count / sum(tab$regions$count) * 100, 1),
    color = tab$regions$colors,
    stringsAsFactors = FALSE
  )
}

scp_venn_set_sizes <- function(tab) {
  if (!inherits(tab, "scp_venn")) stop("tab must be a scp_venn object", call. = FALSE)
  data.frame(id = tab$sets$id, set = tab$sets$name, size = as.integer(tab$sets$size),
             stringsAsFactors = FALSE)
}
