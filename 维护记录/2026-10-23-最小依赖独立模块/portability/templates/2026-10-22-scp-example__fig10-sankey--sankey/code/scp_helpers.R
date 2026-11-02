# Local SCP plotting helpers, copied from SCP v0.5.6 R/SCP-plot.R
# commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
#
# Only compatibility change: palette_scp() reads `palette_list` from the
# local `SCP_helpers` environment instead of `SCP::palette_list`, so the
# template can run without the SCP package installed. The palette data is
# archived verbatim at code/data/palette_list.rda.
# theme_scp() and palette_scp() bodies are otherwise unchanged.

SCP_helpers <- new.env(parent = globalenv())
.helper_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
.helper_dir <- if (!is.null(.helper_file) && nzchar(.helper_file)) {
  dirname(normalizePath(.helper_file, mustWork = TRUE))
} else {
  normalizePath(getwd(), mustWork = TRUE)
}
.helper_data <- file.path(.helper_dir, "data", "palette_list.rda")
if (!file.exists(.helper_data)) stop("Missing palette data: ", .helper_data, call. = FALSE)
load(.helper_data, envir = SCP_helpers)
palette_list <- SCP_helpers$palette_list

theme_scp <- function(aspect.ratio = NULL, base_size = 12, ...) {
  text_size_scale <- base_size / 12
  args1 <- list(
    aspect.ratio = aspect.ratio,
    text = element_text(size = 12 * text_size_scale, color = "black"),
    plot.title = element_text(size = 14 * text_size_scale, colour = "black", vjust = 1),
    plot.subtitle = element_text(size = 13 * text_size_scale, hjust = 0, margin = margin(b = 3)),
    plot.background = element_rect(fill = "white", color = "white"),
    axis.line = element_blank(),
    axis.title = element_text(size = 13 * text_size_scale, colour = "black"),
    axis.text = element_text(size = 12 * text_size_scale, colour = "black"),
    strip.text = element_text(size = 12.5 * text_size_scale, colour = "black", hjust = 0.5, margin = margin(3, 3, 3, 3)),
    strip.background = element_rect(fill = "transparent", linetype = 0),
    strip.switch.pad.grid = unit(-1, "pt"),
    strip.switch.pad.wrap = unit(-1, "pt"),
    strip.placement = "outside",
    legend.title = element_text(size = 12 * text_size_scale, colour = "black", hjust = 0),
    legend.text = element_text(size = 11 * text_size_scale, colour = "black"),
    legend.key = element_rect(fill = "transparent", color = "transparent"),
    legend.key.size = unit(10, "pt"),
    legend.background = element_blank(),
    panel.background = element_rect(fill = "white", color = "white"),
    panel.border = element_rect(fill = "transparent", colour = "black", linewidth = 1)
  )
  args2 <- as.list(match.call())[-1]
  call.envir <- parent.frame(1)
  args2 <- lapply(args2, function(arg) {
    if (is.symbol(arg)) {
      eval(arg, envir = call.envir)
    } else if (is.call(arg)) {
      eval(arg, envir = call.envir)
    } else {
      arg
    }
  })
  for (n in names(args2)) {
    args1[[n]] <- args2[[n]]
  }
  args <- args1[names(args1) %in% formalArgs(theme)]
  out <- do.call(
    what = theme,
    args = args
  )
  return(out)
}

#' Blank theme
#'

