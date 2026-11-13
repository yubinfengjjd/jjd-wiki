library(Seurat)
library(SCpubr)
library(ggunchull)
library(ggplot2)
library(dplyr)
library(scales)
library(grid)
setwd("E:\\青光眼单细胞")
# ============================================================
# 细胞注释与可视化
# 青光眼小鼠数据 (GSE251716)
# 分辨率固定: 0.05
# ============================================================

load("GSE251716_seurat.Rdata")

res_use <- "RNA_snn_res.0.05"
Idents(GLC) <- res_use

# ============================================================
# Step 1: SCpubr DotPlot 基因 × 簇
# ============================================================

markers <- list(
  "RGC"           = c("Pou4f1", "Thy1", "Rbpms", "Sncg", "Nefl"),
  "Amacrine"      = c("Gad1", "Slc6a9", "Pvalb", "Tac1"),
  "Horizontal"    = c("Calb1", "Lhx1", "Onecut1"),
  "Bipolar"       = c("Vsx2", "Grik1", "Cabp5", "Prkca"),
  "Photoreceptor" = c("Rho", "Gnat1", "Nrl", "Opn1mw"),
  "Muller_Glia"   = c("Glul", "Rlbp1", "Aqp4", "Vim", "Sox2"),
  "Astrocyte"     = c("Gfap", "Aldh1l1", "Slc1a3"),
  "Microglia"     = c("Cx3cr1", "Tmem119", "P2ry12", "Aif1"),
  "Macrophage"    = c("Ctsb", "Lyz2", "Cd68", "Itgam"),
  "Endothelial"   = c("Pecam1", "Cldn5", "Flt1", "Tek"),
  "Pericyte"      = c("Pdgfrb", "Cspg4", "Rgs5", "Des"),
  "Fibroblast"    = c("Col1a1", "Col1a2", "Dcn", "Lum"),
  "RPE"           = c("Rpe65", "Mitf", "Tyr", "Best1")
)

pdf(file = "annotation.pdf", width = 16, height = 8)
p <- SCpubr::do_DotPlot(sample = GLC, features = markers, dot.scale = 6)
print(p)
dev.off()
cat("DotPlot 已保存至: annotation.pdf\n")

# ============================================================
# Step 2: 细胞类型注释
# ============================================================

celltype_map <- c(
  "0"  = "Muller_Glia",
  "1"  = "Rod_Photoreceptor",
  "2"  = "Bipolar",
  "3"  = "Cone_Photoreceptor",
  "4"  = "RGC_like",
  "5"  = "Bipolar",
  "6"  = "Bipolar",
  "7"  = "Bipolar",
  "8"  = "Bipolar",
  "9"  = "Bipolar",
  "10" = "Bipolar",
  "11" = "Bipolar",
  "12" = "Bipolar",
  "13" = "Bipolar",
  "14" = "RPE",
  "15" = "Vascular_Pericyte",
  "16" = "Amacrine",
  "17" = "Amacrine_Horizontal_like"
)

GLC$celltype <- factor(
  as.character(GLC@meta.data[[res_use]]),
  levels = names(celltype_map),
  labels = celltype_map
)
table(GLC$celltype)

Idents(GLC) <- "celltype"

# ============================================================
# Step 3: CNS 风格 UMAP 注释图
# ============================================================

plotData <- as.data.frame(Embeddings(GLC, "umap"))
colnames(plotData) <- c("umap_1", "umap_2")
plotData$celltype <- GLC$celltype

n_levels <- nlevels(plotData$celltype)
umap_palette <- c(
  "#E64B35", "#4DBBD5", "#00A087", "#3C5488",
  "#F39B7F", "#8491B4", "#91D1C2", "#DC0000",
  "#7E6148", "#B09C85", "#E18727", "#20854E",
  "#7876B1", "#6F99AD", "#FFDC91", "#EE4C97",
  "#A6CEE3", "#BC80BD", "#FFED6F", "#8DD3C7"
)
mycols <- setNames(umap_palette[seq_len(n_levels)], levels(plotData$celltype))

centroids <- aggregate(cbind(umap_1, umap_2) ~ celltype, data = plotData, FUN = median)

