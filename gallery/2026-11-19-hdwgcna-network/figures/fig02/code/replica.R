# Faceted Co-expression Module Enrichment Horizontal Barplot (Panel B)
# Adapted from KS tutorial section 1; uses pure ggplot2 + patchwork colored module strips
# (no ggh4x dependency required), adaptive column count, and contrast-aware strip text.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(dplyr)
  library(readr)
  library(jsonlite)
})

args <- commandArgs(trailingOnly = TRUE)
get_arg <- function(name, default = NULL) {
  i <- match(name, args)
  if (is.na(i) || i >= length(args)) default else args[i + 1]
}
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_dir <- if (length(script_arg) > 0) dirname(normalizePath(sub("^--file=", "", script_arg[1]))) else getwd()
entry_root <- if (basename(script_dir) == "code") dirname(script_dir) else script_dir

data_dir <- get_arg("--data", file.path(entry_root, "data"))
out_dir <- get_arg("--out", file.path(entry_root, "output"))
style_file <- get_arg("--style", NULL)

style <- list(
  width_in = 6.0,
  height_in = 11.8,
  dpi = 300,
  ncol = 2,
  bar_alpha = 0.52,
  bar_width = 0.72,
  term_size = 2.45,
  strip_text_size = 8.2,
  max_term_chars = 46,
  x_lab = "-log10(P-value)",
  seed = 42
)
if (!is.null(style_file) && file.exists(style_file)) {
  override <- jsonlite::fromJSON(style_file, simplifyVector = FALSE)
  for (k in names(override)) {
    if (!is.null(override[[k]])) style[[k]] <- override[[k]]
  }
}

enrich_path <- file.path(data_dir, "enrich_plot_dat.csv")
if (!file.exists(enrich_path)) stop("Missing enrich_plot_dat.csv in: ", data_dir)

df <- readr::read_csv(enrich_path, show_col_types = FALSE) %>%
  dplyr::mutate(
    module = as.character(module),
    Term = as.character(Term),
    log10p = as.numeric(log10p)
  ) %>%
  dplyr::filter(!is.na(module), !is.na(Term), !is.na(log10p))

if (!"color" %in% names(df) || all(is.na(df$color) | !nzchar(df$color))) {
  mods <- unique(df$module)
  auto_pal <- grDevices::hcl.colors(max(3, length(mods)), palette = "Dark 3")[seq_along(mods)]
  df$color <- auto_pal[match(df$module, mods)]
}

mod_levels <- unique(df$module)
n_mods <- length(mod_levels)
ncol_val <- as.integer(style$ncol)
nrow_val <- ceiling(n_mods / ncol_val)

max_x <- max(8.5, max(df$log10p, na.rm = TRUE) * 1.06)
x_ticks <- pretty(c(0, max_x), n = 4)
x_ticks <- x_ticks[x_ticks <= max_x * 1.02]

max_chars <- as.integer(style$max_term_chars)
truncate_term <- function(s) {
  ifelse(nchar(s) > max_chars, paste0(substr(s, 1, max_chars - 1), "..."), s)
}

strip_text_color <- function(hex) {
  rgb_m <- grDevices::col2rgb(hex) / 255
  lum <- 0.299 * rgb_m[1, 1] + 0.587 * rgb_m[2, 1] + 0.114 * rgb_m[3, 1]
  if (lum < 0.42) "#ffffff" else "#111111"
}

plots <- vector("list", n_mods)
for (idx in seq_len(n_mods)) {
  mod <- mod_levels[idx]
  sub <- df %>%
    dplyr::filter(module == mod) %>%
    dplyr::arrange(log10p) %>%
    dplyr::mutate(
      Term_disp = truncate_term(Term),
      Term_f = factor(Term_disp, levels = unique(Term_disp))
    )
  col_hex <- sub$color[1]
  row_idx <- ceiling(idx / ncol_val)
  is_bottom <- (row_idx == nrow_val) || (idx + ncol_val > n_mods)

  p_mod <- ggplot(sub, aes(x = log10p, y = Term_f)) +
    geom_col(fill = col_hex, alpha = as.numeric(style$bar_alpha), width = as.numeric(style$bar_width)) +
    geom_text(
      aes(x = max_x * 0.03, label = Term_disp),
      hjust = 0,
      size = as.numeric(style$term_size),
      color = "#111111"
    ) +
    facet_wrap(~module, ncol = 1) +
    scale_x_continuous(limits = c(0, max_x), breaks = x_ticks, expand = c(0, 0)) +
    labs(x = NULL, y = NULL) +
    theme_classic(base_size = 9) +
    theme(
      strip.background = element_rect(fill = col_hex, color = "#222222", linewidth = 0.55),
      strip.text = element_text(
        color = strip_text_color(col_hex),
        face = "bold",
        size = as.numeric(style$strip_text_size),
        margin = margin(t = 2.2, b = 2.2)
      ),
      axis.line.y = element_line(color = "#222222", linewidth = 0.45),
      axis.line.x = if (is_bottom) element_line(color = "#222222", linewidth = 0.45) else element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.x = if (is_bottom) element_line(color = "#222222", linewidth = 0.4) else element_blank(),
      axis.text.x = if (is_bottom) element_text(size = 7.8, color = "#111111") else element_blank(),
      panel.background = element_rect(fill = "#ffffff", color = NA),
      plot.background = element_rect(fill = "#ffffff", color = NA),
      plot.margin = margin(2, 5, if (is_bottom) 2 else 3, 5)
    )
  plots[[idx]] <- p_mod
}

combined <- patchwork::wrap_plots(plots, ncol = ncol_val) +
  patchwork::plot_annotation(
    caption = style$x_lab,
    theme = theme(
      plot.caption = element_text(hjust = 0.5, size = 10, color = "#111111", margin = margin(t = 4)),
      plot.background = element_rect(fill = "#ffffff", color = NA)
    )
  )

w_in <- as.numeric(style$width_in)
h_in <- as.numeric(style$height_in)
if (nrow_val > 7) {
  h_in <- max(h_in, nrow_val * 1.68)
}

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dpi <- as.numeric(style$dpi)
ggsave(file.path(out_dir, "replica.png"), combined, width = w_in, height = h_in, dpi = dpi, bg = "#ffffff")
grDevices::cairo_pdf(file.path(out_dir, "replica.pdf"), width = w_in, height = h_in, bg = "#ffffff")
print(combined)
grDevices::dev.off()
if (requireNamespace("svglite", quietly = TRUE)) {
  ggsave(file.path(out_dir, "replica.svg"), combined, width = w_in, height = h_in, device = "svg", bg = "#ffffff")
} else {
  grDevices::svg(file.path(out_dir, "replica.svg"), width = w_in, height = h_in, bg = "#ffffff")
  print(combined)
  grDevices::dev.off()
}
message(sprintf("Rendered %d modules (%d terms) -> %s", n_mods, nrow(df), out_dir))
