# 05_crosstalk_metabolism.R
# Parse official MOESM supplementary tables + real spatial checkpoint expression + metabolic pathway enrichment/scoring
# Input:
#   - data_small/moesm/: cellchat_edges.csv, cellphone_count.csv, cellphone_pvalue.csv,
#     enrich_fib.csv, enrich_ec.csv, enrich_mural.csv, corr_bulk.csv, corr_st.csv, supp1_clinical.csv
#   - data_small/st/caa_st_spots_scores.csv, data_small/st/caa_st_scored.qs
#   - data_small/scrna_stromal_small.qs
# Output (runs/step05_crosstalk/):
#   - fig2k_fib_malignant_lr.csv
#   - fig3a_bulk_corr_matrix.csv
#   - fig3c_checkpoint_box.csv
#   - fig3d_lr_bipartite.csv
#   - fig4i_ec_stromal_counts.csv
#   - fig5j_mural_ec_lr.csv
#   - fig6b_tme_stromal_counts.csv
#   - fig6c_ccl19_lr.csv
#   - fig6f_pgf_tam_lr.csv
#   - sfig5d_chord_edges.csv
#   - sfig6d_pgf_tme_lr.csv
#   - sfig2d_kegg_fib.csv
#   - sfig4d_kegg_ec.csv
#   - sfig5c_kegg_mural.csv
#   - metab_fig4k_ec.csv
#   - metab_fig5k_mural.csv
#   - metab_sfig2e_fib.csv
#   - receipt.json

r_libs <- strsplit(Sys.getenv("RWIKI_R_LIBS", ""), .Platform$path.sep)[[1]]
r_libs <- r_libs[nzchar(r_libs)]
if (length(r_libs)) {
  .libPaths(unique(c(r_libs, .libPaths())))
}
suppressPackageStartupMessages({
  library(Seurat)
  library(qs)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(jsonlite)
  library(tibble)
})

t0 <- proc.time()[["elapsed"]]
set.seed(42)

paper_root <- Sys.getenv("PAPER_ROOT", ".")
paper_dir <- paper_root
moesm_dir <- file.path(paper_dir, "data_small", "moesm")
st_csv_path <- file.path(paper_dir, "data_small", "st", "caa_st_spots_scores.csv")
st_qs_path  <- file.path(paper_dir, "data_small", "st", "caa_st_scored.qs")
sc_qs_path  <- file.path(paper_dir, "data_small", "scrna_stromal_small.qs")
out_dir <- file.path(paper_dir, "runs", "step05_crosstalk")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Check scMetabolism / AUCell honestly
has_scmetabolism <- requireNamespace("scMetabolism", quietly = TRUE)
has_aucell       <- requireNamespace("AUCell", quietly = TRUE)
scMetabolism_status <- if (has_scmetabolism) "available" else "not_run (scMetabolism not installed)"
cat("scMetabolism status:", scMetabolism_status, "\n")

# Helper to classify 57 cell types into compartments
classify_compartment <- function(x) {
  case_when(
    str_detect(x, "^C[0-9]+_Fib_") ~ "Fib",
    str_detect(x, "ArtECs|CapECs|tips_PGF|VenECs|tECs|emtECs|nECs|LECs") ~ "EC",
    str_detect(x, "PC$|PC\\+$|SMC$|SMC\\+$") ~ "Mural",
    str_detect(x, "^CD4_|^CD8_|Regulatory|Transitory|^NK$") ~ "T_NK",
    str_detect(x, "B$|Plasma") ~ "B_Plasma",
    str_detect(x, "^DC_|^M1$|^M2$|Mast|Neutrophil|pDC") ~ "Myeloid",
    x == "Epi" ~ "Epithelial",
    TRUE ~ "Other"
  )
}

