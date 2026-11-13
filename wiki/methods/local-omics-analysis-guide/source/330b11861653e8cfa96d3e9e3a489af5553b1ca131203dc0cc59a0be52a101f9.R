#!/usr/bin/env Rscript

source(file.path("code", "R", "workflow_helpers.R"))

suppressPackageStartupMessages({
  library(linkET)
  library(clusterProfiler)
  library(org.Hs.eg.db)
  library(enrichplot)
  library(patchwork)
})

cfg <- wf_load_config()
wf_set_seed(cfg)
dirs <- wf_step_dirs(cfg, "6", "ube2l6_binary", "6.00_ube2l6_binary.R")
manifest <- wf_manifest_init()

objs <- readRDS(file.path(wf_step_dirs(cfg, "5", "bayesspace_domain")$rds, "spatial_with_domains.rds"))
cell_palette_tbl <- readr::read_csv(file.path(wf_step_dirs(cfg, "2", "preprocess_and_reference")$tables, "reference_celltype_palette.csv"), show_col_types = FALSE)
cell_palette <- setNames(cell_palette_tbl$color, cell_palette_tbl$celltype)

merged_list <- list()
cor_rows <- list()
ube_values_all <- unlist(lapply(objs, function(obj) {
  expr <- get_expr_matrix(obj, prefer = "data")
  as.numeric(expr["UBE2L6", colnames(obj)])
}), use.names = FALSE)
ube_limits <- wf_pretty_limits(ube_values_all, lower_q = 0.02, upper_q = 0.98, include_zero = TRUE)
ube_breaks <- wf_pretty_breaks(ube_limits, n = 4, include_zero = TRUE)


short_celltype_label <- function(x) {
  x <- gsub("_cells$", "", x)
  x <- gsub("_", " ", x)
  x <- gsub("^Fibroblasts$", "Fibro", x)
  x <- gsub("^Macrophage$", "Macroph.", x)
  x <- gsub("^Endothelial$", "Endo", x)
  x <- gsub("^SmoothMuscle$", "SMC", x)
  x <- gsub("^Plasma cells$", "Plasma", x)
  x
}

