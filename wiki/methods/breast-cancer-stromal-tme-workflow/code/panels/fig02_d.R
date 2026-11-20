# Panel ID: fig02/D (Fig. 2 2D)
# Title: Fibroblast chemokine, MHC-I, and MHC-II Z-score heatmap overlaid with published DEG open circles.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_fib.csv, runs/step02_progeny_roe_cox/chemokine_zscore_fib.csv, data_small/moesm/deg_fib.csv, data_small/scrna_stromal_small.qs
# Default dimensions: width = 7.2 in, height = 4.0 in
# Usage: Rscript --vanilla code/panels/fig02_d.R --paper-root <PAPER_ROOT> --out fig02_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_d.png', default_width = 7.2, default_height = 4.0)
fib <- read_step("step01_harmony_de", "umap_fib")
chem <- read_step("step02_progeny_roe_cox", "chemokine_zscore_fib")
desired <- list(
  Chemokines = c("CCL14", "CCL2", "CCL3", "CCL17", "CCL20", "CCL26", "CCL1", "CXCL13", "CCL11", "CXCL11",
    "CXCL10", "CCL19", "CXCL9", "CXCL8", "CXCL1", "CXCL3", "CXCL2", "CXCL6", "CXCL12", "CXCL5",
    "CCL3L1", "CCL28", "XCL1", "CCL16", "CCL8", "CCL7", "CCL21", "CCL22", "CCL15", "CCL5",
    "CCL13", "CCL23", "CCL27", "CCL24"),
  "MHC-I" = c("HLA-A", "HLA-B", "HLA-C", "HLA-E", "HLA-F", "HLA-G", "B2M", "MICA", "MICB"),
  "MHC-II" = c("HLA-DRB5", "HLA-DOA", "HLA-DOB", "HLA-DQA1", "HLA-DQB2", "HLA-DRA", "HLA-DRB1", "HLA-DPA1", "HLA-DPB1")
)
deg <- read_input("data_small", "moesm", "deg_fib.csv")
deg$canonical <- canonical_cluster(deg$cluster, fib_cols)
srt <- qs::qread(file.path(paper_dir, "data_small/scrna_stromal_small.qs"), nthreads = 1)
counts <- as.matrix(SeuratObject::GetAssayData(srt, layer = "counts"))
available <- unique(c(chem$gene, rownames(counts), deg$gene))
desired$Chemokines <- unique(c(desired$Chemokines, grep("^(CCL|CXCL|CX3CL|XCL)[0-9]+[A-Z0-9]*$", available, value = TRUE)))
desired[["MHC-II"]] <- unique(c(desired[["MHC-II"]], grep("^HLA-D[MRQOP][AB][0-9]*$", available, value = TRUE)))
candidates <- unique(unlist(desired, use.names = FALSE))
present <- intersect(setdiff(candidates, chem$gene), rownames(counts))
expr <- log1p(sweep(counts[present, fib$cell, drop = FALSE], 2, colSums(counts)[fib$cell], "/") * 1e4)
means <- vapply(names(fib_cols), function(cl) rowMeans(expr[, fib$canonical_subcluster == cl, drop = FALSE]), numeric(length(present)))
z <- matrix(NA_real_, nrow = length(candidates), ncol = length(fib_cols), dimnames = list(candidates, names(fib_cols)))
if (length(present)) {
  zz <- t(scale(t(means)))
  zz[!is.finite(zz)] <- NA_real_
  z[present, ] <- zz
}
reported <- intersect(candidates, chem$gene)
z[reported, ] <- as.matrix(chem[match(reported, chem$gene), names(fib_cols)])
deg <- deg[deg$gene %in% candidates & !is.na(deg$canonical) & is.finite(deg$avg_log2FC), ]
has_z <- rownames(z)[rowSums(is.finite(z)) > 0]
desired <- lapply(desired, intersect, union(has_z, deg$gene))
rm(srt, counts, expr, means)
xmap <- do.call(rbind, lapply(seq_along(desired), function(i) {
  genes <- desired[[i]]
  offset <- sum(lengths(desired)[seq_len(i - 1)]) + (i - 1) * .55
  data.frame(gene = genes, x = offset + seq_along(genes), block = names(desired)[i])
}))
chemplot <- merge(expand.grid(gene = xmap$gene, cluster = names(fib_cols)), xmap, by = "gene", sort = FALSE)
chemplot$y <- 15 - match(chemplot$cluster, names(fib_cols))
chemplot$z <- z[cbind(match(chemplot$gene, rownames(z)), match(chemplot$cluster, colnames(z)))]
deg_hits <- merge(deg, xmap, by = "gene")
deg_hits$y <- 15 - match(deg_hits$canonical, names(fib_cols))
brackets <- do.call(rbind, lapply(split(xmap, xmap$block), function(d) {
  data.frame(block = d$block[1], start = min(d$x) - .45, end = max(d$x) + .45)
}))
D_plot <- ggplot(chemplot, aes(x, y, fill = z)) +
  geom_tile(width = .96, height = .96, colour = "white", linewidth = .15) +
  geom_point(data = deg_hits, aes(x, y), inherit.aes = FALSE, shape = 1, colour = "#2A2528", size = 1.0, stroke = .31) +
  geom_segment(data = brackets, aes(x = start, xend = end, y = 15.1, yend = 15.1), inherit.aes = FALSE, linewidth = .52) +
  geom_text(data = brackets, aes(x = (start + end) / 2, y = 15.9, label = block), inherit.aes = FALSE, size = 2.12, fontface = "bold") +
  labs(caption = "Open circles: published Fib DEGs") +
  scale_fill_gradientn(colours = chem_cols, limits = c(-2, 2), oob = scales::squish, na.value = "#EDEDED", name = "Z-scale") +
  scale_y_continuous(position = "right", breaks = 14:1, labels = names(fib_cols), expand = expansion(add = c(.5, 2.09))) +
  scale_x_continuous(breaks = xmap$x, labels = xmap$gene, expand = expansion(add = .51)) +
  guides(fill = guide_colourbar(direction = "horizontal", barwidth = grid::unit(16, "mm"), barheight = grid::unit(2, "mm"))) +
  theme_void(base_size = 7) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, size = 5.8),
    axis.text.y = element_text(size = 5.6), legend.position = "bottom", legend.justification = "right",
    legend.text = element_text(size = 5.3), legend.title = element_text(size = 5.4),
    plot.caption = element_text(size = 5.4, hjust = 0, margin = margin(t = 0)),
    plot.margin = margin(2, 1, 0, 6)
  )
p <- panel_tag(D_plot, "D")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
