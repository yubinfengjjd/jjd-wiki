.libPaths(unique(c("E:/research-wiki-env/R-lib/figureya", "E:/research-wiki-env/R-lib-scp/4.5", .libPaths())))
source("E:/research-wiki-env/sources/papers/2026-cai-stromal-tme/src/00c_style_and_manifold.R")

pal <- ec_cols
obs <- read_step("step01_harmony_de","umap_ec")
obs$cluster <- wave_cluster(obs$canonical_subcluster,pal)
u <- make_manifolds("ec")$umap_ec
traj <- read_step("step04_trajectory","traj_ec")
srt <- qs::qread(file.path(paper_dir,"data_small/scrna_stromal_small.qs"),nthreads=1)
counts <- as.matrix(SeuratObject::GetAssayData(srt,layer="counts"))
ids <- match(u$cell,colnames(counts))
genes <- c("SEMA3G","ACKR1","RGCC","LYVE1")
markers <- setNames(lapply(genes,function(gene)
  if(gene %in% rownames(counts)) log1p(1e4*counts[gene,ids]/colSums(counts)[ids]) else NA_real_),genes)
A <- wave_split(u,obs,pal)
B <- wave_features(u,markers,c("#1B7837","#A6DBA0","#F7F7F7","#F4A582","#B2182B"))
C <- wave_cox("ec",pal)
D <- wave_functional("ec",pal,obs,counts)
rm(srt,counts)
invisible(gc())
E <- wave_progeny("ec",pal,c("PI3K","Estrogen","VEGF","Androgen","NFkB","TNFa",
  "EGFR","MAPK","Trail","p53","WNT","TGFb","Hypoxia","JAK-STAT"))
trajectory <- wave_trajectory("ec",pal,u,obs,traj)

interactions <- read_step("step05_crosstalk","fig4i_ec_stromal_counts")
interactions <- interactions[interactions$source_compartment=="EC",]
palettes <- list(Fib=fib_cols,EC=ec_cols,Mural=mural_cols)
interactions$x <- NA_character_
for(group in names(palettes)) {
  rows <- interactions$target_compartment==group
  interactions$x[rows] <- wave_cluster(interactions$TARGET[rows],palettes[[group]])
}
interactions$y <- wave_cluster(interactions$SOURCE,pal)
stopifnot(!anyNA(interactions$x),!anyNA(interactions$y),nrow(interactions)==12*36)
ec_order <- names(pal)[c(8,3,7,10,2,11,6,12,4,5,1,9)]
targets <- c(names(fib_cols),names(mural_cols),names(ec_cols))
I <- panel_tag(wave_counts(interactions,targets,ec_order,small=TRUE),"I")

spatial <- read_step("step03_spatial","st_spots_fig4j")
spatial$band_x <- cut(spatial$imagecol,quantile(spatial$imagecol,0:3/3),include.lowest=TRUE,labels=FALSE)
spatial$band_y <- ave(spatial$imagerow,spatial$band_x,FUN=function(y) as.numeric(y>median(y)))
spatial$region <- 2L*(spatial$band_x-1L)+spatial$band_y+1L
fields <- c("score_C4_TipEC_PGF","score_C5_VenEC_HIF1A","score_C9_emtEC_COL1A1")
# Rasterize the observed scores at their native spacing within each of six regions.
st_long <- do.call(rbind,lapply(split(spatial,spatial$region),function(d) {
  xy <- cbind(x=d$imagecol,y=-d$imagerow)
  grid <- expand.grid(x=seq(min(xy[,1]),max(xy[,1]),length.out=50),
                      y=seq(min(xy[,2]),max(xy[,2]),length.out=50))
  spacing <- stats::median(RANN::nn2(xy,k=2)$nn.dists[,2])
  nn <- RANN::nn2(xy,as.matrix(grid),k=1)
  do.call(rbind,lapply(fields,function(field) {
    bounds <- range(spatial[[field]],na.rm=TRUE)
    value <- scales::rescale(d[[field]][nn$nn.idx[,1]],from=bounds)
    value[nn$nn.dists[,1] > 1.05*spacing] <- NA_real_
    transform(grid,x=round(scale01(x),8),y=round(scale01(y),8),value=value,
              region=d$region[1],signature=sub("^score_","",field))
  }))
}))
st_long$region <- factor(st_long$region,levels=1:6)
st_long$signature <- factor(st_long$signature,levels=sub("^score_","",fields))
j_map <- ggplot(st_long,aes(x,y,fill=value)) +
  geom_raster(interpolate=TRUE) +
  facet_grid(signature~region,switch="y") +
  scale_fill_gradientn(colours=wave_st_cols,limits=c(0,1),na.value="white") +
  coord_cartesian(xlim=c(-.03,1.03),ylim=c(-.03,1.03),expand=FALSE) +
  theme_void() +
  theme(legend.position="none",strip.text.x=element_blank(),
        strip.text.y.left=element_text(size=5.0,angle=0,hjust=1),
        strip.placement="outside",panel.spacing=grid::unit(2.2,"mm"),
        plot.margin=margin(6,1,1,8))
J <- wrap_elements(full=j_map)
for(top in c(.991,.667,.343)) {
  J <- J + inset_element(wave_key(wave_st_cols,min="",max=""),.19,top-.033,.273,top,align_to="full")
}
J <- panel_tag(wrap_plots(
  wrap_elements(full=grid::textGrob("CAA_ST  |  Six regions of one section",x=.065,just="left",
                                    gp=grid::gpar(fontsize=5.6))),
  J,ncol=1,heights=c(.11,.89)),"J")
K <- wave_metabolism("metab_fig4k_ec",pal,"Top3_Metabolic_pathway",20,short_labels=c(
  "Glycosaminoglycan biosynthesis - chondroitin sulfate / dermatan sulfate"="GAG biosynthesis\n(chondroitin / dermatan sulfate)",
  "Biosynthesis of various nucleotide sugars"="Nucleotide sugar biosynthesis"))

bottom <- wave_section(wave_section(I,J,nrow=2,heights=c(.49,.51)),K,widths=c(.58,.42))
fig4 <- wrap_plots(wave_section(A,B,C,widths=c(.25,.27,.48)),
                   wave_section(D,E,widths=c(.68,.32)),
                   trajectory,bottom,ncol=1,heights=c(.24,.22,.18,.36))
save_replica(fig4,"fig04_replica",9.6,12.2)
rm(list=ls()); invisible(gc())

