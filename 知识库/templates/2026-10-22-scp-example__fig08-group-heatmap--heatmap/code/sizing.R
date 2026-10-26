# Portable R sizing policy for the glaucoma single-panel templates.
# Copied into each template so the template remains self-contained.
# style$sizing mode is "fixed"/"replica" for the source replay, "adaptive" for
# re-use with a different number of groups/features/labels.
resolve_sizing <- function(style, profile, n_x, n_y = 1, max_label_chars = 0) {
  s <- style$sizing
  if (is.null(s)) s <- list()
  mode <- s$mode
  if (is.null(mode)) mode <- "adaptive"
  dpi <- style$dpi
  if (is.null(dpi)) dpi <- if (is.null(s$dpi)) 192 else s$dpi
  if (mode %in% c("fixed", "replica")) {
    width <- style$width_in
    if (is.null(width)) width <- s$width_in
    if (is.null(width)) width <- 9
    height <- style$height_in
    if (is.null(height)) height <- s$height_in
    if (is.null(height)) height <- 7
    return(list(
      mode = "fixed", profile = profile, n_x = n_x, n_y = n_y,
      max_label_chars = max_label_chars,
      width_in = as.numeric(width), height_in = as.numeric(height),
      dpi = as.numeric(dpi)
    ))
  }
  if (!identical(mode, "adaptive")) {
    stop("sizing.mode must be 'fixed', 'replica' or 'adaptive'", call. = FALSE)
  }
  base_w <- if (is.null(s$base_width_in)) 6 else s$base_width_in
  per_x <- if (is.null(s$per_x_in)) 0.6 else s$per_x_in
  base_h <- if (is.null(s$base_height_in)) 5 else s$base_height_in
  per_y <- if (is.null(s$per_y_in)) 0.4 else s$per_y_in
  min_w <- if (is.null(s$min_width_in)) 5 else s$min_width_in
  min_h <- if (is.null(s$min_height_in)) 5 else s$min_height_in
  base_chars <- if (is.null(s$base_label_chars)) 8 else s$base_label_chars
  per_char <- if (is.null(s$per_label_char_in)) 0.1 else s$per_label_char_in
  width <- max(min_w, base_w + per_x * n_x +
                 per_char * max(0, max_label_chars - base_chars))
  height <- max(min_h, base_h + per_y * n_y)
  if (!is.null(s$aspect)) height <- max(height, width * s$aspect)
  if (!is.null(s$max_width_in) && width > s$max_width_in) {
    stop("Required width ", round(width, 2), " in exceeds max_width_in ",
         s$max_width_in, " in; enlarge the limit or merge categories, not shrink fonts.",
         call. = FALSE)
  }
  if (!is.null(s$max_height_in) && height > s$max_height_in) {
    stop("Required height ", round(height, 2), " in exceeds max_height_in ",
         s$max_height_in, " in; enlarge the limit or merge categories, not shrink fonts.",
         call. = FALSE)
  }
  list(
    mode = "adaptive", profile = profile, n_x = n_x, n_y = n_y,
    max_label_chars = max_label_chars,
    base_width_in = base_w, per_x_in = per_x,
    base_height_in = base_h, per_y_in = per_y,
    min_width_in = min_w, min_height_in = min_h,
    base_label_chars = base_chars, per_label_char_in = per_char,
    aspect = if (is.null(s$aspect)) NA else s$aspect,
    width_in = width, height_in = height, dpi = as.numeric(dpi)
  )
}
