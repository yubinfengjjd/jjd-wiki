# 02_progeny_roe_cox.R
# Step 02: PROGENy pathway activity, Ro/e tissue & subtype preference + Cox survival merge,
# Chemokine/MHC Z-score expression matrices, and sample/tissue/subtype proportions.
# Faithful to upstream_repo/breastcancer-stromal-cell/{Fig2_CAF_program_distribution_progeny.R,
# Endo_Analysis_FullPipeline_Complete.R, PVL_Analysis_Final.R}
# Seed: 42

.libPaths(unique(c("E:/research-wiki-env/R-lib/figureya", "E:/research-wiki-env/R-lib-scp/4.5", .libPaths())))

suppressPackageStartupMessages({
  library(Seurat)
  library(progeny)
  library(qs)
  library(dplyr)
  library(tidyr)
  library(readr)
  library(tibble)
  library(jsonlite)
})

t0 <- proc.time()
set.seed(42)

paper_dir <- "E:/research-wiki-env/sources/papers/2026-cai-stromal-tme"
in_qs     <- file.path(paper_dir, "data_small", "scrna_stromal_small.qs")
moesm_dir <- file.path(paper_dir, "data_small", "moesm")
out_dir   <- file.path(paper_dir, "runs", "step02_progeny_roe_cox")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Canonical subcluster ordering matching Fig 2C, 4C, 5C ----
fib_levels <- c(
  "C1_mFib_ACTA2", "C2_ifnFib_HSPA6", "C3_lpFib_PLA2G2A", "C4_iFib_BNC2",
  "C5_iFib_CXCL8", "C6_iFib_NFKB1", "C7_lpFib_APOD", "C8_iFib_CCL19",
  "C9_mFib_COL12A1", "C10_lpFib_ABCA8", "C11_tFib_ENO1", "C12_apFib_CD74",
  "C13_lpFib_LUM", "C14_tFib_A2M"
)
ec_levels <- c(
  "C1_ArtEC_SEMA3G", "C2_ArtEC_DLL4", "C3_CapEC_CD36", "C4_TipEC_PGF",
  "C5_VenEC_HIF1A", "C6_VenEC_CD74", "C7_tEC_DOCK4", "C8_emtEC_CD24",
  "C9_emtEC_COL1A1", "C10_nEC_IL6", "C11_nEC_HMOX1", "C12_LEC_CCL21"
)
mural_levels <- c(
  "C1_tPC_COL3A1", "C2_tPC_CCL19", "C3_tPC_CD74", "C4_tPC_SEPT7",
  "C5_tPC_PRKG1", "C6_nPC_CXCL8", "C7_nPC_GJA5",
  "C1_SMC_MLY9", "C2_SMC_FN1", "C3_SMC_MYH11"
)

subcluster_to_canonical <- c(
  # Fib (14)
  "C1_Fib_ACTA2"   = "C1_mFib_ACTA2",
  "C2_Fib_HSPA6"   = "C2_ifnFib_HSPA6",
  "C3_Fib_PLA2G2A" = "C3_lpFib_PLA2G2A",
  "C4_Fib_BNC2"    = "C4_iFib_BNC2",
  "C5_Fib_CXCL8"   = "C5_iFib_CXCL8",
  "C6_Fib_NFKB1"   = "C6_iFib_NFKB1",
  "C7_Fib_APOD"    = "C7_lpFib_APOD",
  "C8_Fib_CCL19"   = "C8_iFib_CCL19",
  "C9_Fib_COL12A1" = "C9_mFib_COL12A1",
  "C10_Fib_ABCA8"  = "C10_lpFib_ABCA8",
  "C11_Fib_ENO1"   = "C11_tFib_ENO1",
  "C12_Fib_CD74"   = "C12_apFib_CD74",
  "C13_Fib_LUM"    = "C13_lpFib_LUM",
  "C14_Fib_A2M"    = "C14_tFib_A2M",
  # EC (12)
  "C1_ArtECs_SEMA3G+" = "C1_ArtEC_SEMA3G",
  "C2_ArtECs_DLL4+"   = "C2_ArtEC_DLL4",
  "C3_CapECs_CD36+"   = "C3_CapEC_CD36",
  "C4_tips_PGF+"      = "C4_TipEC_PGF",
  "C5_VenECs_HIF1A+"  = "C5_VenEC_HIF1A",
  "C6_VenECs_CD74+"   = "C6_VenEC_CD74",
  "C7_tECs_DOCK4+"    = "C7_tEC_DOCK4",
  "C8_emtECs_CD24+"   = "C8_emtEC_CD24",
  "C9_emtECs_COL1A1+" = "C9_emtEC_COL1A1",
  "C10_nECs_IL6+"     = "C10_nEC_IL6",
  "C11_nECs_HMOX1+"   = "C11_nEC_HMOX1",
  "C12_LECs_CCL21+"   = "C12_LEC_CCL21",
  # Mural (10)
  "C1_MLY9+SMC"  = "C1_SMC_MLY9",
  "C2_FN1+SMC"   = "C2_SMC_FN1",
  "C3_MYH11+SMC" = "C3_SMC_MYH11",
  "C1_COL3A1+PC" = "C1_tPC_COL3A1",
  "C2_CCL19+PC"  = "C2_tPC_CCL19",
  "C3_CD74+PC"   = "C3_tPC_CD74",
  "C4_SEPT7+PC"  = "C4_tPC_SEPT7",
  "C5_PRKG1+PC"  = "C5_tPC_PRKG1",
  "C6_CXCL8+PC"  = "C6_nPC_CXCL8",
  "C7_GJA5+PC"   = "C7_nPC_GJA5"
)

