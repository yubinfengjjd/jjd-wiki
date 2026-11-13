# Synthetic cell-level pathway scores for the grouped violin style.
# These are not original GSE251716 observations.
set.seed(20261022)

celltypes <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)
groups <- c("Control", "Glaucoma")
mean_ctrl <- c(0.21, 0.13, 0.01, 0.16, 0.02, 0.32, 0.34, 0.05, 0.12)
mean_glc  <- c(0.21, 0.13, 0.00, 0.16, 0.02, 0.33, 0.30, 0.05, 0.03)
sd_ctrl <- c(0.08, 0.07, 0.07, 0.07, 0.09, 0.10, 0.10, 0.06, 0.04)
sd_glc  <- c(0.10, 0.07, 0.07, 0.07, 0.09, 0.12, 0.15, 0.06, 0.02)

n_per <- 80
rows <- list()
for (i in seq_along(celltypes)) {
  for (j in seq_along(groups)) {
    mu <- if (j == 1) mean_ctrl[i] else mean_glc[i]
    sdv <- if (j == 1) sd_ctrl[i] else sd_glc[i]
    rows[[length(rows) + 1]] <- data.frame(
      celltype = celltypes[i],
      group = groups[j],
      value = pmax(rnorm(n_per, mu, sdv), -0.20),
      stringsAsFactors = FALSE
    )
  }
}
df <- do.call(rbind, rows)

summ <- list()
for (ct in celltypes) {
  sub <- df[df$celltype == ct, , drop = FALSE]
  p <- stats::wilcox.test(value ~ group, data = sub)$p.value
  p_label <- if (p < 0.001) "P < 0.001" else sprintf("P = %.3f", p)
  for (g in groups) {
    vals <- sub$value[sub$group == g]
    summ[[length(summ) + 1]] <- data.frame(
      celltype = ct,
      group = g,
      mean = mean(vals),
      sd = stats::sd(vals),
      p_value = p,
      p_label = p_label,
      p_y = max(sub$value) * 1.10,
      mean_y = as.numeric(stats::quantile(vals, 0.90)),
      mean_sd_label = sprintf("Mean: %.2f\nSD: %.2f", mean(vals), stats::sd(vals)),
      stringsAsFactors = FALSE
    )
  }
}
summ <- do.call(rbind, summ)

write.csv(df, "data/estimated_data.csv", row.names = FALSE)
write.csv(summ, "data/estimated_summaries.csv", row.names = FALSE)
cat("Wrote", nrow(df), "cell-level values and", nrow(summ), "summary rows\n")