# Load MOESM files
cellchat <- read_csv(file.path(moesm_dir, "cellchat_edges.csv"), show_col_types = FALSE)
cp_count <- read_csv(file.path(moesm_dir, "cellphone_count.csv"), show_col_types = FALSE)
cp_pval  <- read_csv(file.path(moesm_dir, "cellphone_pvalue.csv"), show_col_types = FALSE)
corr_bulk <- read_csv(file.path(moesm_dir, "corr_bulk.csv"), show_col_types = FALSE)
corr_st   <- read_csv(file.path(moesm_dir, "corr_st.csv"), show_col_types = FALSE)
enrich_fib   <- read_csv(file.path(moesm_dir, "enrich_fib.csv"), show_col_types = FALSE)
enrich_ec    <- read_csv(file.path(moesm_dir, "enrich_ec.csv"), show_col_types = FALSE)
enrich_mural <- read_csv(file.path(moesm_dir, "enrich_mural.csv"), show_col_types = FALSE)
supp1_clin   <- read_csv(file.path(moesm_dir, "supp1_clinical.csv"), show_col_types = FALSE)

# ---- 1. Fig 2K: Fib -> Epi/Malignant CellChat LR pairs (COLLAGEN/FN1-CD44/SDC4 etc.) ----
fig2k <- cellchat %>%
  filter(str_detect(source, "^C[0-9]+_Fib_"), target == "Epi", pval < 0.05) %>%
  filter(pathway_name %in% c("COLLAGEN", "FN1", "LAMININ", "THBS", "MK", "PTN", "TENASCIN", "IGFBP", "MIF")) %>%
  arrange(desc(prob))
write_csv(fig2k, file.path(out_dir, "fig2k_fib_malignant_lr.csv"))

# ---- 2. Fig 3A: Bulk & ST correlation matrix with C10_lpFib_ABCA8 ----
corr_bulk_clean <- corr_bulk %>%
  mutate(celltype_canonical = case_when(
    celltype == "cancer cell" ~ "Epi",
    TRUE ~ celltype
  )) %>%
  rename(celltype_bulk = celltype, bulk_corr_C10_lpFib_ABCA8 = C10_lpFib_ABCA8)

corr_st_clean <- corr_st %>%
  mutate(celltype_canonical = case_when(
    celltype == "Cytotoxic_T" ~ "CD8_Cytotoxic_T",
    celltype == "Exhausted_T" ~ "CD8_Exhausted_T",
    TRUE ~ celltype
  )) %>%
  rename(celltype_st = celltype, st_corr_C10_lpFib_ABCA8 = correlation, st_p_value = p_value, st_p_adj = p_adj)

fig3a <- full_join(corr_bulk_clean, corr_st_clean, by = "celltype_canonical") %>%
  mutate(
    compartment = case_when(
      str_detect(celltype_canonical, "Fib") ~ "Fib",
      str_detect(celltype_canonical, "EC_") ~ "EC",
      str_detect(celltype_canonical, "PC_|SMC_") ~ "Mural",
      str_detect(celltype_canonical, "_T$|Regulatory|NK") ~ "T_NK",
      str_detect(celltype_canonical, "\\.B$") ~ "B_Plasma",
      str_detect(celltype_canonical, "^DC_|^M1$|^M2$|Mast|Neutrophil|pDC") ~ "Myeloid",
      celltype_canonical == "Epi" ~ "Epithelial",
      TRUE ~ "Other"
    )
  ) %>%
  arrange(desc(bulk_corr_C10_lpFib_ABCA8))
write_csv(fig3a, file.path(out_dir, "fig3a_bulk_corr_matrix.csv"))

# ---- 3. Fig 3C: Immune checkpoint expression across ABCA8_high vs ABCA8_low Visium spots ----
st_scores <- read_csv(st_csv_path, show_col_types = FALSE)
st_obj <- qread(st_qs_path)
DefaultAssay(st_obj) <- "Spatial"

ckpt_genes <- c("PDCD1", "CTLA4", "HAVCR2", "CD274", "ICOS", "TNFRSF4", "TIGIT", "CD276")
ckpt_present <- intersect(ckpt_genes, rownames(st_obj))
ckpt_expr <- as.matrix(GetAssayData(st_obj, assay = "Spatial", layer = "data")[ckpt_present, , drop = FALSE])
ckpt_df <- as.data.frame(t(ckpt_expr)) %>%
  rownames_to_column("spot")

q25 <- as.numeric(quantile(st_scores$score_C10_lpFib_ABCA8, 0.25, na.rm = TRUE))
q75 <- as.numeric(quantile(st_scores$score_C10_lpFib_ABCA8, 0.75, na.rm = TRUE))
q50 <- as.numeric(median(st_scores$score_C10_lpFib_ABCA8, na.rm = TRUE))