tissue_levels  <- c("Normal", "Tumor", "Lymphnode")
subtype_levels <- c("Normal", "Luminal_A", "Luminal_B", "HER2", "TNBC")

# ---- Load inputs ----
srt <- qread(in_qs)
DefaultAssay(srt) <- "RNA"
srt$subcluster <- as.character(srt@meta.data$subcluster)
srt$canonical_subcluster <- unname(subcluster_to_canonical[srt$subcluster])
srt <- NormalizeData(srt, normalization.method = "LogNormalize", scale.factor = 10000, verbose = FALSE)

cox_tcga <- read_csv(file.path(moesm_dir, "cox_tcga.csv"), show_col_types = FALSE) %>%
  transmute(
    canonical_subcluster = as.character(variable),
    tcga_HR = as.numeric(HR),
    tcga_lower95 = as.numeric(lower95),
    tcga_upper95 = as.numeric(upper95),
    tcga_p_value = as.numeric(p.value)
  )

cox_inhouse <- read_csv(file.path(moesm_dir, "cox_inhouse.csv"), show_col_types = FALSE) %>%
  transmute(
    canonical_subcluster = as.character(variable),
    inhouse_HR = as.numeric(HR),
    inhouse_lower95 = as.numeric(lower95),
    inhouse_upper95 = as.numeric(upper95),
    inhouse_p_value = as.numeric(p.value)
  )

progeny_model_100 <- progeny::getModel("Human", top = 100)
progeny_overlap_genes <- intersect(rownames(srt), rownames(progeny_model_100))

# ---- 1. PROGENy helper ----
run_progeny_subset <- function(sub_obj, cl_levels) {
  method_used <- "progeny_seurat"
  sub_obj <- tryCatch(
    {
      progeny::progeny(sub_obj, scale = FALSE, organism = "Human", top = 100, perm = 1, return_assay = TRUE)
    },
    error = function(e) {
      # SeuratObject >= 5.0.0 defuncts GetAssayData(..., slot="data") inside progeny.Seurat;
      # run progeny::progeny() directly on the normalized RNA matrix and attach assay.
      method_used <<- paste0("progeny_matrix_fallback (", conditionMessage(e), ")")
      expr_mat <- as.matrix(GetAssayData(sub_obj, assay = "RNA", layer = "data"))
      p_scores <- progeny::progeny(expr_mat, scale = FALSE, organism = "Human", top = 100, perm = 1)
      sub_obj[["progeny"]] <- CreateAssayObject(data = t(p_scores))
      sub_obj
    }
  )
  sub_obj <- Seurat::ScaleData(sub_obj, assay = "progeny", verbose = FALSE)
  scaled_mat <- as.matrix(GetAssayData(sub_obj, assay = "progeny", layer = "scale.data"))

  cells_df <- tibble::tibble(
    cell = colnames(sub_obj),
    canonical_subcluster = as.character(sub_obj@meta.data$canonical_subcluster)
  )

  long_df <- as.data.frame(t(scaled_mat)) %>%
    rownames_to_column("cell") %>%
    pivot_longer(-cell, names_to = "Pathway", values_to = "Activity") %>%
    inner_join(cells_df, by = "cell")

  sum_wide <- long_df %>%
    group_by(canonical_subcluster, Pathway) %>%
    summarise(avg = mean(Activity, na.rm = TRUE), .groups = "drop") %>%
    pivot_wider(names_from = Pathway, values_from = avg) %>%
    mutate(canonical_subcluster = factor(canonical_subcluster, levels = cl_levels)) %>%
    arrange(canonical_subcluster) %>%
    mutate(canonical_subcluster = as.character(canonical_subcluster))

  list(table = sum_wide, method = method_used)
}

