plot_correlation <- function(results_df, title, filename) {
	# Remove NA values
	results_df <- na.omit(results_df)

	# Add grouping based on significance
	results_df <- results_df %>%
		mutate(group = ifelse(
			abs(Correlation_scores) > 0.2 & P_Value_scores < 0.05,
			"High",
			"Low"
		))

	# Calculate overall Spearman correlation
	cor_test <- suppressWarnings(
		cor.test(
			abs(results_df$Correlation_scores),
			abs(results_df$Correlation_phenotype),
			method = "spearman",
			exact = FALSE
		)
	)

	# Format label
	cor_label <- sprintf(
		"Spearman's rho = %.2f\np = %s",
		cor_test$estimate,
		ifelse(cor_test$p.value < 0.001,
					 "< 0.001",
					 format(cor_test$p.value, digits = 2))
	)

	# Create plot
	p <- ggplot(results_df, aes(x = abs(Correlation_scores), y = abs(Correlation_phenotype), color = group)) +
		geom_point(size = 3.5, alpha = 0.8) +
		geom_smooth(
			method = "lm",
			color = "#5b82a0",
			linetype = "solid",
			size = 1.5,
			se = TRUE,
			fill = "#5a5676",
			alpha = 0.3
		) +
		scale_color_manual(values = c("#0c695e", "#b81b23")) +
		geom_vline(xintercept = 0.2, linetype = "dotted", color = "grey60", size = 1) +
		annotate("text",
						 x = min(abs(results_df$Correlation_scores)) + 0.1,
						 y = max(abs(results_df$Correlation_phenotype)) - 0.05,
						 label = cor_label, hjust = 0, color = "black", size = 5) +
		labs(
			title = title,
			x = "Correlation with Scores",
			y = "Correlation with Phenotype"
		) +
		theme_bw(base_size = 14) +
		theme(
			legend.position = "none",
			panel.grid.major = element_blank(),
			panel.grid.minor = element_blank(),
			panel.border = element_rect(color = "black", size = 1.2),
			plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
			axis.title = element_text(size = 14),
			axis.text = element_text(size = 12)
		)

	# Save plot
	ggsave(paste0(filename, ".pdf"), p, width = 8, height = 7, dpi = 300)
	return(p)
}
