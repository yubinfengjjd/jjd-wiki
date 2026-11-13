mfuzz_plot <- function(eset, cl, mfrow = c(1,1), colo, min.mem = 0, time.labels, new.window = TRUE) {
	if (missing(colo)) {
		colo <- colorRampPalette(c("#2c7bb6", "#ffffbf", "#d7191c"))(100)
	}

	opar <- par(no.readonly = TRUE)
	on.exit(par(opar))
	par(mfrow = mfrow, mar = c(5, 5, 4, 2) + 0.1)

	centers <- cl$centers
	ncluster <- nrow(centers)

	if (missing(time.labels)) {
		time.labels <- colnames(eset)
	}

	for (i in 1:ncluster) {
		center <- centers[i, ]

		plot(1, type = "n",
				 xlim = c(1, length(center)),
				 ylim = range(centers),
				 xlab = "", ylab = "",
				 axes = FALSE,
				 main = paste0("Cluster ", i, " (", sum(cl$cluster == i), " pathways)"),
				 cex.main = 1.8, font.main = 2, col.main = "#333333")

		axis(1, at = 1:length(center), labels = time.labels,
				 cex.axis = 1.5, col.axis = "#333333", col = "gray70", lwd = 1.5)
		axis(2, cex.axis = 1.5, col.axis = "#333333", col = "gray70", lwd = 1.5)

		grid(NA, NULL, col = "gray90", lty = 1, lwd = 0.8)
		abline(h = 0, col = "gray70", lwd = 1.5)

		lines(1:length(center), center,
					col = "#2c3e50", lwd = 3.5, type = "o", pch = 19, cex = 1.5)

		cluster_members <- exprs(eset)[cl$cluster == i, , drop = FALSE]
		for (j in 1:nrow(cluster_members)) {
			lines(1:length(center), cluster_members[j, ],
						col = adjustcolor("#3498db", alpha.f = 0.5),
						lwd = 1.2)
		}

		mtext("Cell State", side = 1, line = 3.5, cex = 1.2, font = 2, col = "#333333")
		mtext("Standardized Activity", side = 2, line = 3.5, cex = 1.2, font = 2, col = "#333333")

		rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4],
				 col = adjustcolor("#f8f9fa", alpha.f = 0.5), border = NA)

		box(lwd = 2, col = "gray70")
	}
}
