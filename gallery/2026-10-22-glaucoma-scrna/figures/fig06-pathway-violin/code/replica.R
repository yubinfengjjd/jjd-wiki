# Replay entry for the grouped violin + box + jitter panel.
# Data are synthetic and are not original GSE251716 observations.
suppressPackageStartupMessages({
  library(ggplot2)
  library(svglite)
})

source("code/core.R")

df <- read.csv("data/estimated_data.csv", stringsAsFactors = FALSE)
summ <- read.csv("data/estimated_summaries.csv", stringsAsFactors = FALSE)
celltype_levels <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)

p <- plot_grouped_violin(
  df = df,
  summaries = summ,
  celltype_levels = celltype_levels,
  group_levels = c("Control", "Glaucoma"),
  color_scheme = c("#FF7F0E", "#1F77B4"),
  title = "Complement Pathway Score Comparison",
  ylab = "Pathway Score",
  base_family = "sans"
)

dir.create("output", showWarnings = FALSE)
ggsave("output/replica.png", p, width = 12, height = 6.5, dpi = 192, bg = "white")
ggsave("output/replica.pdf", p, width = 12, height = 6.5, device = cairo_pdf, bg = "white")
ggsave("output/replica.svg", p, width = 12, height = 6.5, device = svglite::svglite, bg = "white")
cat("Wrote output/replica.png, replica.pdf, replica.svg\n")
