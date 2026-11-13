# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:14602-14695
# sha256(func-block)=a02504d908ce4b2c60c9f69a1abcd5d8c8360d766457ca2b4f98215ded4bc5e0
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
build_patchwork <- function(x, guides = "auto", BPPARAM = BiocParallel::SerialParam()) {
  x$layout <- modifyList(patchwork:::default_layout, x$layout[!vapply(x$layout, is.null, logical(1))])

  guides <- if (guides == "collect" && x$layout$guides != "keep") {
    "collect"
  } else {
    x$layout$guides
  }
  # bpprogressbar(BPPARAM) <- TRUE
  gt <- bplapply(x$plots, patchwork:::plot_table, guides = guides, BPPARAM = BPPARAM)
  fixed_asp <- vapply(gt, function(x) isTRUE(x$respect), logical(1))
  guide_grobs <- unlist(lapply(gt, `[[`, "collected_guides"), recursive = FALSE)
  gt <- bplapply(gt, patchwork:::simplify_gt, BPPARAM = BPPARAM)
  gt <- patchwork:::add_insets(gt)
  if (is.null(x$layout$design)) {
    if (is.null(x$layout$ncol) && !is.null(x$layout$widths) && length(x$layout$widths) > 1) {
      x$layout$ncol <- length(x$layout$widths)
    }
    if (is.null(x$layout$nrow) && !is.null(x$layout$heights) && length(x$layout$heights) > 1) {
      x$layout$nrow <- length(x$layout$heights)
    }
    dims <- wrap_dims(length(gt), nrow = x$layout$nrow, ncol = x$layout$ncol)
    x$layout$design <- patchwork:::create_design(dims[2], dims[1], x$layout$byrow)
  } else {
    dims <- c(
      max(x$layout$design$b),
      max(x$layout$design$r)
    )
  }

  TABLE_COLS <- patchwork:::TABLE_COLS
  TABLE_ROWS <- patchwork:::TABLE_ROWS
  PANEL_ROW <- patchwork:::PANEL_ROW
  PANEL_COL <- patchwork:::PANEL_COL

  gt_new <- gtable(
    unit(rep(0, TABLE_COLS * dims[2]), "null"),
    unit(rep(0, TABLE_ROWS * dims[1]), "null")
  )
  design <- as.data.frame(unclass(x$layout$design))
  if (nrow(design) < length(gt)) {
    warning("Too few patch areas to hold all plots. Dropping plots", call. = FALSE)
    gt <- gt[seq_len(nrow(design))]
    fixed_asp <- fixed_asp[seq_len(nrow(design))]
  } else {
    design <- design[seq_along(gt), ]
  }
  if (any(design$t < 1)) design$t[design$t < 1] <- 1
  if (any(design$l < 1)) design$l[design$l < 1] <- 1
  if (any(design$b > dims[1])) design$b[design$b > dims[1]] <- dims[1]
  if (any(design$r > dims[2])) design$r[design$r > dims[2]] <- dims[2]
  max_z <- lapply(gt, function(x) max(x$layout$z))
  max_z <- c(0, cumsum(max_z))
  gt_new$layout <- do.call(rbind, lapply(seq_along(gt), function(i) {
    loc <- design[i, ]
    lay <- gt[[i]]$layout
    lay$name <- paste0(lay$name, "-", i)
    lay$t <- lay$t + ifelse(lay$t <= PANEL_ROW, (loc$t - 1) * TABLE_ROWS, (loc$b - 1) * TABLE_ROWS)
    lay$l <- lay$l + ifelse(lay$l <= PANEL_COL, (loc$l - 1) * TABLE_COLS, (loc$r - 1) * TABLE_COLS)
    lay$b <- lay$b + ifelse(lay$b < PANEL_ROW, (loc$t - 1) * TABLE_ROWS, (loc$b - 1) * TABLE_ROWS)
    lay$r <- lay$r + ifelse(lay$r < PANEL_COL, (loc$l - 1) * TABLE_COLS, (loc$r - 1) * TABLE_COLS)
    lay$z <- lay$z + max_z[i]
    lay
  }))
  table_dimensions <- patchwork:::table_dims(
    lapply(gt, `[[`, "widths"),
    lapply(gt, `[[`, "heights"),
    design,
    dims[2],
    dims[1]
  )
  gt_new$grobs <- patchwork:::set_grob_sizes(gt, table_dimensions$widths, table_dimensions$heights, design)
  gt_new$widths <- table_dimensions$widths
  gt_new$heights <- table_dimensions$heights
  widths <- rep(x$layout$widths, length.out = dims[2])
  heights <- rep(x$layout$heights, length.out = dims[1])
  gt_new <- patchwork:::set_panel_dimensions(gt_new, gt, widths, heights, fixed_asp, design)
  if (x$layout$guides == "collect") {
    guide_grobs <- patchwork:::collapse_guides(guide_grobs)
    if (length(guide_grobs) != 0) {
      theme <- x$annotation$theme
      if (!attr(theme, "complete")) {
        theme <- theme_get() + theme
      }
      guide_grobs <- patchwork:::assemble_guides(guide_grobs, theme)
      gt_new <- patchwork:::attach_guides(gt_new, guide_grobs, theme)
    }
  } else {
    gt_new$collected_guides <- guide_grobs
  }

  class(gt_new) <- c("gtable_patchwork", class(gt_new))
  gt_new
}
