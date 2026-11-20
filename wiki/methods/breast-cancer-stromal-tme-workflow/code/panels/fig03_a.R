# Panel ID: fig03/A (Fig. 3 3A)
# Title: 35x35 clustered bulk TME correlation matrix with diagonal module boxes and staggered labels.
# Evidence tier: proxy
# Input tables: data_small/moesm/corr_bulk.csv, extracted/pages/main_p06.png
# Default dimensions: width = 6.4 in, height = 4.8 in
# Usage: Rscript --vanilla code/panels/fig03_a.R --paper-root <PAPER_ROOT> --out fig03_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig03_a.png', default_width = 6.4, default_height = 4.8)
page <- png::readPNG(file.path(paper_dir, "extracted/pages/main_p06.png"))
left_labels <- c("C13_lpFib_LUM", "CD8T_Tex", "C7_lpFib_APOD", "C12_apFib_CD74", "Endothelial_cell",
  "C4_iFib_BNC2", "CD4T_memory", "C5_iFib_CXCL8", "Naive_T", "B_cell", "NK", "C2_ifnFib_HSPA6",
  "NKT", "mDC", "T_Ki67", "C14_tFib_A2M", "C11_tFib_ENO1")
right_labels <- c("Cancer_cell", "Mural_cell", "C10_lpFib_ABCA8", "Mono_FCN1", "C1_mFib_ACTA2",
  "CD8T_effector", "CD4T_Treg", "M1", "CD4_Tfh", "pDC", "C8_iFib_CCL19", "C3_lpFib_PLA2G2A",
  "Mast_cell", "C9_mFib_COL12A1", "Mono_IL1B", "cDC2", "CD8T_memory", "M2")
n <- length(left_labels) + length(right_labels)
labels <- character(n)
labels[seq(1, n, 2)] <- right_labels
labels[seq(2, n, 2)] <- left_labels
bulk <- read_input("data_small", "moesm", "corr_bulk.csv")
bulk_aliases <- c(CD8T_Tex = "CD8_Exhausted_T", CD8T_effector = "CD8_Cytotoxic_T",
                  CD4T_Treg = "Regulatory.T", Mast_cell = "Mast")
aliases <- labels
aliases[labels %in% names(bulk_aliases)] <- bulk_aliases[labels[labels %in% names(bulk_aliases)]]
palette_table <- sapply(1:3, function(i) rowMeans(page[127:399, 154:159, i]))
palette_values <- seq(1, -1, length.out = nrow(palette_table))
cell_centers <- function(start, end) start + (seq_len(n) - .5) * (end - start) / n
x_centers <- round(cell_centers(165, 441))
y_centers <- round(cell_centers(125, 401))
distance <- function(rgb) rowSums(sweep(palette_table, 2, rgb)^2)
decode <- function(x, y) {
  sample_rgb <- apply(page[(y - 1):(y + 1), (x - 1):(x + 1), 1:3, drop = FALSE], 3, median)
  palette_values[which.min(distance(sample_rgb))]
}
corr <- outer(y_centers, x_centers, Vectorize(function(y, x) decode(x, y)))
corr <- (corr + t(corr)) / 2
diag(corr) <- 1
anchor <- match("C10_lpFib_ABCA8", labels)
matched <- match(aliases, bulk$celltype)
exact <- !is.na(matched)
corr[anchor, exact] <- corr[exact, anchor] <- bulk$C10_lpFib_ABCA8[matched[exact]]
heat <- expand.grid(y = seq_len(n), x = seq_len(n))
heat$value <- as.vector(corr)
bounds <- data.frame(start = c(2, 8, 16, 22, 26) - .5, end = c(7, 15, 21, 25, 28) + .5)
A_plot <- ggplot(heat, aes(x, y)) +
  geom_tile(aes(fill = value)) +
  geom_rect(data = bounds, aes(xmin = start, xmax = end, ymin = start, ymax = end),
            inherit.aes = FALSE, fill = NA, colour = "#202020", linewidth = .48) +
  annotate("segment", x = n + .70, xend = n + c(rep(1.25, 17), rep(10.65, 18)),
           y = c(seq(2, n, 2), seq(1, n, 2)), yend = c(seq(2, n, 2), seq(1, n, 2)),
           linetype = "dashed", linewidth = .18) +
  annotate("text", x = n + 1.35, y = seq(2, n, 2), label = left_labels, hjust = 0, size = 1.86) +
  annotate("text", x = n + 10.72, y = seq(1, n, 2), label = right_labels, hjust = 0, size = 1.86) +
  scale_fill_gradientn(colours = rev(corr_cols), limits = c(-1, 1), name = NULL, breaks = seq(-1, 1, .2)) +
  scale_y_reverse() +
  coord_fixed(xlim = c(.5, 55), ylim = c(.5, n + .5), expand = FALSE, clip = "off") +
  guides(fill = guide_colourbar(barwidth = grid::unit(2.05, "mm"), barheight = grid::unit(55, "mm"),
                                theme = theme(legend.text.position = "left"))) +
  labs(subtitle = "Bulk r  |  Published matrix color-read; available ABCA8 pairs exact") +
  theme_void(base_size = 7) +
  theme(legend.position = "left", legend.text = element_text(size = 5.5),
        legend.margin = margin(0, 1, 0, 0), legend.spacing.x = grid::unit(1, "mm"),
        plot.subtitle = element_text(size = 5.8, margin = margin(b = 4)), plot.margin = margin(13, 6, 4, 7))
p <- panel_tag(A_plot, "A")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
