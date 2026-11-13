# Replay entry for the top-journal bubble dot plot.
# Data are synthetic and are not original GSE251716 observations.
suppressPackageStartupMessages({
  library(ggplot2)
  library(svglite)
})

source("code/core.R")

df <- read.csv("data/estimated_data.csv", stringsAsFactors = FALSE)
x_levels <- c(
  "Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor",
  "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"
)

features <- unique(df$feature)
target <- df$target_group[match(features, df$feature)]
target_pos <- match(target, x_levels)
y_levels <- features[order(target_pos, seq_along(features), na.last = TRUE)]

p <- plot_dotplot_bubble(
  df,
  x_levels = x_levels,
  y_levels = y_levels,
  plot_width = 6,
  plot_height = 12,
  base_family = "sans"
)

dir.create("output", showWarnings = FALSE)
ggsave("output/replica.png", p, width = 6, height = 12, dpi = 192, bg = "white")
ggsave("output/replica.pdf", p, width = 6, height = 12, device = cairo_pdf, bg = "white")
ggsave("output/replica.svg", p, width = 6, height = 12, device = svglite::svglite, bg = "white")
cat("Wrote output/replica.png, replica.pdf, replica.svg\n")
