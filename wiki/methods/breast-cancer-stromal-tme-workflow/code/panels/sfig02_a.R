# Panel ID: sfig02/A (Supp. Fig. 2 S2A)
# Title: Fib cohort UMAP + ANT/T/LM stacked ratio and batch x tissue pseudo-sample boxplot.
# Evidence tier: proxy
# Input tables: runs/step01_harmony_de/umap_fib.csv, runs/step02_progeny_roe_cox/tissue_prop_fib.csv, extracted/pages/main_p03.png
# Default dimensions: width = 6.0 in, height = 4.8 in
# Usage: Rscript --vanilla code/panels/sfig02_a.R --paper-root <PAPER_ROOT> --out sfig02_a.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig02_a.png', default_width = 6.0, default_height = 4.8)
pal <- fib_cols
obs <- read_step("step01_harmony_de", "umap_fib")
u <- make_manifolds("fib")$umap_fib
fib_batches <- supp_cohort_palette[names(supp_cohort_palette) != "GSE139495"]
batch_map <- supp_batch_plot(u, obs, fib_batches, width = .48, numbered = TRUE, repeats = 3) + theme(plot.margin = margin(2, 2, 2, 8))
batch_key <- wave_dot_legend(fib_batches, cols = 2, header = "GSE_numbers:", size = 1.62)
batch_label <- wrap_elements(full = grid::textGrob("4 local cohorts; numbers follow reference key", gp = grid::gpar(fontsize = 4.8, col = "#5B5859")))
batch <- wave_section(batch_map, batch_key, batch_label, nrow = 3, heights = c(.69, .24, .07))
proportions <- read_step("step02_progeny_roe_cox", "tissue_prop_fib")
tissues <- c("Normal", "Tumor", "Lymphnode")
tissue_ink <- setNames(c("#2B9E77", "#D95F02", "#7570B3"), tissues)
pooled <- proportions[proportions$stratum_type == "tissue_overall" & proportions$tissue %in% tissues, ]
pooled$group <- match(pooled$canonical_subcluster, names(pal))
pooled$tissue <- factor(pooled$tissue, levels = tissues)
tissue_bars <- do.call(rbind, lapply(split(pooled, pooled$group), function(d) {
  d <- d[order(d$tissue), ]; d$x1 <- cumsum(d$n_cells) / sum(d$n_cells); d$x0 <- c(0, head(d$x1, -1)); d
}))
sampled <- proportions[proportions$stratum_type == "batch_tissue" & proportions$tissue %in% tissues, ]
sampled$group <- match(sampled$canonical_subcluster, names(pal))
sampled$x <- 1.10 + sampled$proportion * 3.4
sampled$y <- sampled$group + c(Normal = -.23, Tumor = 0, Lymphnode = .23)[sampled$tissue]
p_values <- vapply(names(pal), function(name) {
  d <- sampled[sampled$canonical_subcluster == name, ]
  paired <- merge(d[d$tissue == "Normal", c("batch", "proportion")], d[d$tissue == "Tumor", c("batch", "proportion")], by = "batch")
  if (nrow(paired) < 3) return(NA_real_)
  if (all(paired$proportion.x == paired$proportion.y)) return(1)
  suppressWarnings(wilcox.test(paired$proportion.x, paired$proportion.y, paired = TRUE, exact = FALSE)$p.value)
}, numeric(1))
p_adj <- p.adjust(p_values, "BH")
signif_lbl <- ifelse(is.na(p_adj), "NA", ifelse(p_adj < .01, "**", ifelse(p_adj < .05, "*", "ns")))
tissue_panel <- ggplot() +
  geom_rect(data = tissue_bars, aes(xmin = x0, xmax = x1, ymin = group - .37, ymax = group + .37, fill = tissue), colour = "white", linewidth = .12) +
  geom_boxplot(data = sampled, aes(x, y, colour = tissue, group = interaction(group, tissue)), orientation = "y", width = .17, linewidth = .20, outlier.shape = NA, fill = NA) +
  geom_point(data = sampled, aes(x, y, colour = tissue), size = .60, stroke = 0, position = position_jitter(width = 0, height = .031, seed = 42)) +
  annotate("text", x = 2.92, y = seq_along(pal), label = signif_lbl, colour = "#474047", size = 1.5) +
  annotate("segment", x = 1.04, xend = 1.04, y = .55, yend = 14.45, colour = "#888888", linewidth = .27) +
  scale_fill_manual(values = tissue_ink, labels = c("ANT", "T", "LM"), name = NULL) +
  scale_colour_manual(values = tissue_ink, guide = "none") +
  scale_x_continuous(breaks = c(0, .5, 1, 1.10, 1.78, 2.46), labels = c("0", "0.5", "1", "0", "20", "40")) +
  scale_y_continuous(breaks = NULL) + labs(caption = "Ratio          % Fib cells\nBatch strata; ANT vs T") +
  coord_cartesian(xlim = c(-.02, 3.06), ylim = c(.49, 14.51), expand = FALSE) + theme_classic(base_size = 6) +
  guides(fill = guide_legend(nrow = 1, override.aes = list(colour = NA))) +
  theme(axis.title = element_blank(), axis.text.x = element_text(size = 4.6, angle = 55, hjust = 1),
        axis.ticks.length = grid::unit(.65, "mm"), legend.position = "top", legend.text = element_text(size = 4.8),
        legend.margin = margin(0, 0, 1, 0), legend.key.height = grid::unit(2.0, "mm"), legend.key.width = grid::unit(2.75, "mm"),
        legend.spacing.x = grid::unit(.55, "mm"), plot.caption = element_text(size = 4.65, hjust = .48), plot.margin = margin(6, 4, 1, 3))
p <- panel_tag(wrap_plots(batch, tissue_panel, nrow = 1, widths = c(.61, .39)), "A")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
