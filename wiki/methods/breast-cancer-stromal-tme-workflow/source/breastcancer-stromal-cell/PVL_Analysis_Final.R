# ===============================================
# PVL Analysis Final Script (Optimized, Readable)
# ===============================================

library(SCP)
library(harmony)
library(Seurat)
library(ggpubr)
library(dplyr)
library(tidyverse)
library(patchwork)
library(ComplexHeatmap)
library(circlize)
library(vegan)
library(openxlsx)
library(ggplot2)
library(qs)
library(scCustomize)
library(progeny)
library(scMetabolism)
library(limma)

# ===============================================
# 1. Load PVL Seurat Object
# ===============================================
sub_PVL <- qread("result/fig3_PVL/sub_PVL_umap.qs")
DefaultAssay(sub_PVL) <- 'RNA'
sub_PVL <- DietSeurat(sub_PVL, assays = "RNA")

# ===============================================
# 2. Integration & Re-clustering
# ===============================================
# Mark low-count samples as "newdata"

# fastMNN integration
sub_PVL <- Integration_SCP(
  srtMerge = sub_PVL, batch = "batch", nHVF =4000,
  vars_to_regress = c("nCount_RNA","percent_mito"),
  neighbor_k = 30L,
  cluster_resolution = c(0.6,0.7,0.8,0.9),
  integration_method = "fastMNN"
)

# Harmony integration
sub_PVL <- Integration_SCP(
  srtMerge = sub_PVL, batch = "batch", nHVF =4000,
  vars_to_regress = c("nCount_RNA","percent_mito"),
  neighbor_k = 30L,
  cluster_resolution = c(0.3,0.4,0.5),
  integration_method = "Harmony"
)

sub_PVL$Harmonyclusters <- sub_PVL$Harmony_SNN_res.0.3


qsave(sub_PVL, "result/fig3_PVL/sub_PVL_re_analysis.qs")

# ===============================================
# 3. DE analysis & annotation
# ===============================================
register(MulticoreParam(workers = 8, progressbar = TRUE))
sub_PVL <- RunDEtest(sub_PVL, group_by = "Harmony_SNN_res.0.3", fc.threshold = 1, only.pos = FALSE)
DEGs <- sub_PVL@tools$DEtest_Harmony_SNN_res.0.3$AllMarkers_wilcox
DEGs <- DEGs %>% filter(avg_log2FC > 0.7, p_val_adj < 0.05) %>% mutate(PCT = pct.1 - pct.2) %>% filter(PCT > 0.1)

# Annotate transcription factors and surface proteins
sub_PVL <- AnnotateFeatures(sub_PVL, db = c("TF", "CSPA"))

# ===============================================
# 4. Subcluster annotation
# ===============================================
# SMC and PC subclusters
sub_PVL$subclusters <- factor(
  case_when(
    sub_PVL$Harmonyclusters %in% c(0,5,9) ~ c("C1_MLY9+SMC","C2_FN1+SMC","C3_MYH11+SMC")[match(sub_PVL$Harmonyclusters[c(0,5,9)], c(0,5,9))],
    sub_PVL$Harmonyclusters %in% c(2,4,8,7,3,6,1) ~ c("C1_COL3A1+PC","C2_CCL19+PC","C3_CD74+PC","C4_SEPT7+PC",
                                                      "C5_PRKG1+PC","C6_CXCL8+PC","C7_GJA5+PC")[match(sub_PVL$Harmonyclusters[c(2,4,8,7,3,6,1)], c(2,4,8,7,3,6,1))],
    TRUE ~ NA_character_
  ),
  levels = c("C1_MLY9+SMC","C2_FN1+SMC","C3_MYH11+SMC",
             "C1_COL3A1+PC","C2_CCL19+PC","C3_CD74+PC","C4_SEPT7+PC",
             "C5_PRKG1+PC","C6_CXCL8+PC","C7_GJA5+PC")
)

sub_PVLmaker <- c(
  'MYL9','RERGL','MUSTN1', #MLY9+SMC 0
  'FN1','EGFL6','IFI27', #FN1+SMC 5
  'MYH11','GADD45B','SORBS2', #MYH11+PC 9
  
  'COL3A1','LUM','POSTN', #COL3A1+PC 2
  'CCL19','CCL21','C1S',#CCL19+PC 4
  'CD74','APOD','AZGP1', #CD74+PC 8
  'SEPT7','H3F3A','SEPT4', #SEPT7+PC 7
  'PRKG1','DLC1','CCDC102B',#PRKG1+PC 3
  'CXCL8','CXCL3','CXCL2', #CXCL8+PC 6
  'CRYAB','LDLR','GJA5' #IER3+PC 1
)
DotPlot(sub_PVL, cols = c("white", "#F15F30"), features =sub_PVLmaker, 
        group.by = "subclusters", dot.scale = 6) +   
  scale_size(range = c(1,4),breaks = c(0,25,50,75))+
  scale_colour_gradient2(low = "#242467", mid = "#f0f1f2", high = "#f20d0d",midpoint = 0.5) + theme(axis.text.y = element_text(size = 4)) + labs(x= "", y = "") + theme(axis.text.x = element_text(size = 6, angle = 90))

ggsave("result/fig3_PVL/sub_PVL_maker.pdf",width = 6,height = 4)

qsave(sub_PVL,"result/fig3_PVL/sub_PVL_re_analysis.qs")