x_range <- range(plotData$umap_1, na.rm = TRUE)
y_range <- range(plotData$umap_2, na.rm = TRUE)
x_span <- x_range[2] - x_range[1]
y_span <- y_range[2] - y_range[1]
x_pad <- x_span * 0.04; y_pad <- y_span * 0.04
x_lim <- c(x_range[1] - x_pad, x_range[2] + x_pad)
y_lim <- c(y_range[1] - y_pad, y_range[2] + y_pad)
x_axis_len <- x_span * 0.12; y_axis_len <- y_span * 0.12
x_axis_start <- x_lim[1] + x_pad
y_axis_start <- y_lim[1] + y_pad

p <- ggplot(plotData, aes(x = umap_1, y = umap_2, color = celltype, fill = celltype)) +
  stat_unchull(alpha = 0.22, size = 0.35, delta = 0.45, linetype = "dashed") +
  geom_point(size = 0.9, alpha = 0.85, stroke = 0) +
  geom_text(data = centroids,
            aes(x = umap_1, y = umap_2, label = celltype),
            color = "grey20", size = 4.5, fontface = "bold",
            family = "Arial", inherit.aes = FALSE) +
  scale_color_manual(values = mycols, name = NULL) +
  scale_fill_manual(values = mycols, name = NULL) +
  coord_fixed(xlim = x_lim, ylim = y_lim, clip = "off") +
  labs(x = NULL, y = NULL) +
  theme_classic(base_size = 12, base_family = "Arial") +
  theme(
    aspect.ratio       = 1,
    panel.background   = element_blank(),
    panel.grid         = element_blank(),
    axis.line          = element_blank(),
    axis.ticks         = element_blank(),
    axis.text          = element_blank(),
    axis.title         = element_blank(),
    legend.position    = "right",
    legend.title       = element_blank(),
    legend.text        = element_text(size = 9, family = "Arial"),
    legend.key.size    = unit(0.35, "cm"),
    legend.background  = element_blank(),
    legend.key         = element_blank(),
    plot.margin        = margin(5, 5, 5, 5)
  ) +
  annotate("segment",
    x = x_axis_start, xend = x_axis_start + x_axis_len,
    y = y_axis_start, yend = y_axis_start,
    linewidth = 0.45, color = "black",
    arrow = arrow(length = unit(0.12, "cm"), type = "closed")
  ) +
  annotate("segment",
    x = x_axis_start, xend = x_axis_start,
    y = y_axis_start, yend = y_axis_start + y_axis_len,
    linewidth = 0.45, color = "black",
    arrow = arrow(length = unit(0.12, "cm"), type = "closed")
  ) +
  annotate("text",
    x = x_axis_start + x_axis_len * 0.55,
    y = y_axis_start - y_span * 0.025,
    label = "UMAP_1", size = 3.5, fontface = "italic", family = "Arial"
  ) +
  annotate("text",
    x = x_axis_start - x_span * 0.025,
    y = y_axis_start + y_axis_len * 0.55,
    label = "UMAP_2", size = 3.5, fontface = "italic", family = "Arial", angle = 90
  ) +
  guides(
    color = guide_legend(override.aes = list(size = 2.5, alpha = 1)),
    fill  = guide_legend(override.aes = list(alpha = 0.25))
  )

cairo_pdf(file = "umap_annotation.pdf", width = 9, height = 7, family = "Arial")
print(p)
dev.off()
cat("CNS 风格 UMAP 注释图已保存至: umap_annotation.pdf\n")

# ============================================================
# Step 4: 顶刊风格气泡图（注释后，横坐标为细胞类型）
# ============================================================