palette_scp <- function(x, n = 100, palette = "Paired", palcolor = NULL, type = "auto",
                        matched = FALSE, reverse = FALSE, NA_keep = FALSE, NA_color = "grey80") {
  palette_list <- palette_list
  if (missing(x)) {
    x <- 1:n
    type <- "continuous"
  }
  if (!palette %in% names(palette_list)) {
    stop("The palette name (", palette, ") is invalid! You can check the available palette names with 'show_palettes()'. Or pass palette colors via the 'palcolor' parameter.")
  }
  if (is.list(palcolor)) {
    palcolor <- unlist(palcolor)
  }
  if (all(palcolor == "")) {
    palcolor <- palette_list[[palette]]
  }
  if (is.null(palcolor) || length(palcolor) == 0) {
    palcolor <- palette_list[[palette]]
  }
  if (!is.null(names(palcolor))) {
    if (all(x %in% names(palcolor))) {
      palcolor <- palcolor[intersect(names(palcolor), x)]
    }
  }
  pal_n <- length(palcolor)

  if (!type %in% c("auto", "discrete", "continuous")) {
    stop("'type' must be one of 'auto','discrete' and 'continuous'.")
  }
  if (type == "auto") {
    if (is.numeric(x)) {
      type <- "continuous"
    } else {
      type <- "discrete"
    }
  }

  if (type == "discrete") {
    if (!is.factor(x)) {
      x <- factor(x, levels = unique(x))
    }
    n_x <- nlevels(x)
    if (isTRUE(attr(palcolor, "type") == "continuous")) {
      color <- colorRampPalette(palcolor)(n_x)
    } else {
      color <- ifelse(rep(n_x, n_x) <= pal_n,
        palcolor[1:n_x],
        colorRampPalette(palcolor)(n_x)
      )
    }
    names(color) <- levels(x)
    if (any(is.na(x))) {
      color <- c(color, setNames(NA_color, "NA"))
    }
    if (isTRUE(matched)) {
      color <- color[x]
      color[is.na(color)] <- NA_color
    }
  } else if (type == "continuous") {
    if (!is.numeric(x) && all(!is.na(x))) {
      stop("'x' must be type of numeric when use continuous color palettes.")
    }
    if (all(is.na(x))) {
      values <- as.factor(rep(0, n))
    } else if (length(unique(na.omit(as.numeric(x)))) == 1) {
      values <- as.factor(rep(unique(na.omit(as.numeric(x))), n))
    } else {
      if (isTRUE(matched)) {
        values <- cut(x, breaks = seq(min(x, na.rm = TRUE), max(x, na.rm = TRUE), length.out = n + 1), include.lowest = TRUE)
      } else {
        values <- cut(1:100, breaks = seq(min(x, na.rm = TRUE), max(x, na.rm = TRUE), length.out = n + 1), include.lowest = TRUE)
      }
    }

    n_x <- nlevels(values)
    color <- ifelse(rep(n_x, n_x) <= pal_n,
      palcolor[1:n_x],
      colorRampPalette(palcolor)(n_x)
    )
    names(color) <- levels(values)
    if (any(is.na(x))) {
      color <- c(color, setNames(NA_color, "NA"))
    }
    if (isTRUE(matched)) {
      if (all(is.na(x))) {
        color <- NA_color
      } else if (length(unique(na.omit(x))) == 1) {
        color <- color[as.character(unique(na.omit(x)))]
        color[is.na(color)] <- NA_color
      } else {
        color <- color[as.character(values)]
        color[is.na(color)] <- NA_color
      }
    }
  }

  if (isTRUE(reverse)) {
    color <- rev(color)
  }
  if (!isTRUE(NA_keep)) {
    color <- color[names(color) != "NA"]
  }
  return(color)
}

# Copied from SCP v0.5.6 R/utils.R, commit b9b0eb7a..., GPL (>= 3).
capitalize <- function(x, force_tolower = FALSE) {
  if (is.null(x)) {
    return(NULL)
  }
  if (inherits(x, "factor")) {
    x <- as.character(x)
  }
  if (!inherits(x, "character")) {
    stop("x must be the type of character.")
  }
  if (isTRUE(force_tolower)) {
    x <- paste(toupper(substr(x, 1, 1)), tolower(substr(x, 2, nchar(x))), sep = "")
  } else {
    first_word <- sapply(strsplit(x, "\\s|-"), function(s) s[1])
    index <- which(first_word == tolower(first_word))
    x[index] <- paste(toupper(substr(x[index], 1, 1)), substr(x[index], 2, nchar(x[index])), sep = "")
  }
  return(x)
}

SCP_helpers$theme_scp <- theme_scp
SCP_helpers$palette_scp <- palette_scp
SCP_helpers$capitalize <- capitalize

