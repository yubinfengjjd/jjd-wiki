# Replay entry for the 3x3 marker feature UMAP grid.
# Data are synthetic and are not original GSE251716 observations.
suppressPackageStartupMessages({
  library(ggplot2)
  library(ggunchull)
  library(patchwork)
  library(cowplot)
  library(grid)
  library(svglite)
})

source("code/core.R")

coords <- read.csv("data/estimated_coordinates.csv", stringsAsFactors = FALSE)
expr <- read.csv("data/estimated_expression.csv", stringsAsFactors = FALSE)

genes <- c("Pou4f1", "Gad1", "Onecut1", "Vsx2", "Rho", "Opn1mw", "Glul", "Rpe65", "Pdgfrb")
gene_to_group <- c(
  Pou4f1 = "RGC_like",
  Gad1 = "Amacrine",
  Onecut1 = "Amacrine_Horizontal_like",
  Vsx2 = "Bipolar",
  Rho = "Rod_Photoreceptor",
  Opn1mw = "Cone_Photoreceptor",
  Glul = "Muller_Glia",
  Rpe65 = "RPE",
  Pdgfrb = "Vascular_Pericyte"
)

plots <- plot_feature_umap_grid(
  coords = coords,
  expr_long = expr,
  genes = genes,
  gene_to_group = gene_to_group,
  ncol = 3,
  family = "sans",
  return_list = TRUE
)
p <- cowplot::plot_grid(plotlist = plots, ncol = 3, align = "hv")

dir.create("output", showWarnings = FALSE)
ggsave("output/replica.png", p, width = 11, height = 10, dpi = 192, bg = "white")
ggsave("output/replica.pdf", p, width = 11, height = 10, device = cairo_pdf, bg = "white")
ggsave("output/replica.svg", p, width = 11, height = 10, device = svglite::svglite, bg = "white")
cat("Wrote output/replica.png, replica.pdf, replica.svg\n")
