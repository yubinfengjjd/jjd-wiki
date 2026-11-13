# Native SCP volcano core, extracted from SCP v0.5.6 R/SCP-plot.R
# commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>=3).
#
# The table half is the data preparation performed inside VolcanoPlot():
# diff_pct, -log10(padj), DE flag, quantile capping, signed y, ordering.
# The plot half is the original single-group ggplot construction, unchanged
# except that the facet variable is explicit instead of hard-coded `group1`.
# No geometry, palette, theme, threshold or label rule was re-implemented.
#
# Dependency: an environment containing theme_scp() and palette_scp(), passed
# via `scp`; defaults to SCP_helpers or SCP_local in globalenv. The SCP package
# is not required.

.scp_default_env <- function() {
  for (nm in c("SCP_helpers", "SCP_local")) {
    if (exists(nm, envir = globalenv(), inherits = FALSE)) {
      return(get(nm, envir = globalenv(), inherits = FALSE))
    }
  }
  stop("Pass a local SCP helper environment via scp=; the SCP package is not required.", call. = FALSE)
}

.scp_fun_v <- function(scp, name) {
  if (is.environment(scp) && exists(name, envir = scp, inherits = FALSE)) {
    get(name, envir = scp, inherits = FALSE)
  } else if (is.character(scp) && length(scp) == 1L) {
    getExportedValue(scp, name)
  } else {
    stop("scp must be an environment or package name containing ", name, call. = FALSE)
  }
}

