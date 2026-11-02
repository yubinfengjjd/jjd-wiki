plot_gene_expression_state <- function(
    seurat_obj, 
    gene_name,
    state_col = "Monocle2_State",
    reference_group = NULL,
    output_file = NULL,
    base_width = 6,
    base_height = 6
) {
  # 检查基因是否存在于对象中
  if (!gene_name %in% rownames(seurat_obj)) {
    stop("基因 '", gene_name, "' 不存在于Seurat对象中")
  }
  
  # 提取基因表达数据
  expr_data <- GetAssayData(seurat_obj, assay = "RNA", slot = "data")[gene_name, ]
  
  # 构建绘图数据框
  plot_data <- data.frame(
    Expression = as.numeric(expr_data),
    Subtype = factor(seurat_obj@meta.data[[state_col]])
  )
  
  # 获取所有存在的state类型
  state_types <- levels(plot_data$Subtype)
  n_groups <- length(state_types)
  
  # 检查参考组有效性
  if (is.null(reference_group)) {
    reference_group <- tail(state_types, 1)  # 默认使用最后一组
  } else if (!reference_group %in% state_types) {
    stop("指定的参考组 '", reference_group, "' 不存在于数据中。可用组别: ", 
         paste(state_types, collapse = ", "))
  }
  
  # 使用科研友好配色
  color_scheme <- pal_npg("nrc")(n_groups)
  
  # ---- 统计检验 ----
  # Kruskal-Wallis检验
  kruskal_p_value <- kruskal.test(Expression ~ Subtype, data = plot_data)$p.value
  sig_label <- ifelse(kruskal_p_value < 0.001, "***",
                      ifelse(kruskal_p_value < 0.01, "**",
                             ifelse(kruskal_p_value < 0.05, "*", "")))
  
  # 生成两两比较组合（所有组与参考组比较）
  other_groups <- setdiff(state_types, reference_group)
  my_comparisons <- lapply(other_groups, function(x) c(x, reference_group))
  n_comparisons <- length(my_comparisons)
  
  # ---- 动态调整图形参数 ----
  y_range <- range(plot_data$Expression, na.rm = TRUE)
  y_min <- y_range[1]
  y_max <- y_range[2]
  range_diff <- diff(y_range)
  
  # 动态调整显著性标记位置
  label_y_step <- range_diff * 0.08
  label_y_start <- y_max + label_y_step
  label_y <- label_y_start + label_y_step * (0:(n_comparisons - 1))
  
  # 调整图形上边界
  plot_upper_limit <- y_max + (n_comparisons + 1) * label_y_step
  
  # ---- 绘图 ----
  set.seed(1)  # 让抖动可复现
  
  p <- ggplot(plot_data, aes(x = Subtype, y = Expression, fill = Subtype)) +
    # 左侧：带缺口的半箱线图
    gghalves::geom_half_boxplot(
      side = "l",
      notch = TRUE,
      outlier.shape = NA,
      width = 0.35,
      alpha = 0.8,
      color = "black",
      lwd = 0.6,
      center = TRUE
    ) +
    # 左侧：抖动点
    gghalves::geom_half_point(
      side = "l",
      shape = 21,
      color = "black",
      stroke = 0.25,
      size = 1.4,
      alpha = 0.6,
      position = position_nudge(x = 0.09),
      transformation = position_jitter(width = 0.05, height = 0)
    ) +
    # 右侧：半边小提琴
    gghalves::geom_half_violin(
      side = "r",
      color = "black",
      lwd = 0.6,
      alpha = 0.7,
      trim = TRUE,
      scale = "width",
      width = 0.35,
      position = position_nudge(x = 0.1)
    ) +
    # 在小提琴上加中位线
    stat_summary(
      fun = median,
      geom = "errorbar",
      aes(ymax = ..y.., ymin = ..y..),
      width = 0.25,
      color = "black",
      linetype = "solid",
      size = 1.2,
      position = position_nudge(x = 0.08)
    ) +
    # 两两比较显著性（动态位置）
    ggpubr::stat_compare_means(
      comparisons = my_comparisons,
      method = "wilcox.test",
      label = "p.signif",
      tip.length = 0.01,
      size = 4.5,
      vjust = 0.4,
      label.y = label_y
    ) +
    # 配色
    scale_fill_manual(values = color_scheme) +
    # 坐标轴与标题
    labs(
      x = "State",
      y = paste0(gene_name, " Expression"),
      title = paste0(gene_name, " Expression Across Cell States"),
      subtitle = paste("Reference group:", reference_group)
    ) +
    # 主题设置
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 15)),
      axis.title.x = element_text(size = 14, face = "bold", margin = margin(t = 10)),
      axis.title.y = element_text(size = 14, face = "bold", margin = margin(r = 10)),
      axis.text.x  = element_text(size = 12, face = "bold", color = "black"),
      axis.text.y  = element_text(size = 12, face = "bold", color = "black"),
      axis.line    = element_line(color = "black", size = 0.8),
      axis.ticks   = element_line(color = "black", size = 0.8),
      panel.grid.major = element_line(color = "grey90", size = 0.3),
      panel.grid.minor = element_blank(),
      legend.position  = "none",
      plot.background  = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      # 动态上边距（按"行数/lines"为单位）
      plot.margin = margin(t = 1 + 0.2 * n_comparisons, r = 1, b = 1, l = 1, unit = "lines")
    ) +
    coord_cartesian(ylim = c(y_min, plot_upper_limit), clip = "off")
  
  # ---- 保存 ----
  if (!is.null(output_file)) {
    ggsave(
      filename = output_file,
      plot = p,
      width = base_width + 0.5 * n_groups,     # 根据组数调整宽度
      height = base_height + 0.3 * n_comparisons, # 根据比较数量调整高度
      dpi = 300
    )
    message("已保存: ", output_file)
  }
  
  return(p)
}
