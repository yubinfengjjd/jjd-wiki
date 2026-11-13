suppressPackageStartupMessages({
  library(Seurat)
  library(SeuratObject)
  library(AUCell)
  library(GSVA)
  library(UCell)
  library(singscore)
  library(org.Mm.eg.db)
  library(AnnotationDbi)
  library(KEGGREST)
  library(BiocParallel)
})

input_rds <- "GSE251716_seurat_annotated.rds"
output_rds <- "GSE251716_seurat_annotated_pathway_scored.rds"
audit_csv <- "pathway_score_gene_overlaps.csv"
assay_name <- "RNA"

get_expr_data <- function(object, assay) {
  tryCatch(
    SeuratObject::GetAssayData(object, assay = assay, layer = "data"),
    error = function(e) {
      SeuratObject::GetAssayData(object, assay = assay, slot = "data")
    }
  )
}

get_go_symbols <- function(go_ids) {
  if (length(go_ids) == 0) {
    return(character())
  }
  go_df <- AnnotationDbi::select(
    org.Mm.eg.db,
    keys = unique(go_ids),
    keytype = "GOALL",
    columns = "SYMBOL"
  )
  unique(na.omit(go_df[["SYMBOL"]]))
}

get_kegg_symbols <- function(pathway_ids) {
  symbols <- character()
  for (pathway_id in pathway_ids) {
    kegg_entry <- tryCatch(
      KEGGREST::keggGet(pathway_id)[[1]],
      error = function(e) {
        warning("Failed to read KEGG pathway ", pathway_id, ": ", conditionMessage(e))
        NULL
      }
    )
    if (is.null(kegg_entry) || is.null(kegg_entry[["GENE"]])) {
      next
    }
    entrez_ids <- kegg_entry[["GENE"]][seq(1, length(kegg_entry[["GENE"]]), by = 2)]
    gene_df <- AnnotationDbi::select(
      org.Mm.eg.db,
      keys = unique(entrez_ids),
      keytype = "ENTREZID",
      columns = "SYMBOL"
    )
    symbols <- c(symbols, gene_df[["SYMBOL"]])
  }
  unique(na.omit(symbols))
}

make_gene_set <- function(go_ids = character(), kegg_ids = character(), markers = character()) {
  unique(c(get_go_symbols(go_ids), get_kegg_symbols(kegg_ids), markers))
}

score_with_singscore <- function(expr_matrix, gene_sets) {
  gene_ranks <- singscore::rankGenes(expr_matrix)
  scores <- lapply(names(gene_sets), function(set_name) {
    result <- singscore::simpleScore(
      rankData = gene_ranks,
      upSet = gene_sets[[set_name]],
      centerScore = FALSE
    )
    result[["TotalScore"]]
  })
  scores_df <- as.data.frame(scores, check.names = FALSE)
  colnames(scores_df) <- paste0(names(gene_sets), "_singscore")
  rownames(scores_df) <- colnames(expr_matrix)
  scores_df
}

score_with_add_module <- function(object, gene_sets, assay) {
  for (set_name in names(gene_sets)) {
    object <- Seurat::AddModuleScore(
      object = object,
      features = list(gene_sets[[set_name]]),
      name = paste0(set_name, "_AddModule"),
      assay = assay,
      slot = "data"
    )
    colnames(object@meta.data)[ncol(object@meta.data)] <- paste0(set_name, "_AddModule")
  }
  object
}

pathway_specs <- list(
  AP1_FOSB_score = list(
    go = c("GO:0035976"),
    kegg = character(),
    markers = c("Fosb")
  ),
  Complement_total_score = list(
    go = c("GO:0006956"),
    kegg = c("mmu04610"),
    markers = character()
  ),
  Complement_classical_score = list(
    go = c("GO:0006958"),
    kegg = character(),
    markers = character()
  ),
  Inflammation_score = list(
    go = c("GO:0006954"),
    kegg = character(),
    markers = character()
  ),
  TNF_NFKB_score = list(
    go = c("GO:0034612", "GO:0007249"),
    kegg = c("mmu04668", "mmu04064"),
    markers = character()
  ),
  Microglia_activation_score = list(
    go = c("GO:0001774", "GO:0042116"),
    kegg = character(),
    markers = character()
  ),
  Reactive_glia_score = list(
    go = c("GO:0061900", "GO:0150103", "GO:0048143"),
    kegg = character(),
    markers = character()
  ),
  Oxidative_stress_NRF2_score = list(
    go = c("GO:0006979", "GO:0034599"),
    kegg = character(),
    markers = c("Nfe2l2")
  ),
  RGC_injury_score = list(
    go = c("GO:0048678"),
    kegg = character(),
    markers = c("Jun", "Atf3", "Socs3", "Gap43")
  ),
  RGC_identity_score = list(
    go = c("GO:0031290"),
    kegg = character(),
    markers = c("Rbpms", "Pou4f1", "Pou4f2", "Thy1", "Sncg", "Isl1")
  )
)

