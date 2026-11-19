# =============================================
# Endo 一键分析完整脚本
# 保留细胞注释 marker
# =============================================

# ----------------------------
# 1. 载入库
# ----------------------------
library(Seurat)
library(SCP)
library(harmony)
library(scMetabolism)
library(progeny)
library(ggpubr)
library(patchwork)
library(dplyr)
library(tidyverse)
library(ComplexHeatmap)
library(circlize)
library(openxlsx)
library(qs)
library(BiocParallel)
library(rsvd)

# ----------------------------
# 2. 输出目录
# ----------------------------
dirs <- c("result/fig4_Endo", 
          "result/fig4_Endo/metabolism")
for(d in dirs){ if(!dir.exists(d)) dir.create(d, recursive = TRUE) }

# ----------------------------
# 3. 自定义函数
# ----------------------------
standarize.fun <- function(indata=NULL, halfwidth=NULL, centerFlag=TRUE, scaleFlag=TRUE) {
  outdata <- t(scale(t(indata), center=centerFlag, scale=scaleFlag))
  if(!is.null(halfwidth)){
    outdata[outdata > halfwidth] <- halfwidth
    outdata[outdata < -halfwidth] <- -halfwidth
  }
  return(outdata)
}

# FeaturePlot 保存函数
FeaturePlot_save <- function(srt, features, reduction='fastMNNUMAP2D', ncol=3, pt.size=0.1, file=NULL, width=10, height=8){
  plots <- lapply(features, function(g){
    FeaturePlot_scCustom(srt, reduction=reduction, pt.size=pt.size,
                         colors_use=colorRampPalette(c("white", "#D53E4F"))(100),
                         features=g) + NoAxes()
  })
  p <- wrap_plots(plots, ncol=ncol)
  if(!is.null(file)) ggsave(file, p, width=width, height=height)
  return(p)
}

# Metabolism 绘图函数
Metabolism_dotchart <- function(df, title, file, color_palette){
  df <- df %>% filter(logFC > 0)
  df$logP <- -log(df$P.Value)
  p <- ggdotchart(df, y="logP", x="KEGGID", title=title,
                  xlab='', ylab="-Log(P value)",
                  color="celltype", size="logFC",
                  palette=color_palette,
                  sorting="ascending", add="segments", rotate=TRUE,
                  ggtheme=theme_classic())
  ggsave(file, p, width=8, height=5)
}

# ----------------------------
# 4. 读取数据
# ----------------------------
sub_Endo <- qread("result/fig4_Endo/sub_Endo_pro.qs")
DefaultAssay(sub_Endo) <- 'RNA'
sub_Endo <- DietSeurat(sub_Endo, assays = "RNA")


sub_Endo <- subset(sub_Endo)

# ----------------------------
# 5. 批次整合 (fastMNN)
# ----------------------------
sub_Endo$batch <- as.character(sub_Endo$sample)


sub_Endo <- Integration_SCP(
  srtMerge = sub_Endo, batch="batch", nHVF=3000,
  vars_to_regress=c("nCount_RNA","percent_mito"),
  neighbor_k=30L, cluster_resolution=c(0.6,0.7,0.8,0.9),
  integration_method="fastMNN"
)

# ----------------------------
# 6. 细胞注释 marker
# ----------------------------
maker <- c("COL1A1",'COL1A2',"DCN",
           'PECAM1', 'VWF',"CD34",
           'ACTA2','PDGFRB','MCAM') 
FeatureDimPlot(
  srt = sub_Endo, features = maker,pt.size = 0.1,pt.alpha = 1,
  bg_color = "grey80", density_color = "white",
  reduction = "HarmonyUMAP2D", theme_use = "theme_blank"
)
genes <- c("GJA4", "FBLN5", "SEMA3G", "GJA5",
           "ACKR1", "VWF", "ADGRG6", "SELP",
           "SELE", "IL6", "ICAM1", "VCAM1",
           "CA4", "FABP5", "CD36",
           "HPGD", "SOST", "SOSTDC1", "TBX3",
           "FOS", "DNAJB1", "JUN",
           "KDR", "CD34", "APLNR", "ESM1",
           "PGF", "CXCR4", "NID2", "LNX1",
           "LYVE1", "PDPN", "PROX1", "CCL21",
           "CD14", "CLEC1B", "FCN3",
           "ISG15", "IFIT5", "CXCL10", "OAS1")
