#!/usr/bin/env Rscript

source(file.path("code", "R", "workflow_helpers.R"))

suppressPackageStartupMessages({
  library(FNN)
  library(patchwork)
})

cfg <- wf_load_config()
wf_set_seed(cfg)
dirs <- wf_step_dirs(cfg, "7", "neighborhood_celltype", "7.00_neighborhood_celltype.R")
manifest <- wf_manifest_init()

cell_palette_tbl <- readr::read_csv(file.path(wf_step_dirs(cfg, "2", "preprocess_and_reference")$tables, "reference_celltype_palette.csv"), show_col_types = FALSE)
objs <- readRDS(file.path(wf_step_dirs(cfg, "6", "ube2l6_binary")$rds, "spatial_with_ube2l6_groups.rds"))

compute_nhood <- function(coords, comp, k) {
  nn <- FNN::get.knn(as.matrix(coords), k = k)$nn.index
  out <- matrix(NA_real_, nrow = nrow(comp), ncol = ncol(comp), dimnames = list(rownames(comp), colnames(comp)))
  for (i in seq_len(nrow(comp))) out[i, ] <- colMeans(comp[nn[i, ], , drop = FALSE], na.rm = TRUE)
  out
}

display_ct <- function(x) wf_display_label(as.character(x))

center_focus_levels <- function(labels, scores) {
  labels <- as.character(labels)
  ord <- labels[order(as.numeric(scores), decreasing = TRUE, na.last = TRUE)]
  n <- length(ord)
  if (n <= 2) return(rev(ord))
  pos <- integer(0)
  center <- ceiling(n / 2)
  pos <- c(pos, center)
  step <- 1L
  while (length(pos) < n) {
    right <- center + step
    left <- center - step
    if (right <= n) pos <- c(pos, right)
    if (left >= 1) pos <- c(pos, left)
    step <- step + 1L
  }
  out <- character(n)
  out[pos[seq_len(n)]] <- ord
  out
}

pick_focal_celltypes <- function(all_stats) {
  score_tbl <- all_stats %>%
    group_by(celltype) %>%
    summarise(
      mean_effect = mean(effect_high_low, na.rm = TRUE),
      mean_abs_effect = mean(abs(effect_high_low), na.rm = TRUE),
      sig_support = sum(fdr < 0.05, na.rm = TRUE),
      best_fdr = min(fdr, na.rm = TRUE),
      .groups = "drop"
    )

  top_pos <- score_tbl %>%
    filter(is.finite(mean_effect), mean_effect > 0) %>%
    arrange(desc(sig_support), desc(mean_effect), desc(mean_abs_effect), best_fdr) %>%
    slice_head(n = 1)
  top_neg <- score_tbl %>%
    filter(is.finite(mean_effect), mean_effect < 0) %>%
    arrange(desc(sig_support), mean_effect, desc(mean_abs_effect), best_fdr) %>%
    slice_head(n = 1)

  bind_rows(top_pos, top_neg)
}

build_summary_plot <- function(all_stats) {
  rank_tbl <- all_stats %>%
    group_by(celltype) %>%
    summarise(
      focus_score = mean(abs(effect_high_low), na.rm = TRUE) + 0.02 * sum(fdr < 0.05, na.rm = TRUE),
      .groups = "drop"
    )
  focus_levels <- center_focus_levels(rank_tbl$celltype, rank_tbl$focus_score)
  max_abs <- max(abs(all_stats$effect_high_low), na.rm = TRUE)
  max_abs <- if (is.finite(max_abs) && max_abs > 0) max_abs else 0.01
  size_breaks <- pretty(c(0, max_abs), n = 3)
  size_breaks <- size_breaks[size_breaks >= 0 & size_breaks <= max_abs]
  fill_breaks <- pretty(c(-max_abs, max_abs), n = 5)
  fill_breaks <- fill_breaks[fill_breaks >= -max_abs & fill_breaks <= max_abs]

  plot_df <- all_stats %>%
    mutate(
      sample_label = factor(wf_sample_label(sample), levels = unique(wf_sample_label(sample))),
      celltype_label = factor(display_ct(celltype), levels = display_ct(focus_levels)),
      outline = ifelse(fdr < 0.05, "focus", "base")
    )

  ggplot(plot_df, aes(x = sample_label, y = celltype_label)) +
    geom_tile(fill = "#FBF8F3", colour = "#F0EAE0", linewidth = 0.35, width = 0.92, height = 0.92) +
    geom_point(aes(size = abs(effect_high_low), fill = effect_high_low, colour = outline), shape = 21, alpha = 0.96, stroke = 0.55) +
    scale_size_continuous(range = c(3.4, 10.8), breaks = size_breaks, limits = c(0, max_abs)) +
    scale_fill_gradient2(
      low = "#5E7B8F",
      mid = "#EFE7DA",
      high = "#B76445",
      midpoint = 0,
      limits = c(-max_abs, max_abs),
      breaks = fill_breaks,
      oob = scales::squish
    ) +
    scale_colour_manual(values = c(base = "#8A8076", focus = "#2F2924"), guide = "none") +
    labs(
      title = "Neighborhood niche summary",
      subtitle = "Bubble size encodes the High-Low magnitude; fill encodes direction.",
      x = NULL,
      y = NULL,
      size = "|High-Low|",
      fill = "High-Low"
    ) +
    guides(
      size = guide_legend(order = 1, override.aes = list(fill = "#CAD5D1", colour = "#4E4A44", alpha = 1)),
      fill = guide_colorbar_paper(barheight_pt = 42, barwidth_pt = 8)
    ) +
    theme_paper() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.x = element_text(face = "bold", colour = "#2B2B2B"),
      axis.text.y = element_text(colour = "#2B2B2B"),
      legend.box = "vertical",
      legend.spacing.y = grid::unit(2, "pt"),
      plot.title.position = "plot"
    )
}

