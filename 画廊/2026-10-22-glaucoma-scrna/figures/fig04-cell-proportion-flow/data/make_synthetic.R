# Synthetic cell-type proportions for the stacked-bar + flow-ribbon style.
# These are not original GSE251716 observations.
celltypes <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)
control <- c(0.25, 0.22, 0.27, 0.08, 0.05, 0.02, 0.07, 0.02, 0.02)
glaucoma <- c(0.27, 0.25, 0.30, 0.05, 0.03, 0.02, 0.05, 0.02, 0.01)

df <- data.frame(
  group = rep(c("Control", "Glaucoma"), each = length(celltypes)),
  celltype = rep(celltypes, times = 2),
  proportion = c(control / sum(control), glaucoma / sum(glaucoma)),
  stringsAsFactors = FALSE
)
write.csv(df, "data/estimated_data.csv", row.names = FALSE)
cat("Wrote", nrow(df), "rows; sums:",
    tapply(df$proportion, df$group, sum), "\n")
