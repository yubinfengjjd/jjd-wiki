.libPaths(unique(c("E:/research-wiki-env/R-lib/figureya", "E:/research-wiki-env/R-lib-scp/4.5", .libPaths())))
source("E:/research-wiki-env/sources/papers/2026-cai-stromal-tme/src/00c_style_and_manifold.R")

pal <- fib_cols
obs <- read_step("step01_harmony_de","umap_fib")
u <- make_manifolds("fib")$umap_fib
fib_batches <- supp_cohort_palette[names(supp_cohort_palette)!="GSE139495"]
batch_map <- supp_batch_plot(u,obs,fib_batches,width=.48,numbered=TRUE,repeats=3)
batch_map <- batch_map + theme(plot.margin=margin(2,2,2,8))
batch_key <- wave_dot_legend(fib_batches,cols=2,header="GSE_numbers:",size=1.62)
batch_label <- wrap_elements(full=grid::textGrob("4 local cohorts; numbers follow reference key",
  gp=grid::gpar(fontsize=4.8,col="#5B5859")))
batch <- wave_section(batch_map,batch_key,batch_label,nrow=3,heights=c(.69,.24,.07))

proportions <- read_step("step02_progeny_roe_cox","tissue_prop_fib")
tissues <- c("Normal","Tumor","Lymphnode")
tissue_ink <- setNames(c("#2B9E77","#D95F02","#7570B3"),tissues)
pooled <- proportions[proportions$stratum_type=="tissue_overall",]
pooled <- pooled[pooled$tissue %in% tissues,]
pooled$group <- match(pooled$canonical_subcluster,names(pal))
stopifnot(!anyNA(pooled$group))
pooled$tissue <- factor(pooled$tissue,levels=tissues)
tissue_bars <- do.call(rbind,lapply(split(pooled,pooled$group),function(d) {
  d <- d[order(d$tissue),]
  d$x1 <- cumsum(d$n_cells)/sum(d$n_cells)
  d$x0 <- c(0,head(d$x1,-1))
  d
}))
sampled <- proportions[proportions$stratum_type=="batch_tissue" & proportions$tissue %in% tissues,]
sampled$group <- match(sampled$canonical_subcluster,names(pal))
sampled$x <- 1.10+sampled$proportion*3.4
sampled$y <- sampled$group+c(Normal=-.23,Tumor=0,Lymphnode=.23)[sampled$tissue]
p_values <- vapply(names(pal),function(name) {
  d <- sampled[sampled$canonical_subcluster==name,]
  a <- d[d$tissue=="Normal",c("batch","proportion")]
  b <- d[d$tissue=="Tumor",c("batch","proportion")]
  paired <- merge(a,b,by="batch")
  if(nrow(paired)<3) return(NA_real_)
  if(all(paired$proportion.x==paired$proportion.y)) return(1)
  suppressWarnings(wilcox.test(paired$proportion.x,paired$proportion.y,paired=TRUE,exact=FALSE)$p.value)
},numeric(1))
p_adj <- p.adjust(p_values,"BH")
signif <- ifelse(is.na(p_adj),"NA",ifelse(p_adj<.01,"**",ifelse(p_adj<.05,"*","ns")))
tissue_panel <- ggplot() +
  geom_rect(data=tissue_bars,aes(xmin=x0,xmax=x1,ymin=group-.37,ymax=group+.37,fill=tissue),
            colour="white",linewidth=.12) +
  geom_boxplot(data=sampled,aes(x,y,colour=tissue,group=interaction(group,tissue)),
               orientation="y",width=.17,linewidth=.20,outlier.shape=NA,fill=NA) +
  geom_point(data=sampled,aes(x,y,colour=tissue),size=.60,stroke=0,
             position=position_jitter(width=0,height=.031,seed=42)) +
  annotate("text",x=2.92,y=seq_along(pal),label=signif,colour="#474047",size=1.5) +
  annotate("segment",x=1.04,xend=1.04,y=.55,yend=14.45,colour="#888888",linewidth=.27) +
  scale_fill_manual(values=tissue_ink,labels=c("ANT","T","LM"),name=NULL) +
  scale_colour_manual(values=tissue_ink,guide="none") +
  scale_x_continuous(breaks=c(0,.5,1,1.10,1.78,2.46),labels=c("0","0.5","1","0","20","40")) +
  scale_y_continuous(breaks=NULL) +
  labs(caption="Ratio          % Fib cells\nBatch strata; ANT vs T") +
  coord_cartesian(xlim=c(-.02,3.06),ylim=c(.49,14.51),expand=FALSE) +
  theme_classic(base_size=6) +
  guides(fill=guide_legend(nrow=1,override.aes=list(colour=NA))) +
  theme(axis.title=element_blank(),axis.text.x=element_text(size=4.6,angle=55,hjust=1),
        axis.ticks.length=grid::unit(.65,"mm"),legend.position="top",
        legend.text=element_text(size=4.8),legend.margin=margin(0,0,1,0),
        legend.key.height=grid::unit(2.0,"mm"),legend.key.width=grid::unit(2.75,"mm"),
        legend.spacing.x=grid::unit(.55,"mm"),plot.caption=element_text(size=4.65,hjust=.48),
        plot.margin=margin(6,4,1,3))
