# Clinical subgroup forest plot, functionized from FigureYa6rHRsV2 (forestplot package).
# Draws effect sizes that were computed upstream; no regression is fitted here.
# A two-line header gets one spacer row below it (as upstream). Any number of rows: horizontal rules and figure height follow nrow(data), not a fixed "30".
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

forest_prepare <- function(df) {
  required <- c("label", "estimate", "lower", "upper")
  missing <- setdiff(required, names(df))
  if (length(missing)) stop("Missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  if (anyNA(df$label)) stop("label cannot be missing (use a header row text)", call. = FALSE)
  for (column in c("estimate", "lower", "upper")) {
    df[[column]] <- suppressWarnings(as.numeric(df[[column]]))
  }
  has <- !is.na(df$estimate)
  partial <- has != !is.na(df$lower) | has != !is.na(df$upper)
  if (any(partial)) {
    stop("Rows with an estimate need both lower and upper (and header rows none): ",
         paste(df$label[partial], collapse = ", "), call. = FALSE)
  }
  if (!any(has)) stop("No row has an estimate", call. = FALSE)
  if (any(df$lower[has] > df$estimate[has] | df$upper[has] < df$estimate[has])) {
    stop("Each estimate must lie within [lower, upper]", call. = FALSE)
  }
  df
}

fmt <- function(x, digits) formatC(x, format = "f", digits = digits)

plot_panel <- function(tables, style) {
  if (!"forest" %in% names(tables)) stop("Missing table: forest", call. = FALSE)
  df <- forest_prepare(as.data.frame(tables$forest))
  xlog <- isTRUE(get_style(style, "xlog", TRUE))
  has <- !is.na(df$estimate)
  if (xlog && any(df$lower[has] <= 0)) stop("xlog = TRUE needs positive ratios", call. = FALSE)
  digits <- get_style(style, "digits", 2)
  header <- list(get_style(style, "label_header", "\nSubgroup"))
  columns <- list(c(header[[1]], NA, df$label))
  show_n <- "n" %in% names(df) && isTRUE(get_style(style, "show_n", TRUE))
  if (show_n) {
    n_text <- ifelse(is.na(df$n), NA,
                     if ("percent" %in% names(df)) paste0(df$n, " (", df$percent, ")") else as.character(df$n))
    columns[[length(columns) + 1]] <- c(get_style(style, "n_header", "No. of\nPatients (%)"), NA, n_text)
  }
  est_text <- ifelse(has, paste0(fmt(df$estimate, digits), " (", fmt(df$lower, digits), " to ",
                                 fmt(df$upper, digits), ")"), NA)
  columns[[length(columns) + 1]] <- c(get_style(style, "estimate_header", "Hazard Ratio\n(95% CI)"), NA, est_text)
  show_p <- "p" %in% names(df) && isTRUE(get_style(style, "show_p", TRUE))
  if (show_p) columns[[length(columns) + 1]] <- c(get_style(style, "p_header", "P-value"), NA, df$p)
  tabletext <- do.call(cbind, columns)
  n_rows <- nrow(tabletext)
  if ("percent" %in% names(df) && any(!is.na(df$percent))) {
    box <- c(NA, NA, df$percent / get_style(style, "box_scale", 75))
  } else {
    box <- c(NA, NA, ifelse(has, get_style(style, "box_size", 0.3), NA))
  }
  zero <- get_style(style, "zero", if (xlog) 1 else 0)
  overall <- isTRUE(get_style(style, "overall_line", TRUE))
  grid_spec <- if (overall) {
    structure(df$estimate[which(has)[1]], gp = grid::gpar(col = "black", lty = 2, lwd = 2))
  } else FALSE
  rules <- list(grid::gpar(lwd = 2, col = "black"), grid::gpar(lwd = 2, col = "black"))
  names(rules) <- c("3", as.character(n_rows + 1))
  xticks <- unlist(get_style(style, "xticks", NULL))
  cex <- get_style(style, "cex", 1.25)
  args <- list(
    labeltext = tabletext, xlog = xlog,
    mean = c(NA, NA, df$estimate), lower = c(NA, NA, df$lower), upper = c(NA, NA, df$upper),
    graph.pos = get_style(style, "graph_pos", min(3, ncol(tabletext) + 1)),
    graphwidth = grid::unit(get_style(style, "graph_width_npc", 0.4), "npc"),
    fn.ci_norm = if (isTRUE(get_style(style, "diamond", TRUE))) "fpDrawDiamondCI" else "fpDrawNormalCI",
    col = forestplot::fpColors(box = get_style(style, "box_col", "steelblue"),
                               lines = get_style(style, "line_col", "black"), zero = "black"),
    boxsize = box, lwd.ci = 2, ci.vertices.height = 0.1, ci.vertices = TRUE,
    zero = zero, lwd.zero = 2, grid = grid_spec, lwd.xaxis = 2,
    xlab = get_style(style, "xlab", ""),
    hrzl_lines = rules,
    txt_gp = forestplot::fpTxtGp(label = grid::gpar(cex = cex), ticks = grid::gpar(cex = cex),
                                 xlab = grid::gpar(cex = cex), title = grid::gpar(cex = cex)),
    lineheight = grid::unit(get_style(style, "line_height_cm", 0.75), "cm"),
    colgap = grid::unit(get_style(style, "colgap_cm", 0.4), "cm"),
    mar = grid::unit(rep(1.25, times = 4), "cm"),
    new_page = FALSE
  )
  if (!is.null(xticks)) args$xticks <- xticks
  p <- do.call(forestplot::forestplot, args)
  attr(p, "n_rows") <- n_rows
  attr(p, "line_height_cm") <- get_style(style, "line_height_cm", 0.75)
  attr(p, "max_label_chars") <- max(nchar(gsub("\n.*", "", tabletext[, 1])), na.rm = TRUE)
  attr(p, "n_text_cols") <- ncol(tabletext)
  p
}

figure_size <- function(tables, style, p) {
  sizing <- get_style(style, "sizing", list())
  n_rows <- attr(p, "n_rows")
  if (identical(get_style(sizing, "mode", "adaptive"), "fixed")) {
    width <- get_style(style, "width_in", 12)
    height <- get_style(style, "height_in", 12)
  } else {
    # fixed physical row height (lineheight) + margins + axis; width from label length and columns
    row_in <- attr(p, "line_height_cm") / 2.54
    height <- get_style(sizing, "base_height_in", 2.2) + row_in * n_rows
    width <- get_style(sizing, "base_width_in", 6) +
      get_style(sizing, "per_text_col_in", 1.8) * (attr(p, "n_text_cols") - 1) +
      get_style(sizing, "per_label_char_in", 0.1) * attr(p, "max_label_chars")
  }
  list(mode = get_style(sizing, "mode", "adaptive"), profile = "forest", n_rows = n_rows,
       width_in = width, height_in = height)
}

draw_figure <- function(p) {
  grid::grid.newpage()
  print(p, newpage = FALSE)
  invisible(p)
}

draw <- function(fig, rect, tables, style) {
  print(plot_panel(tables, style), newpage = FALSE)
}
