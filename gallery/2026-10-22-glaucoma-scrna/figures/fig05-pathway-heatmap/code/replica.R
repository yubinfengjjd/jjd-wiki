# Replay entry for the CNS-style pathway heatmap.
# Data are synthetic and are not original GSE251716 observations.
suppressPackageStartupMessages({
  library(ComplexHeatmap)
  library(circlize)
  library(grid)
  library(svglite)
})

source("code/core.R")

df <- read.csv("data/estimated_data.csv", stringsAsFactors = FALSE)
cols <- read.csv("data/estimated_columns.csv", stringsAsFactors = FALSE)

mat <- as.matrix(xtabs(value ~ pathway + column_id, data = df))
mat <- mat[, cols$column_id, drop = FALSE]
celltype_vec <- stats::setNames(cols$celltype, cols$column_id)
anno1_vec <- stats::setNames(cols$condition, cols$column_id)

rownames(mat) <- gsub("_", " ", rownames(mat))

plot_one <- function() {
  plot_pathway_heatmap_cns(
    mat = mat,
    celltype = celltype_vec,
    sample_anno1 = anno1_vec,
    celltype_order = unique(cols$celltype),
    anno1_name = "Condition",
    anno1_colors = c(Control = "#71ad96", Glaucoma = "#5d5c84"),
    scale_rows = TRUE,
    show_panel_label = FALSE,
    show_column_names = FALSE,
    column_title_rot = 45,
    row_names_fontsize = 10,
    column_title_fontsize = 9,
    heatmap_width = unit(10.5, "cm"),
    heatmap_height = unit(4.5, "cm"),
    legend_side = "left",
    annotation_legend_side = "left"
  )
}

dir.create("output", showWarnings = FALSE)
png("output/replica.png", width = 10, height = 4.4, units = "in", res = 192, bg = "white")
plot_one()
dev.off()
pdf("output/replica.pdf", width = 10, height = 4.4, useDingbats = FALSE)
plot_one()
dev.off()
svglite::svglite("output/replica.svg", width = 10, height = 4.4, bg = "white")
plot_one()
dev.off()
cat("Wrote output/replica.png, replica.pdf, replica.svg\n")
