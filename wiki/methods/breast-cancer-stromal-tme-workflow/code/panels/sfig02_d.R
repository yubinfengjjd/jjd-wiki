# Panel ID: sfig02/D (Supp. Fig. 2 S2D)
# Title: Fibroblast 42 KEGG pathways enrichment bubble matrix across 14 subclusters.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/sfig2d_kegg_fib.csv
# Default dimensions: width = 6.8 in, height = 7.4 in
# Usage: Rscript --vanilla code/panels/sfig02_d.R --paper-root <PAPER_ROOT> --out sfig02_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig02_d.png', default_width = 6.8, default_height = 7.4)
pal <- fib_cols
enrich <- read_step("step05_crosstalk", "sfig2d_kegg_fib")
path_order <- c("KEGG_FOCAL_ADHESION","KEGG_ECM_RECEPTOR_INTERACTION",
  "KEGG_REGULATION_OF_ACTIN_CYTOSKELETON","KEGG_HYPERTROPHIC_CARDIOMYOPATHY_HCM",
  "KEGG_DILATED_CARDIOMYOPATHY","KEGG_PATHWAYS_IN_CANCER","KEGG_NEUROTROPHIN_SIGNALING_PATHWAY",
  "KEGG_PANCREATIC_CANCER","KEGG_ABC_TRANSPORTERS","KEGG_ACUTE_MYELOID_LEUKEMIA",
  "KEGG_GLYCOLYSIS_GLUCONEOGENESIS","KEGG_AMINOACYL_TRNA_BIOSYNTHESIS","KEGG_VIRAL_MYOCARDITIS",
  "KEGG_PENTOSE_PHOSPHATE_PATHWAY","KEGG_ASTHMA","KEGG_CITRATE_CYCLE_TCA_CYCLE","KEGG_DNA_REPLICATION",
  "KEGG_ALLOGRAFT_REJECTION","KEGG_STEROID_BIOSYNTHESIS","KEGG_LYSOSOME","KEGG_ARGININE_AND_PROLINE_METABOLISM",
  "KEGG_OTHER_GLYCAN_DEGRADATION","KEGG_GLUTATHIONE_METABOLISM","KEGG_GLYCOSAMINOGLYCAN_DEGRADATION",
  "KEGG_SMALL_CELL_LUNG_CANCER","KEGG_MAPK_SIGNALING_PATHWAY","KEGG_T_CELL_RECEPTOR_SIGNALING_PATHWAY",
  "KEGG_ARACHIDONIC_ACID_METABOLISM","KEGG_NOD_LIKE_RECEPTOR_SIGNALING_PATHWAY",
  "KEGG_CIRCADIAN_RHYTHM_MAMMAL","KEGG_COMPLEMENT_AND_COAGULATION_CASCADES",
  "KEGG_METABOLISM_OF_XENOBIOTICS_BY_CYTOCHROME_P450","KEGG_AXON_GUIDANCE",
  "KEGG_ETHER_LIPID_METABOLISM","KEGG_VASCULAR_SMOOTH_MUSCLE_CONTRACTION","KEGG_TIGHT_JUNCTION",
  "KEGG_LONG_TERM_DEPRESSION","KEGG_LONG_TERM_POTENTIATION","KEGG_PYRIMIDINE_METABOLISM",
  "KEGG_CYTOSOLIC_DNA_SENSING_PATHWAY","KEGG_RNA_POLYMERASE","KEGG_PROTEASOME")
eligible <- intersect(path_order, enrich$Description)
observed_rank <- aggregate(logp ~ Description, enrich, max)
other <- observed_rank$Description[order(observed_rank$logp, decreasing = TRUE)]
paths <- head(unique(c(eligible, other)), 42)
enrich$cluster <- wave_cluster(enrich$group, pal)
enrich <- enrich[enrich$Description %in% paths & !is.na(enrich$cluster), ]
path_labels <- setNames(stringr::str_trunc(paths, 57), paths)
fib_order <- names(pal)[c(9, 8, 7, 6, 5, 4, 3, 2, 12, 14, 13, 11, 10, 1)]
p <- panel_tag(ggplot(enrich, aes(cluster, Description)) +
  geom_point(aes(size = Count, colour = logp), alpha = .95) +
  scale_x_discrete(limits = fib_order, drop = FALSE, expand = expansion(add = .50)) +
  scale_y_discrete(limits = rev(paths), labels = path_labels, expand = expansion(add = .55)) +
  scale_colour_gradientn(colours = c("#F4A582", "#DF65B0", "#88419D", "#4D004B"),
                         name = "logp", limits = c(2, 10), oob = scales::squish, breaks = seq(2, 10, 2)) +
  scale_size_continuous(range = c(.9, 4.3), breaks = c(4, 8, 12, 16), name = "Count") +
  guides(size = guide_legend(order = 1, override.aes = list(colour = "black")),
         colour = guide_colourbar(order = 2, barheight = grid::unit(19, "mm"), barwidth = grid::unit(2.4, "mm"))) +
  theme_bw(base_size = 6.7) +
  theme(axis.title = element_blank(), axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5, size = 6.35),
        axis.text.y = element_text(size = 5.85, colour = "#303030"), axis.ticks.length = grid::unit(.65, "mm"),
        panel.border = element_rect(colour = "#222222", linewidth = .55),
        panel.grid.major = element_line(colour = "#E5E5E5", linewidth = .49),
        legend.position = "right", legend.text = element_text(size = 5.85), legend.title = element_text(size = 7),
        plot.margin = margin(16, 5, 6, 7)), "D")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
