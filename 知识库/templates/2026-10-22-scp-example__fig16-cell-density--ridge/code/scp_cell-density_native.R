# Native SCP CellDensityPlot core, split into table and plotting halves.
#
# Source: SCP v0.5.6, R/SCP-plot.R, CellDensityPlot() (lines 5679-5872),
# commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
#
# Table half: scp_cell_density_meta() reproduces the Seurat -> data
# preparation of CellDensityPlot() (lines 5689-5758) and returns one row per
# cell x feature (cell, feature, value, group, split + explicit orders).
# scp_cell_density_values() is the same table for an already extracted
# cells x features matrix plus metadata (no Seurat dependency).
#
# Plot half: plot_scp_cell_density() copies the ggplot/ggridges construction
# (lines 5760-5872) line for line. Compatibility changes are limited to
# input assembly and namespace resolution; every drawing call is unchanged.
# See PATCHES.md.

`%||%` <- function(x, y) if (is.null(x)) y else x

# Resolve a helper from an SCP environment or from an installed package name.
.scp_cell_density_fun <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# Table half: long cell x feature table.
# dat_exp: numeric matrix/data.frame, rows = cells, columns = features.
# meta_data: data.frame, rows = cells, columns include group.by / split.by.
# Returns data.frame(cell, feature, value, group, split, feature_order,
# group_order, split_order) with attributes feature_levels, group_levels,
# split_levels so the plotting order survives a CSV round trip.
scp_cell_density_values <- function(dat_exp, meta_data = NULL, group.by = NULL,
                                    split.by = NULL, cells = NULL,
                                    feature_order = NULL) {
  if (is.null(dat_exp)) {
    stop("'dat_exp' must be provided.", call. = FALSE)
  }
  if (!is.numeric(dat_exp) && !inherits(dat_exp, "Matrix")) {
    stop("'dat_exp' must be type of numeric variable.", call. = FALSE)
  }
  dat_exp <- as.matrix(dat_exp)
  if (is.null(rownames(dat_exp)) || is.null(colnames(dat_exp))) {
    stop("'dat_exp' must have cell row names and feature column names.", call. = FALSE)
  }
  if (is.null(group.by)) {
    group.by <- "All.groups"
  }
  if (is.null(split.by)) {
    split.by <- "All.groups"
  }
  if (length(group.by) != 1L || length(split.by) != 1L) {
    stop("This split core handles one group.by and one split.by variable.", call. = FALSE)
  }
  if (is.null(meta_data)) {
    meta_data <- data.frame(row.names = rownames(dat_exp))
  }
  meta_data <- as.data.frame(meta_data, stringsAsFactors = FALSE)
  for (i in c(group.by, split.by)) {
    if (!i %in% colnames(meta_data)) {
      if (i == "All.groups") {
        meta_data[[i]] <- factor("")
      } else {
        stop(paste0(i, " is not in the meta.data of srt object."), call. = FALSE)
      }
    }
    if (!is.factor(meta_data[[i]])) {
      meta_data[[i]] <- factor(meta_data[[i]], levels = unique(meta_data[[i]]))
    }
  }

  dat_use <- cbind(dat_exp, meta_data[rownames(dat_exp), c(group.by, split.by), drop = FALSE])
  if (!is.null(cells)) {
    dat_use <- dat_use[intersect(rownames(dat_use), cells), , drop = FALSE]
  }

  features <- colnames(dat_exp)
  if (!is.null(feature_order)) {
    features <- features[match(unique(feature_order), features)]
    if (anyNA(features)) stop("feature_order must reference table features", call. = FALSE)
  }
  mat <- as.matrix(dat_use[, colnames(dat_exp), drop = FALSE])
  grp <- dat_use[[group.by]]
  spl <- dat_use[[split.by]]
  long <- data.frame(
    cell = rep(rownames(dat_use), each = length(features)),
    feature = rep(features, times = nrow(dat_use)),
    value = as.vector(t(mat[, features, drop = FALSE])),
    group = rep(as.character(grp), each = length(features)),
    split = rep(as.character(spl), each = length(features)),
    feature_order = rep(seq_along(features), times = nrow(dat_use)),
    group_order = rep(as.integer(grp), each = length(features)),
    split_order = rep(as.integer(spl), each = length(features)),
    stringsAsFactors = FALSE
  )
  attr(long, "feature_levels") <- features
  attr(long, "group_levels") <- levels(grp)
  attr(long, "split_levels") <- levels(spl)
  attr(long, "group_by") <- group.by
  attr(long, "split_by") <- split.by
  long
}