st_ckpt_base <- st_scores %>%
  select(spot, abca8_score = score_C10_lpFib_ABCA8) %>%
  left_join(ckpt_df, by = "spot") %>%
  mutate(
    abca8_quartile_group = case_when(
      abca8_score >= q75 ~ "ABCA8_high",
      abca8_score <= q25 ~ "ABCA8_low",
      TRUE ~ "ABCA8_mid"
    ),
    abca8_median_group = ifelse(abca8_score >= q50, "ABCA8_high", "ABCA8_low")
  )

fig3c_long <- st_ckpt_base %>%
  pivot_longer(cols = all_of(ckpt_present), names_to = "gene", values_to = "expression")

# Compute Wilcoxon rank-sum p-values per gene (quartile high vs low, and median high vs low)
ckpt_stats <- fig3c_long %>%
  group_by(gene) %>%
  summarise(
    wilcox_p_quartile = wilcox.test(
      expression[abca8_quartile_group == "ABCA8_high"],
      expression[abca8_quartile_group == "ABCA8_low"]
    )$p.value,
    wilcox_p_median = wilcox.test(
      expression[abca8_median_group == "ABCA8_high"],
      expression[abca8_median_group == "ABCA8_low"]
    )$p.value,
    mean_high_q = mean(expression[abca8_quartile_group == "ABCA8_high"], na.rm = TRUE),
    mean_low_q  = mean(expression[abca8_quartile_group == "ABCA8_low"], na.rm = TRUE),
    .groups = "drop"
  )

fig3c <- fig3c_long %>% left_join(ckpt_stats, by = "gene")
write_csv(fig3c, file.path(out_dir, "fig3c_checkpoint_box.csv"))

# ---- 4. Fig 3D: Fib <-> T-cell immune checkpoint & immunomodulatory LR bipartite table ----
t_subsets_cp <- c("CD4_Effector_T", "CD4_Exhausted_T", "CD4_Naive_T", "CD4_Tfh",
                  "CD8_Cytotoxic_T", "Regulatory_T", "Transitory_T")
fib_subsets_cp <- grep("^C[0-9]+_Fib_", unique(cp_count$SOURCE), value = TRUE)

target_cp_pairs <- c(
  "LGALS9_HAVCR2", "LGALS9_CD44", "LGALS9_CD47", "CTLA4_CD86", "CTLA4_CD80",
  "CD28_CD86", "PDCD1_CD274", "PDCD1_PDCD1LG2", "PVR_TIGIT", "TIGIT_NECTIN2",
  "TIGIT_NECTIN3", "TNFSF4_TNFRSF4", "ICOSLG_ICOS", "CCL19_ACKR4", "CCR7_CCL19",
  "CCL21_CCR7", "CXCL12_CXCR4", "CD96_NECTIN1", "PVR_CD226", "CD226_NECTIN2"
)

cp_sub <- cp_pval %>% filter(interacting_pair %in% target_cp_pairs)
pair_cols <- colnames(cp_sub)[12:ncol(cp_sub)]
# Keep columns involving Fib and T subsets
fib_t_cols <- pair_cols[vapply(pair_cols, function(col_nm) {
  parts <- str_split_fixed(col_nm, "\\|", 2)
  (parts[1] %in% fib_subsets_cp && parts[2] %in% t_subsets_cp) ||
    (parts[2] %in% fib_subsets_cp && parts[1] %in% t_subsets_cp)
}, logical(1))]

cp_long <- cp_sub %>%
  select(interacting_pair, all_of(fib_t_cols)) %>%
  pivot_longer(cols = all_of(fib_t_cols), names_to = "pair_dir", values_to = "pval") %>%
  separate(pair_dir, into = c("cell_a", "cell_b"), sep = "\\|") %>%
  mutate(
    fib_subset = ifelse(cell_a %in% fib_subsets_cp, cell_a, cell_b),
    t_subset   = ifelse(cell_a %in% t_subsets_cp, cell_a, cell_b),
    direction  = ifelse(cell_a %in% fib_subsets_cp, "Fib_to_T", "T_to_Fib"),
    source_db  = "CellPhoneDB",
    pathway_name = "Checkpoint_Immune",
    score_or_prob = ifelse(pval == 0, 1.0, pmax(0, 1 - pval)),
    is_sig = pval < 0.05
  ) %>%
  select(source_db, fib_subset, t_subset, direction, interaction_name = interacting_pair,
         pathway_name, score_or_prob, pval, is_sig)