plot_topjournal_bubble <- function(
    data, x_col, y_col, expr_col, pct_col,
    x_levels = NULL, y_levels = NULL, x_colors = NULL,
    expr_palette = c("#083B6F", "#3B8FC2", "#D9EEF4", "#F6F3EA", "#F07C56", "#8A001F"),
    expr_limits = c(0, 1), expr_breaks = c(0, 0.25, 0.50, 0.75, 1.00),
    size_limits = c(0, 100), size_breaks = c(25, 50, 75),
    size_range = c(1.2, 7.0), panel_fill = "#F2F2F2",
    plot_width = 3.45, plot_height = 7.2,
    italic_y = TRUE, dpi = 600
) {
  df <- data %>%
    dplyr::select(x_value = all_of(x_col), y_value = all_of(y_col),
                  expr_value = all_of(expr_col), pct_value = all_of(pct_col)) %>%
    dplyr::mutate(
      x_value = as.character(x_value), y_value = as.character(y_value),
      expr_value = as.numeric(expr_value), pct_value = as.numeric(pct_value))
  # 限幅处理
  df$expr_value <- pmax(expr_limits[1], pmin(expr_limits[2], df$expr_value))
  df$pct_value  <- pmax(size_limits[1],  pmin(size_limits[2],  df$pct_value))
  if (is.null(x_levels)) x_levels <- unique(df$x_value)
  if (is.null(y_levels)) y_levels <- unique(df$y_value)
  x_levels <- as.character(x_levels); y_levels <- as.character(y_levels)
  df <- df %>%
    dplyr::filter(x_value %in% x_levels, y_value %in% y_levels) %>%
    dplyr::mutate(
      x_value = factor(x_value, levels = x_levels),
      y_value = factor(y_value, levels = y_levels),
      x = as.numeric(x_value),
      y = length(y_levels) - as.numeric(y_value) + 1)
  if (is.null(x_colors)) {
    x_colors <- c("#F2A000", "#37B7AE", "#13A25B", "#F0DB35",
                  "#1C9AD6", "#D65F00", "#AEB0B4", "#C98CB7",
                  "#E64B35", "#4DBBD5", "#00A087", "#3C5488",
                  "#F39B7F", "#7876B1", "#EE4C97", "#7E6148",
                  "#20854E", "#FFDC91", "#BC80BD", "#8DD3C7")
    x_colors <- setNames(x_colors[seq_along(x_levels)], x_levels)
  }
  anno_df <- data.frame(x = seq_along(x_levels), y = -0.85,
                         anno = factor(x_levels, levels = x_levels))
  ggplot(df, aes(x = x, y = y)) +
    geom_point(aes(size = pct_value, colour = expr_value), alpha = 0.98) +
    geom_point(data = anno_df, aes(x = x, y = y, fill = anno),
               inherit.aes = FALSE, shape = 21, size = 4.8, stroke = 0) +
    scale_fill_manual(values = x_colors, guide = "none") +
    scale_colour_gradientn(
      colours = expr_palette, limits = expr_limits, breaks = expr_breaks,
      labels = sprintf("%.2f", expr_breaks), oob = scales::squish, name = "Relative\nExpression") +
    scale_size_continuous(range = size_range, limits = size_limits,
      breaks = size_breaks, name = "Percentage\nExpressed") +
    scale_x_continuous(breaks = seq_along(x_levels), labels = x_levels,
      limits = c(0.5, length(x_levels) + 0.5), expand = expansion(mult = 0)) +
    scale_y_continuous(breaks = seq_along(y_levels), labels = rev(y_levels),
      limits = c(-1.35, length(y_levels) + 0.6), expand = expansion(mult = 0)) +
    coord_cartesian(clip = "off") +
    guides(
      colour = guide_colourbar(title.position = "top", title.hjust = 0,
        barheight = unit(3.0, "cm"), barwidth = unit(0.45, "cm"),
        ticks.colour = "black", frame.colour = NA),
      size = guide_legend(title.position = "top", title.hjust = 0,
        override.aes = list(colour = "black", alpha = 1), label.position = "right")) +
    theme_classic(base_size = 10) +
    theme(
      panel.background = element_rect(fill = panel_fill, colour = NA),
      plot.background  = element_rect(fill = "white", colour = NA),
      panel.border = element_rect(fill = NA, colour = "black", linewidth = 1.5),
      axis.line = element_blank(), axis.title = element_blank(),
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1,
        colour = "black", size = 9.5, margin = margin(t = 3)),
      axis.text.y = element_text(colour = "black", size = 9.2,
        face = if (italic_y) "italic" else "plain", margin = margin(r = 3)),
      axis.ticks = element_line(colour = "black", linewidth = 0.55),
      axis.ticks.length = unit(2.3, "pt"),
      legend.position = "right", legend.box = "vertical",
      legend.box.spacing = unit(1.2, "cm"),
      legend.title = element_text(size = 10.5, colour = "black", lineheight = 0.9),
      legend.text = element_text(size = 8.7, colour = "black"),
      legend.key = element_blank(), plot.margin = margin(8, 22, 8, 8))
}