DotPlot(sub_Endo, cols = c("white", "#F15F30"), features =genes, 
        group.by = "fastMNN_SNN_res.0.6", dot.scale = 6) +   
  scale_size(range = c(1,6),breaks = c(0,25,50,75))+
  scale_colour_gradient2(low = "#242467", mid = "#f0f1f2", high = "#f20d0d",midpoint = 0.5)+ NoLegend() + theme(axis.text.y = element_text(size = 4)) + labs(x= "", y = "") + theme(axis.text.x = element_text(size = 6, angle = 90))



plots=list()
for (i in 1:length(maker)){
  plots[[i]]=FeaturePlot_scCustom(seurat_object = sub_Endo, reduction = 'fastMNNUMAP2D',pt.size = 1,
                                  colors_use = colorRampPalette(c("white",  "#D53E4F" ))(100), 
                                  features = maker[i])+NoAxes()#+
  #theme(panel.border = element_rect(fill = NA,color = "black",
  #size=1.5,linetype = "solid"))
}

library(patchwork)
p<-wrap_plots(plots, ncol = 3);p
p


endo_maker <- c(
  'GJA4','SEMA3G','GJA5', #3 C1_ArtECs_SEMA3G+
  'NOTCH4','NOTCH1','DLL4', #11 C2_ArtECs_DLL4+
  
  'CD36','RGCC','FABP4', #6, C3_CapECs_CD36+
  'ESM1','VWA1','PGF',  #5 C4_tips_PGF+
  
  'SELE','MCTP1','CNKSR3','HIF1A', #4 C5_VenECs_HIF1A
  'ACKR1','CD74','CCL14', #0 C6_VenECs_CD74
  
  'RASAL2','DOCK4','MAGI1', #1 C7_tECs_DOCK4+
  'CD24','KRT19','AZGP1', #2 C8_ECs_CD24+ EndoMT2
  
  'ACTA2','APOE','COL1A1', #9 C9_ECs_COL1A1+  EndoMT1
  'IL6','CXCL8','CSF3',  #7 C10_iECs_IL6+
  'HMOX1','MT1A','CYP1A1', #8 C11_ECs_HMOX1+
  'PROX1','LYVE1','CCL21' #12,10 C12_LECs_CCL21+
)

FeaturePlot_save(sub_Endo, features=endo_maker, ncol=3, file="result/fig4_Endo/Endo_marker_FeaturePlot.pdf")

# -------------------------------
# Subcluster annotation (retain cell annotation)
sub_Endo$Harmonyclusters <- sub_Endo$fastMNN_SNN_res.0.6
mapping <- c("3"="C1_ArtECs_SEMA3G+", "11"="C2_ArtECs_DLL4+", "6"="C3_CapECs_CD36+",
             "5"="C4_tips_PGF+","4"="C5_VenECs_HIF1A+","0"="C6_VenECs_CD74+",
             "1"="C7_tECs_DOCK4+","2"="C8_emtECs_CD24+","9"="C9_emtECs_COL1A1+",
             "7"="C10_nECs_IL6+","8"="C11_nECs_HMOX1+","12"="C12_LECs_CCL21+")
sub_Endo$subclusters <- mapping[as.character(sub_Endo$Harmonyclusters)]

CellDimPlot(
  srt = sub_Endo, group.by = c("subclusters"),label = T,
  palcolor = zzm60colors,pt.size = 0.0000000001,
  reduction = "fastMNNUMAP2D", theme_use = "theme_blank"
)
ggsave("result/fig4_Endo/Endo_subclusters_UMAP.pdf",height = 5,width = 6)

