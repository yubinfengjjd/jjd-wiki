# Multi-track CellChat Circos Diagram Core (circlize + ComplexHeatmap)
# Replicates KS科研分享与服务 multi-layer cell-cell communication Circos plot:
# - Outer arc bars & cell-type titles
# - Italicized ligand (mint green) / receptor (magenta) radial gene labels
# - Track 1: Celltype x Gene expression heatmap (Blue-White-Red)
# - Track 2: Per-gene interaction strength/degree barplot (colored by cell type, 0-100 axis)
# - Track 3: Inner chord links colored by Interaction Score (YlGnBu) with top-N highlighted links
# - Right-side stacked legends (ligand/receptor, Interaction Score, Expression)

`%||%` <- function(x, y) if (is.null(x)) y else x

ks_palette_colors <- function(palette_name, n) {
  palettes <- list(
    NPG = c("#0B5D1E", "#1FB83A", "#14B88E", "#F5B762", "#8AD4EB", "#E41A37", "#F5A623", "#C38ED9", "#F24E1E", "#3C5488"),
    Nature = c("#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F", "#8491B4", "#91D1C2", "#DC0000", "#7E6148", "#B09C85"),
    Lancet = c("#00468B", "#ED0000", "#42B540", "#0099B4", "#925E9F", "#FDAF91", "#AD002A", "#ADB6B6", "#1B1919"),
    NEJM = c("#BC3C29", "#0072B5", "#E18727", "#20854E", "#7876B1", "#6F99AD", "#FFDC91", "#EE4C97"),
    JAMA = c("#374E55", "#DF8F44", "#00A1D5", "#B24745", "#79AF97", "#6A6599", "#80796B"),
    Cell = c("#0073C2", "#EFC000", "#868686", "#CD534C", "#7AA6DC", "#003C67", "#8F7700", "#3B3B3B", "#A73030")
  )
  base_cols <- palettes[[palette_name]] %||% palettes[["NPG"]]
  if (n <= length(base_cols)) return(base_cols[seq_len(n)])
  grDevices::colorRampPalette(base_cols)(n)
}