# ===============================================
# 5. FeatureHeatmap
# ===============================================
plot_heatmap <- function(seurat_obj, genes, group.by = "subclusters", title = NULL){
  expr_avg <- AverageExpression(seurat_obj, assays = 'RNA', features = genes, group.by = group.by)$RNA
  df <- t(scale(t(as.data.frame(expr_avg)), center = TRUE, scale = TRUE))
  Heatmap(df, cluster_rows = FALSE, cluster_columns = TRUE,
          column_dend_height = unit(1.5,"cm"),
          clustering_distance_columns = "pearson",
          col = colorRamp2(c(-1,0,1), c("blue","white","red")),
          rect_gp = gpar(col = "white", lty = 1, lwd = 1),
          column_names_gp = gpar(fontsize=8),
          row_names_gp = gpar(fontsize=8),
          name = "scale",
          column_title = title)
}

# Example: chemokines heatmap
gene_chemokines <- read_csv("rawdata/gene_chemokines.csv")$gene
pdf("result/fig3_PVL/PVL_chemokines_heatmap.pdf", width = 8, height = 3)
draw(plot_heatmap(sub_PVL, gene_chemokines, title = "Chemokines"))
dev.off()

# ===============================================
# 6. Metabolism dotchart function
# ===============================================
plot_metabolism_dotchart <- function(df, celltype_colors, title){
  df <- df %>% filter(logFC > 0)
  df$logP <- -log(df$P.Value)
  ggdotchart(df, y = "logP", x = "KEGGID",
             title = title, xlab = '', ylab = "-Log (P value)",
             color = "celltype", size = 'logFC',
             palette = celltype_colors,
             sorting = "ascending",
             add = "segments", rotate = TRUE,
             ggtheme = theme_classic())
}

# ===============================================
# 7. Loop through all metabolism groups
# ===============================================
metabolism_groups <- list(
  Lipid_metabolism = c('alpha-Linolenic acid metabolism','Fatty acid degradation','Fatty acid biosynthesis',
                       'Fatty acid elongation','Ether lipid metabolism','Biosynthesis of unsaturated fatty acid',
                       'Arachidonic acid metabolism','Steroid biosynthesis','Sphingolipid metabolism',
                       'Steroid hormone biosynthesis','Glycerophospholipid metabolism','Glycerolipid metabolism',
                       'Primary bile acid biosynthesis','Linoleic acid metabolism'),
  
  Carbohydrate_metabolism = c('Galactose metabolism','Ascorbate and aldarate metabolism','Starch and sucrose metabolism',
                              'Glycolysis / Gluconeogenesis','Fructose and mannose metabolism','Propanoate metabolism',
                              'Inositol phosphate metabolism','Amino sugar and nucleotide sugar metabolism','Butanoate metabolism',
                              'Pentose phosphate pathway','Pentose and glucuronate interconversions','Glyoxylate and dicarboxylate metabolism',
                              'Pyruvate metabolism','Citrate cycle (TCA cycle)'),
  
  Xenobiotics_biodegradation_and_metabolism = c('Drug metabolism - cytochrome P450',
                                                'Drug metabolism - other enzymes',
                                                'Metabolism of xenobiotics by cytochrome P450'),
  
  Nucleotide_metabolism = c('Pyrimidine metabolism','Purine metabolism'),
  
  Energy_metabolism = c('Nitrogen metabolism','Sulfur metabolism','Oxidative phosphorylation'),
  
  Metabolism_of_cofactors_and_vitamins = c('Pand nicotinamide metabolism','Folate biosynthesis','Retinol metabolism',
                                           'Pantothenate and CoA biosynthesis','Lipoic acid metabolism','Thiamine metabolism',
                                           'Ubiquinone and other terpenoid-quinone biosynthesis','Porphyrin and chlorophyll metabolism',
                                           'Biotin metabolism','One carbon pool by folate','Vitamin B6 metabolism','Riboflavin metabolism'),
  
  Glycan_biosynthesis_and_metabolism = c('Glycosaminoglycan biosynthesis - heparan sulfate / heparin',
                                         'Mucin type O-glycan biosynthesis','Glycosylphosphatidylinositol (GPI)-anchor biosynthesis',
                                         'Glycosaminoglycan biosynthesis - keratan sulfate','Mannose type O-glycan biosynthesis',
                                         'Other types of O-glycan biosynthesis','Glycosaminoglycan biosynthesis - chondroitin sulfate / dermatan sulfate',
                                         'Glycosphingolipid biosynthesis - lacto and neolacto series','Glycosphingolipid biosynthesis - ganglio series',
                                         'Other glycan degradation','Glycosaminoglycan degradation','Glycosphingolipid biosynthesis - globo and isoglobo series',
                                         'Various types of N-glycan biosynthesis','N-Glycan biosynthesis'),
  
  Metabolism_of_other_amino_acids = c('Taurine and hypotaurine metabolism','beta-Alanine metabolism','Selenocompound metabolism',
                                      'D-Amino acid metabolism','Glutathione metabolism','Phosphonate and phosphinate metabolism')
)

# Loop
for (group_name in names(metabolism_groups)) {
  pathways <- metabolism_groups[[group_name]]
  df_group <- outputdf %>% filter(KEGGID %in% pathways)
  if (nrow(df_group) > 0) {
    pdf(file = paste0("result/fig3_PVL/metabolism/", group_name, "_dotchart.pdf"), width = 8, height = 6)
    plot_metabolism_dotchart(df_group, celltype_color, title = group_name)
    dev.off()
  }
}

# ===============================================
# 8. Remaining PVL analyses remain unchanged
# (FeaturePlot, ModuleScore, Distribution, PROGENy, etc.)
# ===============================================