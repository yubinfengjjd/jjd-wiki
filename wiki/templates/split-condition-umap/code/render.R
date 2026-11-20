# Split-Condition Side-by-Side UMAP with Gray Manifold Background & Multi-Column Dot Legend
# Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(jsonlite)
  library(RColorBrewer)
  library(grid)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1L]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
tpl_root <- dirname(dirname(normalizePath(sub("^--file=", "", script_arg[1L]))))

data_dir <- get_arg("--data")
out_dir <- get_arg("--out")
style_file <- get_arg("--style", NULL)
if (is.null(data_dir) || is.null(out_dir)) {
  stop("Usage: Rscript code/render.R --data <dir> --out <dir> [--style <json>]")
}
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

spec <- jsonlite::fromJSON(file.path(tpl_root, "spec.json"), simplifyVector = FALSE)
style <- if (is.null(spec$style)) list() else spec$style
if (!is.null(style_file) && file.exists(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  for (k in names(override)) if (!is.null(override[[k]])) style[[k]] <- override[[k]]
}

fname <- if (!is.null(spec$tables$cells$filename)) spec$tables$cells$filename else "split_condition_umap_cells.csv"
df <- utils::read.csv(file.path(data_dir, fname), check.names = FALSE, stringsAsFactors = FALSE)
df$x <- as.numeric(df$umap_1)
df$y <- as.numeric(df$umap_2)
df$subcluster <- as.character(df$subcluster)
df$condition <- as.character(df$condition)
df <- df[is.finite(df$x) & is.finite(df$y) & !is.na(df$subcluster) & !is.na(df$condition), , drop = FALSE]

known_pal <- c(
  C1_mFib_ACTA2="#A3C9DC", C2_ifnFib_HSPA6="#327EB0", C3_lpFib_PLA2G2A="#81B992",
  C4_iFib_BNC2="#6BB458", C5_iFib_CXCL8="#7DA545", C6_iFib_NFKB1="#F2AA56",
  C7_lpFib_APOD="#EF7E1E", C8_iFib_CCL19="#F1958A", C9_mFib_COL12A1="#DA3539",
  C10_lpFib_ABCA8="#9578B2", C11_tFib_ENO1="#937694", C12_apFib_CD74="#ECDE86",
  C13_lpFib_LUM="#AA5829", C14_tFib_A2M="#4867A0",
  C1_ArtEC_SEMA3G="#3A97C2", C2_ArtEC_DLL4="#B9719F", C3_CapEC_CD36="#AA95BE",
  C4_TipEC_PGF="#D19570", C5_VenEC_HIF1A="#517188", C6_VenEC_CD74="#4B6C8B",
  C7_tEC_DOCK4="#A58882", "C8_emtEC_CD24+"="#8D6798", C9_emtEC_COL1A1="#6E6370",
  C10_nEC_IL6="#C88B68", C11_nEC_HMOX1="#D55635", C12_LEC_CCL21="#B14E53",
  C1_SMC_MYL9="#AA5244", C2_SMC_FN1="#B7987C", C3_SMC_MYH11="#DECCD8",
  C4_tPC_COL3A1="#D39CBB", C5_tPC_CCL19="#C9B2C5", C6_tPC_CD74="#E0B483",
  C7_tPC_SEPT7="#A66155", C8_tPC_PRKG1="#D19855", C9_nPC_CXCL8="#60A274",
  C10_nPC_GJA5="#C7D4A6"
)

subs <- unique(df$subcluster)
pal <- setNames(rep(NA_character_, length(subs)), subs)
m_idx <- subs %in% names(known_pal)
pal[m_idx] <- known_pal[subs[m_idx]]
if (any(!m_idx)) {
  pal[!m_idx] <- grDevices::colorRampPalette(RColorBrewer::brewer.pal(12, "Paired"))(sum(!m_idx))
}

bg_col <- if (!is.null(style$bg_color)) as.character(style$bg_color) else "#DCDCDC"
dot_sz <- if (!is.null(style$dot_size)) as.numeric(style$dot_size) else 0.65
leg_cols <- if (!is.null(style$legend_cols)) as.integer(style$legend_cols) else 2L

conds <- unique(df$condition)
if (all(c("Adjacent normal tissue", "Tumor") %in% conds)) {
  conds <- c("Adjacent normal tissue", "Tumor", setdiff(conds, c("Adjacent normal tissue", "Tumor")))
}

axis_grob <- grid::grobTree(
  grid::segmentsGrob(x0 = c(0.22, 0.22), x1 = c(0.88, 0.22), y0 = c(0.22, 0.22), y1 = c(0.22, 0.88),
                     arrow = grid::arrow(length = grid::unit(1.1, "mm")), gp = grid::gpar(lwd = 0.85, col = "#222222")),
  grid::textGrob("UMAP2D_1", x = 0.56, y = 0.06, gp = grid::gpar(fontsize = 6.2, col = "#222222")),
  grid::textGrob("UMAP2D_2", x = 0.08, y = 0.56, rot = 90, gp = grid::gpar(fontsize = 6.2, col = "#222222"))
)

views <- lapply(seq_along(conds), function(i) {
  cn <- conds[i]
  act <- df[df$condition == cn, , drop = FALSE]
  p <- ggplot(df, aes(x = x, y = y)) +
    geom_point(size = dot_sz * 1.55, stroke = 0, alpha = 0.92, colour = bg_col) +
    geom_point(data = act, aes(colour = subcluster), size = dot_sz * 1.48, stroke = 0, alpha = 0.95) +
    scale_colour_manual(values = pal, guide = "none") +
    coord_equal() +
    labs(title = cn) +
    theme_void(base_size = 8.5) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "plain", size = 9.5, margin = margin(b = 3)),
      plot.margin = margin(4, 6, 4, 6)
    )
  if (i == 1L) {
    p <- p + patchwork::inset_element(axis_grob, 0.01, 0.01, 0.36, 0.26, align_to = "full")
  }
  p
})

n_sub <- length(subs)
n_rows <- ceiling(n_sub / leg_cols)
leg_df <- data.frame(
  label = subs,
  col = (seq_len(n_sub) - 1L) %/% n_rows,
  row = n_rows - (seq_len(n_sub) - 1L) %% n_rows,
  stringsAsFactors = FALSE
)
leg_p <- ggplot(leg_df, aes(x = col, y = row)) +
  geom_point(aes(colour = label), size = 2.4) +
  geom_text(aes(x = col + 0.06, label = label), hjust = 0, size = 2.65, colour = "#222222") +
  scale_colour_manual(values = pal, guide = "none") +
  coord_cartesian(xlim = c(-0.08, leg_cols - 0.05), ylim = c(0.4, n_rows + 0.6), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.margin = margin(2, 10, 4, 12))

top_row <- patchwork::wrap_plots(views, nrow = 1L)
combined <- patchwork::wrap_plots(top_row, leg_p, ncol = 1L, heights = c(0.68, 0.32))

w_in <- if (!is.null(style$width_in)) as.numeric(style$width_in) else 6.2
h_in <- if (!is.null(style$height_in)) as.numeric(style$height_in) else 4.8
dpi_val <- if (!is.null(style$dpi)) as.integer(style$dpi) else 300L

ggsave(file.path(out_dir, "figure.png"), combined, width = w_in, height = h_in, dpi = dpi_val, bg = "white")
ggsave(file.path(out_dir, "figure.pdf"), combined, width = w_in, height = h_in, device = grDevices::cairo_pdf, bg = "white")
ggsave(file.path(out_dir, "figure.svg"), combined, width = w_in, height = h_in, device = grDevices::svg, bg = "white")
