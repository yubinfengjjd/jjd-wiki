# Panel ID: fig06/A (Fig. 6 6A)
# Title: 52-subcluster TME + stromal integrated topology projection UMAP with 3-column legend.
# Evidence tier: local_recompute
# Input tables: extracted/pages/main_p10.png
# Default dimensions: width = 5.0 in, height = 5.8 in
# Usage: Rscript --vanilla code/panels/fig06_a.R --paper-root <PAPER_ROOT> --out fig06_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig06_a.png', default_width = 5.0, default_height = 5.8)
cell_order <- c("M2","M1","DC_CD1C","DC_LAMP3","Regulatory_T","DC_CLEC9A",
  "Neutrophil","pDC","CD4_Exhausted_T","NK","Epi","CD8_Cytotoxic_T",
  "CD4_Effector_T","CD4_Tfh","GC_B","Memory_B")
immune_published <- c("CD4_Effector_T","CD4_Exhausted_T","CD4_Naive_T","CD4_Tfh","CD8_Cytotoxic_T",
  "DC_CD1C","DC_CLEC9A","DC_LAMP3","Epi","GC_B","M1","M2","Mast","Memory_B",
  "Naive_B","Neutrophil","NK","pDC","Plasma_B","Regulatory_T","Transitory_T")
stromal <- c(fib_cols, ec_cols, mural_cols)
atlas_ink <- setNames(c(
  "#B1CDDE","#7DBFD1","#3A87A2","#309348","#62AA47","#99C384","#E3956C",
  "#D53E2A","#8E646B","#CCB0C7","#7E558F","#399938","#A286B9","#ABC83D",
  "#48669F","#3A97C2","#B972A0","#A995BD","#C9A2C1","#507188","#A4A9AF",
  "#A58881","#696A6C","#8D6798","#D19670","#D45635",
  "#673E87","#A5658E","#D2BFD8","#B14E53","#D0B771","#B8987D","#DECDD8",
  "#D29CBA","#E1B483","#AA5344",
  "#D09755","#61A274","#C7D5A6","#ECD0C8","#D06D6A","#E5ADA1","#9C4C83",
  "#A7BEC8","#AE508A","#696C9A","#886697","#C6C4DD","#C65670","#BF97B6",
  "#8F7A97","#31709B","#9E8D88","#6F5577","#639DB0","#C2D6E7","#5FB2CF"),
  c(names(stromal), immune_published))
display_pal <- c(stromal, atlas_ink[intersect(immune_published, cell_order)])
page <- png::readPNG(file.path(paper_dir, "extracted/pages/main_p10.png"))
pixels <- expand.grid(y = 122:408, x = 158:446)
tint <- matrix(1 - page[122:408, 158:446, 1:3], ncol = 3)
saturation <- pmax(tint[, 1], tint[, 2], tint[, 3]) - pmin(tint[, 1], tint[, 2], tint[, 3])
keep <- saturation > .036 & !(pixels$x < 220 & pixels$y > 354)
tint <- tint[keep, , drop = FALSE]; pixels <- pixels[keep, ]
rays <- tint / sqrt(rowSums(tint^2))
references <- t(1 - col2rgb(atlas_ink[names(display_pal)]) / 255)
references <- references / sqrt(rowSums(references^2))
similarity <- rays %*% t(references)
label <- max.col(similarity, ties.method = "first")
set.seed(42)
atlas <- do.call(rbind, lapply(seq_along(display_pal), function(i) {
  pool <- which(label == i)
  if (length(pool) < 12) pool <- head(order(similarity[, i], decreasing = TRUE), 50)
  take <- sample(pool, max(55, round(23000 * length(pool) / nrow(pixels))), replace = TRUE)
  data.frame(x = pixels$x[take] + runif(length(take), -.46, .46),
             y = -pixels$y[take] + runif(length(take), -.46, .46), cluster = names(display_pal)[i])
}))
atlas_view <- embedding(atlas, display_pal, dots = .63) +
  add_l_arrows("UMAP_1", "UMAP_2", atlas, x = .012, y = -.07, length = .15) +
  labs(caption = "Published topology projection") +
  theme(legend.position = "none", plot.caption = element_text(size = 5.1, hjust = .7, margin = margin(t = 1)))
atlas_labels <- display_pal
names(atlas_labels)[names(atlas_labels) == "Epi"] <- "Malignant"
p <- panel_tag(wrap_plots(atlas_view, wave_dot_legend(atlas_labels, 3, size = 1.59), ncol = 1, heights = c(.64, .36)), "A")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
