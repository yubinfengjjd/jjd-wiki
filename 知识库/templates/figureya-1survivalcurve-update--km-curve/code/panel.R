# KM survival curve + number-at-risk table, functionized from FigureYa1survivalCurve_update.
# Statistics are the upstream ones: survival::survfit(Surv(time, event) ~ group) and the
# log-rank P that survminer::ggsurvplot(pval = TRUE) computes (survival::survdiff).
# Any number of groups (>= 2); order/labels/colours come from style, never from fixed counts.
get_style <- function(style, name, default) {
  value <- style[[name]]
  if (is.null(value)) default else value
}

km_prepare <- function(df, style) {
  required <- c("time", "event", "group")
  missing <- setdiff(required, names(df))
  if (length(missing)) stop("Missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  if (!is.numeric(df$time) || anyNA(df$time) || any(df$time < 0)) {
    stop("time must be numeric, non-missing and >= 0", call. = FALSE)
  }
  if (anyNA(df$event) || !all(df$event %in% c(0, 1))) {
    stop("event must be coded 0 (censored) / 1 (event); recode upstream 1/2 codes first", call. = FALSE)
  }
  if (anyNA(df$group) || any(!nzchar(as.character(df$group)))) {
    stop("group cannot be missing or empty", call. = FALSE)
  }
  levels <- unlist(get_style(style, "levels", NULL))
  observed <- unique(as.character(df$group))
  if (is.null(levels)) {
    levels <- observed
  } else {
    unknown <- setdiff(observed, levels)
    if (length(unknown)) stop("Groups not in style.levels: ", paste(unknown, collapse = ", "), call. = FALSE)
    absent <- setdiff(levels, observed)
    if (length(absent)) stop("style.levels not present in data: ", paste(absent, collapse = ", "), call. = FALSE)
  }
  if (length(levels) < 2) stop("At least two groups are needed for a log-rank comparison", call. = FALSE)
  df$group <- factor(as.character(df$group), levels = levels)
  df
}

km_palette <- function(n, style) {
  palette <- unlist(get_style(style, "palette", NULL))
  if (is.null(palette)) {
    upstream <- c("red", "blue", "darkgreen", "navy")
    palette <- if (n <= length(upstream)) upstream[seq_len(n)] else scales::hue_pal()(n)
  }
  if (length(palette) < n) {
    stop("style.palette has ", length(palette), " colours for ", n,
         " groups; give one colour per group (no silent recycling)", call. = FALSE)
  }
  palette[seq_len(n)]
}

plot_panel <- function(tables, style) {
  if (!"surv" %in% names(tables)) stop("Missing table: surv", call. = FALSE)
  df <- km_prepare(as.data.frame(tables$surv), style)
  n <- nlevels(df$group)
  labels <- unlist(get_style(style, "labels", NULL))
  if (is.null(labels)) labels <- levels(df$group)
  if (length(labels) != n) stop("style.labels must have one label per group (", n, ")", call. = FALSE)
  # `data` is passed to ggsurvplot explicitly, so nothing is looked up in the global environment.
  .km_data <- df
  fit <- survival::survfit(survival::Surv(time, event) ~ group, data = .km_data)
  conf <- isTRUE(get_style(style, "conf_int", TRUE))
  risk <- isTRUE(get_style(style, "risk_table", TRUE))
  p <- survminer::ggsurvplot(
    fit, data = .km_data,
    pval = isTRUE(get_style(style, "pval", TRUE)),
    linetype = get_style(style, "linetype", "solid"),
    palette = km_palette(n, style),
    legend.title = get_style(style, "legend_title", ""),
    legend = unlist(get_style(style, "legend_pos", list(0.75, 0.9))),
    legend.labs = labels,
    xlab = get_style(style, "xlab", "Time"),
    ylab = get_style(style, "ylab", "Survival probability"),
    risk.table = risk,
    tables.height = get_style(style, "tables_height", 0.25),
    tables.theme = survminer::theme_cleantable(),
    conf.int = conf,
    conf.int.style = "ribbon",
    conf.int.alpha = get_style(style, "conf_int_alpha", 0.1)
  )
  attr(p, "n_groups") <- n
  attr(p, "max_label_chars") <- max(nchar(labels))
  attr(p, "risk_table") <- risk
  p
}

figure_size <- function(tables, style, p) {
  sizing <- get_style(style, "sizing", list())
  n <- attr(p, "n_groups")
  chars <- attr(p, "max_label_chars")
  base_w <- get_style(sizing, "base_width_in", 6)
  base_h <- get_style(sizing, "base_height_in", 5)
  per_group <- get_style(sizing, "per_group_in", 0.25)
  per_char <- get_style(sizing, "per_label_char_in", 0.06)
  base_chars <- get_style(sizing, "base_label_chars", 16)
  if (identical(get_style(sizing, "mode", "adaptive"), "fixed")) {
    width <- get_style(style, "width_in", base_w)
    height <- get_style(style, "height_in", base_h)
  } else {
    width <- base_w + per_char * max(0, chars - base_chars)
    # each extra group adds one risk-table row (and a legend key)
    height <- base_h + per_group * max(0, n - 2) * (if (isTRUE(attr(p, "risk_table"))) 1.5 else 1)
  }
  list(mode = get_style(sizing, "mode", "adaptive"), profile = "km-curve", n_groups = n,
       max_label_chars = chars, width_in = width, height_in = height)
}

draw_figure <- function(p) {
  print(p, newpage = FALSE)
  invisible(p)
}

draw <- function(fig, rect, tables, style) {
  draw_figure(plot_panel(tables, style))
}
