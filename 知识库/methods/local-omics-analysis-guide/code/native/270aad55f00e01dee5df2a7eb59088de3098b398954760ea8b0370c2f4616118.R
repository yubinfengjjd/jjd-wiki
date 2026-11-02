plot_cluster_auc_with_density <- function(aucDF, clusters, outdir = ".") {
	if (!dir.exists(outdir)) dir.create(outdir)

	for (cluster_num in clusters) {
		cluster_data <- subset(aucDF, mclust == cluster_num)
		cluster_data$auc <- as.numeric(gsub("Area under the curve: ", "", cluster_data$auc))
		cluster_data <- cluster_data[order(-cluster_data$auc), ]
		cluster_data$rank <- 1:nrow(cluster_data)

		p_auc = ggplot(cluster_data, aes(x = auc, y = rank)) +
			geom_segment(
				aes(
					x = min(cluster_data$auc),
					xend = max(cluster_data$auc),
					y = 0,
					yend = 0
				),size = 2) +
			geom_ribbon(
				aes(ymin = 0, ymax = rank),
				fill = "#ffe7c5",
				alpha = 0.5
			) +
			geom_smooth(se = FALSE, color = "#eba85b", size = 2.5, span = 0.4) +
			geom_point(
				data = cluster_data[which.max(cluster_data$auc), ],
				aes(x = auc, y = 0),
				color = "#a3570b",
				size = 6
			) +
			annotate(
				"text",
				x = cluster_data[which.max(cluster_data$auc), "auc"],
				y = cluster_data[which.max(cluster_data$auc), "rank"]+0.03*nrow(cluster_data),
				label = round(max(cluster_data$auc), 4),
				color = "#a0570d",
				size = 6
			) +
			scale_y_continuous(
				trans = "reverse",
				expand = expansion(mult = c(0.05, 0.05))
			) +
			scale_x_continuous(
				limits = c(min(cluster_data$auc), max(cluster_data$auc) + 0.005),
				expand = c(0, 0)
			) +
			labs(
				x = "AUC Value",
				y = "Model Rank (Descending)",
				title = paste0("AUC Ranking of Cluster ",cluster_num," Models"),
				subtitle = paste0(nrow(cluster_data),"Models Ordered by AUC (Highest to Lowest)")
			) +
			theme_minimal() +
			theme(
				plot.background = element_blank(),
				panel.grid = element_blank(),
				panel.border = element_rect(color = "black", size = 2, fill = NA),
				axis.text = element_text(color = "black"),
				plot.title = element_text(hjust = 0.5, face = "bold"),
				plot.subtitle = element_text(hjust = 0.5, color = "grey40")
			)

		dens <- density(cluster_data$auc)
		ridge_df <- data.frame(x = dens$x, height = dens$y, y = 1)

		p_ridge <- ggplot(ridge_df, aes(x = x, y = y, height = height)) +
			geom_ridgeline(fill = "grey80", color = "grey40", alpha = 0.7, scale = 0.9) +
			annotate("text",
							 x = min(cluster_data$auc), y = 1.2,
							 label = paste0(nrow(cluster_data), " models"),
							 hjust = 0, size = 4.5, fontface = "bold"
			) +
			theme_void() +
			theme(
				plot.margin = margin(0, 0, 0, 0),
				panel.border = element_blank()
			)

		final_plot <- p_ridge + p_auc + plot_layout(ncol = 2, widths = c(2, 4))

		ggsave(
			filename = file.path(outdir, paste0("cluster_auc_C", cluster_num, ".pdf")),
			plot = final_plot,
			width = 6, height = 8
		)
	}
}
