# Panel ID: sfig05/D (Supp. Fig. 5 S5D)
# Title: 52-node stromal + TME VEGF directional signaling ring.
# Evidence tier: original_table
# Input tables: runs/step05_crosstalk/sfig5d_chord_edges.csv
# Default dimensions: width = 6.8 in, height = 6.6 in
# Usage: Rscript --vanilla code/panels/sfig05_d.R --paper-root <PAPER_ROOT> --out sfig05_d.png

script_arg <- grep('^--file=', commandArgs(trailingOnly = FALSE), value = TRUE)
panel_dir <- dirname(normalizePath(sub('^--file=', '', script_arg[1]), winslash = '/', mustWork = FALSE))
source(file.path(panel_dir, '_panel_common.R'))
cfg <- init_panel_env(default_out = 'sfig05_d.png', default_width = 6.8, default_height = 6.6)
pal <- mural_cols
legacy_labels <- setNames(c("C1_SMC_MYL9","C2_SMC_FN1","C3_SMC_MYH11","C1_tPC_COL3A1",
  "C2_tPC_CCL19","C3_tPC_CD74","C4_tPC_SEPT7","C5_tPC_PRKG1","C6_nPC_CXCL8","C7_nPC_GJA5"), names(pal))
stromal <- c(fib_cols, ec_cols, mural_cols)
extra <- c("Transitory_T","Regulatory_T","Plasma_B","pDC","NK","Neutrophil","Naive_B",
  "Memory_B","Mast","M2","M1","GC_B","Epi","DC_LAMP3","CD8_Cytotoxic_T","CD4_Effector_T")
extra_pal <- setNames(c("#A0A3A4","#94B3AC","#88C5BE","#A6D5BA","#B9DCA7","#CBDC83","#CDCD47",
  "#9EB847","#63864E","#2B6246","#557C64","#78969F","#8277A4","#776BA4","#AA5896","#56A9B4"), extra)
inks <- c(stromal, extra_pal)
start <- "C1_ArtEC_SEMA3G"
inks[start] <- "#D7191C"
preferred_order <- c(start,extra,"C9_mFib_COL12A1","C9_emtEC_COL1A1","C8_emtEC_CD24+",
  "C8_iFib_CCL19","C7_tEC_DOCK4","C10_nPC_GJA5","C7_lpFib_APOD","C6_VenEC_CD74",
  "C9_nPC_CXCL8","C6_iFib_NFKB1","C5_VenEC_HIF1A","C8_tPC_PRKG1","C5_iFib_CXCL8",
  "C4_TipEC_PGF","C7_tPC_SEPT7","C4_iFib_BNC2","C3_SMC_MYH11","C6_tPC_CD74",
  "C3_CapEC_CD36","C3_lpFib_PLA2G2A","C2_SMC_FN1","C5_tPC_CCL19","C2_ifnFib_HSPA6",
  "C2_ArtEC_DLL4","C14_tFib_A2M","C13_lpFib_LUM","C12_LEC_CCL21","C12_apFib_CD74",
  "C11_nEC_HMOX1","C11_tFib_ENO1","C10_nEC_IL6","C10_lpFib_ABCA8","C1_SMC_MYL9",
  "C4_tPC_COL3A1","C1_mFib_ACTA2")
node_order <- unique(c(intersect(preferred_order, names(inks)), names(inks)))
node_text <- node_order
idx <- match(node_order, names(legacy_labels))
node_text[!is.na(idx)] <- legacy_labels[idx[!is.na(idx)]]
hubs <- c("C1_ArtEC_SEMA3G","C10_nEC_IL6","C4_TipEC_PGF","C5_VenEC_HIF1A","C7_tEC_DOCK4","C9_mFib_COL12A1")
theta <- -2 * pi * (seq_along(node_order) - 1L) / length(node_order)
left <- cos(theta) < 0
node <- data.frame(name = node_order, label = node_text, x = cos(theta), y = sin(theta),
  tx = 1.106 * cos(theta), ty = 1.106 * sin(theta), align = ifelse(left, 1, 0),
  angle = theta * 180 / pi + ifelse(left, 180, 0), node_ink = unname(inks[node_order]),
  label_ink = ifelse(node_order %in% hubs, "#D7191C", "#252229"))
edge <- read_step("step05_crosstalk", "sfig5d_chord_edges")
edge_name <- function(ids, compartment) {
  result <- gsub(" ", "_", ids, fixed = TRUE)
  for (kind in c("Fib", "EC", "Mural")) {
    palette <- switch(kind, Fib = fib_cols, EC = ec_cols, Mural = mural_cols)
    selected <- compartment == kind
    result[selected] <- wave_cluster(ids[selected], palette)
  }
  result
}
edge$from <- edge_name(edge$source, edge$source_compartment)
edge$to <- edge_name(edge$target, edge$target_compartment)
pairs <- aggregate(prob ~ from + to, edge, max)
pairs <- pairs[order(pairs$prob), ]
curve <- do.call(rbind, lapply(seq_len(nrow(pairs)), function(i) {
  a <- as.numeric(node[match(pairs$from[i], node$name), c("x", "y")])
  b <- as.numeric(node[match(pairs$to[i], node$name), c("x", "y")])
  t <- seq(0, 1, length.out = 36)
  if (all(a == b)) {
    orth <- c(-a[2], a[1]); p0 <- .99*a - .035*orth; p3 <- .99*a + .035*orth; p1 <- .69*a - .22*orth; p2 <- .69*a + .22*orth
    xy <- outer((1-t)^3, p0) + outer(3*(1-t)^2*t, p1) + outer(3*(1-t)*t^2, p2) + outer(t^3, p3)
  } else {
    control <- .33 * (a + b)
    xy <- outer((1-t)^2, a) + outer(2*(1-t)*t, control) + outer(t^2, b)
  }
  data.frame(x = xy[, 1], y = xy[, 2], id = i, ink = unname(inks[pairs$from[i]]), prob = pairs$prob[i])
}))
ring <- ggplot() +
  geom_path(data = curve, aes(x, y, group = id, colour = ink, linewidth = prob, alpha = prob), lineend = "round") +
  geom_point(data = node, aes(x, y, fill = node_ink), shape = 21, colour = "white", size = 4.48, stroke = .28) +
  geom_text(data = node, aes(x = tx, y = ty, angle = angle, hjust = align, label = label, colour = label_ink), size = 2.07) +
  scale_colour_identity() + scale_fill_identity() +
  scale_linewidth_continuous(range = c(.13, 1.33), guide = "none") +
  scale_alpha_continuous(range = c(.20, .67), guide = "none") +
  coord_equal(xlim = c(-1.70, 1.70), ylim = c(-1.59, 1.59), expand = FALSE, clip = "off") +
  theme_void() + theme(plot.margin = margin(5, 9, 3, 9))
p <- panel_tag(ring, "D")

save_panel(p, cfg$out, width = cfg$width, height = cfg$height, dpi = cfg$dpi)
rm(list = ls()); invisible(gc())