# ---------------------------------------------------------------------------
# Vendored ggsankey functions used by geom_sankey()/make_long().
# Source: SCP v0.5.6 R/ggsankey.R (a modified ggsankey), commit
# b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
# Copied verbatim: prepare_params (lines 8-34), find_default_space (36-46),
# sigmoid (48-55), make_long (70-108), StatSankeyFlow (214-342),
# StatSankeyNode (583-651), geom_sankey (691-744).
# Only namespace qualification was added where the copied text calls helpers
# directly; no geometry, statistic, default or aesthetic was changed.
# ---------------------------------------------------------------------------

# ** make_long / geom_sankey support ----------------------------------------
prepare_params <- function(...) {
  # Prepare aesthics for flow lines
  flow.aes <- list(...)
  removes <- names(flow.aes) %>%
    stringr::str_extract_all(., "(?<=flow.).*") %>%
    unlist()
  removes2 <- names(flow.aes) %>%
    stringr::str_subset(., "node") %>%
    unlist()
  flow.aes[c(removes, removes2)] <- NULL
  names(flow.aes) <- names(flow.aes) %>%
    stringr::str_replace_all("flow.", "")

  # Prepare aesthics for node boxes
  node.aes <- list(...)
  removes <- names(node.aes) %>%
    stringr::str_extract_all(., "(?<=node.).*") %>%
    unlist()
  removes2 <- names(node.aes) %>%
    stringr::str_subset(., "flow") %>%
    unlist()
  node.aes[c(removes, removes2)] <- NULL
  names(node.aes) <- names(node.aes) %>%
    stringr::str_replace_all(., "node.", "")

  return(list(flow.aes, node.aes))
}

find_default_space <- function(.df) {
  .df %>%
    dplyr::group_by(.data$n_x) %>%
    dplyr::reframe(
      n_groups = dplyr::n_distinct(.data$node),
      freq = sum(.data$freq, na.rm = TRUE)
    ) %>%
    dplyr::mutate(v = .data$freq / .data$n_groups / 4) %>%
    dplyr::pull(.data$v) %>%
    max()
}