cc_fib_t <- cellchat %>%
  filter(str_detect(source, "^C[0-9]+_Fib_"),
         target %in% c("CD4_Effector_T", "CD4_Exhausted_T", "CD4_Naive_T", "CD4_Tfh",
                       "CD8_Cytotoxic_T", "Regulatory T", "Transitory_T"),
         pathway_name %in% c("GALECTIN", "NECTIN", "CXCL", "CCL", "MIF", "MHC-I", "MHC-II", "ICAM", "COLLAGEN", "FN1")) %>%
  mutate(
    source_db = "CellChat",
    fib_subset = str_remove(source, "\\+$"),
    t_subset   = str_replace_all(target, " ", "_"),
    direction  = "Fib_to_T",
    is_sig     = pval < 0.05
  ) %>%
  select(source_db, fib_subset, t_subset, direction, interaction_name,
         pathway_name, score_or_prob = prob, pval, is_sig)

fig3d <- bind_rows(cp_long, cc_fib_t) %>%
  arrange(source_db, desc(is_sig), pval, desc(score_or_prob))
write_csv(fig3d, file.path(out_dir, "fig3d_lr_bipartite.csv"))

# ---- 5. Fig 4I: CellPhoneDB EC <-> stromal subset counts ----
cp_annotated <- cp_count %>%
  mutate(
    source_compartment = classify_compartment(SOURCE),
    target_compartment = classify_compartment(TARGET)
  )

fig4i <- cp_annotated %>%
  filter((source_compartment == "EC" & target_compartment %in% c("Fib", "EC", "Mural")) |
           (target_compartment == "EC" & source_compartment %in% c("Fib", "EC", "Mural")))
write_csv(fig4i, file.path(out_dir, "fig4i_ec_stromal_counts.csv"))

# ---- 6. Fig 5J: Mural (C1_COL3A1+PC, C2_FN1+SMC) -> C4_tips_PGF+ CellChat LR pairs ----
fig5j <- cellchat %>%
  filter(source %in% c("C1_COL3A1+PC", "C2_FN1+SMC"), target == "C4_tips_PGF+", pval < 0.05) %>%
  arrange(desc(prob))
write_csv(fig5j, file.path(out_dir, "fig5j_mural_ec_lr.csv"))

# ---- 7. Fig 6B: All 57x57 TME & stromal interaction counts ----
write_csv(cp_annotated, file.path(out_dir, "fig6b_tme_stromal_counts.csv"))

# ---- 8. Fig 6C: C8_Fib_CCL19+ -> TME immune cell LR pairs ----
tme_immune_targets <- setdiff(unique(cellchat$target), c(
  grep("^C[0-9]+_", unique(cellchat$target), value = TRUE), "Epi"
))
fig6c <- cellchat %>%
  filter(source == "C8_Fib_CCL19+", target %in% tme_immune_targets, pval < 0.05) %>%
  arrange(desc(prob))
write_csv(fig6c, file.path(out_dir, "fig6c_ccl19_lr.csv"))

# ---- 9. Fig 6F: C4_tips_PGF+ -> TAM (M1, M2) LR pairs ----
fig6f <- cellchat %>%
  filter(source == "C4_tips_PGF+", target %in% c("M1", "M2"), pval < 0.05) %>%
  arrange(desc(prob))
write_csv(fig6f, file.path(out_dir, "fig6f_pgf_tam_lr.csv"))