prepare_circos_data <- function(interactions, expression = NULL, style = list()) {
  src_col <- style$source_col %||% "source"
  tgt_col <- style$target_col %||% "target"
  lig_col <- style$ligand_col %||% "ligand"
  rec_col <- style$receptor_col %||% "receptor"
  prob_col <- style$prob_col %||% "prob"
  pval_col <- style$pval_col %||% "pval"

  req_cols <- c(src_col, tgt_col, lig_col, rec_col, prob_col)
  miss <- setdiff(req_cols, names(interactions))
  if (length(miss) > 0) stop("Missing required interaction columns: ", paste(miss, collapse = ", "))

  df <- data.frame(
    source = as.character(interactions[[src_col]]),
    target = as.character(interactions[[tgt_col]]),
    ligand = as.character(interactions[[lig_col]]),
    receptor = as.character(interactions[[rec_col]]),
    prob = as.numeric(interactions[[prob_col]]),
    pval = if (pval_col %in% names(interactions)) as.numeric(interactions[[pval_col]]) else 0.01,
    stringsAsFactors = FALSE
  )
  if ("highlight" %in% names(interactions)) {
    df$highlight <- as.logical(interactions$highlight)
  } else {
    df$highlight <- FALSE
  }

  score_thr <- as.numeric(style$score_threshold %||% 0.05)
  pval_thr <- as.numeric(style$pval_threshold %||% 0.05)
  df <- df[!is.na(df$prob) & df$prob >= score_thr & (is.na(df$pval) | df$pval <= pval_thr), , drop = FALSE]
  if (nrow(df) == 0) stop("No interactions remain after filtering (score_threshold=", score_thr, ")")

  # Determine cell types in stable order
  preferred_order <- c("ECs", "Tcell", "SMCs", "Mon", "Kers", "Fibs", "Mast", "lang", "Men")
  all_cells <- unique(c(df$source, df$target))
  if (!is.null(expression) && (style$cell_type_col %||% "cell_type") %in% names(expression)) {
    all_cells <- unique(c(all_cells, as.character(expression[[style$cell_type_col %||% "cell_type"]])))
  }
  ordered_cells <- c(intersect(preferred_order, all_cells), sort(setdiff(all_cells, preferred_order)))

  # Collect per-sector nodes (genes acting as ligand or receptor in that cell type)
  lig_nodes <- unique(data.frame(cell = df$source, gene = df$ligand, role = "ligand", stringsAsFactors = FALSE))
  rec_nodes <- unique(data.frame(cell = df$target, gene = df$receptor, role = "receptor", stringsAsFactors = FALSE))
  nodes <- rbind(lig_nodes, rec_nodes)
  # If a gene is both ligand & receptor in the same cell type, keep role with higher sum prob, or keep separate/unique per cell+gene
  nodes <- nodes[!duplicated(paste(nodes$cell, nodes$gene, sep = "::")), , drop = FALSE]

  # Order within each sector: ligands first (alphabetical), then receptors (alphabetical)
  sector_list <- list()
  for (ct in ordered_cells) {
    sub <- nodes[nodes$cell == ct, , drop = FALSE]
    if (nrow(sub) == 0) next
    sub$role_ord <- ifelse(sub$role == "ligand", 1, 2)
    sub <- sub[order(sub$role_ord, sub$gene), , drop = FALSE]
    sub$x <- seq_len(nrow(sub)) - 0.5
    # Compute gene bar value (normalized 0-100 interaction strength sum)
    bar_vals <- vapply(seq_len(nrow(sub)), function(k) {
      g <- sub$gene[k]
      r <- sub$role[k]
      if (r == "ligand") {
        sum(df$prob[df$source == ct & df$ligand == g], na.rm = TRUE)
      } else {
        sum(df$prob[df$target == ct & df$receptor == g], na.rm = TRUE)
      }
    }, numeric(1))
    sub$raw_bar <- bar_vals
    sector_list[[ct]] <- sub
  }
  node_df <- do.call(rbind, sector_list)
  rownames(node_df) <- NULL
  max_bar <- max(node_df$raw_bar, na.rm = TRUE)
  if (max_bar <= 0) max_bar <- 1
  # Power-scale to 25..96 so gene bars read clearly across the 0..100 track
  node_df$bar_val <- pmin(98, 22 + 74 * ((node_df$raw_bar / max_bar) ^ 0.55))

  # Build expression matrix (rows = rev(ordered_cells), cols = all sector gene slots)
  active_cells <- names(sector_list)
  row_order <- rev(active_cells)
  expr_mat <- matrix(0, nrow = length(row_order), ncol = nrow(node_df),
                     dimnames = list(row_order, paste(node_df$cell, node_df$gene, sep = "|")))

  if (!is.null(expression) && nrow(expression) > 0) {
    g_col <- style$gene_col %||% "gene"
    ct_col <- style$cell_type_col %||% "cell_type"
    ex_col <- style$expression_col %||% "expression"
    if (all(c(g_col, ct_col, ex_col) %in% names(expression))) {
      key_val <- stats::setNames(
        as.numeric(expression[[ex_col]]),
        paste(as.character(expression[[ct_col]]), as.character(expression[[g_col]]), sep = "|")
      )
      for (i in seq_along(row_order)) {
        r_ct <- row_order[i]
        for (j in seq_len(nrow(node_df))) {
          k <- paste(r_ct, node_df$gene[j], sep = "|")
          if (k %in% names(key_val) && !is.na(key_val[[k]])) {
            expr_mat[i, j] <- key_val[[k]]
          }
        }
      }
    }
  } else {
    # Deterministic fallback expression proxy from interaction participation if no expression CSV provided
    for (i in seq_along(row_order)) {
      r_ct <- row_order[i]
      for (j in seq_len(nrow(node_df))) {
        if (node_df$cell[j] == r_ct) expr_mat[i, j] <- 1.6 else expr_mat[i, j] <- -0.8
      }
    }
  }

  # Map x positions onto links
  key_x <- stats::setNames(node_df$x, paste(node_df$cell, node_df$gene, sep = "|"))
  df$x1 <- key_x[paste(df$source, df$ligand, sep = "|")]
  df$x2 <- key_x[paste(df$target, df$receptor, sep = "|")]
  df <- df[!is.na(df$x1) & !is.na(df$x2), , drop = FALSE]

  # Mark top N links if none explicitly marked highlight
  top_n <- as.integer(style$highlight_top_n %||% 2)
  if (top_n > 0 && !any(df$highlight)) {
    ord <- order(df$prob, decreasing = TRUE)
    df$highlight[ord[seq_len(min(top_n, nrow(df)))]] <- TRUE
  }

  list(
    sectors = active_cells,
    row_order = row_order,
    nodes = node_df,
    expr_mat = expr_mat,
    links = df
  )
}

