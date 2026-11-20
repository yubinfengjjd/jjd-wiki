# Panel ID: fig02/H (Fig. 2 2H)
# Title: Fibroblast Slingshot pseudotime differentiation state projected on UMAP with MST cluster-center guide.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_fib.csv, runs/step04_trajectory/traj_fib.csv, extracted/pages/main_p03.png
# Default dimensions: width = 4.2 in, height = 4.0 in
# Usage: Rscript --vanilla code/panels/fig02_h.R --paper-root <PAPER_ROOT> --out fig02_h.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_h.png', default_width = 4.2, default_height = 4.0)
traj <- read_step("step04_trajectory", "traj_fib")
umap <- make_manifolds("fib")$umap_fib
mapped <- match(umap$cell, traj$cell_id)
umap$slingshot <- traj$slingshot_pseudotime[mapped]
sling_centers <- aggregate(cbind(x, y, slingshot) ~ cluster, umap, median)
pairwise <- as.matrix(dist(sling_centers[c("x", "y")]))
tree <- data.frame()
joined <- which.min(sling_centers$slingshot)
while (length(joined) < nrow(sling_centers)) {
  rest <- setdiff(seq_len(nrow(sling_centers)), joined)
  dist_subset <- pairwise[joined, rest, drop = FALSE]
  nearest <- which(dist_subset == min(dist_subset), arr.ind = TRUE)[1, ]
  from <- joined[nearest[1]]; to <- rest[nearest[2]]
  tree <- rbind(tree, data.frame(x = sling_centers$x[from], y = sling_centers$y[from],
                                 xe = sling_centers$x[to], ye = sling_centers$y[to]))
  joined <- c(joined, to)
}
H_plot <- feature_panel(umap, "slingshot", c("#440154", "#B83289", "#FDE725"),
                        "Differentiation state (Slingshot)", dots = .69, bar = TRUE, horizontal = TRUE, manifold = TRUE) +
  geom_segment(data = tree, aes(x, y, xend = xe, yend = ye), inherit.aes = FALSE, linewidth = .36, colour = "black") +
  labs(subtitle = "Cluster-center guide") +
  theme(plot.title = element_text(face = "plain", size = 8.8),
        plot.subtitle = element_text(size = 5, hjust = .5, margin = margin(b = .2)))
p <- panel_tag(H_plot, "H")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
