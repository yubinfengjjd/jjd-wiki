#!/usr/bin/env Rscript

source(file.path("code", "R", "workflow_helpers.R"))

suppressPackageStartupMessages({
  library(Seurat)
})

cfg <- wf_load_config()
wf_set_seed(cfg)
dirs <- wf_step_dirs(cfg, "5", "bayesspace_domain", "5.00_bayesspace_domain.R")
manifest <- wf_manifest_init()

source_rctd_rds <- file.path(wf_step_dirs(cfg, "3", "rctd_deconvolution")$rds, "spatial_with_rctd.rds")
existing_domain_rds <- file.path(dirs$rds, "spatial_with_domains.rds")
objs <- if (file.exists(existing_domain_rds)) readRDS(existing_domain_rds) else readRDS(source_rctd_rds)

domain_labels <- paste0("Domain_", seq_len(cfg$analysis$domain_k))
domain_palette <- wf_spatial_domain_palette(domain_labels)
method_rows <- list()

compute_domain_display_spec <- function(objs) {
  topology_tbl <- bind_rows(lapply(names(objs), function(sample_id) {
    wf_spatial_df(objs[[sample_id]], "BayesSpace_domain", "meta") %>%
      group_by(value) %>%
      summarise(x = mean(x, na.rm = TRUE), y = mean(y, na.rm = TRUE), .groups = "drop") %>%
      mutate(
        sample = sample_id,
        x_scaled = if (dplyr::n() > 1L) scales::rescale(x) else 0.5,
        y_scaled = if (dplyr::n() > 1L) scales::rescale(y) else 0.5
      )
  }))
  raw_order <- topology_tbl %>%
    group_by(value) %>%
    summarise(x_scaled = mean(x_scaled), y_scaled = mean(y_scaled), .groups = "drop") %>%
    arrange(x_scaled, y_scaled) %>%
    pull(value)
  display_labels <- paste("Domain", seq_along(raw_order) - 1L)
  display_map <- setNames(display_labels, raw_order)
  list(raw_order = raw_order, display_levels = unname(display_map[raw_order]), display_map = display_map)
}

build_domain_plot <- function(obj, sample_id, display_spec, palette_display) {
  dom_df <- wf_spatial_df(obj, "BayesSpace_domain", "meta") %>%
    mutate(
      domain_raw = as.character(value),
      value = unname(display_spec$display_map[domain_raw])
    ) %>%
    select(x, y, value)

  label_map <- stats::setNames(gsub("^Domain\\s+", "", display_spec$display_levels), display_spec$display_levels)
  wf_plot_spatial_structure_ref2_style(
    dom_df,
    feature_name = sample_id,
    palette = palette_display,
    legend_title = "Spatial domain",
    point_size = 2.45,
    legend_levels = display_spec$display_levels,
    add_domain_labels = TRUE,
    label_map = label_map
  )
}

if (!file.exists(existing_domain_rds)) {
  for (sample_id in names(objs)) {
    obj <- objs[[sample_id]]
    emb <- Embeddings(obj, "pca")[, seq_len(min(15, ncol(Embeddings(obj, "pca")))), drop = FALSE]
    domain <- NULL
    method <- "kmeans_fallback"
    if (requireNamespace("BayesSpace", quietly = TRUE) && requireNamespace("SingleCellExperiment", quietly = TRUE)) {
      domain <- tryCatch({
        sce <- as.SingleCellExperiment(obj)
        sce <- BayesSpace::spatialPreprocess(sce, platform = "Visium", skip.PCA = FALSE, n.PCs = min(15, ncol(emb)), log.normalize = FALSE)
        sce <- BayesSpace::spatialCluster(sce, q = cfg$analysis$domain_k, platform = "Visium", d = min(15, ncol(emb)), nrep = 500, gamma = 2)
        as.character(SummarizedExperiment::colData(sce)$spatial.cluster)
      }, error = function(e) NULL)
      if (!is.null(domain)) method <- "BayesSpace"
    }
    if (is.null(domain)) domain <- as.character(stats::kmeans(emb, centers = cfg$analysis$domain_k, nstart = 20)$cluster)
    obj$BayesSpace_domain <- paste0("Domain_", domain)
    objs[[sample_id]] <- obj
    method_rows[[sample_id]] <- tibble(sample = sample_id, domain_method = method)
  }
  saveRDS(objs, existing_domain_rds)
} else {
  method_rows[[1]] <- tibble(sample = names(objs), domain_method = "reused_existing_rds")
}

display_spec <- compute_domain_display_spec(objs)
domain_palette_display <- setNames(unname(domain_palette[display_spec$raw_order]), display_spec$display_levels)

for (sample_id in names(objs)) {
  p <- build_domain_plot(objs[[sample_id]], sample_id, display_spec, domain_palette_display)
  manifest <- wf_copy_single_panel_pdf_png(p, dirs, paste0(sample_id, "_bayesspace_spatial"), width = 6.9, height = 6.0, paper_level = "main_text", note = "Domain spatial", manifest = manifest)
}

method_tbl <- bind_rows(method_rows)
method_path <- file.path(dirs$tables, "domain_assignment_method.csv")
readr::write_csv(method_tbl, method_path)
manifest <- wf_manifest_add(manifest, method_path, "csv", "supplementary", "BayesSpace method status")
manifest <- wf_manifest_add(manifest, existing_domain_rds, "rds", "reject", "Spatial objects with domains")

domain_summary <- bind_rows(lapply(names(objs), function(sample_id) {
  tibble(sample = sample_id, domain = objs[[sample_id]]$BayesSpace_domain) %>% count(sample, domain, name = "spots")
})) %>%
  mutate(
    sample = factor(sample, levels = names(objs)),
    domain_display = factor(unname(display_spec$display_map[domain]), levels = display_spec$display_levels)
  )
domain_summary_path <- file.path(dirs$tables, "domain_assignment.csv")
readr::write_csv(domain_summary, domain_summary_path)
manifest <- wf_manifest_add(manifest, domain_summary_path, "csv", "supplementary", "Domain assignments")

bar <- ggplot(domain_summary, aes(x = sample, y = spots, fill = domain_display)) +
  geom_col(position = position_fill(reverse = TRUE), colour = "white", linewidth = 0.35, width = 0.74) +
  scale_fill_manual(values = domain_palette_display, drop = FALSE) +
  scale_y_continuous(labels = scales::label_percent(accuracy = 1), breaks = seq(0, 1, by = 0.25), expand = expansion(mult = c(0, 0.02))) +
  labs(title = "Domain summary", x = NULL, y = "Spots (%)", fill = "Spatial domain") +
  theme_paper() +
  theme(
    panel.grid.major.y = element_line(colour = "#D9D9D9", linewidth = 0.3),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(face = "bold"),
    legend.title = element_text(margin = margin(b = 4))
  )
manifest <- wf_copy_pdf_png(bar, dirs, "domain_summary_barplot", width = 7.4, height = 5.6, paper_level = "main_text", note = "Domain summary", manifest = manifest)
wf_manifest_write(dirs, manifest)