# Panel ID: fig03/D (Fig. 3 3D)
# Title: MOESM8 Fib-T immunosuppressive L-R bipartite CellPhoneDB bubble plot.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/fig3d_lr_bipartite.csv, data_small/moesm/cellphone_pvalue.csv
# Default dimensions: width = 5.2 in, height = 3.8 in
# Usage: Rscript --vanilla code/panels/fig03_d.R --paper-root <PAPER_ROOT> --out fig03_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig03_d.png', default_width = 5.2, default_height = 3.8)
lr <- read_step("step05_crosstalk", "fig3d_lr_bipartite")
cp <- read_input("data_small", "moesm", "cellphone_pvalue.csv")
ligands <- c("LGALS9/3", "PVR", "LILRB4", "CD274", "PDCD1LG2", "CD80", "CD86", "CD200", "TNFRSF14", "CD276", "IDO1")
receptors <- c("HAVCR2", "LAG3", "TIGIT", "LAIR1", "PDCD1", "CTLA4", "CD200R1", "CD209", "BTLA")
links <- data.frame(
  ligand = c("LGALS9/3", "LGALS9/3", "PVR", "LILRB4", "CD274", "PDCD1LG2", "CD80", "CD86", "CD200", "TNFRSF14"),
  receptor = c("HAVCR2", "LAG3", "TIGIT", "LAIR1", "PDCD1", "PDCD1", "CTLA4", "CTLA4", "CD200R1", "BTLA"),
  pair = c("LGALS9_HAVCR2", NA, "PVR_TIGIT", NA, "PDCD1_CD274", "PDCD1_PDCD1LG2",
           "CTLA4_CD80", "CTLA4_CD86", "CD200_CD200R1", "BTLA_TNFRSF14")
)
xlig <- setNames(seq_along(ligands), ligands)
xrec <- setNames(seq(1.1, 10.5, length.out = length(receptors)), receptors)
links$x <- unname(xlig[links$ligand])
links$xe <- unname(xrec[links$receptor])
links$rate <- NA_real_
links$support <- NA_real_
compare_columns <- names(cp)[grepl("C[0-9]+_Fib_", names(cp)) & grepl("CD[48]|Regulatory|Transitory", names(cp))]
for (i in which(!is.na(links$pair))) {
  pvals <- lr$pval[lr$source_db == "CellPhoneDB" & lr$interaction_name == links$pair[i]]
  if (!length(pvals)) {
    cp_rows <- which(cp$interacting_pair == links$pair[i])
    pvals <- unlist(cp[cp_rows, compare_columns], use.names = FALSE)
  }
  pvals <- as.numeric(pvals)
  pvals <- pvals[is.finite(pvals)]
  if (length(pvals)) {
    links$support[i] <- max(-log10(pmax(pvals, 1e-4)))
    links$rate[i] <- 100 * mean(pvals < .05)
  }
}
nodes <- function(labels, coordinates, lookup, y) {
  paired <- split(seq_len(nrow(links)), lookup)
  best <- vapply(labels, function(name) {
    idx <- paired[[name]]
    idx <- idx[is.finite(links$support[idx])]
    if (length(idx)) idx[which.max(links$support[idx])] else NA_integer_
  }, integer(1))
  data.frame(gene = labels, x = unname(coordinates[labels]), y = y, rate = links$rate[best], support = links$support[best])
}
endpoints <- rbind(nodes(ligands, xlig, links$ligand, 2.47), nodes(receptors, xrec, links$receptor, .39))
links$available <- is.finite(links$support)
D_plot <- ggplot(endpoints, aes(x, y)) +
  annotate("rect", xmin = .55, xmax = 11.45, ymin = c(2.15, .07), ymax = c(2.79, .71),
           fill = "white", colour = "#888888", linewidth = .34) +
  geom_segment(data = links, aes(x = x + .10, xend = xe - .10, y = 1.58, yend = 1.25, linetype = available),
               inherit.aes = FALSE, colour = "#212121", linewidth = .27,
               arrow = grid::arrow(length = grid::unit(1.3, "mm"), type = "closed")) +
  geom_point(data = endpoints[is.na(endpoints$support), ], shape = 21, colour = "#B3B3B3", fill = "white", size = 2.35, stroke = .35) +
  geom_point(data = endpoints[!is.na(endpoints$support), ], aes(size = rate, fill = support), shape = 21, stroke = 0, alpha = .96) +
  geom_text(aes(y = ifelse(y > 1, 2.10, .76), label = gene), angle = 90, hjust = ifelse(endpoints$y > 1, 1, 0), size = 1.85) +
  annotate("text", x = .42, y = c(2.47, .39), label = c("Ligands", "Receptors"), hjust = 1, size = 2.25) +
  scale_fill_gradientn(colours = c("#CBD5E1", "#F4A582", "#D73027"), name = "Peak -log10(p)", limits = c(0, 4)) +
  scale_size_continuous(name = "% tests\np < 0.05", limits = c(0, 100), breaks = c(25, 50, 75), range = c(3.5, 10.5)) +
  scale_linetype_manual(values = c("FALSE" = "dashed", "TRUE" = "solid"), guide = "none") +
  guides(fill = guide_colourbar(barwidth = grid::unit(1.8, "mm"), barheight = grid::unit(10, "mm")),
         size = guide_legend(override.aes = list(fill = "#242424", alpha = 1))) +
  coord_cartesian(xlim = c(-1.6, 11.55), ylim = c(0, 2.88), expand = FALSE) +
  labs(subtitle = "CellPhoneDB support across tested Fib/T-cell pairs\nDashed links and open markers indicate unavailable statistics") +
  theme_void() +
  theme(legend.position = "right", legend.title = element_text(size = 5.8), legend.text = element_text(size = 5.5),
        legend.key.height = grid::unit(3.0, "mm"), legend.margin = margin(0, 0, 0, 0),
        legend.spacing.y = grid::unit(1, "mm"), plot.subtitle = element_text(size = 5.6, margin = margin(b = 3)),
        plot.margin = margin(19, 2, 3, 6))
p <- panel_tag(D_plot, "D")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
