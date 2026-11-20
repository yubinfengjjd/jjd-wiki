# Panel ID: fig01/C (Fig. 1 1C)
# Title: 9 canonical stromal lineage marker expression feature UMAPs (COL1A1, COL1A2, DCN, PECAM1, VWF, CD34, ACTA2, PDGFRB, MCAM).
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_all.csv, data_small/scrna_stromal_small.qs, extracted/pages/main_p03.png
# Default dimensions: width = 6.4 in, height = 5.2 in
# Usage: Rscript --vanilla code/panels/fig01_c.R --paper-root <PAPER_ROOT> --out fig01_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig01_c.png', default_width = 6.4, default_height = 5.2)
atlas <- make_manifolds("all")$umap_all
markers <- c("COL1A1", "COL1A2", "DCN", "PECAM1", "VWF", "CD34", "ACTA2", "PDGFRB", "MCAM")
srt <- qs::qread(file.path(paper_dir, "data_small/scrna_stromal_small.qs"), nthreads = 1)
counts <- as.matrix(SeuratObject::GetAssayData(srt, layer = "counts"))
library_size <- colSums(counts)
expr <- log1p(sweep(counts[markers, atlas$cell, drop = FALSE], 2, library_size[atlas$cell], "/") * 1e4)
features <- lapply(seq_along(markers), function(i) {
  atlas$expression <- as.numeric(expr[i, ])
  mural_marker <- markers[i] %in% c("ACTA2", "PDGFRB", "MCAM")
  upper <- quantile(atlas$expression, .995, names = FALSE)
  ramp <- if (mural_marker) {
    c("#DAD8D8", "#DDDADA", "#E8C9D0", marker_cols[2])
  } else {
    c(marker_cols[1], "#D6D4D2", "#E6DDDE", "#F1CED2", marker_cols[2])
  }
  feature_panel(
    atlas, "expression", ramp, markers[i],
    dots = .42, bar = TRUE, manifold = TRUE,
    limits = c(0, upper),
    colours_at = if (mural_marker) c(0, .63, .92, 1) else NULL
  ) +
    theme(plot.title = element_text(size = 9.2, face = "bold"))
})
p <- panel_tag(wrap_plots(features, ncol = 3), "C")
rm(srt, counts, expr, features)

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
