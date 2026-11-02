#!/usr/bin/env Rscript

source(file.path("code", "R", "workflow_helpers.R"))

suppressPackageStartupMessages({
  library(spdep)
  library(patchwork)
})

panel_clip <- c(0.02, 0.98)
legend_breaks <- c(0.00, 0.25, 0.50, 0.75, 1.00)
panel_background <- '#FFFFFF'
panel_palette <- 'cividis'
panel_point_size <- 2.55

gini_index <- function(x) {
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  if (length(x) == 0L) return(NA_real_)
  x <- x - min(x)
  total <- sum(x)
  if (!is.finite(total) || total <= 0) return(0)
  x <- sort(x)
  n <- length(x)
  (2 * sum(seq_len(n) * x) / (n * total)) - (n + 1) / n
}

cfg <- wf_load_config()
wf_set_seed(cfg)
dirs <- wf_step_dirs(cfg, "4", "svg_spatial", "4.00_svg_spatial.R")
manifest <- wf_manifest_init()

objs <- readRDS(file.path(wf_step_dirs(cfg, "2", "preprocess_and_reference")$rds, "spatial_preprocessed.rds"))

for (sample_id in names(objs)) {
  obj <- objs[[sample_id]]
  expr <- get_expr_matrix(obj, prefer = "data")
  var_genes <- head(VariableFeatures(obj), cfg$analysis$moran_top_var_genes)
  coords <- get_spatial_xy(obj)[colnames(expr), , drop = FALSE]
  knn <- spdep::knearneigh(as.matrix(coords), k = cfg$analysis$neighborhood_k)
  nb <- spdep::knn2nb(knn)
  lw <- spdep::nb2listw(nb, style = "W", zero.policy = TRUE)

  stat_list <- lapply(var_genes, function(g) {
    v <- as.numeric(expr[g, ])
    mt <- tryCatch(spdep::moran.test(v, lw, alternative = "greater", zero.policy = TRUE), error = function(e) NULL)
    tibble(gene = g, moran_I = mt$estimate[[1]] %||% NA_real_, p_value = mt$p.value %||% NA_real_, z_score = mt$statistic %||% NA_real_)
  })
  stat_tbl <- bind_rows(stat_list) %>% arrange(desc(moran_I), p_value)
  stat_path <- file.path(dirs$tables, paste0("MoranSVG_SVGs_", sample_id, ".csv"))
  readr::write_csv(stat_tbl, stat_path)
  manifest <- wf_manifest_add(manifest, stat_path, "csv", "supplementary", "Moran SVG ranking")

  display_tbl <- head(stat_tbl, cfg$analysis$moran_top_plots) %>%
    mutate(
      pattern_specificity = vapply(gene, function(g) {
        df <- wf_spatial_df(obj, g, source = "expr")
        scaled <- wf_scale01(df$value, lower_q = panel_clip[[1]], upper_q = panel_clip[[2]])
        gini_index(scaled)
      }, numeric(1))
    ) %>%
    arrange(desc(pattern_specificity), desc(moran_I), p_value) %>%
    mutate(panel_rank = seq_len(n()))
  panel_order_path <- file.path(dirs$tables, paste0("MoranSVG_panel_order_", sample_id, ".csv"))
  readr::write_csv(display_tbl, panel_order_path)
  manifest <- wf_manifest_add(manifest, panel_order_path, "csv", "supplementary", "Top Moran SVG panel order")

  plots <- lapply(display_tbl$gene, function(g) {
    df <- wf_spatial_df(obj, g, source = "expr")
    df$value <- wf_scale01(df$value, lower_q = panel_clip[[1]], upper_q = panel_clip[[2]])
    wf_plot_spatial_continuous(
      df,
      title = g,
      legend_title = g,
      limits = c(0, 1),
      palette = panel_palette,
      background = panel_background,
      point_size = panel_point_size,
      legend_barheight_pt = 44,
      legend_barwidth_pt = 8,
      breaks = legend_breaks,
      labels = sprintf("%.2f", legend_breaks)
    ) +
      theme(
        plot.margin = margin(3, 3, 3, 3),
        plot.background = element_rect(fill = panel_background, colour = NA),
        panel.background = element_rect(fill = panel_background, colour = NA)
      )
  })
  for (i in seq_along(plots)) {
    stem <- paste0(sample_id, "_MoranSVG_", sprintf("%02d", display_tbl$panel_rank[[i]]), "_", display_tbl$gene[[i]], "_spatial")
    manifest <- wf_copy_single_panel_pdf_png(plots[[i]], dirs, stem, width = 6.9, height = 6.0, paper_level = "main_text", note = paste0("Top Moran SVG spatial: ", display_tbl$gene[[i]]), manifest = manifest, bg = panel_background)
  }
  ncol_panel <- max(2, ceiling(length(plots) / 2))
  panel_width <- max(14.6, 3.0 * ncol_panel + 1.5)
  titled_plots <- Map(function(p, ttl) wf_with_subplot_title(p, ttl, size = 9.0, hjust = 0.5), plots, display_tbl$gene)
  panel <- wf_wrap_grouped_panel(titled_plots, ncol = ncol_panel, panel_background = panel_background, guides = "collect")
  manifest <- wf_copy_pdf_png(panel, dirs, paste0("MoranSVG_TopSVGs_spatial_", sample_id), width = panel_width, height = 7.0, paper_level = "supplementary", note = "Grouped Top Moran SVG spatial panels", manifest = manifest)
}

wf_manifest_write(dirs, manifest)