# Table-producing half of VolcanoPlot(). `de_df` is one AllMarkers table with
# gene, group1, avg_log2FC, pct.1, pct.2, p_val_adj.
scp_volcano_table <- function(de_df,
                              group.by = "group1",
                              DE_threshold = "avg_log2FC > 0 & p_val_adj < 0.05",
                              x_metric = c("diff_pct", "avg_log2FC")) {
  x_metric <- match.arg(x_metric)
  required <- c("gene", group.by, "avg_log2FC", "pct.1", "pct.2", "p_val_adj")
  missing <- setdiff(required, names(de_df))
  if (length(missing)) {
    stop("missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  de_df <- as.data.frame(de_df)
  if (!is.factor(de_df[[group.by]])) {
    de_df[[group.by]] <- factor(de_df[[group.by]], levels = unique(as.character(de_df[[group.by]])))
  }
  de_df[, "diff_pct"] <- de_df[, "pct.1"] - de_df[, "pct.2"]
  de_df[, "-log10padj"] <- -log10(de_df[, "p_val_adj"])
  de_df[, "DE"] <- FALSE
  de_df[with(de_df, eval(rlang::parse_expr(DE_threshold))), "DE"] <- TRUE

  x_upper <- quantile(de_df[["avg_log2FC"]][is.finite(de_df[["avg_log2FC"]])], c(0.99, 1))
  x_lower <- quantile(de_df[["avg_log2FC"]][is.finite(de_df[["avg_log2FC"]])], c(0.01, 0))
  x_upper <- ifelse(x_upper[1] > 0, x_upper[1], x_upper[2])
  x_lower <- ifelse(x_lower[1] < 0, x_lower[1], x_lower[2])
  if (x_upper > 0 & x_lower < 0) {
    value_range <- min(abs(c(x_upper, x_lower)), na.rm = TRUE)
    x_upper <- value_range
    x_lower <- -value_range
  }

  de_df[, "border"] <- FALSE
  de_df[de_df[["avg_log2FC"]] > x_upper, "border"] <- TRUE
  de_df[de_df[["avg_log2FC"]] > x_upper, "avg_log2FC"] <- x_upper
  de_df[de_df[["avg_log2FC"]] < x_lower, "border"] <- TRUE
  de_df[de_df[["avg_log2FC"]] < x_lower, "avg_log2FC"] <- x_lower

  de_df[, "y"] <- -log10(de_df[, "p_val_adj"])
  if (x_metric == "diff_pct") {
    de_df[, "x"] <- de_df[, "diff_pct"]
    de_df[de_df[, "avg_log2FC"] < 0, "y"] <- -de_df[de_df[, "avg_log2FC"] < 0, "y"]
    de_df <- de_df[order(abs(de_df[, "avg_log2FC"]), decreasing = FALSE, na.last = FALSE), , drop = FALSE]
  } else if (x_metric == "avg_log2FC") {
    de_df[, "x"] <- de_df[, "avg_log2FC"]
    de_df[de_df[, "diff_pct"] < 0, "y"] <- -de_df[de_df[, "diff_pct"] < 0, "y"]
    de_df <- de_df[order(abs(de_df[, "diff_pct"]), decreasing = FALSE, na.last = FALSE), , drop = FALSE]
  }
  de_df[, "distance"] <- de_df[, "x"]^2 + de_df[, "y"]^2

  attr(de_df, "group.by") <- group.by
  attr(de_df, "x_metric") <- x_metric
  attr(de_df, "x_upper") <- x_upper
  attr(de_df, "x_lower") <- x_lower
  attr(de_df, "DE_threshold") <- DE_threshold
  de_df
}

# Label selection performed inside VolcanoPlot(), extracted so the table half,
# renderer sizing and the plot use one rule. Returns `dat` with a label column.
scp_volcano_labels <- function(dat, group.by = "group1", nlabel = 5,
                               features_label = NULL) {
  de_df <- as.data.frame(dat)
  if (!all(c("gene", group.by, "y", "distance") %in% names(de_df))) {
    stop("dat must be produced by scp_volcano_table()", call. = FALSE)
  }
  de_df[, "label"] <- FALSE
  for (group in levels(de_df[[group.by]])) {
    idx <- which(de_df[[group.by]] == group)
    if (!length(idx)) next
    if (is.null(features_label)) {
      for (sign in c(TRUE, FALSE)) {
        sub <- idx[if (sign) de_df$y[idx] >= 0 else de_df$y[idx] < 0]
        if (!length(sub)) next
        chosen <- sub[head(order(de_df$distance[sub], decreasing = TRUE), nlabel)]
        de_df$label[chosen] <- TRUE
      }
    } else {
      de_df$label[idx] <- de_df$gene[idx] %in% features_label
    }
  }
  de_df
}

# Table-consuming half: original VolcanoPlot() ggplot construction.
# Set the RNG seed before calling if geom_text_repel layout must be reproduced;
# VolcanoPlot() itself does not seed.
plot_scp_volcano <- function(dat,
                             group.by = "group1",
                             x_metric = c("diff_pct", "avg_log2FC"),
                             palette = "RdBu", palcolor = NULL,
                             pt.size = 1, pt.alpha = 1,
                             cols.highlight = "black", sizes.highlight = 1,
                             alpha.highlight = 1, stroke.highlight = 0.5,
                             nlabel = 5, features_label = NULL,
                             label.fg = "black", label.bg = "white",
                             label.bg.r = 0.1, label.size = 4,
                             aspect.ratio = NULL,
                             xlab = NULL, ylab = "-log10(p-adjust)",
                             theme_use = "theme_scp", theme_args = list(),
                             combine = TRUE, nrow = NULL, ncol = NULL,
                             byrow = TRUE, scp = NULL) {
  if (missing(group.by) && !is.null(attr(dat, "group.by"))) group.by <- attr(dat, "group.by")
  if (missing(x_metric) && !is.null(attr(dat, "x_metric"))) x_metric <- attr(dat, "x_metric")
  x_metric <- match.arg(x_metric)
  if (is.null(scp)) scp <- .scp_default_env()
  palette_scp <- .scp_fun_v(scp, "palette_scp")
  if (is.character(theme_use)) theme_use <- .scp_fun_v(scp, theme_use)
  de_df <- as.data.frame(dat)
  if (!all(c("x", "y", "DE", "border", "distance", "avg_log2FC") %in% names(de_df))) {
    stop("dat must be produced by scp_volcano_table()", call. = FALSE)
  }
  if (is.null(xlab)) xlab <- x_metric
  color_by <- ifelse(x_metric == "diff_pct", "avg_log2FC", "diff_pct")

  labeled <- scp_volcano_labels(de_df, group.by = group.by,
                                 nlabel = nlabel,
                                 features_label = features_label)
  plist <- list()
  for (group in levels(de_df[[group.by]])) {
    df <- labeled[labeled[[group.by]] == group, , drop = FALSE]
    if (nrow(df) == 0) {
      next
    }
    x_nudge <- diff(range(df$x)) * 0.05
    jitter <- position_jitter(width = 0.2, height = 0.2, seed = 11)
    p <- ggplot() +
      geom_point(data = df[!df[["DE"]] & !df[["border"]], , drop = FALSE], aes(x = x, y = y, color = .data[[color_by]]), size = pt.size, alpha = pt.alpha) +
      geom_point(data = df[!df[["DE"]] & df[["border"]], , drop = FALSE], aes(x = x, y = y, color = .data[[color_by]]), size = pt.size, alpha = pt.alpha, position = jitter) +
      geom_point(data = df[df[["DE"]] & !df[["border"]], , drop = FALSE], aes(x = x, y = y), color = cols.highlight, size = sizes.highlight + stroke.highlight, alpha = alpha.highlight) +
      geom_point(data = df[df[["DE"]] & df[["border"]], , drop = FALSE], aes(x = x, y = y), color = cols.highlight, size = sizes.highlight + stroke.highlight, alpha = alpha.highlight, position = jitter) +
      geom_point(data = df[df[["DE"]] & !df[["border"]], , drop = FALSE], aes(x = x, y = y, color = .data[[color_by]]), size = pt.size, alpha = pt.alpha) +
      geom_point(data = df[df[["DE"]] & df[["border"]], , drop = FALSE], aes(x = x, y = y, color = .data[[color_by]]), size = pt.size, alpha = pt.alpha, position = jitter) +
      geom_hline(yintercept = 0, color = "black", linetype = 1) +
      geom_vline(xintercept = 0, color = "grey", linetype = 2) +
      geom_text_repel(
        data = df[df[["label"]], , drop = FALSE], aes(x = x, y = y, label = gene),
        min.segment.length = 0, max.overlaps = 100, segment.colour = "grey40",
        color = label.fg, bg.color = label.bg, bg.r = label.bg.r, size = label.size, force = 20,
        nudge_x = ifelse(df[df[["label"]], "y"] >= 0, -x_nudge, x_nudge)
      ) +
      labs(x = xlab, y = ylab) +
      scale_color_gradientn(
        name = ifelse(x_metric == "diff_pct", "log2FC", "diff_pct"), colors = palette_scp(palette = palette, palcolor = palcolor),
        values = rescale(unique(c(min(c(df[, color_by], 0), na.rm = TRUE), 0, max(c(df[, color_by], 0), na.rm = TRUE)))),
        guide = guide_colorbar(frame.colour = "black", ticks.colour = "black", title.hjust = 0, order = 1)
      ) +
      scale_y_continuous(labels = abs) +
      facet_wrap(as.formula(paste("~", group.by))) +
      do.call(theme_use, theme_args) +
      theme(aspect.ratio = aspect.ratio)
    plist[[group]] <- p
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

# Convenience entry matching the upstream input contract: pull one
# AllMarkers_<test.use> table from srt@tools[[DEtest_<group_by>]].
scp_volcano_meta <- function(srt, group_by = "custom", test.use = "wilcox", ...,
                             DE_threshold = "avg_log2FC > 0 & p_val_adj < 0.05",
                             x_metric = c("diff_pct", "avg_log2FC"),
                             scp = NULL) {
  slot <- paste0("DEtest_", group_by)
  if (!slot %in% names(srt@tools) || length(grep(pattern = "AllMarkers", names(srt@tools[[slot]]))) == 0) {
    stop("Cannot find the DEtest result for the group '", group_by, "'. You may perform RunDEtest first.", call. = FALSE)
  }
  index <- grep(pattern = paste0("AllMarkers_", test.use), names(srt@tools[[slot]]))[1]
  if (is.na(index)) stop("Cannot find the 'AllMarkers_", test.use, "' in the DEtest result.", call. = FALSE)
  de <- srt@tools[[slot]][[index]]
  tab <- scp_volcano_table(de, group.by = "group1", DE_threshold = DE_threshold, x_metric = x_metric)
  plot_scp_volcano(tab, group.by = "group1", x_metric = attr(tab, "x_metric"), ...,
                   scp = scp)
}