build_focal_spatial_specs <- function(all_stats) {
  focal_tbl <- pick_focal_celltypes(all_stats)
  if (nrow(focal_tbl) == 0) return(tibble())

  bind_rows(lapply(seq_len(nrow(focal_tbl)), function(i) {
    ct <- focal_tbl$celltype[[i]]
    mean_eff <- focal_tbl$mean_effect[[i]]
    stat_row <- if (mean_eff >= 0) {
      all_stats %>% filter(celltype == ct) %>% arrange(desc(effect_high_low), fdr) %>% slice_head(n = 1)
    } else {
      all_stats %>% filter(celltype == ct) %>% arrange(effect_high_low, fdr) %>% slice_head(n = 1)
    }
    tibble(
      celltype = ct,
      sample = stat_row$sample,
      direction = ifelse(mean_eff >= 0, "High-enriched niche", "Low-enriched niche")
    )
  })) %>% distinct(celltype, sample, .keep_all = TRUE)
}

compute_focal_limits <- function(panel_specs, nhood_store) {
  all_values <- unlist(lapply(seq_len(nrow(panel_specs)), function(i) {
    nhood_store[[panel_specs$sample[[i]]]][, panel_specs$celltype[[i]], drop = TRUE]
  }))
  limits <- stats::quantile(all_values, probs = c(0.03, 0.97), na.rm = TRUE, names = FALSE, type = 7)
  if (!all(is.finite(limits)) || diff(limits) <= 0) limits <- range(all_values, na.rm = TRUE)
  limits
}

build_focal_spatial_plot <- function(sample_id, celltype, group_name, limits, nhood_store, coords_store, group_store) {
  df <- coords_store[[sample_id]]
  df$value <- nhood_store[[sample_id]][rownames(df), celltype]
  df$group <- as.character(group_store[[sample_id]][rownames(df)])
  df_highlight <- df[df$group == group_name, c("x", "y", "value"), drop = FALSE]
  backdrop_df <- df[, c("x", "y"), drop = FALSE]
  wf_plot_spatial_feature_ref1_style(
    df = df_highlight,
    feature_name = display_ct(celltype),
    legend_title = "Nhood abundance",
    limits = limits,
    point_size = 2.18,
    point_alpha = 0.98,
    legend_barheight_pt = 40,
    legend_barwidth_pt = 8,
    backdrop_df = backdrop_df,
    backdrop_size = 2.02,
    backdrop_fill = "#F4F4F4",
    backdrop_colour = "#D8D8D8",
    background = "#FFFFFF"
  ) +
    theme(legend.position = "right")
}

build_focal_spatial_panel <- function(panel_specs, limits, nhood_store, coords_store, group_store) {
  if (nrow(panel_specs) == 0) return(NULL)
  row_plots <- lapply(seq_len(nrow(panel_specs)), function(i) {
    sample_id <- panel_specs$sample[[i]]
    celltype <- panel_specs$celltype[[i]]
    (
      build_focal_spatial_plot(sample_id, celltype, "High", limits, nhood_store, coords_store, group_store) +
      build_focal_spatial_plot(sample_id, celltype, "Low", limits, nhood_store, coords_store, group_store)
    ) +
      plot_annotation(title = panel_specs$direction[[i]]) &
      theme(plot.title = element_text(size = 10.1, face = "bold", colour = "#2C2722"))
  })

  wrap_plots(row_plots, ncol = 1, guides = "collect") &
    theme(legend.position = "right")
}

stats_all <- list()
nhood_store <- list()
coords_store <- list()
group_store <- list()