plot_compact_linket <- function(immune, cor_tbl, sample_id) {
  ct_order <- colnames(immune)
  plot_levels <- rev(ct_order)
  label_map <- setNames(short_celltype_label(ct_order), ct_order)
  cor_mat <- stats::cor(immune, method = "spearman", use = "pairwise.complete.obs")
  cor_mat[is.na(cor_mat) | is.infinite(cor_mat)] <- 0
  cor_mat <- cor_mat[ct_order, ct_order, drop = FALSE]

  cor_df <- as.data.frame(as.table(cor_mat), stringsAsFactors = FALSE) %>%
    transmute(
      row = Var1,
      col = Var2,
      cor = Freq,
      row_idx = match(Var1, ct_order),
      col_idx = match(Var2, ct_order)
    ) %>%
    filter(row_idx >= col_idx) %>%
    mutate(
      row = factor(row, levels = plot_levels),
      col = factor(col, levels = c(ct_order, "UBE2L6"))
    )

  rho_tbl <- cor_tbl %>%
    filter(celltype %in% ct_order) %>%
    mutate(
      row = factor(celltype, levels = plot_levels),
      col = factor("UBE2L6", levels = c(ct_order, "UBE2L6"))
    )

  sig_tbl <- rho_tbl %>% filter(fdr < 0.05)
  label_tbl <- sig_tbl %>% arrange(desc(abs(rho))) %>% slice_head(n = 4L)

  ggplot() +
    geom_tile(
      data = cor_df,
      aes(x = col, y = row, fill = cor),
      width = 0.96,
      height = 0.96,
      colour = "#E7E2D8",
      linewidth = 0.35
    ) +
    geom_tile(
      data = rho_tbl,
      aes(x = col, y = row, fill = rho),
      width = 0.72,
      height = 0.72,
      colour = NA
    ) +
    geom_tile(
      data = sig_tbl,
      aes(x = col, y = row),
      width = 0.72,
      height = 0.72,
      fill = NA,
      colour = "#2F2F2F",
      linewidth = 0.48
    ) +
    geom_text(
      data = label_tbl,
      aes(x = col, y = row, label = sprintf("%.2f", rho)),
      size = 2.7,
      fontface = "bold",
      colour = "#222222"
    ) +
    scale_x_discrete(position = "top", labels = c(label_map, UBE2L6 = "UBE2L6")) +
    scale_y_discrete(labels = label_map[plot_levels]) +
    scale_diverging_fill_paper(limits = c(-1, 1)) +
    guides(fill = guide_colorbar_paper(barheight_pt = 44, barwidth_pt = 8)) +
    labs(
      title = paste(sample_id, "cell-type correlation matrix"),
      x = NULL,
      y = NULL,
      fill = "Correlation"
    ) +
    coord_equal() +
    theme_heatmap_paper() +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 0, vjust = 0),
      axis.text.y = element_text(size = rel(0.95)),
      plot.margin = margin(8, 12, 8, 8)
    )
}
for (sample_id in names(objs)) {
  obj <- objs[[sample_id]]
  sample_label <- wf_sample_label(sample_id)
  expr <- get_expr_matrix(obj, prefer = "data")
  ube <- as.numeric(expr["UBE2L6", colnames(obj)])
  ube_group <- wf_binary_group(ube)
  obj$UBE2L6_expr <- ube
  obj[["UBE2L6_group"]] <- ube_group
  objs[[sample_id]] <- obj

  assign_tbl <- tibble(spot = colnames(obj), sample = sample_id, UBE2L6_expr = ube, UBE2L6_group = as.character(ube_group))
  assign_path <- file.path(dirs$tables, paste0(sample_id, "_UBE2L6_group_assignment.csv"))
  readr::write_csv(assign_tbl, assign_path)
  manifest <- wf_manifest_add(manifest, assign_path, "csv", "supplementary", "UBE2L6 High/Low assignments")

  p_expr <- wf_plot_spatial_continuous(
    wf_spatial_df(obj, "UBE2L6", "expr"),
    paste(sample_label, "UBE2L6"),
    legend_title = "UBE2L6",
    limits = ube_limits,
    breaks = ube_breaks,
    palette = "mako"
  )
  p_grp <- wf_plot_spatial_binary(obj, "UBE2L6_group", paste(sample_label, "Group"))
  manifest <- wf_copy_single_panel_pdf_png(p_expr, dirs, paste0(sample_id, "_UBE2L6_spatial"), width = 6.9, height = 6.0, paper_level = "main_text", note = "UBE2L6 continuous spatial", manifest = manifest)
  manifest <- wf_copy_single_panel_pdf_png(p_grp, dirs, paste0(sample_id, "_UBE2L6_group_spatial"), width = 6.9, height = 6.0, paper_level = "main_text", note = "UBE2L6 binary spatial", manifest = manifest)
  if (wf_export_spatial_composites(cfg)) {
    panel <- p_expr + p_grp + plot_layout(guides = "collect", widths = c(1.08, 0.92))
    manifest <- wf_copy_pdf_png(panel, dirs, paste0(sample_id, "_UBE2L6_spatial_composite"), width = 11, height = 5.4, paper_level = "supplementary", note = "Optional UBE2L6 composite spatial", manifest = manifest)
  }

  md <- obj@meta.data
  ct_cols <- wf_detect_celltype_cols(md, known = names(cell_palette))
  cor_tbl <- bind_rows(lapply(ct_cols, function(ct) {
    res <- suppressWarnings(cor.test(obj$UBE2L6_expr, md[[ct]], method = "spearman"))
    tibble(sample = sample_id, celltype = ct, rho = unname(res$estimate), p_value = res$p.value)
  })) %>%
    mutate(fdr = p.adjust(p_value, method = "BH"))
  cor_rows[[sample_id]] <- cor_tbl
  cor_path <- file.path(dirs$tables, paste0(sample_id, "_celltype_correlation.csv"))
  readr::write_csv(cor_tbl, cor_path)
  manifest <- wf_manifest_add(manifest, cor_path, "csv", "supplementary", "UBE2L6-celltype correlation")

  immune <- md[, ct_cols, drop = FALSE]
  immune <- immune[, vapply(immune, function(x) stats::sd(x, na.rm = TRUE) > 0, logical(1)), drop = FALSE]
  p_link <- plot_compact_linket(immune, cor_tbl, sample_id)
  manifest <- wf_copy_pdf_png(p_link, dirs, paste0(sample_id, "_linkET_celltype_cor"), width = 7.6, height = 6.8, paper_level = "main_text", note = "linkET celltype correlation", manifest = manifest)

  merged_list[[sample_id]] <- RenameCells(obj, add.cell.id = sample_id)
}

readr::write_csv(bind_rows(cor_rows), file.path(dirs$tables, "all_celltype_correlations.csv"))
combined_expr <- list()
group_vec <- character()
for (sample_id in names(objs)) {
  mat <- as.matrix(get_expr_matrix(objs[[sample_id]], prefer = "data"))
  new_cols <- paste(sample_id, colnames(mat), sep = "_")
  colnames(mat) <- new_cols
  combined_expr[[sample_id]] <- mat
  group_vals <- as.character(objs[[sample_id]]$UBE2L6_group)
  names(group_vals) <- new_cols
  group_vec <- c(group_vec, group_vals)
  names(group_vec)[(length(group_vec) - length(new_cols) + 1):length(group_vec)] <- new_cols
}
expr_all <- do.call(cbind, combined_expr)
group_counts <- table(group_vec, useNA = "ifany")
group_count_path <- file.path(dirs$tables, "UBE2L6_group_counts.csv")
readr::write_csv(tibble(group = names(group_counts), n = as.integer(group_counts)), group_count_path)
manifest <- wf_manifest_add(manifest, group_count_path, "csv", "supplementary", "Merged UBE2L6 group counts")