cat("Reading input: ", input_rds, "\n", sep = "")
UC <- readRDS(input_rds)
if (!inherits(UC, "Seurat")) {
  stop("Input object is not a Seurat object.")
}
if (!assay_name %in% names(UC@assays)) {
  stop("Assay not found: ", assay_name)
}
SeuratObject::DefaultAssay(UC) <- assay_name
expr <- get_expr_data(UC, assay_name)
if (is.null(rownames(expr)) || is.null(colnames(expr))) {
  stop("Expression matrix must have gene rownames and cell colnames.")
}

cat("Building pathway gene sets.\n")
raw_gene_sets <- lapply(pathway_specs, function(spec) {
  make_gene_set(
    go_ids = spec[["go"]],
    kegg_ids = spec[["kegg"]],
    markers = spec[["markers"]]
  )
})

gene_sets <- lapply(raw_gene_sets, function(genes) {
  intersect(unique(genes), rownames(expr))
})

empty_sets <- names(gene_sets)[vapply(gene_sets, length, integer(1)) == 0]
if (length(empty_sets) > 0) {
  stop("No genes overlap the expression matrix for: ", paste(empty_sets, collapse = ", "))
}

audit_df <- do.call(
  rbind,
  lapply(names(pathway_specs), function(set_name) {
    data.frame(
      pathway = set_name,
      go_ids = paste(pathway_specs[[set_name]][["go"]], collapse = ";"),
      kegg_ids = paste(pathway_specs[[set_name]][["kegg"]], collapse = ";"),
      marker_genes = paste(pathway_specs[[set_name]][["markers"]], collapse = ";"),
      raw_gene_count = length(raw_gene_sets[[set_name]]),
      overlap_gene_count = length(gene_sets[[set_name]]),
      overlap_genes = paste(gene_sets[[set_name]], collapse = ";"),
      stringsAsFactors = FALSE
    )
  })
)
write.csv(audit_df, audit_csv, row.names = FALSE)
cat("Wrote audit table: ", audit_csv, "\n", sep = "")
print(audit_df[, c("pathway", "raw_gene_count", "overlap_gene_count")], row.names = FALSE)

cat("Calculating AddModuleScore.\n")
UC <- score_with_add_module(UC, gene_sets, assay_name)

cat("Building AUCell rankings.\n")
cells_rankings <- AUCell::AUCell_buildRankings(expr, nCores = 1, plotStats = FALSE, verbose = FALSE)
cells_auc <- AUCell::AUCell_calcAUC(
  geneSets = gene_sets,
  rankings = cells_rankings,
  aucMaxRank = nrow(cells_rankings) * 0.05,
  nCores = 1,
  verbose = FALSE
)
auc_scores <- t(as.matrix(AUCell::getAUC(cells_auc)))
colnames(auc_scores) <- paste0(colnames(auc_scores), "_AUCell")
UC <- Seurat::AddMetaData(UC, as.data.frame(auc_scores[rownames(UC@meta.data), , drop = FALSE]))

cat("Calculating ssGSEA.\n")
expr_dense <- as.matrix(expr)
ssgsea_param <- GSVA::ssgseaParam(expr_dense, gene_sets, minSize = 1, maxSize = Inf, normalize = TRUE)
ssgsea_scores <- t(as.matrix(GSVA::gsva(ssgsea_param)))
colnames(ssgsea_scores) <- paste0(colnames(ssgsea_scores), "_ssGSEA")
UC <- Seurat::AddMetaData(UC, as.data.frame(ssgsea_scores[rownames(UC@meta.data), , drop = FALSE]))