draw_ks_circos <- function(prep, style = list()) {
  sectors <- prep$sectors
  node_df <- prep$nodes
  expr_mat <- prep$expr_mat
  links <- prep$links

  palette_name <- style$palette %||% "NPG"
  cell_cols <- stats::setNames(ks_palette_colors(palette_name, length(sectors)), sectors)
  expr_lim <- as.numeric(style$expr_limit %||% 2.5)
  font_pt <- as.numeric(style$font_size %||% 10.0)
  show_bar <- isTRUE(style$show_bar_track %||% TRUE)
  gap_deg <- as.numeric(style$sector_gap %||% 4.5)
  start_deg <- as.numeric(style$start_degree %||% 85)

  # Reserve right-side margin for stacked legends
  grid::grid.newpage()
  vp_main <- grid::viewport(x = 0.41, y = 0.49, width = 0.79, height = 0.96)
  grid::pushViewport(vp_main)

  # Base graphics inside grid viewport
  par_old <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(par_old), add = TRUE)
  graphics::par(new = TRUE, fig = gridBase::gridFIG(), mar = c(0.4, 0.4, if (nzchar(style$title %||% "")) 2.0 else 0.4, 0.4))

  circlize::circos.clear()
  # Make the gap before the first sector (Men -> ECs at 12 o'clock) slightly wider for row & y-axis labels
  gaps <- rep(gap_deg, length(sectors))
  gaps[length(gaps)] <- max(gap_deg * 2.8, 13.0)

  circlize::circos.par(
    start.degree = start_deg,
    gap.after = gaps,
    track.margin = c(0.012, 0.012),
    cell.padding = c(0, 0, 0, 0),
    canvas.xlim = c(-1.16, 1.16),
    canvas.ylim = c(-1.16, 1.16)
  )

  xlim_mat <- t(vapply(sectors, function(ct) {
    c(0, sum(node_df$cell == ct))
  }, numeric(2)))

  circlize::circos.initialize(factors = factor(sectors, levels = sectors), xlim = xlim_mat)

  # Track 0 (outermost): Colored sector arc bar + Cell Type title
  circlize::circos.trackPlotRegion(
    ylim = c(0, 1),
    track.height = 0.022,
    bg.border = NA,
    panel.fun = function(x, y) {
      sec <- circlize::CELL_META$sector.index
      xlim <- circlize::CELL_META$xlim
      # Draw thin outer colored arc with black outline
      circlize::circos.rect(xlim[1], 0.45, xlim[2], 0.88, col = cell_cols[[sec]], border = "black", lwd = 0.7)
      # Sector title outside arc
      circlize::circos.text(
        mean(xlim), 1.65, labels = sec,
        facing = "bending.inside", niceFacing = TRUE,
        cex = max(0.82, font_pt / 9.2), font = 2, col = "black", adj = c(0.5, 0)
      )
    }
  )

  # Gene label track (ligand = #5AC394, receptor = #E7298A) with generous clearance from outer arc
  circlize::circos.trackPlotRegion(
    ylim = c(0, 1),
    track.height = 0.215,
    bg.border = NA,
    panel.fun = function(x, y) {
      sec <- circlize::CELL_META$sector.index
      sub <- node_df[node_df$cell == sec, , drop = FALSE]
      g_cols <- ifelse(sub$role == "ligand", "#5AC394", "#E7298A")
      for (k in seq_len(nrow(sub))) {
        circlize::circos.text(
          sub$x[k], 0.04, labels = sub$gene[k],
          facing = "clockwise", niceFacing = TRUE,
          adj = c(0, 0.5),
          cex = max(0.45, (font_pt / 15.8)),
          font = 3, col = g_cols[k]
        )
      }
    }
  )

  # Track 1: Expression Heatmap (9 celltypes x sector genes)
  expr_col_fun <- circlize::colorRamp2(
    c(-expr_lim, -expr_lim * 0.45, 0, expr_lim * 0.45, expr_lim),
    c("#17347A", "#4A82BA", "#F7F7F7", "#E67A61", "#9E0D22")
  )
  n_rows <- nrow(expr_mat)
  circlize::circos.trackPlotRegion(
    ylim = c(0, n_rows),
    track.height = 0.225,
    bg.border = "black",
    bg.lwd = 0.9,
    panel.fun = function(x, y) {
      sec <- circlize::CELL_META$sector.index
      idx <- which(node_df$cell == sec)
      sub_mat <- expr_mat[, idx, drop = FALSE]
      for (r in seq_len(n_rows)) {
        for (c_i in seq_len(ncol(sub_mat))) {
          val <- sub_mat[r, c_i]
          circlize::circos.rect(
            c_i - 1, r - 1, c_i, r,
            col = expr_col_fun(val),
            border = "#E5E7EB", lwd = 0.35
          )
        }
      }
      # Re-stroke outer crisp black box around sector heatmap
      circlize::circos.rect(0, 0, ncol(sub_mat), n_rows, col = NA, border = "black", lwd = 0.9)
      # Row labels at the 12 o'clock gap (left edge of first sector)
      if (sec == sectors[1]) {
        for (r in seq_len(n_rows)) {
          circlize::circos.text(
            -0.25, r - 0.5, labels = rownames(expr_mat)[r],
            facing = "inside", niceFacing = TRUE,
            adj = c(1, 0.5), cex = max(0.42, font_pt / 18.5), col = "black"
          )
        }
      }
    }
  )

  # Track 2: Per-gene Barplot (0-100)
  if (show_bar) {
    circlize::circos.trackPlotRegion(
      ylim = c(0, 105),
      track.height = 0.13,
      bg.border = "black",
      bg.lwd = 0.85,
      panel.fun = function(x, y) {
        sec <- circlize::CELL_META$sector.index
        sub <- node_df[node_df$cell == sec, , drop = FALSE]
        for (k in seq_len(nrow(sub))) {
          circlize::circos.rect(
            k - 0.88, 0, k - 0.12, sub$bar_val[k],
            col = cell_cols[[sec]], border = NA
          )
        }
        if (sec == sectors[1]) {
          circlize::circos.yaxis(
            side = "left", at = c(0, 50, 100),
            labels = c("0", "50", "100"),
            labels.cex = max(0.42, font_pt / 17.5),
            tick.length = circlize::convert_x(1.2, "mm")
          )
        }
      }
    )
  }

  # Track 3: Inner Chord Links colored by Interaction Score
  score_min <- min(links$prob, na.rm = TRUE)
  score_max <- max(links$prob, na.rm = TRUE)
  if (score_max <= score_min) score_max <- score_min + 0.1
  score_col_fun <- circlize::colorRamp2(
    seq(score_min, score_max, length.out = 5),
    c("#F6FBB2", "#A1DAB4", "#41B6C4", "#2C7FB8", "#251478")
  )

  # Draw regular links first (ascending score), then highlighted thick links on top
  links_reg <- links[!links$highlight, , drop = FALSE]
  links_reg <- links_reg[order(links_reg$prob), , drop = FALSE]
  for (i in seq_len(nrow(links_reg))) {
    lk <- links_reg[i, ]
    col_hex <- grDevices::adjustcolor(score_col_fun(lk$prob), alpha.f = 0.42)
    circlize::circos.link(
      lk$source, lk$x1, lk$target, lk$x2,
      col = col_hex, lwd = 0.9, h.ratio = 0.72
    )
  }

  links_hi <- links[links$highlight, , drop = FALSE]
  for (i in seq_len(nrow(links_hi))) {
    lk <- links_hi[i, ]
    hi_col <- cell_cols[[lk$source]] %||% "#E41A37"
    circlize::circos.link(
      lk$source, lk$x1, lk$target, lk$x2,
      col = grDevices::adjustcolor(hi_col, alpha.f = 0.80),
      lwd = 3.2, h.ratio = 0.68
    )
  }

  if (nzchar(style$title %||% "")) {
    graphics::title(main = style$title, cex.main = 1.15)
  }

  circlize::circos.clear()
  grid::popViewport()

  # Right-side stacked legends
  vp_leg <- grid::viewport(x = 0.88, y = 0.52, width = 0.20, height = 0.78)
  grid::pushViewport(vp_leg)

  lgd_role <- ComplexHeatmap::Legend(
    labels = c("ligand", "receptor"),
    type = "lines",
    background = NA,
    legend_gp = grid::gpar(col = c("#5AC394", "#E7298A"), lwd = 3.5),
    labels_gp = grid::gpar(fontsize = font_pt),
    grid_width = grid::unit(6, "mm"),
    row_gap = grid::unit(2.5, "mm")
  )
  lgd_score <- ComplexHeatmap::Legend(
    col_fun = score_col_fun,
    title = "Interaction Score",
    title_position = "leftcenter-rot",
    title_gp = grid::gpar(fontsize = font_pt, fontface = "plain"),
    labels_gp = grid::gpar(fontsize = font_pt * 0.9),
    legend_height = grid::unit(26, "mm"),
    border = "black"
  )
  lgd_expr <- ComplexHeatmap::Legend(
    col_fun = expr_col_fun,
    title = "Expression",
    title_position = "leftcenter-rot",
    title_gp = grid::gpar(fontsize = font_pt, fontface = "plain"),
    labels_gp = grid::gpar(fontsize = font_pt * 0.9),
    at = c(-expr_lim, 0, expr_lim),
    legend_height = grid::unit(26, "mm"),
    border = "black"
  )
  pd <- ComplexHeatmap::packLegend(
    lgd_role, lgd_score, lgd_expr,
    direction = "vertical",
    gap = grid::unit(9, "mm")
  )
  ComplexHeatmap::draw(pd, just = c("center", "center"))
  grid::popViewport()
}