# ---- 2. Ro/e + Cox helper ----
compute_roe_cox <- function(sub_obj, cl_levels) {
  md <- sub_obj@meta.data
  cl_fac <- factor(as.character(md$canonical_subcluster), levels = cl_levels)

  # Tissue Ro/e
  t_fac <- factor(as.character(md$tissue), levels = tissue_levels)
  obs_t <- table(cl_fac, t_fac)
  chi_t_warn <- NULL
  chi_t <- withCallingHandlers(
    chisq.test(obs_t),
    warning = function(w) {
      chi_t_warn <<- conditionMessage(w)
      invokeRestart("muffleWarning")
    }
  )
  roe_t <- as.data.frame.matrix(obs_t / chi_t$expected)
  colnames(roe_t) <- paste0("roe_tissue_", colnames(roe_t))

  # Subtype Ro/e
  s_fac <- factor(as.character(md$subtype), levels = subtype_levels)
  obs_s <- table(cl_fac, s_fac)
  chi_s_warn <- NULL
  chi_s <- withCallingHandlers(
    chisq.test(obs_s),
    warning = function(w) {
      chi_s_warn <<- conditionMessage(w)
      invokeRestart("muffleWarning")
    }
  )
  roe_s <- as.data.frame.matrix(obs_s / chi_s$expected)
  colnames(roe_s) <- paste0("roe_subtype_", colnames(roe_s))

  n_vec <- as.integer(rowSums(obs_t))

  out <- tibble::tibble(
    canonical_subcluster = cl_levels,
    n_cells = n_vec
  ) %>%
    left_join(cox_tcga, by = "canonical_subcluster") %>%
    left_join(cox_inhouse, by = "canonical_subcluster") %>%
    bind_cols(as_tibble(roe_s), as_tibble(roe_t))

  list(
    table = out,
    chi2_tissue = list(statistic = unname(chi_t$statistic), df = unname(chi_t$parameter), p_value = chi_t$p.value, warning = chi_t_warn),
    chi2_subtype = list(statistic = unname(chi_s$statistic), df = unname(chi_s$parameter), p_value = chi_s$p.value, warning = chi_s_warn)
  )
}

# ---- 3. Chemokine / MHC Z-score helper (Fig 2D, 4D, 5D) ----
chemokine_genes <- c(
  "CCL4L2", "CCL4", "CCL3L3", "CCL17", "CCL26", "CCL11", "CCL1", "CXCL13",
  "CCL5", "CXCL11", "CXCL10", "CXCL9", "CXCL6", "CXCL1", "CXCL3", "CCL20",
  "CXCL2", "CXCL8", "CXCL5", "CCL28", "CCL16", "XCL1", "CCL2", "CCL8",
  "CCL13", "CCL21", "CCL19", "CCL14", "CCL23", "CCL22", "CCL24", "CCL15",
  "CCL18", "CXCL12", "CXCL14", "CCL3", "CCL7", "CXCL16"
)
mhci_genes <- c("HLA-A", "HLA-B", "HLA-C", "MICA", "MICB")
mhcii_genes <- c("HLA-DRB5", "HLA-DQA1", "HLA-DQB1", "HLA-DQA2", "HLA-DQB2",
                 "HLA-DRA", "HLA-DRB1", "HLA-DPB1", "HLA-DPA1")
