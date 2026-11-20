# Panel ID: sfig02/C (Supp. Fig. 2 S2C)
# Title: Fibroblast Angiogenic_signature local gene-set proxy projected on UMAP.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_fib.csv, data_small/scrna_stromal_small.qs, extracted/pages/main_p03.png
# Default dimensions: width = 5.0 in, height = 4.4 in
# Usage: Rscript --vanilla code/panels/sfig02_c.R --paper-root <PAPER_ROOT> --out sfig02_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig02_c.png', default_width = 5.0, default_height = 4.4)
u <- make_manifolds("fib")$umap_fib
srt <- qs::qread(file.path(paper_dir, "data_small/scrna_stromal_small.qs"), nthreads = 1)
counts <- as.matrix(SeuratObject::GetAssayData(srt, layer = "counts"))
angio <- intersect(c("COL3A1", "FN1", "POSTN", "THY1", "COL1A1", "PGF", "EGFL6"), rownames(counts))
ids <- match(u$cell, colnames(counts))
normalized <- log1p(sweep(counts[angio, ids, drop = FALSE], 2, colSums(counts)[ids], "/") * 1e4)
u$score <- .5 + scale01(colMeans(normalized))
rm(srt, counts, normalized)
angio_ink <- c("#3288BD", "#ABDDA4", "#FFFFBF", "#FDAE61", "#D53E4F")
set.seed(42)
focused <- u[rep(seq_len(nrow(u)), 3L), ]
focused$x <- focused$x + runif(nrow(focused), -1.25, 1.25)
focused$y <- focused$y + runif(nrow(focused), -1.25, 1.25)
dx <- diff(range(focused$x)); dy <- diff(range(focused$y))
ox <- min(focused$x) - dx * (.04 + .02 * 1.08); oy <- min(focused$y) - dy * (.04 + .068 * 1.08)
p <- panel_tag(feature_panel(focused, "score", angio_ink, "Angiogenic_signature", dots = .53, limits = c(.5, 1.5),
  bar = TRUE, manifold = TRUE) +
  add_l_arrows(data = focused, x = -.02, y = -.068, length = .16) +
  annotate("text", x = ox + .014 * dx, y = oy - .037 * dy, label = "HarmonyUMAP2D_1", hjust = 0, size = 1.86) +
  annotate("text", x = ox - .038 * dx, y = oy + .027 * dy, label = "HarmonyUMAP2D_2", angle = 90, hjust = 0, size = 1.86) +
  labs(caption = "Local gene-set proxy, normalized for display") +
  theme(plot.title = element_text(size = 9.3, face = "plain"), plot.caption = element_text(size = 5.4, hjust = .76),
        plot.margin = margin(5, 4, 7, 15)), "C")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
