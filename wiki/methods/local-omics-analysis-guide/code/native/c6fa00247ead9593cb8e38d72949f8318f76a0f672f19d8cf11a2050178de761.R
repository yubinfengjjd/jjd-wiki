plot_subtype_pathways <- function(plot_df, pathway_list, title,
																	subtype_col = "Monocle2_State",
																	code_prefix = "M",
																	legend_cols = 2,        # 说明面板列数
																	top_expand = 0.20,
																	legend_trunc = 50,      # 说明面板换行宽度（字符）
																	legend_replace_us = TRUE,
																	legend_text_size = 5,   # 说明面板字体
																	star_size = 6,          # 主图星号大小
																	legend_left_pad = 0.05, # ← 左侧"贴边"程度
																	legend_col_spacing = 1.6 # ← 列间水平间距
) {
	# 1) 短码映射
	code_map    <- setNames(paste0(code_prefix, seq_along(pathway_list)), pathway_list)
	levels_code <- unname(code_map[pathway_list])
	
	# 2) 整形为长表
	plot_data <- plot_df %>%
		select(all_of(pathway_list), all_of(subtype_col)) %>%
		tidyr::pivot_longer(cols = -all_of(subtype_col), 
												names_to = "Pathway", 
												values_to = "Score") %>%
		mutate(
			Pathway = factor(Pathway, levels = pathway_list),
			Code    = factor(code_map[Pathway], levels = levels_code),
			Subtype = factor(.data[[subtype_col]])
		)
	
	# 3) 每通路 Wilcoxon + 星号
	p_values <- sapply(pathway_list, function(p) {
		d <- dplyr::filter(plot_data, Pathway == p)
		out <- try(wilcox.test(Score ~ Subtype, data = d)$p.value, silent = TRUE)
		if (inherits(out, "try-error")) NA_real_ else out
	})
	
	sig_labels <- ifelse(p_values < 0.001, "***",
											 ifelse(p_values < 0.01,  "**",
											 			 ifelse(p_values < 0.05,  "*",  "")))
	
	sig_df <- data.frame(
		Code  = factor(unname(code_map[pathway_list]), levels = levels_code),
		label = sig_labels, 
		stringsAsFactors = FALSE
	)
	
	# 4) 主图
	y_min <- min(plot_data$Score, na.rm = TRUE)
	y_max <- max(plot_data$Score, na.rm = TRUE)
	y_lim <- c(y_min, y_max * (1 + top_expand))
	
	# 定义颜色方案
	fill_colors <- c("2" = "#E64B35", "1" = "#4DBBD5")
	color_colors <- c("2" = "#B71C1C", "1" = "#006064")
	
	p_main <- ggplot(plot_data, aes(x = Code, y = Score, fill = Subtype)) +
		geom_vline(xintercept = seq(1.5, length(levels_code) - 0.5), 
							 color = "gray70", linetype = "dashed", linewidth = 0.5) +
		gghalves::geom_half_violin(
			aes(fill = Subtype),
			position = position_dodge(0.8),
			side = "l", scale = "width",
			width = 0.7, alpha = 0.5, color = NA
		) +
		geom_boxplot(
			aes(color = Subtype),
			width = 0.3, position = position_dodge(0.8),
			outlier.shape = NA, notch = TRUE, notchwidth = 0.5,
			alpha = 0.8, linewidth = 0.6
		) +
		geom_point(
			aes(color = Subtype),
			position = position_jitterdodge(jitter.width = 0.15, dodge.width = 0.8),
			size = 0.4, alpha = 0.4
		) +
		geom_text(
			data = sig_df,
			aes(x = Code, y = y_lim[2] - 0.02 * diff(y_lim), label = label),
			inherit.aes = FALSE, size = star_size, vjust = 0.5, fontface = "bold"
		) +
		scale_fill_manual(values = fill_colors, name = "Group") +
		scale_color_manual(values = color_colors, name = "Group", guide = "none") +
		labs(title = title, x = "", y = "Pathway Activity Score") +
		theme_minimal(base_size = 13) +
		theme(
			axis.text.x = element_text(angle = 0, hjust = 0.5, face = "bold", 
																 size = 11, color = "#333333"),
			axis.text.y = element_text(face = "bold", size = 11, color = "#333333"),
			axis.title.y = element_text(face = "bold", size = 12, margin = margin(r = 10)),
			plot.title   = element_text(hjust = 0.5, size = 16, face = "bold", margin = margin(b = 8)),
			legend.position = "top",
			legend.title    = element_text(face = "bold", size = 12),
			legend.text     = element_text(size = 11),
			panel.grid.major.y = element_line(color = "grey92", linewidth = 0.6),
			panel.grid.minor   = element_blank(),
			panel.background  = element_rect(fill = "white", color = NA),
			plot.background   = element_rect(fill = "white", color = NA),
			panel.border      = element_rect(color = "grey80", fill = NA, linewidth = 0.8),
			plot.margin       = margin(10, 15, 5, 15)
		) +
		coord_cartesian(ylim = y_lim, clip = "off")
	
	# 5) 说明面板
	legend_map <- tibble(
		Pathway = pathway_list,
		Code    = unname(code_map[pathway_list])
	) %>%
		mutate(
			PrettyName = if (legend_replace_us) str_replace_all(Pathway, "_", " ") else Pathway,
			LabelFull  = paste0(Code, ": ", PrettyName),
			Label      = str_wrap(LabelFull, width = legend_trunc),
			idx        = row_number(),
			row        = ceiling(idx / legend_cols),
			col        = (idx - 1) %% legend_cols + 1,
			x          = (col - 1) * legend_col_spacing + legend_left_pad
		)
	
	x_right <- (legend_cols - 1) * legend_col_spacing + legend_left_pad + 1
	
	p_legend <- ggplot(legend_map, aes(x = x, y = row, label = Label)) +
		geom_text(hjust = 0, vjust = 1, size = legend_text_size, lineheight = 1.05) +
		scale_x_continuous(limits = c(0, x_right), expand = c(0, 0)) +
		scale_y_reverse(expand = c(0.18, 0.18)) +
		coord_cartesian(clip = "off") +
		theme_void(base_size = 12) +
		theme(
			panel.border = element_rect(color = "grey50", linetype = "dashed", fill = NA),
			plot.margin  = margin(0, 24, 10, 10)
		)
	
	# 组合图形
	ggpubr::ggarrange(p_main, p_legend, ncol = 1, heights = c(1, 0.30))
}