A <- panel_tag(wrap_plots(batch,tissue_panel,nrow=1,widths=c(.61,.39)),"A")

marker_order <- c("ACTA2","TAGLN","MYL9","BAG3","HSPA6","CLEC3B","PLA2G2A","PI16","RORA",
  "BNC2","KCND2","PRKG1","CXCL8","CXCL3","CXCL1","NFKB1","ZSWIM6","APOD","APOE","CCL19",
  "CXCL10","CXCL9","COL12A1","COL10A1","SULF1","ABCA8","SVEP1","ENO1","TGFBI","CD74",
  "HLA-DRA","LUM","SFRP2","NOTCH3","F2R","A2M")
markers <- read_step("step01_harmony_de","dotplot_fib")
genes <- intersect(marker_order,markers$gene)
message("Supplementary Figure 2B markers: ",length(genes))
B <- panel_tag(supp_dotplot(markers,names(pal),genes,c(-1,2),c(.55,3.0),18,7.5) +
  theme(plot.margin=margin(23,5,4,8)),"B")

# Apply the existing local angiogenic gene set to measured Fib expression.
srt <- qs::qread(file.path(paper_dir,"data_small/scrna_stromal_small.qs"),nthreads=1)
counts <- as.matrix(SeuratObject::GetAssayData(srt,layer="counts"))
angio <- intersect(c("COL3A1","FN1","POSTN","THY1","COL1A1","PGF","EGFL6"),rownames(counts))
stopifnot(length(angio)>=2L)
message("Supplementary Figure 2C local angiogenic genes: ",paste(angio,collapse=", "))
ids <- match(u$cell,colnames(counts))
normalized <- log1p(sweep(counts[angio,ids,drop=FALSE],2,colSums(counts)[ids],"/")*1e4)
u$score <- .5+scale01(colMeans(normalized))
rm(srt,counts,normalized)
invisible(gc())
angio_ink <- c("#3288BD","#ABDDA4","#FFFFBF","#FDAE61","#D53E4F")
set.seed(42)
focused <- u[rep(seq_len(nrow(u)),3L),]
focused$x <- focused$x+runif(nrow(focused),-1.25,1.25)
focused$y <- focused$y+runif(nrow(focused),-1.25,1.25)
dx <- diff(range(focused$x)); dy <- diff(range(focused$y))
ox <- min(focused$x)-dx*(.04+.02*1.08)
oy <- min(focused$y)-dy*(.04+.068*1.08)
C <- panel_tag(feature_panel(focused,"score",angio_ink,"Angiogenic_signature",dots=.53,limits=c(.5,1.5),
  bar=TRUE,manifold=TRUE) +
  add_l_arrows(data=focused,x=-.02,y=-.068,length=.16) +
  annotate("text",x=ox+.014*dx,y=oy-.037*dy,label="HarmonyUMAP2D_1",hjust=0,size=1.86) +
  annotate("text",x=ox-.038*dx,y=oy+.027*dy,label="HarmonyUMAP2D_2",angle=90,hjust=0,size=1.86) +
  labs(caption="Local gene-set proxy, normalized for display") +
  theme(plot.title=element_text(size=9.3,face="plain"),plot.caption=element_text(size=5.4,hjust=.76),
        plot.margin=margin(5,4,7,15)),"C")