# Explicit Seurat entry: reproduces CellDensityPlot() data preparation,
# then returns the lossless long table.
scp_cell_density_meta <- function(srt, features, group.by = NULL, split.by = NULL,
                                  assay = NULL, slot = "data", cells = NULL,
                                  scp = SCP_helpers) {
  as_matrix <- .scp_cell_density_fun(scp, "as_matrix")
  # Upstream CellDensityPlot() calls DefaultAssay() from Seurat (attached by
  # the SCP namespace). Resolve it from SeuratObject so the explicit entry
  # does not need SCP to be installed.
  assay <- assay %||% SeuratObject::DefaultAssay(srt)
  if (is.null(features)) {
    stop("'features' must be provided.", call. = FALSE)
  }
  if (!inherits(features, "character")) {
    stop("'features' is not a character vectors", call. = FALSE)
  }
  if (is.null(group.by)) {
    group.by <- "All.groups"
    srt@meta.data[[group.by]] <- factor("")
  }
  if (is.null(split.by)) {
    split.by <- "All.groups"
    srt@meta.data[[split.by]] <- factor("")
  }
  for (i in c(group.by, split.by)) {
    if (!i %in% colnames(srt@meta.data)) {
      stop(paste0(i, " is not in the meta.data of srt object."), call. = FALSE)
    }
    if (!is.factor(srt@meta.data[[i]])) {
      srt@meta.data[[i]] <- factor(srt@meta.data[[i]], levels = unique(srt@meta.data[[i]]))
    }
  }

  features <- unique(features)
  features_drop <- features[!features %in% c(rownames(srt@assays[[assay]]), colnames(srt@meta.data))]
  if (length(features_drop) > 0) {
    warning(paste0(features_drop, collapse = ","), " are not in the features of srt.", immediate. = TRUE)
    features <- features[!features %in% features_drop]
  }

  features_gene <- features[features %in% rownames(srt@assays[[assay]])]
  features_meta <- features[features %in% colnames(srt@meta.data)]
  if (length(intersect(features_gene, features_meta)) > 0) {
    warning("Features appear in both gene names and metadata names: ", paste0(intersect(features_gene, features_meta), collapse = ","))
  }

  if (length(features_gene) > 0) {
    dat_gene <- t(methods::slot(srt@assays[[assay]], slot)[features_gene, , drop = FALSE])
  } else {
    dat_gene <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  if (length(features_meta) > 0) {
    dat_meta <- as_matrix(srt@meta.data[, features_meta, drop = FALSE])
  } else {
    dat_meta <- matrix(nrow = ncol(srt@assays[[1]]), ncol = 0)
  }
  dat_exp <- cbind(dat_gene, dat_meta)
  features <- unique(features[features %in% c(features_gene, features_meta)])

  if (!is.numeric(dat_exp) && !inherits(dat_exp, "Matrix")) {
    stop("'features' must be type of numeric variable.", call. = FALSE)
  }
  scp_cell_density_values(
    dat_exp = dat_exp, meta_data = srt@meta.data,
    group.by = group.by, split.by = split.by, cells = cells,
    feature_order = features
  )
}

# Plot half: rebuild dat_use from the long table, then run the upstream
# ggplot construction. `tab` is the table returned by the table half (or the
# interface CSV); every drawing parameter is read from `style`.
plot_scp_cell_density <- function(tab, style = list(), scp = SCP_helpers) {
  palette_scp <- .scp_cell_density_fun(scp, "palette_scp")
  theme_scp <- .scp_cell_density_fun(scp, "theme_scp")

  cell_col <- style$cell_col %||% "cell"
  feature_col <- style$feature_col %||% "feature"
  value_col <- style$value_col %||% "value"
  group_col <- style$group_col %||% "group"
  split_col <- style$split_col %||% "split"
  feature_order_col <- style$feature_order_col %||% "feature_order"
  group_order_col <- style$group_order_col %||% "group_order"
  split_order_col <- style$split_order_col %||% "split_order"
  group.by <- style$group_by %||% attr(tab, "group_by") %||% "SubCellType"
  split.by <- style$split_by %||% attr(tab, "split_by") %||% "All.groups"

  req <- c(cell_col, feature_col, value_col, group_col)
  if (!all(req %in% names(tab))) {
    stop("Missing table column: ", paste(setdiff(req, names(tab)), collapse = ", "), call. = FALSE)
  }
  features <- unique(as.character(tab[[feature_col]]))
  if (feature_order_col %in% names(tab)) {
    ord <- tapply(tab[[feature_order_col]], tab[[feature_col]], function(x) x[1])
    features <- names(sort(ord))
  }
  group_levels <- unique(as.character(tab[[group_col]]))
  if (group_order_col %in% names(tab)) {
    gord <- tapply(tab[[group_order_col]], tab[[group_col]], function(x) x[1])
    group_levels <- names(sort(gord))
  }
  split_levels <- "All.groups"
  if (split_col %in% names(tab)) {
    split_levels <- unique(as.character(tab[[split_col]]))
    if (split_order_col %in% names(tab)) {
      sord <- tapply(tab[[split_order_col]], tab[[split_col]], function(x) x[1])
      split_levels <- names(sort(sord))
    }
  }
  if (!is.null(style$feature_levels)) {
    features <- as.character(style$feature_levels)
    if (!setequal(features, unique(as.character(tab[[feature_col]])))) {
      stop("style feature_levels must cover exactly the observed features", call. = FALSE)
    }
  }
  if (!is.null(style$group_levels)) {
    group_levels <- as.character(style$group_levels)
    if (!setequal(group_levels, unique(as.character(tab[[group_col]])))) {
      stop("style group_levels must cover exactly the observed groups", call. = FALSE)
    }
  }
  if (anyNA(tab[[group_col]])) {
    stop("group must not contain NA", call. = FALSE)
  }

  cells <- unique(as.character(tab[[cell_col]]))
  dat_exp <- matrix(NA_real_, nrow = length(cells), ncol = length(features),
                    dimnames = list(cells, features))
  cell_idx <- match(as.character(tab[[cell_col]]), cells)
  feat_idx <- match(as.character(tab[[feature_col]]), features)
  slots <- cbind(cell_idx, feat_idx)
  if (anyDuplicated(slots)) {
    stop("duplicated cell x feature rows in the input table", call. = FALSE)
  }
  dat_exp[slots] <- as.numeric(tab[[value_col]])
  first <- match(cells, as.character(tab[[cell_col]]))
  if (split_col %in% names(tab)) {
    dat_split <- factor(as.character(tab[[split_col]])[first], levels = split_levels)
  } else {
    dat_split <- factor(rep("", length(cells)), levels = "")
  }
  meta_use <- data.frame(
    group = factor(as.character(tab[[group_col]])[first], levels = group_levels),
    split = dat_split,
    stringsAsFactors = FALSE
  )
  colnames(meta_use) <- c(group.by, split.by)

  dat_use <- cbind(dat_exp, meta_use)

  x_order <- style$x_order %||% "value"
  flip <- style$flip %||% FALSE
  reverse <- style$reverse %||% FALSE
  decreasing <- style$decreasing %||% NULL
  palette <- style$palette %||% "Paired"
  palcolor <- style$palcolor %||% NULL
  keep_empty <- style$keep_empty %||% FALSE
  y.nbreaks <- style$y_nbreaks %||% 4
  y.min <- style$y_min %||% NULL
  y.max <- style$y_max %||% NULL
  aspect.ratio <- style$aspect_ratio %||% NULL
  title <- style$title %||% NULL
  subtitle <- style$subtitle %||% NULL
  legend.position <- style$legend_position %||% "right"
  legend.direction <- style$legend_direction %||% "vertical"
  theme_use <- style$theme_use %||% "theme_scp"
  theme_args <- style$theme_args %||% list()
  combine <- style$combine %||% TRUE
  nrow <- style$nrow %||% NULL
  ncol <- style$ncol %||% NULL
  byrow <- style$byrow %||% TRUE

  # ---- upstream CellDensityPlot() lines 5760-5859, unchanged ----
  plist <- list()
  for (f in features) {
    for (g in group.by) {
      colors <- palette_scp(levels(dat_use[[g]]), palette = palette, palcolor = palcolor)
      for (s in levels(dat_use[[split.by]])) {
        dat <- dat_use[dat_use[[split.by]] == s, , drop = FALSE]
        if (any(is.infinite(dat[, f]))) {
          dat[, f][dat[, f] == max(dat[, f], na.rm = TRUE)] <- max(dat[, f][is.finite(dat[, f])], na.rm = TRUE)
          dat[, f][dat[, f] == min(dat[, f], na.rm = TRUE)] <- min(dat[, f][is.finite(dat[, f])], na.rm = TRUE)
        }
        dat[, "cell"] <- rownames(dat)
        if (x_order == "value") {
          dat[, "value"] <- dat[, f]
        } else {
          dat[, "value"] <- rank(dat[, f])
        }
        dat[, "features"] <- f
        dat[, "split.by"] <- s
        dat <- dat[!is.na(dat[[f]]), , drop = FALSE]
        y_max_use <- y.max %||% suppressWarnings(max(dat[, "value"][is.finite(x = dat[, "value"])], na.rm = TRUE))
        y_min_use <- y.min %||% suppressWarnings(min(dat[, "value"][is.finite(x = dat[, "value"])], na.rm = TRUE))

        if (!is.null(decreasing)) {
          levels <- dat %>%
            group_by_at(g) %>%
            summarise_at(.funs = median, .vars = f, na.rm = TRUE) %>%
            arrange_at(.vars = f, .funs = if (decreasing) desc else list()) %>%
            pull(g) %>%
            as.character()
          dat[["order"]] <- factor(dat[[g]], levels = levels)
        } else {
          dat[["order"]] <- factor(dat[[g]], levels = rev(levels(dat[[g]])))
        }
        if (flip) {
          dat[["order"]] <- factor(dat[[g]], levels = levels(dat[[g]]))
          aspect.ratio <- 1 / aspect.ratio
          if (length(aspect.ratio) == 0 || is.na(aspect.ratio)) {
            aspect.ratio <- NULL
          }
        }
        p <- ggplot(dat, aes(x = .data[["value"]], y = .data[["order"]], fill = .data[[g]])) +
          ggridges::geom_density_ridges()
        p <- p + scale_fill_manual(
          name = paste0(g, ":"),
          values = colors
        )
        y.trans <- ifelse(flip, "reverse", "identity")
        y.trans <- ifelse(reverse, setdiff(c("reverse", "identity"), y.trans), y.trans)

        limits <- if (y.trans == "reverse") c(y_max_use, y_min_use) else c(y_min_use, y_max_use)
        p <- p +
          scale_y_discrete(drop = !keep_empty, expand = c(0, 0)) +
          scale_x_continuous(
            limits = limits, trans = y.trans, n.breaks = y.nbreaks,
            expand = c(0, 0)
          )
        if (split.by != "All.groups") {
          p <- p + facet_grid(. ~ split.by)
        }
        p <- p + labs(title = title, subtitle = subtitle, x = f, y = g)
        if (isTRUE(flip)) {
          p <- p + do.call(theme_use, theme_args) +
            theme(
              aspect.ratio = aspect.ratio,
              strip.text.x = element_text(angle = 0),
              axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
              axis.ticks.x = element_line(),
              panel.grid.major.x = element_line(color = "grey", linetype = 2),
              legend.position = legend.position,
              legend.direction = legend.direction
            ) + coord_flip()
        } else {
          p <- p + do.call(theme_use, theme_args) +
            theme(
              aspect.ratio = aspect.ratio,
              strip.text.y = element_text(angle = 0),
              axis.text.x = element_text(),
              axis.text.y = element_text(hjust = 1),
              axis.ticks.y = element_line(),
              panel.grid.major.y = element_line(color = "grey", linetype = 2),
              legend.position = legend.position,
              legend.direction = legend.direction
            )
        }
        plist[[paste0(f, ":", g, ":", paste0(s, collapse = ","))]] <- p
      }
    }
  }

  if (isTRUE(combine)) {
    if (length(plist) > 1) {
      plot <- wrap_plots(plotlist = plist, nrow = nrow, ncol = ncol, byrow = byrow)
    } else {
      plot <- plist[[1]]
    }
    return(plot)
  } else {
    return(plist)
  }
}