marker_genes <- c(
  "Pou4f1", "Thy1", "Rbpms", "Sncg", "Nefl",
  "Gad1", "Slc6a9", "Pvalb", "Tac1",
  "Calb1", "Lhx1", "Onecut1",
  "Vsx2", "Grik1", "Cabp5", "Prkca",
  "Rho", "Gnat1", "Nrl", "Opn1mw",
  "Glul", "Rlbp1", "Aqp4", "Vim", "Sox2",
  "Gfap", "Aldh1l1", "Slc1a3",
  "Cx3cr1", "Tmem119", "P2ry12", "Aif1",
  "Ctsb", "Lyz2", "Cd68", "Itgam",
  "Pecam1", "Cldn5", "Flt1", "Tek",
  "Pdgfrb", "Cspg4", "Rgs5", "Des",
  "Col1a1", "Col1a2", "Dcn", "Lum",
  "Rpe65", "Mitf", "Tyr", "Best1"
)

dp_data <- DotPlot(GLC, features = marker_genes, group.by = "celltype")$data
dp_data$avg_exp_01 <- rescale(dp_data$avg.exp.scaled, to = c(0, 1))

# 基因→标记组映射
gene_to_group <- setNames(
  rep(names(markers), lengths(markers)),
  unlist(markers)
)

# 标记组→目标注释细胞类型
group_to_target <- c(
  "RGC"           = "RGC_like",
  "Amacrine"      = "Amacrine",
  "Horizontal"    = "Amacrine_Horizontal_like",
  "Bipolar"       = "Bipolar",
  "Photoreceptor" = "Rod_Photoreceptor",
  "Muller_Glia"   = "Muller_Glia",
  "RPE"           = "RPE",
  "Pericyte"      = "Vascular_Pericyte",
  "Astrocyte"     = NA_character_,
  "Microglia"     = NA_character_,
  "Macrophage"    = NA_character_,
  "Endothelial"   = NA_character_,
  "Fibroblast"    = NA_character_
)

# x 轴：按注释细胞类型原有顺序
x_levels <- levels(GLC$celltype)

# y 轴：基因按对应细胞类型在 x 轴的位置排序，组内保持原始顺序
y_order <- data.frame(
  gene     = marker_genes,
  group    = gene_to_group[marker_genes],
  gene_idx = seq_along(marker_genes),
  stringsAsFactors = FALSE
)
y_order$target     <- group_to_target[y_order$group]
y_order$target_pos <- match(y_order$target, x_levels)
y_order <- y_order[order(y_order$target_pos, y_order$gene_idx, na.last = TRUE), ]
y_levels <- y_order$gene

p_bubble <- plot_topjournal_bubble(
  data = dp_data,
  x_col = "id",
  y_col = "features.plot",
  expr_col = "avg_exp_01",
  pct_col = "pct.exp",
  x_levels = x_levels,
  y_levels = y_levels,
  plot_width = 6, plot_height = 9
)

cairo_pdf(file = "annotation_bubble.pdf", width = 6, height = 12, family = "Arial")
print(p_bubble)
dev.off()
cat("顶刊气泡图已保存至: annotation_bubble.pdf\n")

# ============================================================
# Step 5: CNS 风格每类细胞单 marker UMAP 特征图
# ============================================================

.parse_cutoff <- function(x, values) {
  if (is.numeric(x)) return(x)
  if (is.character(x) && grepl("^q[0-9]+$", x)) {
    q <- as.numeric(sub("^q", "", x)) / 100
    return(as.numeric(stats::quantile(values, probs = q, na.rm = TRUE)))
  }
  stop("cutoff must be numeric or character like 'q05', 'q95'")
}

