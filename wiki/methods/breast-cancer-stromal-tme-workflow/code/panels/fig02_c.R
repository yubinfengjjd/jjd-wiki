# Panel ID: fig02/C (Fig. 2 2C)
# Title: Fibroblast subcluster tissue/subtype Ro/e combined with TCGA/in-house Cox HR.
# Evidence tier: original_table
# Input tables: runs/step02_progeny_roe_cox/roe_cox_fib.csv, data_small/moesm/cox_tcga.csv, data_small/moesm/cox_inhouse.csv
# Default dimensions: width = 6.4 in, height = 4.2 in
# Usage: Rscript --vanilla code/panels/fig02_c.R --paper-root <PAPER_ROOT> --out fig02_c.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'fig02_c.png', default_width = 6.4, default_height = 4.2)
roe <- read_step("step02_progeny_roe_cox", "roe_cox_fib")
roe <- roe[match(names(fib_cols), roe$canonical_subcluster), ]
for (cohort in c("tcga", "inhouse")) {
  published <- read_input("data_small", "moesm", paste0("cox_", cohort, ".csv"))
  idx <- match(roe$canonical_subcluster, published$variable)
  available <- !is.na(idx)
  stopifnot(isTRUE(all.equal(roe[[paste0(cohort, "_HR")]][available], published$HR[idx[available]])))
}
cox_block <- function(cohort, label, row) {
  hr <- roe[[paste0(cohort, "_HR")]]
  pv <- roe[[paste0(cohort, "_p_value")]]
  data.frame(
    x = seq_along(hr), y = row,
    label = ifelse(!is.na(pv) & pv < .05, "*", ""),
    fill = ifelse(is.na(hr), "#D9D9D9", unname(cox_cols[ifelse(hr > 1, "Risk", "Protective")])),
    rowname = label
  )
}
numeric_block <- function(prefix, labels, y, palette, limits) {
  do.call(rbind, lapply(seq_along(labels), function(i) {
    value <- roe[[paste0(prefix, labels[i])]]
    data.frame(
      x = seq_along(value), y = y[i],
      label = ifelse(is.na(value), "", sprintf("%.1f", value)),
      fill = panel_tile_colours(value, palette, limits),
      rowname = labels[i]
    )
  }))
}
heat <- rbind(
  cox_block("tcga", "TCGA cohort", 10.45),
  cox_block("inhouse", "Inhouse cohort", 9.45),
  numeric_block("roe_subtype_", c("Normal", "Luminal_A", "Luminal_B", "HER2", "TNBC"), 8:4, subtype_cols, c(0, 2.5)),
  numeric_block("roe_tissue_", c("Normal", "Tumor", "Lymphnode"), c(2.73, 1.73, .73), tissue_cols, c(0, 2))
)
C_plot <- ggplot(heat, aes(x, y)) +
  geom_tile(aes(fill = fill), width = .99, height = .99, colour = "#EEEEEE", linewidth = .18) +
  annotate("rect", xmin = .5, xmax = 14.5, ymin = c(8.95, 3.50, .23), ymax = c(10.95, 8.50, 3.23),
           fill = NA, colour = "#656565", linewidth = .23) +
  geom_text(aes(label = label), size = 1.98, na.rm = TRUE) +
  geom_text(data = unique(heat[c("y", "rowname")]), aes(x = 14.62, label = rowname), hjust = 0, size = 1.98) +
  scale_x_continuous(breaks = 1:14, labels = roe$canonical_subcluster) +
  scale_fill_identity(na.value = "#DFDFDF") +
  coord_cartesian(xlim = c(.35, 18.8), ylim = c(.18, 11), expand = FALSE, clip = "off") +
  theme_void() +
  theme(
    axis.text.x = element_text(size = 5.5, angle = 90, hjust = 1, vjust = .5, colour = "#222222", margin = margin(t = 3)),
    plot.margin = margin(6, 4, 5, 11)
  )
cox_key <- grid::grobTree(
  grid::rectGrob(x = .08, y = c(.76, .31), width = .14, height = .28, gp = grid::gpar(fill = unname(cox_cols), col = NA)),
  grid::textGrob(c("Risk factor", "Protective factor"), x = .19, y = c(.76, .31), just = "left", gp = grid::gpar(fontsize = 5))
)
C_plot <- C_plot +
  inset_element(cox_key, .787, .138, .986, .232, align_to = "full") +
  inset_element(panel_legend_bar(subtype_cols, "Ro/e", c("0", "2.5"), TRUE), .789, .023, .869, .134, align_to = "full") +
  inset_element(panel_legend_bar(tissue_cols, "Ro/e", c("0", "2"), TRUE), .899, .023, .979, .134, align_to = "full")
p <- panel_tag(C_plot, "C")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
