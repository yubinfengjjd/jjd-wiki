plot_state_violin <- function(
    data, colname, state_col = "Monocle2_State",
    reference_group = NULL,  # 新增参考组参数
    output_prefix = "state_violin",
    base_width = 6, base_height = 6
) {
  # 构建绘图数据
  plot_data <- data.frame(
    Expression = data[[colname]],
    Subtype = factor(data[[state_col]])
  )
  colnames(plot_data) <- c("Expression", "Subtype")
  
  state_types <- levels(plot_data$Subtype)
  n_groups <- length(state_types)
  color_scheme <- pal_npg("nrc")(n_groups)
  
  # 确定参考组（新增逻辑）
  if(is.null(reference_group)) {
    reference_group <- tail(state_types, 1)  # 默认使用最后一组
  } else if(!reference_group %in% state_types) {
    stop("指定的参考组 '", reference_group, "' 不存在于数据中。可用组别: ", 
         paste(state_types, collapse = ", "))
  }
  
  # 动态统计和图边距设置
  y_range <- range(plot_data$Expression, na.rm = TRUE)
  y_min <- y_range[1]; y_max <- y_range[2]; range_diff <- diff(y_range)
  
  # 生成比较组合：所有非参考组 vs 参考组
  other_groups <- setdiff(state_types, reference_group)
  comps <- lapply(other_groups, function(x) c(x, reference_group))
  n_comparisons <- length(comps)
  
  label_y_step <- range_diff * 0.08
  label_y_start <- y_max + label_y_step
  label_y <- label_y_start + label_y_step * (0:(n_comparisons - 1))
  plot_upper_limit <- y_max + (n_comparisons + 1) * label_y_step
  
  # 绘图
  p <- ggplot(plot_data, aes(x = Subtype, y = Expression, fill = Subtype)) +
    gghalves::geom_half_boxplot(side = "l", notch = TRUE,
                                outlier.shape = NA, width = 0.35,
                                alpha = 0.8, color = "black", lwd = 0.6, center = TRUE) +
    gghalves::geom_half_point(side = "l", shape = 21,
                              color = "black", stroke = 0.25,
                              size = 1.4, alpha = 0.6,
                              position = position_nudge(x = 0.09),
                              transformation = position_jitter(width = 0.05, height = 0),
                              range_scale = 0.9) +
    gghalves::geom_half_violin(side = "r", color = "black", lwd = 0.6, alpha = 0.7,
                               trim = TRUE, scale = "width", width = 0.35,
                               position = position_nudge(x = 0.10)) +
    stat_summary(fun = median, geom = "errorbar",
                 aes(ymax = ..y.., ymin = ..y..),
                 width = 0.25, color = "black", linetype = "solid", size = 1.2,
                 position = position_nudge(x = 0.08)) +
    ggpubr::stat_compare_means(comparisons = comps,
                               method = "wilcox.test",
                               label = "p.signif",
                               tip.length = 0.01,
                               size = 4.5,
                               vjust = 0.4,
                               label.y = label_y) +
    scale_fill_manual(values = color_scheme) +
    labs(
      x = "State",
      y = colname,
      title = paste(colname, "across cell states"),
      subtitle = paste("Reference group:", reference_group)  # 显示参考组
    ) +
    theme_minimal(base_size = 14) +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 15)),
      axis.title.x = element_text(size = 14, face = "bold", margin = margin(t = 10)),
      axis.title.y = element_text(size = 14, face = "bold", margin = margin(r = 10)),
      axis.text.x = element_text(size = 12, face = "bold", color = "black"),
      axis.text.y = element_text(size = 12, face = "bold", color = "black"),
      axis.line = element_line(color = "black", size = 0.8),
      axis.ticks = element_line(color = "black", size = 0.8),
      panel.grid.major = element_line(color = "grey90", size = 0.3),
      panel.grid.minor = element_blank(),
      legend.position = "none",
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(t = 1 + 0.2 * n_comparisons,
                           r = 1, b = 1, l = 1, unit = "lines")
    ) +
    coord_cartesian(ylim = c(y_min, plot_upper_limit), clip = "off")
  
  # 保存图
  filename <- paste0(output_prefix, "_", colname, ".pdf")
  ggsave(filename, plot = p,
         width = base_width + 0.5 * n_groups,
         height = base_height + 0.3 * n_comparisons,
         dpi = 300)
  
  return(p)
}