plot_feature_cns_advanced <- function(
    seu,
    features,
    reduction = "umap",
    ncol = 3,
    group = NULL,
    gene_to_celltype = NULL,
    show_axes = TRUE,
    contour.color = "#A0A0A0",
    contour.fill = "#D8D8D8",
    contour.alpha = 0.25,
    contour.size = 0.22,
    contour.delta = 0.45,
    pt.size.bg = 0.28,
    pt.size.fg = 0.32,
    alpha.bg = 0.38,
    alpha.fg = 0.95,
    bg.color = "#D0D0D0",
    exp.palette = c("#6FB7AE", "#C8DDC4", "#F1E8A6"),
    min.cutoff = "q05",
    max.cutoff = "q95",
    title.size = 13,
    title.face = "italic",
    legend.text.size = 7.2,
    legend.bar.height = 1.6,
    legend.bar.width = 0.20,
    panel.margin = margin(3, 3, 3, 3),
    xpad_ratio = 0.03,
    ypad_ratio = 0.03,
    order_points = TRUE,
    keep_zero_background = TRUE
) {
  emb <- Embeddings(seu, reduction = reduction)[, 1:2, drop = FALSE]
  plot_base <- data.frame(
    cell  = rownames(emb),
    dim1  = emb[, 1],
    dim2  = emb[, 2],
    stringsAsFactors = FALSE
  )
  if (!is.null(group)) {
    plot_base$group <- group
  }

  x_rng <- range(plot_base$dim1, na.rm = TRUE)
  y_rng <- range(plot_base$dim2, na.rm = TRUE)
  x_span <- diff(x_rng)
  y_span <- diff(y_rng)
  x_pad <- x_span * xpad_ratio
  y_pad <- y_span * ypad_ratio
  x_lim_lo <- x_rng[1] - x_pad
  x_lim_hi <- x_rng[2] + x_pad
  y_lim_lo <- y_rng[1] - y_pad
  y_lim_hi <- y_rng[2] + y_pad

  # 短坐标轴参数
  axis_len_x <- x_span * 0.12
  axis_len_y <- y_span * 0.12
  axis_x0 <- x_lim_lo + x_pad
  axis_y0 <- y_lim_lo + y_pad

  make_one_panel <- function(gene) {
    expr_df <- FetchData(seu, vars = gene)
    df <- plot_base
    df$expr <- expr_df[, 1]

    df_bg <- df
    df_fg <- df %>% filter(!is.na(expr), expr > 0)

    if (nrow(df_fg) == 0) {
      p <- ggplot() +
        geom_point(
          data = df_bg,
          aes(dim1, dim2),
          color = bg.color,
          size = pt.size.bg,
          alpha = alpha.bg,
          stroke = 0
        ) +
        coord_fixed(
          xlim = c(x_lim_lo, x_lim_hi),
          ylim = c(y_lim_lo, y_lim_hi),
          expand = FALSE,
          clip = "off"
        ) +
        labs(title = gene) +
        theme_void() +
        theme(
          plot.title = element_text(
            face = title.face,
            size = title.size,
            hjust = 0.5,
            margin = margin(b = 2)
          ),
          plot.margin = panel.margin
        )
      return(p)
    }

    min_val <- .parse_cutoff(min.cutoff, df_fg$expr)
    max_val <- .parse_cutoff(max.cutoff, df_fg$expr)

    if (isTRUE(min_val >= max_val)) {
      min_val <- min(df_fg$expr, na.rm = TRUE)
      max_val <- max(df_fg$expr, na.rm = TRUE)
    }

    df_fg$expr_plot <- pmin(pmax(df_fg$expr, min_val), max_val)

    if (order_points) {
      df_fg <- df_fg %>% arrange(expr_plot)
    }

    brks <- pretty(c(min_val, max_val), n = 4)
    brks <- brks[brks >= min_val & brks <= max_val]

    p <- ggplot() +
      geom_point(
        data = df_bg,
        aes(dim1, dim2),
        color = bg.color,
        size = pt.size.bg,
        alpha = alpha.bg,
        stroke = 0
      ) +
      geom_point(
        data = df_fg,
        aes(dim1, dim2, colour = expr_plot),
        size = pt.size.fg,
        alpha = alpha.fg,
        stroke = 0
      ) +
      scale_colour_gradientn(
        colours = exp.palette,
        limits = c(min_val, max_val),
        breaks = brks,
        labels = function(x) format(round(x, 0), trim = TRUE, scientific = FALSE),
        oob = scales::squish,
        guide = guide_colorbar(
          title = NULL,
          frame.colour = NA,
          ticks.colour = NA,
          barheight = unit(legend.bar.height, "cm"),
          barwidth  = unit(legend.bar.width, "cm")
        )
      ) +
      coord_fixed(
        xlim = c(x_lim_lo, x_lim_hi),
        ylim = c(y_lim_lo, y_lim_hi),
        expand = FALSE,
        clip = "off"
      ) +
      labs(title = gene) +
      theme_void() +
      theme(
        plot.title = element_text(
          face = title.face,
          size = title.size,
          hjust = 0.5,
          margin = margin(b = 2)
        ),
        legend.position = "right",
        legend.text = element_text(size = legend.text.size, colour = "black"),
        legend.key.height = unit(0.35, "cm"),
        legend.key.width  = unit(0.22, "cm"),
        plot.background = element_rect(fill = "white", colour = NA),
        panel.background = element_rect(fill = "white", colour = NA),
        plot.margin = panel.margin
      )

    # 仅该 marker 对应细胞群的轮廓
    if (!is.null(plot_base$group) && !is.null(gene_to_celltype)) {
      target_ct <- gene_to_celltype[gene]
      if (!is.na(target_ct)) {
        df_contour <- df_bg[df_bg$group == target_ct, , drop = FALSE]
        if (nrow(df_contour) > 2) {
          p <- p + stat_unchull(
            data = df_contour,
            aes(x = dim1, y = dim2),
            colour = contour.color,
            fill = contour.fill,
            alpha = contour.alpha,
            size = contour.size,
            delta = contour.delta,
            linetype = "dashed",
            inherit.aes = FALSE
          )
        }
      }
    } else if (!is.null(plot_base$group)) {
      p <- p + stat_unchull(
        data = df_bg,
        aes(x = dim1, y = dim2, group = group),
        colour = contour.color,
        fill = contour.fill,
        alpha = contour.alpha,
        size = contour.size,
        delta = contour.delta,
        linetype = "dashed",
        inherit.aes = FALSE
      )
    }

    # 左下角短坐标轴
    if (show_axes) {
      p <- p +
        annotate("segment",
          x = axis_x0, xend = axis_x0 + axis_len_x,
          y = axis_y0, yend = axis_y0,
          linewidth = 0.4, color = "black",
          arrow = arrow(length = unit(0.10, "cm"), type = "closed")
        ) +
        annotate("segment",
          x = axis_x0, xend = axis_x0,
          y = axis_y0, yend = axis_y0 + axis_len_y,
          linewidth = 0.4, color = "black",
          arrow = arrow(length = unit(0.10, "cm"), type = "closed")
        ) +
        annotate("text",
          x = axis_x0 + axis_len_x * 0.55,
          y = axis_y0 - y_span * 0.040,
          label = "UMAP_1", size = 2.8, fontface = "italic", family = "Arial"
        ) +
        annotate("text",
          x = axis_x0 - x_span * 0.040,
          y = axis_y0 + axis_len_y * 0.55,
          label = "UMAP_2", size = 2.8, fontface = "italic", family = "Arial", angle = 90
        )
    }

    return(p)
  }

  plot_list <- lapply(features, make_one_panel)
  combined_plot <- wrap_plots(plotlist = plot_list, ncol = ncol, byrow = TRUE)
  return(combined_plot)
}

