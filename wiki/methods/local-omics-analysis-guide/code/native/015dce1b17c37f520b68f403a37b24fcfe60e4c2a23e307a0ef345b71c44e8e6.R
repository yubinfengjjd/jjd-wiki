plot_with_statistics <- function(data,
																 x_col = "Variable1",
																 y_col = "Variable2",
																 color_palette = c("#440154FF", "#3B528BFF", "#21908CFF", "#5DC863FF", "#FDE725FF"),
																 show_fit_line = FALSE,
																 text_size = 14,
																 line_size = 0.5) {

	library(ggplot2)
	library(ggpubr)
	library(ggpointdensity)

	p <- ggplot(data = data,
							mapping = aes_string(x = x_col, y = y_col)) +
		geom_pointdensity(size = 4) +
		scale_color_gradientn(colors = color_palette) +
		theme_classic(base_size = text_size) +
		labs(x = x_col, y = y_col) +
		theme(
			axis.title = element_text(size = text_size, face = "bold"),
			axis.text = element_text(size = text_size - 2, face = "bold")
		)

	if (show_fit_line) {
		p <- p +
			geom_smooth(method = "lm", formula = y ~ x, color = "black", size = line_size) +
			stat_cor(
				method = "spearman",
				aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~")),
				label.x = -1,
				size = text_size / 2.8,
				fontface = "bold"
			)
	}

	return(p)
}