# ---- 10. SFig 5D: VEGFA / VEGF LR chord edges across stromal subsets ----
sfig5d <- cellchat %>%
  filter(pathway_name == "VEGF" | ligand == "VEGFA") %>%
  mutate(
    source_compartment = classify_compartment(source),
    target_compartment = classify_compartment(target),
    is_stromal_to_stromal = source_compartment %in% c("Fib", "EC", "Mural") &
      target_compartment %in% c("Fib", "EC", "Mural")
  ) %>%
  filter(source_compartment %in% c("Fib", "EC", "Mural") | target_compartment %in% c("Fib", "EC", "Mural")) %>%
  arrange(desc(is_stromal_to_stromal), desc(prob))
write_csv(sfig5d, file.path(out_dir, "sfig5d_chord_edges.csv"))

# ---- 11. SFig 6D: PGF & Fib representative LR edges ----
sfig6d_pgf <- cellchat %>%
  filter(ligand == "PGF", pval < 0.05) %>%
  mutate(panel_subset = "PGF_ligand")
sfig6d_fib <- cellchat %>%
  filter(str_detect(source, "^C[0-9]+_Fib_"),
         pathway_name %in% c("COLLAGEN", "FN1", "CXCL", "CCL", "MIF", "PDGF", "TGFb", "VEGF"),
         pval < 0.05) %>%
  group_by(source, pathway_name) %>%
  slice_max(order_by = prob, n = 5, with_ties = FALSE) %>%
  ungroup() %>%
  mutate(panel_subset = "Fib_representative")
sfig6d <- bind_rows(sfig6d_pgf, sfig6d_fib) %>% arrange(panel_subset, desc(prob))
write_csv(sfig6d, file.path(out_dir, "sfig6d_pgf_tme_lr.csv"))

# ---- 12. SFig 2D / SFig 4D / SFig 5C: KEGG enrichment per subcluster from MOESM6 ----
sfig2d <- enrich_fib %>%
  arrange(group, p.adjust, pvalue)
write_csv(sfig2d, file.path(out_dir, "sfig2d_kegg_fib.csv"))

sfig4d <- enrich_ec %>%
  filter(Database == "KEGG") %>%
  group_by(Groups) %>%
  slice_min(order_by = pvalue, n = 10, with_ties = FALSE) %>%
  ungroup() %>%
  arrange(Groups, pvalue)
write_csv(sfig4d, file.path(out_dir, "sfig4d_kegg_ec.csv"))

sfig5c <- enrich_mural %>%
  filter(Database == "KEGG") %>%
  group_by(Groups) %>%
  slice_min(order_by = pvalue, n = 10, with_ties = FALSE) %>%
  ungroup() %>%
  arrange(Groups, pvalue)
write_csv(sfig5c, file.path(out_dir, "sfig5c_kegg_mural.csv"))

# ---- 13. Metabolism fallback (scMetabolism absent): MOESM6 KEGG metabolic enrichment + scRNA gene-set activity ----
srt_sc <- qread(sc_qs_path)
DefaultAssay(srt_sc) <- "RNA"
srt_sc <- NormalizeData(srt_sc, verbose = FALSE)
expr_sc <- as.matrix(GetAssayData(srt_sc, assay = "RNA", layer = "data"))

score_kegg_metabolism <- function(enrich_df, major_label, group_col = "Groups", is_fib = FALSE) {
  if (is_fib) {
    metab_df <- enrich_df %>%
      filter(str_detect(Description, regex("METABOL|GLYCOLYSIS|CITRATE|OXIDATIVE|FATTY|GLUTATHIONE|BIOSYNTHESIS|DEGRADATION", ignore_case = TRUE))) %>%
      mutate(Groups = .data[[group_col]])
  } else {
    metab_df <- enrich_df %>%
      filter(Database == "KEGG",
             str_detect(ID, "^hsa00|^hsa011|^hsa012") |
               str_detect(Description, regex("metabolism|glycolysis|citrate|oxidative|fatty|glutathione|biosynthesis|degradation", ignore_case = TRUE))) %>%
      group_by(Groups) %>%
      slice_min(order_by = pvalue, n = 5, with_ties = FALSE) %>%
      ungroup()
  }

  # Compute mean normalized gene-set expression in corresponding scRNA subclusters from scrna_stromal_small.qs
  sub_cells <- WhichCells(srt_sc, expression = major_type == major_label)
  sub_meta <- srt_sc@meta.data[sub_cells, , drop = FALSE]
  sub_expr <- expr_sc[, sub_cells, drop = FALSE]

  metab_df %>%
    rowwise() %>%
    mutate(
      genes_list = list(intersect(str_split(geneID, "/")[[1]], rownames(sub_expr))),
      n_genes_in_small_scrna = length(genes_list),
      scRNA_mean_activity = {
        cl_clean <- str_remove(Groups, "\\+$")
        idx <- which(sub_meta$subcluster == Groups | sub_meta$subcluster == cl_clean)
        if (length(genes_list) > 0 && length(idx) > 0) {
          mean(sub_expr[genes_list, idx, drop = FALSE])
        } else {
          NA_real_
        }
      },
      neg_log10_pval = -log10(pmax(pvalue, 1e-300)),
      activity_source = "MOESM6_KEGG_enrichment_plus_scRNA_mean_expr"
    ) %>%
    ungroup() %>%
    select(-genes_list) %>%
    arrange(Groups, pvalue)
}