cat("Calculating UCell.\n")
ucell_scores <- UCell::ScoreSignatures_UCell(
  matrix = expr,
  features = gene_sets,
  name = "_Ucell",
  ncores = 1,
  BPPARAM = BiocParallel::SerialParam()
)
UC <- Seurat::AddMetaData(UC, ucell_scores[rownames(UC@meta.data), , drop = FALSE])

cat("Calculating singscore.\n")
singscore_scores <- score_with_singscore(expr_dense, gene_sets)
UC <- Seurat::AddMetaData(UC, singscore_scores[rownames(UC@meta.data), , drop = FALSE])

cat("Combining raw scores.\n")
for (set_name in names(gene_sets)) {
  score_columns <- c(
    paste0(set_name, "_AddModule"),
    paste0(set_name, "_AUCell"),
    paste0(set_name, "_ssGSEA"),
    paste0(set_name, "_Ucell"),
    paste0(set_name, "_singscore")
  )
  missing_columns <- setdiff(score_columns, colnames(UC@meta.data))
  if (length(missing_columns) > 0) {
    stop("Missing intermediate score columns for ", set_name, ": ", paste(missing_columns, collapse = ", "))
  }
  UC@meta.data[[set_name]] <- rowSums(UC@meta.data[, score_columns, drop = FALSE], na.rm = TRUE)
}

intermediate_pattern <- paste0(
  "(",
  paste(c("_AddModule", "_AUCell", "_ssGSEA", "_Ucell", "_singscore"), collapse = "|"),
  ")$"
)
UC@meta.data <- UC@meta.data[, !grepl(intermediate_pattern, colnames(UC@meta.data)), drop = FALSE]

cat("Saving output: ", output_rds, "\n", sep = "")
saveRDS(UC, output_rds)
cat("Finished pathway scoring.\n")

# ============================================================
# Pathway 热图：细胞类型 × 样本 平均通路得分
# ============================================================

library(dplyr)
library(tibble)

source("pathway_heatmap_cns_function.R")

scored_rds <- "GSE251716_seurat_annotated_pathway_scored.rds"
cat("Reading scored object: ", scored_rds, "\n", sep = "")
GLC <- readRDS(scored_rds)

pathway_names <- c(
  "AP1_FOSB_score",
  "Complement_total_score",
  "Complement_classical_score",
  "Inflammation_score",
  "TNF_NFKB_score",
  "Microglia_activation_score",
  "Reactive_glia_score",
  "Oxidative_stress_NRF2_score",
  "RGC_injury_score",
  "RGC_identity_score"
)

# 确认所有通路列存在
missing_pw <- setdiff(pathway_names, colnames(GLC@meta.data))
if (length(missing_pw) > 0) {
  stop("Missing pathway columns: ", paste(missing_pw, collapse = ", "))
}

# 每个 celltype × phenotype 组合的平均通路得分
mean_df <- GLC@meta.data %>%
  dplyr::group_by(celltype, phenotype) %>%
  dplyr::summarise(
    dplyr::across(dplyr::all_of(pathway_names), ~ mean(.x, na.rm = TRUE)),
    n_cells = dplyr::n(),
    .groups = "drop"
  )

# 构建列名
mean_df$column <- paste(mean_df$celltype, mean_df$phenotype, sep = "_")

# 矩阵: rows = pathways, cols = celltype_phenotype
mat <- t(as.matrix(mean_df[, pathway_names]))
rownames(mat) <- pathway_names
colnames(mat) <- mean_df$column

# 列注释向量（named vector, names = colnames(mat)）
celltype_vec  <- setNames(as.character(mean_df$celltype),  mean_df$column)
anno1_vec     <- setNames(as.character(mean_df$phenotype),  mean_df$column)

cat("Matrix dimensions:", nrow(mat), "pathways x", ncol(mat), "columns\n")

# 配色
phenotype_colors <- c("Control" = "#71ad96", "Glaucoma" = "#5d5c84")

# 通路显示名称（去掉 _score 后缀）
display_names <- gsub("_score$", "", pathway_names)
display_names <- gsub("_", " ", display_names)
rownames(mat) <- display_names