# GLC 专用 wrapper（自动注入 celltype 轮廓 + 坐标轴 + 基因→细胞类型映射）
plot_GLC_markers_cns <- function(features, ncol = 3, ...) {
  # 从 markers 列表自动构建 gene → celltype 映射
  gene_to_ct <- stats::setNames(rep(NA_character_, length(features)), features)
  for (nm in names(markers)) {
    target <- group_to_target[nm]
    if (is.na(target)) next
    for (g in markers[[nm]]) {
      if (g %in% features) gene_to_ct[g] <- target
    }
  }
  plot_feature_cns_advanced(
    seu = GLC, features = features, ncol = ncol,
    group = GLC$celltype, gene_to_celltype = gene_to_ct, show_axes = TRUE, ...
  )
}

# 每类注释细胞选一个最具特征性的 marker
top_markers <- c(
  "Pou4f1",  # RGC_like
  "Gad1",    # Amacrine
  "Onecut1", # Amacrine_Horizontal_like
  "Vsx2",    # Bipolar
  "Rho",     # Rod_Photoreceptor
  "Opn1mw",  # Cone_Photoreceptor
  "Glul",    # Muller_Glia
  "Rpe65",   # RPE
  "Pdgfrb"   # Vascular_Pericyte
)

p_markers <- plot_GLC_markers_cns(
  features = top_markers,
  ncol = 3,
  pt.size.bg = 0.24,
  pt.size.fg = 0.30,
  alpha.bg = 0.32,
  alpha.fg = 0.96,
  bg.color = "#CFCFCF",
  exp.palette = c("#74B8AF", "#CFE0C7", "#F1E8AE"),
  min.cutoff = "q05",
  max.cutoff = "q98",
  title.size = 13.5,
  legend.text.size = 7,
  xpad_ratio = 0.018,
  ypad_ratio = 0.018,
  panel.margin = margin(7, 7, 7, 7)
)