metab_ec    <- score_kegg_metabolism(enrich_ec, "EC", "Groups", is_fib = FALSE)
metab_mural <- score_kegg_metabolism(enrich_mural, "Mural cell", "Groups", is_fib = FALSE)
metab_fib   <- score_kegg_metabolism(enrich_fib, "Fib", "group", is_fib = TRUE)

write_csv(metab_ec, file.path(out_dir, "metab_fig4k_ec.csv"))
write_csv(metab_mural, file.path(out_dir, "metab_fig5k_mural.csv"))
write_csv(metab_fib, file.path(out_dir, "metab_sfig2e_fib.csv"))

elapsed <- round(proc.time()[["elapsed"]] - t0, 3)

out_files <- c(
  "fig2k_fib_malignant_lr.csv", "fig3a_bulk_corr_matrix.csv", "fig3c_checkpoint_box.csv",
  "fig3d_lr_bipartite.csv", "fig4i_ec_stromal_counts.csv", "fig5j_mural_ec_lr.csv",
  "fig6b_tme_stromal_counts.csv", "fig6c_ccl19_lr.csv", "fig6f_pgf_tam_lr.csv",
  "sfig5d_chord_edges.csv", "sfig6d_pgf_tme_lr.csv",
  "sfig2d_kegg_fib.csv", "sfig4d_kegg_ec.csv", "sfig5c_kegg_mural.csv",
  "metab_fig4k_ec.csv", "metab_fig5k_mural.csv", "metab_sfig2e_fib.csv"
)

outputs_meta <- list()
for (fn in out_files) {
  fp <- file.path(out_dir, fn)
  tmp_df <- read_csv(fp, show_col_types = FALSE)
  outputs_meta[[fn]] <- list(path = fp, rows = nrow(tmp_df), cols = ncol(tmp_df))
}

receipt <- list(
  step = "step05_crosstalk",
  script = "src/05_crosstalk_metabolism.R",
  seed = 42L,
  status = "completed",
  scMetabolism_status = scMetabolism_status,
  aucell_status = if (has_aucell) "available" else "not_run (AUCell not installed)",
  scale_down_boundary = paste0(
    "MOESM6/7/8/9 tables use official full-cohort supplementary results (68,419 CellChat edges; 3,249 CellPhoneDB counts; ",
    "1,370 CellPhoneDB p-value rows; 41,750 EC & 27,769 Mural & 70 Fib enrichment rows; 57 bulk & 56 ST correlations). ",
    "Fig 3C checkpoint expression quartiles use real CAA_ST Visium spots (n = 2,241) instead of TCGA-BRCA bulk RNA-seq. ",
    "Metabolism outputs combine MOESM6 KEGG metabolic pathway enrichment with mean normalized expression in scrna_stromal_small.qs (n = 1,800 cells, 289 genes) because scMetabolism is not installed."
  ),
  clinical_cohort_n = nrow(supp1_clin),
  fig3c_checkpoint_wilcox = ckpt_stats,
  outputs = outputs_meta,
  elapsed_seconds = elapsed
)

write_json(receipt, file.path(out_dir, "receipt.json"), pretty = TRUE, auto_unbox = TRUE)
cat("Step 05 completed in", elapsed, "sec. Total CSVs:", length(out_files), "\n")