ec_angio_genes <- c("FLT1", "KDR", "NRP1", "FLT4", "NRP2", "TEK", "PDGFB",
                    "JAG1", "EFNB2", "HEY1", "DLL4", "HES1",
                    "ROBO1", "ROBO4", "PLXND1", "ROBO3", "UNC5B")

compute_chemokine_zscore <- function(sub_obj, cl_levels, include_ec_angio = FALSE) {
  gene_catalog <- bind_rows(
    tibble(gene = chemokine_genes, gene_group = "Chemokine"),
    tibble(gene = mhci_genes, gene_group = "MHC-I"),
    tibble(gene = mhcii_genes, gene_group = "MHC-II")
  )
  if (include_ec_angio) {
    gene_catalog <- bind_rows(
      tibble(gene = ec_angio_genes, gene_group = "Angiogenesis_Notch_Guidance"),
      gene_catalog
    )
  }
  gene_catalog <- gene_catalog %>%
    filter(gene %in% rownames(sub_obj)) %>%
    distinct(gene, .keep_all = TRUE)

  sub_obj$canonical_subcluster <- factor(as.character(sub_obj@meta.data$canonical_subcluster), levels = cl_levels)
  ae <- AverageExpression(
    sub_obj,
    assays = "RNA",
    features = gene_catalog$gene,
    group.by = "canonical_subcluster",
    verbose = FALSE
  )$RNA
  ae_mat <- as.matrix(ae)

  # Restore underscore subcluster names (Seurat v5 AverageExpression replaces '_' with '-')
  dash_to_canon <- setNames(cl_levels, gsub("_", "-", cl_levels))
  colnames(ae_mat) <- unname(dash_to_canon[colnames(ae_mat)])
  ae_mat <- ae_mat[gene_catalog$gene, cl_levels, drop = FALSE]

  # Row-wise Z-score across subclusters (matching standarize.fun in author scripts)
  z_mat <- t(apply(ae_mat, 1, function(x) {
    s <- sd(x, na.rm = TRUE)
    if (is.na(s) || s == 0) rep(0, length(x)) else (x - mean(x, na.rm = TRUE)) / s
  }))
  colnames(z_mat) <- cl_levels

  out <- gene_catalog %>%
    bind_cols(as_tibble(z_mat))
  out
}

# ---- 4. Sample / Tissue / Subtype proportion helper ----
compute_proportions <- function(sub_obj, cl_levels) {
  md <- sub_obj@meta.data %>%
    as_tibble() %>%
    transmute(
      batch = as.character(batch),
      tissue = as.character(tissue),
      subtype = as.character(subtype),
      canonical_subcluster = factor(as.character(canonical_subcluster), levels = cl_levels)
    )

  # Stratum 1: batch x tissue
  p_bt <- md %>%
    count(batch, tissue, canonical_subcluster, name = "n_cells", .drop = FALSE) %>%
    group_by(batch, tissue) %>%
    mutate(
      total_cells = sum(n_cells),
      proportion = ifelse(total_cells > 0, n_cells / total_cells, 0),
      stratum_type = "batch_tissue",
      sample_id = paste(batch, tissue, sep = "_"),
      subtype = NA_character_
    ) %>%
    ungroup()

  # Stratum 2: batch x subtype
  p_bs <- md %>%
    count(batch, subtype, canonical_subcluster, name = "n_cells", .drop = FALSE) %>%
    group_by(batch, subtype) %>%
    mutate(
      total_cells = sum(n_cells),
      proportion = ifelse(total_cells > 0, n_cells / total_cells, 0),
      stratum_type = "batch_subtype",
      sample_id = paste(batch, subtype, sep = "_"),
      tissue = ifelse(subtype == "Normal", "Normal", "Tumor_or_Lymphnode")
    ) %>%
    ungroup()

  # Stratum 3: tissue overall
  p_t <- md %>%
    count(tissue, canonical_subcluster, name = "n_cells", .drop = FALSE) %>%
    group_by(tissue) %>%
    mutate(
      total_cells = sum(n_cells),
      proportion = ifelse(total_cells > 0, n_cells / total_cells, 0),
      stratum_type = "tissue_overall",
      sample_id = tissue,
      batch = "ALL",
      subtype = NA_character_
    ) %>%
    ungroup()

  # Stratum 4: subtype overall
  p_s <- md %>%
    count(subtype, canonical_subcluster, name = "n_cells", .drop = FALSE) %>%
    group_by(subtype) %>%
    mutate(
      total_cells = sum(n_cells),
      proportion = ifelse(total_cells > 0, n_cells / total_cells, 0),
      stratum_type = "subtype_overall",
      sample_id = subtype,
      batch = "ALL",
      tissue = ifelse(subtype == "Normal", "Normal", "Tumor_or_Lymphnode")
    ) %>%
    ungroup()

  bind_rows(p_bt, p_bs, p_t, p_s) %>%
    mutate(canonical_subcluster = as.character(canonical_subcluster)) %>%
    select(stratum_type, sample_id, batch, tissue, subtype, canonical_subcluster, n_cells, total_cells, proportion)
}