for (sample_id in names(objs)) {
  obj <- objs[[sample_id]]
  md <- obj@meta.data
  ct_cols <- wf_detect_celltype_cols(md, known = cell_palette_tbl$celltype)
  comp <- md[, ct_cols, drop = FALSE]
  coords <- get_spatial_xy(obj)[rownames(comp), , drop = FALSE]
  nhood <- compute_nhood(coords, comp, cfg$analysis$neighborhood_k)
  rownames(nhood) <- rownames(comp)
  nhood_store[[sample_id]] <- nhood
  coords_store[[sample_id]] <- coords
  group_store[[sample_id]] <- setNames(as.character(obj$UBE2L6_group), rownames(comp))

  out_tbl <- as.data.frame(nhood)
  out_tbl$spot <- rownames(out_tbl)
  out_path <- file.path(dirs$tables, paste0(sample_id, "_nhood_matrix.csv"))
  readr::write_csv(out_tbl, out_path)
  manifest <- wf_manifest_add(manifest, out_path, "csv", "supplementary", "Neighborhood matrix")

  stat_tbl <- bind_rows(lapply(colnames(nhood), function(ct) {
    v <- nhood[, ct]
    high_mean <- mean(v[obj$UBE2L6_group == "High"], na.rm = TRUE)
    low_mean <- mean(v[obj$UBE2L6_group == "Low"], na.rm = TRUE)
    tibble(
      sample = sample_id,
      celltype = ct,
      high_mean = high_mean,
      low_mean = low_mean,
      effect_high_low = high_mean - low_mean,
      p_value = suppressWarnings(tryCatch(wilcox.test(v ~ obj$UBE2L6_group)$p.value, error = function(e) NA_real_))
    )
  })) %>% mutate(fdr = p.adjust(p_value, method = "BH")) %>% arrange(fdr, desc(abs(effect_high_low)))
  stats_all[[sample_id]] <- stat_tbl
}

all_stats <- bind_rows(stats_all)
stats_path <- file.path(dirs$tables, "nhood_effect_stats.csv")
readr::write_csv(all_stats, stats_path)
manifest <- wf_manifest_add(manifest, stats_path, "csv", "supplementary", "Neighborhood effect stats")

sum_plot <- build_summary_plot(all_stats)
manifest <- wf_copy_single_panel_pdf_png(sum_plot, dirs, "nhood_summary_plot", width = 7.8, height = 6.4, paper_level = "supplementary", note = "Neighborhood summary bubble", manifest = manifest, bg = "white")

panel_specs <- build_focal_spatial_specs(all_stats)
panel_limits <- if (nrow(panel_specs) > 0) compute_focal_limits(panel_specs, nhood_store) else c(0, 1)
if (nrow(panel_specs) > 0) {
  for (i in seq_len(nrow(panel_specs))) {
    sample_id <- panel_specs$sample[[i]]
    celltype <- panel_specs$celltype[[i]]
    for (group_name in c("High", "Low")) {
      p_one <- build_focal_spatial_plot(sample_id, celltype, group_name, panel_limits, nhood_store, coords_store, group_store)
      stem <- paste(sample_id, wf_sanitize_stem(celltype), tolower(group_name), "nhood_spatial", sep = "_")
      manifest <- wf_copy_single_panel_pdf_png(p_one, dirs, stem, width = 5.4, height = 5.7, paper_level = "supplementary", note = paste("Neighborhood niche spatial", display_ct(celltype), group_name), manifest = manifest, bg = "white")
    }
  }
}

panel <- build_focal_spatial_panel(panel_specs, panel_limits, nhood_store, coords_store, group_store)
if (wf_export_spatial_composites(cfg) && !is.null(panel)) {
  manifest <- wf_copy_pdf_png(panel, dirs, "high_low_celltype_spatial_panels", width = 11.2, height = 8.7, paper_level = "supplementary", note = "Optional High-vs-Low niche spatial composite", manifest = manifest)

  result_panel <- sum_plot +
    theme(
      legend.position = "none",
      plot.margin = margin(5.5, 8, 5.5, 5.5)
    ) |
    panel
  result_panel <- result_panel +
    plot_layout(widths = c(1.05, 1.35)) +
    plot_annotation(
      title = "Neighborhood niche result panel",
      subtitle = "Left: cross-sample effect summary. Right: representative spatial examples for the most consistent enriched and depleted niches."
    ) &
    theme(
      plot.title = element_text(face = "bold", size = 11.3),
      plot.subtitle = element_text(size = 8.7, colour = "#625A52")
    )
  manifest <- wf_copy_pdf_png(result_panel, dirs, "nhood_result_panel", width = 14.2, height = 7.2, paper_level = "supplementary", note = "Optional integrated neighborhood result panel", manifest = manifest)
}

saveRDS(objs, file.path(dirs$rds, "spatial_with_nhood.rds"))
manifest <- wf_manifest_add(manifest, file.path(dirs$rds, "spatial_with_nhood.rds"), "rds", "reject", "Objects with neighborhood context")
wf_manifest_write(dirs, manifest)