pdf("pathway_heatmap.pdf", width = 10, height = 5, useDingbats = FALSE)
plot_pathway_heatmap_cns(
  mat                = mat,
  celltype           = celltype_vec,
  sample_anno1       = anno1_vec,
  celltype_order     = levels(GLC$celltype),
  anno1_name         = "Condition",
  anno1_colors       = phenotype_colors,
  scale_rows         = TRUE,
  show_panel_label   = FALSE,
  show_column_names  = FALSE,
  column_title_rot   = 45,
  row_names_fontsize    = 10,
  column_title_fontsize = 9,
  heatmap_width  = unit(10.5, "cm"),
  heatmap_height = unit(4.5, "cm")
)
dev.off()
cat("Pathway heatmap saved to: pathway_heatmap.pdf\n")

# ============================================================
# 补体通路小提琴图 (celltype × phenotype)
# ============================================================

library(ggpubr)
library(tidyr)
library(tidyverse)

#------------------[参数设置]------------------
type_groups <- c("Control", "Glaucoma")
color_scheme <- c("#FF7F0E", "#1F77B4")

#------------------[数据准备]------------------
plot_data <- GLC@meta.data %>%
  rownames_to_column("CellID") %>%
  filter(phenotype %in% type_groups) %>%
  mutate(Group = factor(phenotype, levels = type_groups)) %>%
  dplyr::select(CellID, Group, celltype, Complement_total_score) %>%
  rename(Value = Complement_total_score)

#------------------[统计学检验]------------------
stat_data <- plot_data %>%
  group_by(celltype) %>%
  summarise(
    p_value = wilcox.test(Value ~ Group)$p.value,
    y_max = max(Value) * 1.1,
    .groups = "drop"
  ) %>%
  mutate(
    p_label = case_when(
      p_value < 0.001 ~ "***P < 0.001",
      TRUE ~ paste0("*P = ", signif(p_value, 3)))
  )

mean_sd <- plot_data %>%
  group_by(celltype, Group) %>%
  summarise(
    mean = mean(Value, na.rm = TRUE),
    sd   = sd(Value, na.rm = TRUE),
    y_pos = quantile(Value, 0.90),
    .groups = "drop"
  ) %>%
  mutate(
    label = sprintf("Mean: %.2f\nSD: %.2f", mean, sd))

#------------------[可视化]------------------
p_comp <- ggplot(plot_data, aes(x = celltype, y = Value)) +
  geom_violin(aes(fill = Group),
    position = position_dodge(0.8),
    width = 0.7,
    alpha = 0.5,
    trim = FALSE,
    linewidth = 0.3) +
  geom_boxplot(aes(group = interaction(celltype, Group)),
    position = position_dodge(0.8),
    width = 0.18,
    outlier.size = 0.4,
    alpha = 0.85,
    linewidth = 0.3) +
  geom_jitter(aes(color = Group),
    position = position_jitterdodge(jitter.width = 0.18, dodge.width = 0.8),
    size = 0.6,
    alpha = 0.25) +
  geom_text(data = stat_data,
    aes(x = celltype, y = y_max, label = p_label),
    size = 3.2,
    vjust = -0.3,
    family = "Arial",
    inherit.aes = FALSE) +
  geom_text(data = mean_sd,
    aes(x = celltype, y = y_pos,
        label = label, group = Group),
    position = position_dodge(0.8),
    size = 2,
    color = "black",
    vjust = 0.5) +
  scale_fill_manual(values = color_scheme) +
  scale_color_manual(values = color_scheme) +
  labs(title = "Complement Pathway Score Comparison",
       y = "Pathway Score",
       x = NULL) +
  theme_classic(base_size = 11, base_family = "Arial") +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 13),
    axis.text.x = element_text(angle = 30, hjust = 1, size = 9, colour = "black"),
    axis.text.y = element_text(size = 9, colour = "black"),
    axis.title.y = element_text(size = 11),
    axis.ticks.length = unit(0.12, "cm"),
    legend.position = "top",
    legend.title = element_blank(),
    legend.text = element_text(size = 10),
    panel.grid.major.y = element_line(color = "grey90", linewidth = 0.3),
    plot.margin = margin(0.8, 0.8, 0.8, 0.8, "cm")
  ) +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.22)))

cairo_pdf(file = "complement_violin.pdf", width = 12, height = 6.5, family = "Arial")
print(p_comp)
dev.off()
cat("补体小提琴图已保存至: complement_violin.pdf\n")