# ---- Execute for Fib, EC, Mural ----
compartments <- list(
  fib   = list(major = "Fib",        levels = fib_levels,   ec_angio = FALSE),
  ec    = list(major = "EC",         levels = ec_levels,    ec_angio = TRUE),
  mural = list(major = "Mural cell", levels = mural_levels, ec_angio = FALSE)
)

progeny_methods <- list()
chi2_results <- list()
output_stats <- list()

for (nm in names(compartments)) {
  cfg <- compartments[[nm]]
  sub_obj <- subset(srt, subset = major_type == cfg$major)

  # PROGENy
  pr <- run_progeny_subset(sub_obj, cfg$levels)
  progeny_methods[[nm]] <- pr$method
  f_prog <- paste0("progeny_", nm, ".csv")
  write_csv(pr$table, file.path(out_dir, f_prog))
  output_stats[[f_prog]] <- list(rows = nrow(pr$table), cols = ncol(pr$table))

  # Ro/e + Cox
  rc <- compute_roe_cox(sub_obj, cfg$levels)
  chi2_results[[nm]] <- list(tissue = rc$chi2_tissue, subtype = rc$chi2_subtype)
  f_roe <- paste0("roe_cox_", nm, ".csv")
  write_csv(rc$table, file.path(out_dir, f_roe))
  output_stats[[f_roe]] <- list(
    rows = nrow(rc$table),
    cols = ncol(rc$table),
    tcga_matched = sum(!is.na(rc$table$tcga_HR)),
    inhouse_matched = sum(!is.na(rc$table$inhouse_HR))
  )

  # Chemokine / MHC Z-scores
  cz <- compute_chemokine_zscore(sub_obj, cfg$levels, include_ec_angio = cfg$ec_angio)
  f_chem <- paste0("chemokine_zscore_", nm, ".csv")
  write_csv(cz, file.path(out_dir, f_chem))
  output_stats[[f_chem]] <- list(rows = nrow(cz), cols = ncol(cz))

  # Tissue & subtype proportions
  tp <- compute_proportions(sub_obj, cfg$levels)
  f_prop <- paste0("tissue_prop_", nm, ".csv")
  write_csv(tp, file.path(out_dir, f_prop))
  output_stats[[f_prop]] <- list(rows = nrow(tp), cols = ncol(tp))
}

elapsed_sec <- as.numeric((proc.time() - t0)[["elapsed"]])

receipt <- list(
  step = "step02_progeny_roe_cox",
  script = "src/02_progeny_roe_cox.R",
  seed = 42L,
  elapsed_seconds = round(elapsed_sec, 3),
  scale_down_boundary = paste0(
    "Computed on the 1,800-cell x 289-gene stratified small scRNA object (Fib=700, EC=600, Mural=500; ",
    "50 cells/subcluster across 36 subclusters) merged with real MOESM5 Cox tables (cox_tcga.csv, cox_inhouse.csv)."
  ),
  progeny_details = list(
    organism = "Human",
    top = 100L,
    perm = 1L,
    scale = FALSE,
    post_scale = "Seurat::ScaleData(assay='progeny')",
    model_genes_total = nrow(progeny_model_100),
    overlap_genes_count = length(progeny_overlap_genes),
    overlap_genes = progeny_overlap_genes,
    methods_used = progeny_methods
  ),
  chi2_tests = chi2_results,
  outputs = output_stats
)

write_json(receipt, file.path(out_dir, "receipt.json"), auto_unbox = TRUE, pretty = TRUE)
cat("Step 02 completed in", round(elapsed_sec, 2), "seconds.\n")
