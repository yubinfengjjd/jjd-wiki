.libPaths(unique(c("E:/research-wiki-env/R-lib/figureya", "E:/research-wiki-env/R-lib-scp/4.5", .libPaths())))
source("E:/research-wiki-env/sources/papers/2026-cai-stromal-tme/src/00c_style_and_manifold.R")

pal <- ec_cols
obs <- read_step("step01_harmony_de","umap_ec")
u <- make_manifolds("ec")$umap_ec
A <- supp_batch_and_ratio("ec",u,obs,pal,TRUE,"% EC cells")
markers <- read_step("step01_harmony_de","dotplot_ec")
markers$cluster <- wave_cluster(markers$cluster,pal)
preferred <- c("GJA4","SEMA3G","GJA5","NOTCH4","NOTCH1","DLL4","CD36","RGCC","FABP4",
  "ESM1","VWA1","PGF","SELE","MCTP1","CNKSR3","HIF1A","ACKR1","CD74","CCL14",
  "RASAL2","DOCK4","MAGI1","CD24","KRT19","AZGP1","ACTA2","APOE","COL1A1",
  "IL6","CXCL8","CSF3","HMOX1","MT1A","CYP1A1","PROX1","LYVE1","CCL21")
genes <- head(intersect(preferred,markers$gene),32)
message("Supplementary Figure 4B markers: ",length(genes))
dot <- supp_dotplot(markers,names(pal),genes,c(-1,2),c(.81,3.9),23,8,size_name="Pct",colour_name="Exp") +
  theme(plot.margin=margin(22,8,7,8))
B <- panel_tag(dot,"B")

traj <- read_step("step04_trajectory","traj_ec")
idx <- match(u$cell,traj$cell_id)
stopifnot(!anyNA(idx),all(is.finite(traj$score_Tip_cell[idx])))
u$score <- .25+.5*scale01(traj$score_Tip_cell[idx])
set.seed(42)
focused <- u[rep(seq_len(nrow(u)),3L),]
focused$x <- focused$x+runif(nrow(focused),-1.05,1.05)
focused$y <- focused$y+runif(nrow(focused),-1.05,1.05)
angio_ink <- c("#3288BD","#ABDDA4","#FFFFBF","#FDAE61","#D53E4F")
C <- panel_tag(feature_panel(focused,"score",angio_ink,"Angiogenic_signature",dots=.53,
  limits=c(.25,.75),bar=TRUE,manifold=TRUE,value_breaks=c(.25,.50,.75)) +
  add_l_arrows(data=focused,x=-.036,y=-.05,length=.16) +
  labs(caption="Local Tip-cell score proxy, rescaled for display") +
  theme(plot.title=element_text(size=10,face="plain"),plot.caption=element_text(size=5.8,hjust=.82),
        plot.margin=margin(8,5,6,12)),"C")

plots <- supp_kegg_bars("sfig4d_kegg_ec",pal,5,font=6.0)
kegg <- wrap_plots(lapply(plots,function(p) wrap_elements(full=p)),ncol=3)
D <- panel_tag(wrap_plots(wrap_elements(),wrap_elements(full=kegg),ncol=1,heights=c(.047,.953)),"D")
figure <- wrap_plots(wave_section(A,B,widths=c(.35,.65)),wave_section(C,D,widths=c(.33,.67)),
                     ncol=1,heights=c(.36,.64))
save_replica(figure,"sfig04_replica",12.5,9.5)
rm(list=ls()); invisible(gc())