endo_maker2 <- c(
  'SEMA3G', #动脉
  'RGCC', #毛细血管
  'LYVE1',#淋巴内皮
  'ACKR1' #静脉
)

CellDimPlot(
  srt = sub_Endo, label = T,group.by = c("subclusters"),
  reduction = "fastMNNUMAP2D", theme_use = "theme_blank"
)
DimPlot(sub_Endo,reduction = 'fastMNNUMAP2D',group.by = 'subclusters')

library(scCustomize)
plots=list()
for (i in 1:length(endo_maker2)){
  plots[[i]]=FeaturePlot_scCustom(seurat_object = sub_Endo, 
                                  reduction = 'fastMNNUMAP2D',pt.size = 0.05,raster = T,
                                  colors_use = colorRampPalette(c("#3288BD", "white", "#D53E4F" ))(50), 
                                  features = endo_maker2[i])+NoAxes()#+
  #theme(panel.border = element_rect(fill = NA,color = "black",
  #size=1.5,linetype = "solid"))
}

library(patchwork)
p<-wrap_plots(plots, ncol = 2);p

ggsave(p,file="result/fig4_Endo//Endo_genesets.pdf",height = 5,width = 6)

# ----------------------------
# 7. Tip/Stalk cell score
# ----------------------------
Tip_cell <- c("ADM","ANGPT2","ANKRD37","APLN","C1QTNF6","CD93","CLDN5","COL4A1",
              "COL4A2","COTL1","CXCR4","DLL4","EDNRB","ESM1","FSCN1","GPIHBP1",
              "HSPG2","IGFBP3","INHBB","ITGA5","JUP","KCNE3","KCNJ8","KDR",
              "LAMA4","LAMB1","LAMC1","LXN","MARCKS","MARCKSL1","MCAM","MEST",
              "MYH9","MYO1B","N4BP3","NID2","NOTCH4","PDGFB","PGF","PLOD1",
              "PLXND1","PMEPA1","PTN","RAMP3","RBP1","RGCC","RHOC","SMAD1",
              "SOX17","SOX4","SPARC","TCF4","UNC5B","VIM")
Stalk_cell <- c("ACKR1","AQP1","C1QTNF9","CD36","CSRP2","EHD4","FBLN5","HSPB1",
                "LIGP1","IL6ST","JAM2","LGALS3","LRG1","MEOX2","PLSCR2","SDPR",
                "SELP","SPINT2","TGFBI","TGM2","TMEM176A","TMEM176B","TMEM252",
                "TSPAN7","VEGFR1","VWF")
geneset_Endo <- list('Stalk_cell'=Stalk_cell, 'Tip_cell'=Tip_cell)

sub_Endo <- AddModuleScore(sub_Endo, features=geneset_Endo)
FeaturePlot_save(sub_Endo, features=names(geneset_Endo), ncol=2,
                 file="result/fig4_Endo/Tip_Stalk_FeaturePlot.pdf")

# ----------------------------
# 8. 差异表达 (DE)
# ----------------------------
register(MulticoreParam(workers=8, progressbar=TRUE))
sub_Endo <- RunDEtest(srt=sub_Endo, group_by="subclusters", fc.threshold=1, only.pos=FALSE)

DEGs <- sub_Endo@tools$DEtest_subclusters$AllMarkers_wilcox
DEGs <- DEGs[DEGs$avg_log2FC > 1 & DEGs$p_val_adj < 0.05,]

# FeatureHeatmap
ht <- FeatureHeatmap(sub_Endo, group.by="subclusters", features=DEGs$gene, feature_split=DEGs$group1,
                     db=c("GO_BP","KEGG","WikiPathway"), anno_terms=TRUE)
pdf("result/fig4_Endo/FeatureHeatmap_DEGs.pdf", width=25, height=15)
print(ht$plot)
dev.off()