enrich <- read_step("step05_crosstalk","sfig2d_kegg_fib")
path_order <- c("KEGG_FOCAL_ADHESION","KEGG_ECM_RECEPTOR_INTERACTION",
  "KEGG_REGULATION_OF_ACTIN_CYTOSKELETON","KEGG_HYPERTROPHIC_CARDIOMYOPATHY_HCM",
  "KEGG_DILATED_CARDIOMYOPATHY","KEGG_PATHWAYS_IN_CANCER","KEGG_NEUROTROPHIN_SIGNALING_PATHWAY",
  "KEGG_PANCREATIC_CANCER","KEGG_ABC_TRANSPORTERS","KEGG_ACUTE_MYELOID_LEUKEMIA",
  "KEGG_GLYCOLYSIS_GLUCONEOGENESIS","KEGG_AMINOACYL_TRNA_BIOSYNTHESIS","KEGG_VIRAL_MYOCARDITIS",
  "KEGG_PENTOSE_PHOSPHATE_PATHWAY","KEGG_ASTHMA","KEGG_CITRATE_CYCLE_TCA_CYCLE","KEGG_DNA_REPLICATION",
  "KEGG_ALLOGRAFT_REJECTION","KEGG_STEROID_BIOSYNTHESIS","KEGG_LYSOSOME","KEGG_ARGININE_AND_PROLINE_METABOLISM",
  "KEGG_OTHER_GLYCAN_DEGRADATION","KEGG_GLUTATHIONE_METABOLISM","KEGG_GLYCOSAMINOGLYCAN_DEGRADATION",
  "KEGG_SMALL_CELL_LUNG_CANCER","KEGG_MAPK_SIGNALING_PATHWAY","KEGG_T_CELL_RECEPTOR_SIGNALING_PATHWAY",
  "KEGG_ARACHIDONIC_ACID_METABOLISM","KEGG_NOD_LIKE_RECEPTOR_SIGNALING_PATHWAY",
  "KEGG_CIRCADIAN_RHYTHM_MAMMAL","KEGG_COMPLEMENT_AND_COAGULATION_CASCADES",
  "KEGG_METABOLISM_OF_XENOBIOTICS_BY_CYTOCHROME_P450","KEGG_AXON_GUIDANCE",
  "KEGG_ETHER_LIPID_METABOLISM","KEGG_VASCULAR_SMOOTH_MUSCLE_CONTRACTION","KEGG_TIGHT_JUNCTION",
  "KEGG_LONG_TERM_DEPRESSION","KEGG_LONG_TERM_POTENTIATION","KEGG_PYRIMIDINE_METABOLISM",
  "KEGG_CYTOSOLIC_DNA_SENSING_PATHWAY","KEGG_RNA_POLYMERASE","KEGG_PROTEASOME")
eligible <- intersect(path_order,enrich$Description)
observed_rank <- aggregate(logp~Description,enrich,max)
other <- observed_rank$Description[order(observed_rank$logp,decreasing=TRUE)]
paths <- head(unique(c(eligible,other)),42)
enrich$cluster <- wave_cluster(enrich$group,pal)
enrich <- enrich[enrich$Description %in% paths & !is.na(enrich$cluster),]
message("Supplementary Figure 2D pathways: ",length(paths))
path_labels <- setNames(stringr::str_trunc(paths,57),paths)
fib_order <- names(pal)[c(9,8,7,6,5,4,3,2,12,14,13,11,10,1)]
D <- panel_tag(ggplot(enrich,aes(cluster,Description)) +
  geom_point(aes(size=Count,colour=logp),alpha=.95) +
  scale_x_discrete(limits=fib_order,drop=FALSE,expand=expansion(add=.50)) +
  scale_y_discrete(limits=rev(paths),labels=path_labels,expand=expansion(add=.55)) +
  scale_colour_gradientn(colours=c("#F4A582","#DF65B0","#88419D","#4D004B"),
    name="logp",limits=c(2,10),oob=scales::squish,breaks=seq(2,10,2)) +
  scale_size_continuous(range=c(.9,4.3),breaks=c(4,8,12,16),name="Count") +
  guides(size=guide_legend(order=1,override.aes=list(colour="black")),
    colour=guide_colourbar(order=2,barheight=grid::unit(19,"mm"),barwidth=grid::unit(2.4,"mm"))) +
  theme_bw(base_size=6.7) +
  theme(axis.title=element_blank(),axis.text.x=element_text(angle=90,hjust=1,vjust=.5,size=6.35),
        axis.text.y=element_text(size=5.85,colour="#303030"),axis.ticks.length=grid::unit(.65,"mm"),
        panel.border=element_rect(colour="#222222",linewidth=.55),
        panel.grid.major=element_line(colour="#E5E5E5",linewidth=.49),
        legend.position="right",legend.text=element_text(size=5.85),legend.title=element_text(size=7),
        plot.margin=margin(16,5,6,7)),"D")

E <- wave_metabolism("metab_sfig2e_fib",pal,"Top_Metabolic_pathway",16,tag="E",key_cols=3,clean_names=TRUE)
figure <- wrap_plots(wave_section(A,B,widths=c(.36,.64)),
  wave_section(wave_section(C,E,nrow=2,heights=c(.42,.58)),D,widths=c(.44,.56)),
  ncol=1,heights=c(.30,.70))
save_replica(figure,"sfig02_replica",11.4,10.6)
rm(list=ls()); invisible(gc())

