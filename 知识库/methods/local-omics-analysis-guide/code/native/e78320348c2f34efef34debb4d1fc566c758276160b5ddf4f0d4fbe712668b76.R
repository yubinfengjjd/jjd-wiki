generate_violin_with_p <- function(df_one, metabolite_label){
	if (nrow(df_one) < 2 || nlevels(df_one$type) < 2) return(invisible(NULL))
	# 取差异分析p
	pval <- unname(p_map[metabolite_label])
	y_top <- max(df_one$count, na.rm = TRUE)
	p_lab <- ifelse(is.na(pval), "p = NA", paste0("p = ", formatC(pval, format="e", digits=2)))
	
	p <- ggplot(df_one, aes(x = type, y = count, fill = type)) +
		scale_fill_manual(values = setNames(unname(color_palette), c(control_name, treat_name))) +
		geom_violin(alpha = 0.4, position = position_dodge(width = .75),
								linewidth = 0.8, color = "black") +
		geom_boxplot(notch = TRUE, outlier.size = -1, linewidth = 0.8,
								 alpha = 0.7, color = "black",
								 position = position_dodge(width = .75)) +
		geom_point(shape = 21, size = 2, color = "black",
							 position = position_jitterdodge(dodge.width = .75)) +
		scale_x_discrete(drop = FALSE) +
		annotate("text", x = 1.5, y = y_top * 1.08, label = p_lab, size = 4.5) +
		expand_limits(y = y_top * 1.12) +
		theme_bw() +
		labs(title = metabolite_label, x = "", y = "Abundance") +
		theme(
			panel.background  = element_blank(),
			panel.grid        = element_blank(),
			axis.text.x       = element_text(size = 8, color = "black"),
			axis.text.y       = element_text(size = 8, color = "black"),
			axis.title        = element_text(size = 8),
			axis.ticks        = element_line(linewidth = 0.2, color = "black"),
			axis.ticks.length = unit(0.2, "cm"),
			legend.position   = "none",
			plot.title        = element_text(face = "bold", hjust = 0.5)
		)
	
	fn <- file.path("Results", paste0(gsub("[^A-Za-z0-9_]+","_", metabolite_label), "_violin.pdf"))
	ggsave(fn, p, width = 4, height = 6)
	message("Saved: ", fn)
}