# ----------------------------
# 9. PROGENy
# ----------------------------
Idents(sub_Endo) <- sub_Endo$subclusters
CellsClusters <- data.frame(Cell=names(Idents(sub_Endo)), CellType=as.character(Idents(sub_Endo)))
sub_Endo <- progeny(sub_Endo, scale=FALSE, organism="Human", top=500, perm=1, return_assay=TRUE)
sub_Endo <- ScaleData(sub_Endo, assay="progeny")

progeny_scores_df <- as.data.frame(t(GetAssayData(sub_Endo, slot="scale.data", assay="progeny"))) %>%
  rownames_to_column("Cell") %>% gather(Pathway, Activity, -Cell)
progeny_scores_df <- inner_join(progeny_scores_df, CellsClusters)
summarized_progeny_scores <- progeny_scores_df %>%
  group_by(Pathway, CellType) %>% summarise(avg=mean(Activity), std=sd(Activity))
summarized_progeny_scores_df <- summarized_progeny_scores %>% select(-std) %>% spread(Pathway, avg) %>% data.frame(row.names=1)

pdf("result/fig4_Endo/progeny.pdf", width=4.5, height=5)
pheatmap(t(summarized_progeny_scores_df), cluster_cols=TRUE, fontsize=12, fontsize_row=10, color=colorRampPalette(c("Darkblue","white","red"))(100))
dev.off()

# ----------------------------
# 10. Chemokines / Heatmap
# ----------------------------
gene_chemokine <- read_csv("rawdata/gene_chemokines.csv")$gene
subcluters_expr <- AverageExpression(sub_Endo, assays='RNA', features=gene_chemokine, group.by='subclusters')$RNA
df <- standarize.fun(subcluters_expr, halfwidth=1)
hm <- Heatmap(t(df), cluster_rows=F, cluster_columns=T, col=colorRamp2(c(-1,0,1),c("blue","white","red")), name="scale")
pdf("result/fig4_Endo/Chemokine_Heatmap.pdf", width=10, height=4)
draw(hm)
dev.off()

# ----------------------------
# 11. Metabolism KEGG 分析
# ----------------------------
countexp.Seurat <- sc.metabolism.Seurat(sub_Endo, method="AUCell", metabolism.type="KEGG")
counts <- countexp.Seurat@assays$METABOLISM$score
qsave(counts, "result/fig4_Endo/Endo_Metabolic_KEGGAUC.qs")

df.group <- data.frame(umi=names(Idents(sub_Endo)), cluster=sub_Endo$subclusters)
outputdf <- data.frame()
for(group2 in unique(df.group$cluster)){
  cluster.group <- as.numeric(df.group$cluster==group2)
  design <- cbind(sampleGroup1=1, sampleGroup2vs1=cluster.group)
  fit <- limma::lmFit(counts, design) %>% limma::eBayes()
  sigPathways <- limma::topTable(fit, coef="sampleGroup2vs1", number=Inf, p.value=0.05, adjust="BH")
  sigPathways$celltype <- group2
  sigPathways$KEGGID <- rownames(sigPathways)
  outputdf <- rbind(outputdf, sigPathways)
}
qsave(outputdf, "result/fig4_Endo/Endo_Metabolic_KEGG_outresult.qs")

# Example: Lipid metabolism
Lipid_metabolism <- c('alpha-Linolenic acid metabolism','Fatty acid degradation','Fatty acid biosynthesis')
data <- dplyr::filter(outputdf, KEGGID %in% Lipid_metabolism)
Metabolism_dotchart(data, title='Lipid_metabolism', file='result/fig4_Endo/metabolism/Lipid_metabolism_dotchart.pdf', color_palette=colorRampPalette(c("#4b6aa8","#3ca0cf","#c376a7"))(12))


# ----------------------------
# 12. 保存结果
# ----------------------------
qsave(sub_Endo, "result/fig4_Endo/sub_Endo_final.qs")