sigmoid <- function(x_from, x_to, y_from, y_to, smooth = 5, n = 300) {
  x <- seq(-smooth, smooth, length = n)
  y <- exp(x) / (exp(x) + 1)
  out <- data.frame(
    x = (x + smooth) / (smooth * 2) * (x_to - x_from) + x_from,
    y = y * (y_to - y_from) + y_from
  )
}
make_long <- function(.df, ..., value = NULL) {
  if ("..r" %in% names(.df)) stop("The column name '..r' is not allowed")
  .vars <- dplyr::quos(...)

  if (!missing(value)) {
    value_var <- dplyr::enquo(value)
    out <- .df %>%
      dplyr::select(!!!.vars, value = !!value_var) %>%
      dplyr::mutate(..r = dplyr::row_number()) %>%
      tidyr::gather(x, node, -..r, -value) %>%
      dplyr::arrange(.data$..r) %>%
      dplyr::group_by(.data$..r) %>%
      dplyr::mutate(
        next_x = dplyr::lead(.data$x),
        next_node = dplyr::lead(.data$node)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(-..r) %>%
      dplyr::relocate(value, .after = dplyr::last_col())
  } else {
    out <- .df %>%
      dplyr::select(!!!.vars) %>%
      dplyr::mutate(..r = dplyr::row_number()) %>%
      tidyr::gather(x, node, -..r) %>%
      dplyr::arrange(.data$..r) %>%
      dplyr::group_by(.data$..r) %>%
      dplyr::mutate(
        next_x = dplyr::lead(.data$x),
        next_node = dplyr::lead(.data$node)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(-..r)
  }

  levels <- unique(out$x)

  out %>%
    dplyr::mutate(dplyr::across(c(x, next_x), ~ factor(., levels = levels)))
}

# ** StatSankeyFlow ----------------------------------------------------------
StatSankeyFlow <- ggplot2::ggproto("StatSankeyFlow", ggplot2::Stat,
  extra_params = c("n_grid", "na.rm", "type", "width", "space", "smooth"),
  setup_data = function(data, params) {
    purrr::map_dfr(
      unique(data$PANEL),
      ~ {
        data <- data %>% dplyr::filter(PANEL == .x)

        data <- data %>%
          dplyr::mutate(dplyr::across(c(x, next_x), ~ as.numeric(.), .names = ("n_{.col}")))

        if (!("value" %in% names(data))) {
          flow_data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::group_by(n_x, node, n_next_x, next_node) %>%
            dplyr::reframe(flow_freq = dplyr::n(), .groups = "keep") %>%
            dplyr::ungroup()

          data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::select(-n_next_x, -next_node, -next_x) %>%
            dplyr::group_by_all() %>%
            dplyr::reframe(freq = dplyr::n(), .groups = "keep") %>%
            dplyr::ungroup()
        } else {
          flow_data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::group_by(n_x, node, n_next_x, next_node) %>%
            dplyr::reframe(flow_freq = sum(value, na.rm = TRUE), .groups = "keep") %>%
            dplyr::ungroup()

          data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::select(-n_next_x, -next_node, -next_x) %>%
            dplyr::group_by_at(dplyr::vars(dplyr::everything(), -value)) %>%
            dplyr::reframe(freq = sum(value, na.rm = TRUE), , .groups = "keep") %>%
            dplyr::ungroup()
        }

        if (is.null(params$space)) {
          params$space <- find_default_space(data)
        }

        data <- data %>%
          dplyr::group_by(n_x) %>%
          dplyr::mutate(
            ymax = cumsum(freq) + (dplyr::row_number() - 1) * params$space,
            ymin = ymax - freq
          ) %>%
          dplyr::ungroup()

        if (params$type == "sankey") {
          data <- data %>%
            dplyr::group_by(n_x) %>%
            dplyr::mutate(
              ymin = ymin - max(ymax) / 2,
              ymax = ymax - max(ymax) / 2
            ) %>%
            dplyr::ungroup()
        } else if (params$type == "alluvial") {
          data <- data
        }

        data <- data %>%
          dplyr::mutate(
            xmin = n_x - params$width / 2,
            xmax = n_x + params$width / 2
          )

        if ("shift" %in% names(data)) {
          data <- data %>%
            dplyr::mutate(dplyr::across(dplyr::contains("y"), ~ . + shift))
        }

        df <- data %>%
          dplyr::left_join(flow_data, by = c("n_x", "node"))



        flows <- df %>%
          dplyr::left_join(
            df %>%
              dplyr::select(n_x, node, ymin_end = ymin, ymax_end = ymax, xmin_end = xmin, xmax_end = xmax) %>%
              dplyr::distinct(),
            by = c("n_next_x" = "n_x", "next_node" = "node")
          ) %>%
          tidyr::drop_na(n_x, node, next_node, n_next_x, ymax_end, ymin_end, xmax_end, xmin_end) %>%
          dplyr::mutate(r = dplyr::row_number()) %>%
          dplyr::arrange(n_x, -r) %>%
          dplyr::select(-r) %>%
          dplyr::group_by(n_x, node) %>%
          dplyr::mutate(cum_flow_freq = cumsum(flow_freq) - flow_freq) %>%
          dplyr::ungroup() %>%
          dplyr::group_by(n_x, n_next_x, node, next_node) %>%
          dplyr::mutate(
            flow_start_ymax = ymax - cum_flow_freq,
            flow_start_ymin = flow_start_ymax - flow_freq
          )

        flows <- flows %>%
          dplyr::arrange(n_x, n_next_x, next_node) %>%
          dplyr::group_by(n_next_x, next_node) %>%
          dplyr::mutate(cum_flow_freq_end = cumsum(flow_freq) - flow_freq) %>%
          dplyr::mutate(
            flow_end_ymax = ymax_end - cum_flow_freq_end,
            flow_end_ymin = flow_end_ymax - flow_freq
          ) %>%
          dplyr::ungroup()

        flows <- flows %>%
          dplyr::select(-n_x, -node, -freq, -ymax, -ymin, -xmin, -n_next_x, -next_node, -flow_freq, -ymin_end, -ymax_end, -xmax_end, -cum_flow_freq, -cum_flow_freq_end) %>%
          dplyr::mutate(group = dplyr::row_number())

        flows %>%
          dplyr::mutate(smooth = params$smooth) %>%
          as.data.frame()
      }
    )
  },
  compute_group = function(data, scales) {
    out1 <- sigmoid(data$xmax, data$xmin_end, data$flow_start_ymax, data$flow_end_ymax,
      smooth = data$smooth
    )
    out2 <- sigmoid(data$xmin_end, data$xmax, data$flow_end_ymin, data$flow_start_ymin,
      smooth = data$smooth
    )
    dplyr::bind_rows(out1, out2)
  }
)

# ** StatSankeyNode ----------------------------------------------------------
StatSankeyNode <- ggplot2::ggproto("StatSankeyNode", ggplot2::Stat,
  extra_params = c("n_grid", "na.rm", "type", "width", "space", "smooth"),
  setup_data = function(data, params) {
    purrr::map_dfr(
      unique(data$PANEL),
      ~ {
        data <- data %>% dplyr::filter(PANEL == .x)
        data <- data %>%
          dplyr::mutate(dplyr::across(c(x, next_x), ~ as.numeric(.), .names = ("n_{.col}")))

        if (!("value" %in% names(data))) {
          data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::select(-n_next_x, -next_node, -next_x) %>%
            dplyr::group_by_all() %>%
            dplyr::reframe(freq = dplyr::n(), .groups = "keep") %>%
            dplyr::ungroup()
        } else {
          data <- data %>%
            dplyr::mutate(group = 1) %>%
            dplyr::select(-n_next_x, -next_node, -next_x) %>%
            dplyr::group_by_at(dplyr::vars(dplyr::everything(), -value)) %>%
            dplyr::reframe(freq = sum(value, na.rm = TRUE), .groups = "keep") %>%
            dplyr::ungroup()
        }

        if (is.null(params$space)) {
          params$space <- find_default_space(data)
        }

        data <- data %>%
          dplyr::group_by(n_x) %>%
          dplyr::mutate(
            ymax = cumsum(freq) + (dplyr::row_number() - 1) * params$space,
            ymin = ymax - freq
          ) %>%
          dplyr::ungroup()

        if (params$type == "sankey") {
          data <- data %>%
            dplyr::group_by(n_x) %>%
            dplyr::mutate(
              ymin = ymin - max(ymax) / 2,
              ymax = ymax - max(ymax) / 2
            ) %>%
            dplyr::ungroup()
        } else if (params$type == "alluvial") {
          data <- data
        }

        data <- data %>%
          dplyr::mutate(
            xmin = n_x - params$width / 2,
            xmax = n_x + params$width / 2
          )

        if ("shift" %in% names(data)) {
          data <- data %>%
            dplyr::mutate(dplyr::across(dplyr::contains("y"), ~ . + shift))
        }

        return(as.data.frame(data))
      }
    )
  },
  compute_group = function(data, scales) {
    data
  }
)

# ** geom_sankey -------------------------------------------------------------
geom_sankey <- function(mapping = NULL,
                        data = NULL,
                        position = "identity",
                        na.rm = FALSE,
                        show.legend = NA,
                        space = NULL,
                        type = "sankey",
                        width = .1,
                        smooth = 8,
                        inherit.aes = TRUE,
                        ...) {
  params_list <- prepare_params(...)

  list(
    flow = ggplot2::layer(
      stat = StatSankeyFlow,
      data = data,
      mapping = mapping,
      geom = "polygon",
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = purrr::flatten(
        list(
          na.rm = na.rm,
          width = width,
          space = space,
          smooth = smooth,
          type = type,
          params_list[[1]]
        )
      )
    ),
    node = ggplot2::layer(
      stat = StatSankeyNode,
      data = data,
      mapping = mapping,
      geom = ggplot2::GeomRect,
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = purrr::flatten(
        list(
          na.rm = na.rm,
          width = width,
          space = space,
          smooth = smooth,
          type = type,
          params_list[[2]]
        )
      )
    )
  )
}

# ---------------------------------------------------------------------------
# Plot-grob helpers from SCP v0.5.6 R/SCP-plot.R (lines 14710-14794),
# commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3).
# as_grob/as_gtable/add_grob are copied with namespace qualification only.
# The upstream as_grob() branch for patchwork objects (which calls patchwork
# internals) is omitted: a single sankey panel is always a ggplot here.
# get_legend() carries compatibility patch P3 (see PATCHES.md): ggplot2 >= 3.5
# keeps zeroGrob placeholders in all guide-box slots, so selecting the first
# "guide-box" match can return an empty slot. P3 returns the first non-empty
# guide box. Legend content, order and grob are otherwise unchanged.
# ---------------------------------------------------------------------------

as_grob <- function(plot, ...) {
  if (inherits(plot, "gList")) {
    grid::grobTree(plot)
  } else if (inherits(plot, "ggplot")) {
    ggplot2::ggplotGrob(plot)
  } else {
    warning("Cannot convert object of class ", paste0(class(plot), collapse = ","), " into a grob.")
  }
}

as_gtable <- function(plot, ...) {
  if (inherits(plot, "gtable")) {
    return(plot)
  }
  if (inherits(plot, "grob")) {
    u <- grid::unit(1, "null")
    gt <- gtable::gtable_col(NULL, list(plot), u, u)
    gt$layout$clip <- "inherit"
    return(gt)
  } else {
    grob <- as_grob(plot, ...)
    if (inherits(grob, "gtable")) {
      return(grob)
    } else {
      return(as_gtable(grob, ...))
    }
  }
}

get_legend <- function(plot) {
  plot <- as_gtable(plot)
  grob_names <- plot$layout$name
  grobs <- plot$grobs
  grobIndex <- which(grepl("guide-box", grob_names))
  grobIndex <- grobIndex[!vapply(grobs[grobIndex], inherits, logical(1), what = "zeroGrob")]
  if (length(grobIndex) == 0) {
    return(NULL)
  }
  matched_grobs <- grobs[[grobIndex[1]]]
  return(matched_grobs)
}

add_grob <- function(gtable, grob, position = c("top", "bottom", "left", "right", "none"), space = NULL, clip = "on") {
  position <- match.arg(position)
  if (position == "none" || is.null(grob)) {
    return(gtable)
  }

  if (is.null(space)) {
    if (gtable::is.gtable(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- sum(grob$heights)
      } else {
        space <- sum(grob$widths)
      }
    } else if (grid::is.grob(grob)) {
      if (position %in% c("top", "bottom")) {
        space <- grid::grobHeight(grob)
      } else {
        space <- grid::grobWidth(grob)
      }
    }
  }

  if (position == "top") {
    gtable <- gtable::gtable_add_rows(gtable, space, 0)
    gtable <- gtable::gtable_add_grob(gtable, grob, t = 1, l = mean(gtable$layout[grepl(pattern = "panel", x = gtable$layout$name), "l"]), clip = clip)
  }
  if (position == "bottom") {
    gtable <- gtable::gtable_add_rows(gtable, space, -1)
    gtable <- gtable::gtable_add_grob(gtable, grob, t = dim(gtable)[1], l = mean(gtable$layout[grepl(pattern = "panel", x = gtable$layout$name), "l"]), clip = clip)
  }
  if (position == "left") {
    gtable <- gtable::gtable_add_cols(gtable, space, 0)
    gtable <- gtable::gtable_add_grob(gtable, grob, t = mean(gtable$layout[grep("panel", gtable$layout$name), "t"]), l = 1, clip = clip)
  }
  if (position == "right") {
    gtable <- gtable::gtable_add_cols(gtable, space, -1)
    gtable <- gtable::gtable_add_grob(gtable, grob, t = mean(gtable$layout[grep("panel", gtable$layout$name), "t"]), l = dim(gtable)[2], clip = clip)
  }
  return(gtable)
}

# Expose the vendored functions through the local helper environment so the
# native core can resolve them with scp = SCP_helpers.
SCP_helpers$prepare_params <- prepare_params
SCP_helpers$find_default_space <- find_default_space
SCP_helpers$sigmoid <- sigmoid
SCP_helpers$make_long <- make_long
SCP_helpers$StatSankeyFlow <- StatSankeyFlow
SCP_helpers$StatSankeyNode <- StatSankeyNode
SCP_helpers$geom_sankey <- geom_sankey
SCP_helpers$as_grob <- as_grob
SCP_helpers$as_gtable <- as_gtable
SCP_helpers$get_legend <- get_legend
SCP_helpers$add_grob <- add_grob
