.libPaths(unique(c("E:/research-wiki-env/R-lib/figureya", "E:/research-wiki-env/R-lib-scp/4.5", .libPaths())))
source("E:/research-wiki-env/sources/papers/2026-cai-stromal-tme/src/00c_style_and_manifold.R")

u <- make_manifolds("all")$umap_all
obs <- read_step("step01_harmony_de","umap_all")
by_batch <- supp_batch_plot(u,obs,supp_cohort_palette,width=.42,repeats=4)
key <- wave_dot_legend(supp_cohort_palette,cols=1,header="GSE_number:",size=3.5) +
  annotate("text",x=-.04,y=.50,label="4 cohorts in local subset",hjust=0,size=2.15,colour="#565656") +
  theme(plot.title=element_text(size=11,hjust=0,margin=margin(b=4)))
# Retain the reference cohort key. Plot pixels carry only observed local batches.
batch_key <- wrap_plots(wrap_elements(),key,wrap_elements(),ncol=1,heights=c(.23,.52,.25))
A <- panel_tag(wrap_plots(by_batch,batch_key,nrow=1,widths=c(.765,.235)),"A")

genes <- c("COL1A1","COL1A2","DCN","PECAM1","VWF","CD34","ACTA2","PDGFRB","MCAM")
markers <- read_step("step01_harmony_de","dotplot_major")
B <- panel_tag(supp_dotplot(markers,c("Fib","EC","Mural cell"),genes,c(-.5,1),c(.9,7.6),29,12),"B")
figure <- wave_section(A,B,widths=c(.48,.52))
save_replica(figure,"sfig01_replica",12.2,5.0)
rm(list=ls()); invisible(gc())