if (all(c("High", "Low") %in% names(group_counts)) && all(group_counts[c("High", "Low")] > 10)) {
  genes_use <- unique(unlist(lapply(merged_list, VariableFeatures)))
  genes_use <- intersect(genes_use, rownames(expr_all))
  if (length(genes_use) < 500) genes_use <- rownames(expr_all)
  high_cells <- names(group_vec)[group_vec == "High"]
  low_cells <- names(group_vec)[group_vec == "Low"]
  deg <- bind_rows(lapply(genes_use, function(g) {
    x <- as.numeric(expr_all[g, high_cells])
    y <- as.numeric(expr_all[g, low_cells])
    tibble(
      gene = g,
      avg_log2FC = mean(x, na.rm = TRUE) - mean(y, na.rm = TRUE),
      p_val = tryCatch(stats::wilcox.test(x, y)$p.value, error = function(e) NA_real_),
      pct.1 = mean(x > 0, na.rm = TRUE),
      pct.2 = mean(y > 0, na.rm = TRUE)
    )
  })) %>% mutate(p_val_adj = p.adjust(p_val, method = "BH")) %>% arrange(p_val_adj, desc(avg_log2FC))
  deg_path <- file.path(dirs$tables, "DEG_table.csv")
  readr::write_csv(deg, deg_path)
  manifest <- wf_manifest_add(manifest, deg_path, "csv", "supplementary", "High vs Low DEG")

  sel <- deg %>% filter(p_val_adj < 0.05, avg_log2FC > 0.15) %>% arrange(desc(avg_log2FC))
  if (nrow(sel) < 10) sel <- deg %>% arrange(desc(avg_log2FC)) %>% head(60)
  ids <- suppressWarnings(clusterProfiler::bitr(sel$gene, fromType = "SYMBOL", toType = "ENTREZID", OrgDb = org.Hs.eg.db))
  if (!is.null(ids) && nrow(ids) > 0) {
    ego <- clusterProfiler::enrichGO(gene = unique(ids$ENTREZID), OrgDb = org.Hs.eg.db, ont = "BP", pAdjustMethod = "BH", readable = TRUE)
    go_tbl <- as.data.frame(ego)
    go_path <- file.path(dirs$tables, "GO_table.csv")
    readr::write_csv(go_tbl, go_path)
    manifest <- wf_manifest_add(manifest, go_path, "csv", "supplementary", "GO enrichment")
    go_plot_tbl <- go_tbl %>%
      mutate(
        gene_ratio = parse_ratio_to_numeric(GeneRatio),
        sig = -log10(pmax(p.adjust, 1e-300))
      ) %>%
      filter(is.finite(gene_ratio), is.finite(sig)) %>%
      arrange(p.adjust, desc(gene_ratio), desc(Count)) %>%
      slice_head(n = 12L)
    if (nrow(go_plot_tbl) > 0) {
      sig_limits <- range(go_plot_tbl$sig, na.rm = TRUE)
      if (!all(is.finite(sig_limits)) || diff(sig_limits) <= 0) sig_limits <- NULL
      go_plot_tbl <- go_plot_tbl %>%
        mutate(Description = factor(Description, levels = rev(unique(Description))))
      p_go <- ggplot(go_plot_tbl, aes(x = gene_ratio, y = Description, size = Count, fill = sig)) +
        geom_point(shape = 21, colour = "#4A4A4A", stroke = 0.35, alpha = 0.96) +
        scale_size_summary_paper(go_plot_tbl$Count, name = "Count", max_size = 8.1, n_breaks = 4L, labels = scales::label_number(accuracy = 1)) +
        wf_scale_fill_ref2_bubble(limits = sig_limits) +
        scale_y_discrete(labels = label_wrap_paper(30)) +
        scale_x_continuous(labels = scales::label_percent(accuracy = 1), expand = expansion(mult = c(0.03, 0.08))) +
        labs(x = "Gene ratio", y = NULL, size = "Count", fill = "-log10(FDR)") +
        wf_theme_bubble_ref2() +
        guides(
          size = guide_legend_paper(override.aes = list(fill = "#DCE7EE"), nrow = 2),
          fill = guide_colorbar_paper(barheight_pt = 34, barwidth_pt = 8)
        ) +
        theme(
          axis.text.y = element_text(size = 7.8),
          legend.title = element_text(margin = margin(b = 4))
        )
      manifest <- wf_copy_pdf_png(p_go, dirs, "GO_dotplot", width = 7.2, height = 6.5, paper_level = "main_text", note = "GO dotplot", manifest = manifest)
    }
  }
}

saveRDS(objs, file.path(dirs$rds, "spatial_with_ube2l6_groups.rds"))
manifest <- wf_manifest_add(manifest, file.path(dirs$rds, "spatial_with_ube2l6_groups.rds"), "rds", "reject", "Objects with UBE2L6 metadata")
wf_manifest_write(dirs, manifest)