cairo_pdf(file = "marker_feature_umap.pdf", width = 11, height = 10, family = "Arial")
print(p_markers)
dev.off()
cat("CNS 风格 marker 特征图已保存至: marker_feature_umap.pdf\n")

# ============================================================
# Step 6: 细胞比例堆叠柱状图 + 相邻组流带
# ============================================================

plot_cellprop_flow <- function(
    data,
    x_col = "group",
    celltype_col = "celltype",
    prop_col = "prop",
    x_levels = NULL,
    stack_levels = NULL,
    legend_levels = NULL,
    palette = NULL,
    normalize = TRUE,
    bar_width = 0.36,
    flow_alpha = 0.22,
    bar_alpha = 0.92,
    flow_n = 120,
    y_lab = "Cell proportion",
    legend_title = "celltype",
    base_family = "Arial"
) {
  df <- data %>%
    dplyr::transmute(
      group    = .data[[x_col]],
      celltype = .data[[celltype_col]],
      prop     = as.numeric(.data[[prop_col]])
    )

  if (is.null(x_levels))     x_levels     <- unique(df$group)
  if (is.null(stack_levels)) stack_levels  <- unique(df$celltype)
  if (is.null(legend_levels)) legend_levels <- rev(stack_levels)

  df <- df %>%
    mutate(
      group    = factor(group, levels = x_levels),
      celltype = factor(celltype, levels = stack_levels)
    ) %>%
    filter(!is.na(group), !is.na(celltype), !is.na(prop))

  if (normalize) {
    df <- df %>%
      group_by(group) %>%
      mutate(prop = prop / sum(prop)) %>%
      ungroup()
  }

  pos_df <- df %>%
    arrange(group, celltype) %>%
    group_by(group) %>%
    mutate(
      ymax = cumsum(prop),
      ymin = ymax - prop,
      x    = match(group, x_levels)
    ) %>%
    ungroup()

  flow_list <- list()
  idx <- 1
  for (ct in levels(pos_df$celltype)) {
    tmp <- pos_df %>% filter(celltype == ct) %>% arrange(x)
    if (nrow(tmp) >= 2) {
      for (i in 1:(nrow(tmp) - 1)) {
        left  <- tmp[i, ]
        right <- tmp[i + 1, ]
        x_seq <- seq(left$x + bar_width / 2,
                     right$x - bar_width / 2,
                     length.out = flow_n)
        flow_list[[idx]] <- data.frame(
          x        = x_seq,
          ymin     = seq(left$ymin, right$ymin, length.out = flow_n),
          ymax     = seq(left$ymax, right$ymax, length.out = flow_n),
          celltype = as.character(ct),
          flow_id  = paste0(ct, "_", i),
          stringsAsFactors = FALSE
        )
        idx <- idx + 1
      }
    }
  }
  flow_df <- bind_rows(flow_list)

  if (is.null(palette)) {
    n_types <- length(stack_levels)
    palette <- setNames(
      c("#D96C86", "#F2A3A1", "#BDD6E8", "#8EA8D2", "#86C6BC", "#BCA7D8", "#DDD1EC",
        "#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F")[seq_len(n_types)],
      stack_levels
    )
  }

  p <- ggplot() +
    geom_ribbon(
      data = flow_df,
      aes(x = x, ymin = ymin, ymax = ymax, group = flow_id, fill = celltype),
      alpha = flow_alpha,
      colour = NA
    ) +
    geom_rect(
      data = pos_df,
      aes(xmin = x - bar_width / 2, xmax = x + bar_width / 2,
          ymin = ymin, ymax = ymax, fill = celltype),
      colour = NA,
      alpha = bar_alpha
    ) +
    scale_fill_manual(
      values  = palette,
      breaks  = legend_levels,
      name    = legend_title,
      drop    = FALSE
    ) +
    scale_x_continuous(
      breaks  = seq_along(x_levels),
      labels  = x_levels,
      expand  = expansion(mult = c(0.12, 0.12))
    ) +
    scale_y_continuous(
      limits  = c(0, 1),
      breaks  = c(0, 0.25, 0.50, 0.75, 1.00),
      labels  = function(x) sprintf("%.2f", x),
      expand  = c(0, 0)
    ) +
    labs(x = NULL, y = y_lab) +
    coord_cartesian(clip = "off") +
    theme_classic(base_size = 12, base_family = base_family) +
    theme(
      axis.line         = element_line(colour = "#4D4D4D", linewidth = 1.0),
      axis.ticks        = element_line(colour = "#4D4D4D", linewidth = 1.0),
      axis.ticks.length = unit(0.16, "cm"),
      axis.text         = element_text(colour = "#333333", size = 11),
      axis.title.y      = element_text(colour = "#333333", size = 13),
      axis.title.x      = element_blank(),
      legend.position   = "right",
      legend.title      = element_text(size = 12, face = "bold"),
      legend.text       = element_text(size = 10),
      legend.key.size   = unit(0.42, "cm"),
      legend.background = element_blank(),
      panel.border      = element_blank(),
      panel.grid        = element_blank(),
      plot.background   = element_rect(fill = "white", colour = NA),
      panel.background  = element_rect(fill = "white", colour = NA),
      plot.margin       = margin(8, 10, 8, 8)
    )

  return(p)
}

