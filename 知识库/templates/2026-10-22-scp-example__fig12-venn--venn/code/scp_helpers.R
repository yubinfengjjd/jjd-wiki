# Local SCP helpers needed by the native venn core, copied from SCP v0.5.6
# (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0, GPL (>= 3)):
#   palette_scp()  R/SCP-plot.R
#   blendcolors(), Blend2Color(), BlendRGBList(), RGBA2RGB()  R/SCP-plot.R
#
# Only compatibility change: palette_scp() reads `palette_list` from the local
# SCP_helpers environment instead of SCP::palette_list. The palette data is
# archived verbatim at data/palette_list.rda. Function bodies are unchanged.

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

RGBA2RGB <- function(RGBA, BackGround = c(1, 1, 1)) {
  A <- RGBA[[length(RGBA)]]
  RGB <- RGBA[[-length(RGBA)]] * A + BackGround * (1 - A)
  return(RGB)
}

Blend2Color <- function(C1, C2, mode = "blend") {
  c1 <- C1[[1]]
  c1a <- C1[[2]]
  c2 <- C2[[1]]
  c2a <- C2[[2]]
  A <- 1 - (1 - c1a) * (1 - c2a)
  if (A < 1.0e-6) {
    return(list(c(0, 0, 0), 1))
  }
  if (mode == "blend") {
    out <- (c1 * c1a + c2 * c2a * (1 - c1a)) / A
    A <- 1
  }
  if (mode == "average") {
    out <- (c1 + c2) / 2
    out[out > 1] <- 1
  }
  if (mode == "screen") {
    out <- 1 - (1 - c1) * (1 - c2)
  }
  if (mode == "multiply") {
    out <- c1 * c2
  }
  return(list(out, A))
}

BlendRGBList <- function(Clist, mode = "blend", RGB_BackGround = c(1, 1, 1)) {
  N <- length(Clist)
  ClistUse <- Clist
  while (N != 1) {
    temp <- ClistUse
    ClistUse <- list()
    for (C in temp[1:(length(temp) - 1)]) {
      c1 <- C[[1]]
      a1 <- C[[2]]
      c2 <- temp[[length(temp)]][[1]]
      a2 <- temp[[length(temp)]][[2]]
      ClistUse <- append(ClistUse, list(Blend2Color(C1 = list(c1, a1 * (1 - 1 / N)), C2 = list(c2, a2 * 1 / N), mode = mode)))
    }
    N <- length(ClistUse)
  }
  Result <- list(ClistUse[[1]][[1]], ClistUse[[1]][[2]])
  Result <- RGBA2RGB(Result, BackGround = RGB_BackGround)
  return(Result)
}

blendcolors <- function(colors, mode = c("blend", "average", "screen", "multiply")) {
  mode <- match.arg(mode)
  colors <- colors[!is.na(colors)]
  if (length(colors) == 0) {
    return(NA)
  }
  if (length(colors) == 1) {
    return(colors)
  }
  rgb <- as.list(as.data.frame(col2rgb(colors) / 255))
  Clist <- lapply(rgb, function(x) {
    list(x, 1)
  })
  blend_color <- BlendRGBList(Clist, mode = mode)
  blend_color <- rgb(blend_color[1], blend_color[2], blend_color[3])
  return(blend_color)
}

SCP_helpers$palette_scp <- palette_scp
SCP_helpers$blendcolors <- blendcolors
SCP_helpers$Blend2Color <- Blend2Color
SCP_helpers$BlendRGBList <- BlendRGBList
SCP_helpers$RGBA2RGB <- RGBA2RGB
