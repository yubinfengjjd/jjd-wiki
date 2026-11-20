# Panel ID: fig02/G (Fig. 2 2G)
# Title: Fibroblast DPT pseudotime differentiation state projected on UMAP with directed cluster median guides.
# Evidence tier: local_recompute
# Input tables: runs/step01_harmony_de/umap_fib.csv, runs/step04_trajectory/traj_fib.csv, extracted/pages/main_p03.png
# Default dimensions: width = 4.4 in, height = 4.0 in
# Usage: Rscript --vanilla code/panels/fig02_g.R --paper-root <PAPER_ROOT> --out fig02_g.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_g.png', default_width = 4.4, default_height = 4.0)
traj <- read_step("step04_trajectory", "traj_fib")
umap <- make_manifolds("fib")$umap_fib
mapped <- match(umap$cell, traj$cell_id)
umap$dpt <- traj$dpt_pseudotime[mapped]
umap$slingshot <- traj$slingshot_pseudotime[mapped]
sling_centers <- aggregate(cbind(x, y, slingshot, dpt) ~ cluster, umap, median)
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
edges <- transform(tree, t0 = sling_centers$dpt[match(x, sling_centers$x)], t1 = sling_centers$dpt[match(xe, sling_centers$x)])
forward <- edges$t0 <= edges$t1
G_plot <- feature_panel(umap, "dpt", c("#2B5C8F", "#44AA99", "#DDCC77", "#D55E00"),
                        "Differentiation state (DPT)", dots = .69, bar = TRUE, horizontal = TRUE, manifold = TRUE) +
  geom_curve(data = edges, aes(x = ifelse(forward, x, xe), y = ifelse(forward, y, ye),
                               xend = ifelse(forward, xe, x), yend = ifelse(forward, ye, y)),
             inherit.aes = FALSE, curvature = .14, linewidth = .24, lineend = "round", colour = "#353535",
             arrow = grid::arrow(length = grid::unit(.92, "mm"), type = "closed")) +
  labs(subtitle = "Display guides from cluster DPT medians") +
  theme(plot.title = element_text(face = "plain", size = 8.8),
        plot.subtitle = element_text(size = 5, hjust = .5, margin = margin(b = .2)))
p <- panel_tag(G_plot, "G")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
