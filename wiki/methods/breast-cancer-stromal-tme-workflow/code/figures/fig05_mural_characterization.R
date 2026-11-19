.libPaths(unique(c("E:/research-wiki-env/R-lib/figureya", "E:/research-wiki-env/R-lib-scp/4.5", .libPaths())))
source("E:/research-wiki-env/sources/papers/2026-cai-stromal-tme/src/00c_style_and_manifold.R")

pal <- mural_cols
obs <- read_step("step01_harmony_de","umap_mural")
obs$cluster <- wave_cluster(obs$canonical_subcluster,pal)
u <- make_manifolds("mural")$umap_mural
traj <- read_step("step04_trajectory","traj_mural")
srt <- qs::qread(file.path(paper_dir,"data_small/scrna_stromal_small.qs"),nthreads=1)
counts <- as.matrix(SeuratObject::GetAssayData(srt,layer="counts"))
ids <- match(u$cell,colnames(counts))
traj_ids <- match(u$cell,traj$cell_id)
markers <- list(Angiogenic_signature=traj$score_Angiogenic[traj_ids],
                Quiescent_signature=traj$score_Quiescent[traj_ids])
for(gene in c("ACTA2","RGS5")) {
  markers[[gene]] <- if(gene %in% rownames(counts))
    log1p(1e4*counts[gene,ids]/colSums(counts)[ids]) else NA_real_
}
A <- wave_split(u,obs,pal)
B <- wave_features(u,markers,c("#4DAC26","#F7F7F7","#D73027"))
C <- wave_cox("mural",pal[c(4:10,1:3)])
D <- wave_functional("mural",pal,obs,counts)
col6_sc <- "COL6A3" %in% rownames(counts)
rm(srt,counts)
invisible(gc())
st <- qs::qread(file.path(paper_dir,"data_small/CAA_ST-umap.qs"),nthreads=1)
col6_st <- "COL6A3" %in% rownames(st[["Spatial"]])
rm(st)
invisible(gc())
col6_deg <- "COL6A3" %in% read_input("data_small","moesm","deg_mural.csv")$gene
message("COL6A3 in small scRNA / raw CAA_ST / published mural DEG: ",
        paste(c(col6_sc,col6_st,col6_deg),collapse=" / "))

E <- wave_progeny("mural",pal,c("p53","Trail","JAK-STAT","Hypoxia","TGFb","Androgen",
  "NFkB","TNFa","EGFR","MAPK","PI3K","Estrogen","VEGF","WNT"))
trajectory <- wave_trajectory("mural",pal,u,obs,traj)

dynamics <- read_step("step04_trajectory","traj_mural_branch_genes")
genes <- c("COL6A3","MUSTN1","SORBS2","CCL21","NET1","THY1","RERGL","MYH11")
lineage_size <- aggregate(n_cells_lineage~lineage,dynamics,max)
selected <- lineage_size$lineage[which.max(lineage_size$n_cells_lineage)]
message("Mural branch displayed: ",selected," (",max(lineage_size$n_cells_lineage)," cells)")
dynamics <- dynamics[dynamics$lineage==selected,]
views <- lapply(genes,function(gene) {
  values <- dynamics[dynamics$gene==gene & is.finite(dynamics$smoothed_expr),]
  p <- ggplot(values,aes(pseudotime_norm,smoothed_expr)) +
    labs(title=gene,x="Pseudotime",y=NULL) +
    scale_x_continuous(breaks=c(0,.5,1),labels=c("0","0.5","1")) +
    theme_bw(base_size=6.1) +
    theme(panel.border=element_rect(colour="black",linewidth=.47),
          aspect.ratio=.86,panel.grid=element_blank(),plot.title=element_text(hjust=.5,size=7),
          axis.title.x=element_text(size=5.45,margin=margin(t=1)),
          axis.text=element_text(size=5.1),axis.ticks.length=grid::unit(.65,"mm"),
          plot.margin=margin(2,3,2,4))
  if (nrow(values)) return(p+geom_line(colour="#529E73",linewidth=.70))
  note <- if(gene=="COL6A3" && !col6_sc) "Unavailable in\nsmall scRNA" else "No fitted curve"
  p + annotate("text",x=.5,y=.5,label=note,size=2.05,colour="#555555") +
    coord_cartesian(xlim=c(0,1),ylim=c(0,1)) +
    theme(axis.text=element_blank(),axis.ticks=element_blank())
})
I <- panel_tag(wrap_plots(views,ncol=2),"I")

lr <- read_step("step05_crosstalk","fig5j_mural_ec_lr")
lr$x <- wave_cluster(lr$source,pal)
lr$y <- lr$interaction_name
lr_rows <- c("JAG1_NOTCH4","JAG1_NOTCH1","COL4A2_ITGA9_ITGB1","COL4A1_ITGA9_ITGB1",
  "COL1A2_ITGA9_ITGB1","COL1A1_ITGA9_ITGB1","LAMA4_ITGA6_ITGB1","COL6A1_ITGA1_ITGB1",
  "COL4A2_ITGA1_ITGB1","COL4A1_ITGA1_ITGB1","COL1A2_ITGA1_ITGB1","COL1A1_ITGA1_ITGB1","PGF_VEGFR1")
J <- panel_tag(wave_bubbles(lr,names(pal)[c(4,2)],lr_rows,font=5.35,size=c(.95,3.35)) +
  guides(size=guide_legend(order=1,ncol=1,override.aes=list(fill="black"))) +
  theme(legend.title=element_text(size=4.85),legend.box.margin=margin(0,3,0,0)),"J")
K <- wave_metabolism("metab_fig5k_mural",pal,"Top_Metabolic_pathway",14)

fig5 <- wrap_plots(wave_section(A,B,C,widths=c(.25,.27,.48)),
    wave_section(D,E,widths=c(.68,.32)),
    trajectory,wave_section(I,J,K,widths=c(.30,.25,.45)),
    ncol=1,heights=c(.24,.21,.21,.34))
save_replica(fig5,"fig05_replica",9.6,12.2)
rm(list=ls()); invisible(gc())

