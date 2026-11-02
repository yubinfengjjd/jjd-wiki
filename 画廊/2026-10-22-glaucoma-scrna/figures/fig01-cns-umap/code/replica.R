# Replay entry for the CNS-style UMAP panel.
# Data are synthetic and are not original GSE251716 observations.
suppressPackageStartupMessages({
  library(ggplot2)
  library(ggunchull)
  library(grid)
  library(svglite)
})

source("code/core.R")

df <- read.csv("data/estimated_data.csv", stringsAsFactors = FALSE)
group_levels <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)

p <- plot_cns_umap(df, group_levels = group_levels, family = "sans")

dir.create("output", showWarnings = FALSE)
ggsave("output/replica.png", p, width = 9, height = 7, dpi = 192, bg = "white")
ggsave("output/replica.pdf", p, width = 9, height = 7, device = cairo_pdf, bg = "white")
ggsave("output/replica.svg", p, width = 9, height = 7, device = svglite::svglite, bg = "white")
cat("Wrote output/replica.png, replica.pdf, replica.svg\n")