# 计算每个样本 (Control / Glaucoma) 的细胞类型比例
prop_data <- GLC@meta.data %>%
  dplyr::count(phenotype, celltype) %>%
  dplyr::group_by(phenotype) %>%
  dplyr::mutate(prop = n / sum(n)) %>%
  dplyr::ungroup()

# 复用 UMAP 注释图的细胞类型配色（保证全图配色一致）
ct_levels <- levels(GLC$celltype)
prop_palette <- c(
  "#E64B35", "#4DBBD5", "#00A087", "#3C5488",
  "#F39B7F", "#8491B4", "#91D1C2", "#DC0000", "#7E6148"
)
names(prop_palette) <- ct_levels

p_prop <- plot_cellprop_flow(
  data          = prop_data,
  x_col         = "phenotype",
  celltype_col  = "celltype",
  prop_col      = "prop",
  x_levels      = c("Control", "Glaucoma"),
  stack_levels  = ct_levels,
  legend_levels = rev(ct_levels),
  palette       = prop_palette,
  y_lab         = "Cell proportion",
  legend_title  = "Cell type"
)

cairo_pdf(file = "cell_proportion_flow.pdf", width = 5.5, height = 4.5, family = "Arial")
print(p_prop)
dev.off()
cat("细胞比例流带图已保存至: cell_proportion_flow.pdf\n")

# ============================================================
# 保存注释后的 Seurat 对象
# ============================================================
saveRDS(GLC, file = "GSE251716_seurat_annotated.rds")
cat("注释后对象已保存至: GSE251716_seurat_annotated.rds\n")



