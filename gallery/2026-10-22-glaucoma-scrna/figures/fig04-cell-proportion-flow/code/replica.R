# Replay entry for the cell-proportion stacked bars with flow ribbons.
# Data are synthetic and are not original GSE251716 observations.
suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(svglite)
})

source("code/core.R")

df <- read.csv("data/estimated_data.csv", stringsAsFactors = FALSE)
x_levels <- c("Control", "Glaucoma")
stack_levels <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)
palette <- c(
  "#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F",
  "#8491B4", "#91D1C2", "#DC0000", "#7E6148"
)

p <- plot_cellprop_flow(
  data = df,
  x_levels = x_levels,
  stack_levels = stack_levels,
  legend_levels = rev(stack_levels),
  palette = palette,
  y_lab = "Cell proportion",
  legend_title = "Cell type",
  base_family = "sans"
)

dir.create("output", showWarnings = FALSE)
ggsave("output/replica.png", p, width = 5.5, height = 4.5, dpi = 192, bg = "white")
ggsave("output/replica.pdf", p, width = 5.5, height = 4.5, device = cairo_pdf, bg = "white")
ggsave("output/replica.svg", p, width = 5.5, height = 4.5, device = svglite::svglite, bg = "white")
cat("Wrote output/replica.png, replica.pdf, replica.svg\n")
