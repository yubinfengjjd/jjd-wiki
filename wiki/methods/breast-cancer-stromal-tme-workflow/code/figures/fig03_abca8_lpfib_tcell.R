script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) {
  stop("Run this figure with Rscript --vanilla <figure-script.R>.")
}
script_dir <- dirname(sub("^--file=", "", script_arg))
source(file.path(script_dir, "..", "00c_style_and_manifold.R"))

# Digitize the complete clustered bulk matrix using the source color bar.
# The unrounded published ABCA8 values replace matched digitized cells.
page <- png::readPNG(file.path(paper_dir,"extracted/pages/main_p06.png"))
left_labels <- c("C13_lpFib_LUM","CD8T_Tex","C7_lpFib_APOD","C12_apFib_CD74","Endothelial_cell",
  "C4_iFib_BNC2","CD4T_memory","C5_iFib_CXCL8","Naive_T","B_cell","NK","C2_ifnFib_HSPA6",
  "NKT","mDC","T_Ki67","C14_tFib_A2M","C11_tFib_ENO1")
right_labels <- c("Cancer_cell","Mural_cell","C10_lpFib_ABCA8","Mono_FCN1","C1_mFib_ACTA2",
  "CD8T_effector","CD4T_Treg","M1","CD4_Tfh","pDC","C8_iFib_CCL19","C3_lpFib_PLA2G2A",
  "Mast_cell","C9_mFib_COL12A1","Mono_IL1B","cDC2","CD8T_memory","M2")
n <- length(left_labels)+length(right_labels)
labels <- character(n)
labels[seq(1,n,2)] <- right_labels
labels[seq(2,n,2)] <- left_labels
bulk <- read_input("data_small","moesm","corr_bulk.csv")
bulk_aliases <- c(CD8T_Tex="CD8_Exhausted_T",CD8T_effector="CD8_Cytotoxic_T",
                  CD4T_Treg="Regulatory.T",Mast_cell="Mast")
aliases <- labels
aliases[labels %in% names(bulk_aliases)] <- bulk_aliases[labels[labels %in% names(bulk_aliases)]]
palette_table <- sapply(1:3,function(i) rowMeans(page[127:399,154:159,i]))
palette_values <- seq(1,-1,length.out=nrow(palette_table))
cell_centers <- function(start,end) start+(seq_len(n)-.5)*(end-start)/n
x_centers <- round(cell_centers(165,441))
y_centers <- round(cell_centers(125,401))
distance <- function(rgb) rowSums(sweep(palette_table,2,rgb)^2)
decode <- function(x,y) {
  sample_rgb <- apply(page[(y-1):(y+1),(x-1):(x+1),1:3,drop=FALSE],3,median)
  palette_values[which.min(distance(sample_rgb))]
}
corr <- outer(y_centers,x_centers,Vectorize(function(y,x) decode(x,y)))
corr <- (corr+t(corr))/2
diag(corr) <- 1
anchor <- match("C10_lpFib_ABCA8",labels)
matched <- match(aliases,bulk$celltype)
exact <- !is.na(matched)
corr[anchor,exact] <- corr[exact,anchor] <- bulk$C10_lpFib_ABCA8[matched[exact]]
stopifnot(isSymmetric(corr,tol=1e-12),all(diag(corr)==1))
heat <- expand.grid(y=seq_len(n),x=seq_len(n))
heat$value <- as.vector(corr)
bounds <- data.frame(start=c(2,8,16,22,26)-.5,end=c(7,15,21,25,28)+.5)
A <- ggplot(heat,aes(x,y)) +
  geom_tile(aes(fill=value)) +
  geom_rect(data=bounds,aes(xmin=start,xmax=end,ymin=start,ymax=end),inherit.aes=FALSE,
            fill=NA,colour="#202020",linewidth=.48) +
  annotate("segment",x=n+.70,xend=n+c(rep(1.25,17),rep(10.65,18)),
    y=c(seq(2,n,2),seq(1,n,2)),yend=c(seq(2,n,2),seq(1,n,2)),
    linetype="dashed",linewidth=.18) +
  annotate("text",x=n+1.35,y=seq(2,n,2),label=left_labels,hjust=0,size=1.86) +
  annotate("text",x=n+10.72,y=seq(1,n,2),label=right_labels,hjust=0,size=1.86) +
  scale_fill_gradientn(colours=rev(corr_cols),limits=c(-1,1),name=NULL,breaks=seq(-1,1,.2)) +
  scale_y_reverse() + coord_fixed(xlim=c(.5,55),ylim=c(.5,n+.5),expand=FALSE,clip="off") +
  guides(fill=guide_colourbar(barwidth=grid::unit(2.05,"mm"),barheight=grid::unit(55,"mm"),
    theme=theme(legend.text.position="left"))) +
  labs(subtitle="Bulk r  |  Published matrix color-read; available ABCA8 pairs exact") +
  theme_void(base_size=7) +
  theme(legend.position="left",legend.text=element_text(size=5.5),
        legend.margin=margin(0,1,0,0),legend.spacing.x=grid::unit(1,"mm"),
        plot.subtitle=element_text(size=5.8,margin=margin(b=4)),
        plot.margin=margin(13,6,4,7))
A <- panel_tag(A,"A")

st <- read_step("step03_spatial","st_spots_fig3be")
spot_fields <- c(Tumor_cell="weight_Tumor_cell", C10_lpFib_ABCA8="weight_C10_lpFib_ABCA8",
                CD8_Cytotoxic_T="weight_CD8_Cytotoxic_T",Exhausted_T="weight_Exhausted_T")
st$region <- interaction(st$imagecol>median(st$imagecol),st$imagerow>median(st$imagerow))
region_mean <- tapply(st$weight_C10_lpFib_ABCA8,st$region,mean)
regions <- names(sort(region_mean,decreasing=TRUE))
tile_names <- c("Tumor cell","C10_lpFib_ABCA8","CD8_Cytotoxic_T","Exhausted_T")

# Render a local Gaussian average on a regular grid, masked by spot proximity.
# The raster is a display of the observed scores, with no new observations.
spot_grid <- function(d, side=95L, square=TRUE) {
  xy <- cbind(x=d$imagecol,y=-d$imagerow)
  margin <- diff(range(xy[,1]))*.01
  ranges <- apply(xy,2,range)
  steps <- ranges[2,]-ranges[1,]
  dims <- if(square) rep(side,2) else pmax(2,round(side*steps/max(steps)))
  grid <- expand.grid(x=seq(ranges[1,1]-margin,ranges[2,1]+margin,length.out=dims[1]),
                      y=seq(ranges[1,2]-margin,ranges[2,2]+margin,length.out=dims[2]))
  local <- RANN::nn2(xy,k=2)
  spacing <- median(local$nn.dists[,2])
  near <- RANN::nn2(xy,as.matrix(grid),k=6)
  w <- exp(-.5*(near$nn.dists/(.73*spacing))^2)
  list(grid=grid, index=near$nn.idx, weight=w, inside=near$nn.dists[,1]<=1.21*spacing)
}
limits <- lapply(spot_fields,function(field)
  c(min(st[[field]],na.rm=TRUE),quantile(st[[field]],.96,na.rm=TRUE,names=FALSE)))
density <- do.call(rbind,lapply(seq_along(regions),function(row) {
  area <- st[st$region==regions[row],]
  sampled <- spot_grid(area)
  do.call(rbind,lapply(seq_along(spot_fields),function(col) {
    raw <- area[[spot_fields[col]]]
    values <- matrix(raw[sampled$index],nrow=nrow(sampled$index))
    smoothed <- rowSums(sampled$weight*values)/rowSums(sampled$weight)
    smoothed[!sampled$inside] <- NA_real_
    transform(sampled$grid, x=round(scale01(x),8), y=round(scale01(y),8),
      density=scales::rescale(smoothed,from=limits[[col]]),
      region=factor(row,levels=seq_along(regions)),
      feature=factor(tile_names[col],levels=tile_names))
  }))
}))
B_tiles <- ggplot(density,aes(x,y,fill=density)) +
  geom_raster(interpolate=TRUE) +
  facet_grid(region~feature) +
  scale_fill_gradientn(colours=density_cols,limits=c(0,1),oob=scales::squish,na.value="white") +
  coord_cartesian(xlim=c(0,1),ylim=c(0,1),expand=FALSE) +
  theme_void() +
  theme(aspect.ratio=1,strip.text.x=element_text(size=5.8,margin=margin(b=2)),
        strip.text.y=element_blank(),strip.background=element_blank(),legend.position="none",
        panel.border=element_rect(fill=NA,colour="black",linewidth=.6),
        panel.spacing.x=grid::unit(3.3,"pt"),panel.spacing.y=grid::unit(3.5,"pt"),
        plot.margin=margin(0,4,0,2))
annot_label <- function(label,size=6) {
  wrap_elements(full=grid::textGrob(label,gp=grid::gpar(fontsize=size)))
}
region_labels <- wrap_elements(full=grid::textGrob(
  c("Higher ABCA8+ lpCAF score","Lower ABCA8+ lpCAF score"),
  x=.85,y=c(.735,.25),rot=90,gp=grid::gpar(fontsize=6.2)))
bar_grob <- function(palette,label) {
  grob_palette <- as.raster(matrix(grDevices::colorRampPalette(palette)(128),nrow=1))
  grid::grobTree(grid::textGrob(label,x=.75,y=.63,just="right",gp=grid::gpar(fontsize=6.1)),
     grid::rasterGrob(grob_palette,x=.868,y=.65,width=.205,height=.25,interpolate=FALSE),
     grid::textGrob(c("Min","Max"),x=c(.766,.971),y=.24,gp=grid::gpar(fontsize=5)))
}
B <- wrap_plots(annot_label("Four regions of one Visium section (CAA_ST)"),
  wrap_plots(region_labels,B_tiles,nrow=1,widths=c(.045,.955)),
  wrap_elements(full=bar_grob(density_cols,"Cell density proxy")),
  ncol=1,heights=c(.042,.923,.035))
B <- panel_tag(B,"B")
checkpoints <- c("PDCD1","CTLA4","HAVCR2","CD274","ICOS","TNFRSF4","TIGIT","CD276")
ck <- read_step("step05_crosstalk","fig3c_checkpoint_box")
ck <- ck[ck$abca8_quartile_group %in% c("ABCA8_low","ABCA8_high") & ck$gene %in% checkpoints,]
ck$group <- factor(sub("ABCA8_","",ck$abca8_quartile_group),levels=c("low","high"))
ck$gene <- factor(ck$gene,levels=checkpoints)
pvalue <- unique(ck[c("gene","wilcox_p_quartile")])
display_limits <- aggregate(expression~gene,ck,function(x) unname(quantile(x,.97)))
names(display_limits)[2] <- "cap"
pvalue <- merge(pvalue,display_limits,by="gene")
pvalue$stars <- cut(pvalue$wilcox_p_quartile,breaks=c(-Inf,.0001,.001,.01,.05,Inf),
                   labels=c("****","***","**","*","ns"),right=FALSE)
by_group <- split(ck,interaction(ck$gene,ck$group,drop=TRUE))
box_groups <- lapply(by_group,function(d) {
  x <- d$expression
  hinges <- quantile(x,c(.25,.5,.75),names=FALSE)
  inlier <- x >= hinges[1]-1.5*diff(hinges[c(1,3)]) &
            x <= hinges[3]+1.5*diff(hinges[c(1,3)])
  cap <- display_limits$cap[match(d$gene[1],display_limits$gene)]
  cap <- max(cap,hinges[3])
  list(box=data.frame(gene=d$gene[1],group=d$group[1],
         ymin=min(x[inlier]),lower=hinges[1],middle=hinges[2],upper=hinges[3],
         ymax=min(max(x[inlier]),cap)),outliers=d[!inlier & x<=cap,])
})
boxes <- do.call(rbind,lapply(box_groups,"[[","box"))
outliers <- do.call(rbind,lapply(box_groups,"[[","outliers"))
pvalue$expression <- 1.12*pmax(pvalue$cap,tapply(boxes$ymax,boxes$gene,max)[as.character(pvalue$gene)])
C <- ggplot(boxes,aes(group,fill=group)) +
  geom_boxplot(aes(ymin=ymin,lower=lower,middle=middle,upper=upper,ymax=ymax),
               stat="identity",width=.62,colour="black",linewidth=.34) +
  geom_point(data=outliers,aes(group,expression),inherit.aes=FALSE,
             size=.52,alpha=.65) +
  geom_text(data=pvalue,aes(x=1.5,y=expression,label=stars),inherit.aes=FALSE,size=2.3) +
  facet_wrap(~gene,ncol=4,scales="free_y") +
  scale_fill_manual(values=box_cols,guide="none") +
  scale_y_continuous(expand=expansion(mult=c(.02,.055)),n.breaks=4) +
  coord_transform(y="sqrt") +
  labs(x=NULL,y="Expression",subtitle="CAA_ST | ABCA8 quartiles | square-root axis, display capped at P97") +
  theme_classic(base_size=7) +
  theme(strip.background=element_blank(),strip.text=element_text(size=7,face="plain"),
        panel.border=element_rect(fill=NA,linewidth=.26,colour="#757575"),
        axis.text=element_text(size=6),axis.ticks.length=grid::unit(.7,"mm"),
        panel.spacing=grid::unit(1.75,"mm"),plot.subtitle=element_text(size=6),
        plot.margin=margin(9,1,0,8))
C <- panel_tag(C,"C")
notice <- wrap_elements(full=grid::grobTree(
  grid::roundrectGrob(width=.92,height=.83,r=grid::unit(.025,"npc"),
    gp=grid::gpar(fill="#FBFAF8",col="#C3BFB9",lwd=.7)),
  grid::textGrob("Excluded wet-lab panels",x=.09,y=.73,just="left",
    gp=grid::gpar(fontface="bold",fontsize=8)),
  grid::textGrob(c("Fig. 3F  Mouse 4T1 CAF-T co-culture    |    Fig. 3G  Flow cytometry",
    "Fig. 3H  Human BRCA multiplex IF"),
    x=.09,y=c(.48,.25),just="left",gp=grid::gpar(fontsize=6.5))))
lr <- read_step("step05_crosstalk","fig3d_lr_bipartite")
cp <- read_input("data_small","moesm","cellphone_pvalue.csv")
ligands <- c("LGALS9/3","PVR","LILRB4","CD274","PDCD1LG2","CD80","CD86",
             "CD200","TNFRSF14","CD276","IDO1")
receptors <- c("HAVCR2","LAG3","TIGIT","LAIR1","PDCD1","CTLA4","CD200R1","CD209","BTLA")
links <- data.frame(
  ligand=c("LGALS9/3","LGALS9/3","PVR","LILRB4","CD274","PDCD1LG2","CD80","CD86","CD200","TNFRSF14"),
  receptor=c("HAVCR2","LAG3","TIGIT","LAIR1","PDCD1","PDCD1","CTLA4","CTLA4","CD200R1","BTLA"),
  pair=c("LGALS9_HAVCR2",NA,"PVR_TIGIT",NA,"PDCD1_CD274","PDCD1_PDCD1LG2",
         "CTLA4_CD80","CTLA4_CD86","CD200_CD200R1","BTLA_TNFRSF14"))
xlig <- setNames(seq_along(ligands),ligands)
xrec <- setNames(seq(1.1,10.5,length.out=length(receptors)),receptors)
links$x <- unname(xlig[links$ligand])
links$xe <- unname(xrec[links$receptor])
links$rate <- NA_real_
links$support <- NA_real_
compare_columns <- names(cp)[grepl("C[0-9]+_Fib_",names(cp)) &
  grepl("CD[48]|Regulatory|Transitory",names(cp))]
for(i in which(!is.na(links$pair))) {
  pvals <- lr$pval[lr$source_db=="CellPhoneDB" & lr$interaction_name==links$pair[i]]
  if (!length(pvals)) {
    cp_rows <- which(cp$interacting_pair==links$pair[i])
    pvals <- unlist(cp[cp_rows,compare_columns],use.names=FALSE)
  }
  pvals <- as.numeric(pvals)
  pvals <- pvals[is.finite(pvals)]
  if(length(pvals)) {
    links$support[i] <- max(-log10(pmax(pvals,1e-4)))
    links$rate[i] <- 100*mean(pvals<.05)
  }
}
nodes <- function(labels,coordinates,lookup,y) {
  paired <- split(seq_len(nrow(links)),lookup)
  best <- vapply(labels,function(name) {
    idx <- paired[[name]]
    idx <- idx[is.finite(links$support[idx])]
    if(length(idx)) idx[which.max(links$support[idx])] else NA_integer_
  },integer(1))
  data.frame(gene=labels,x=unname(coordinates[labels]),y=y,
             rate=links$rate[best],support=links$support[best])
}
endpoints <- rbind(nodes(ligands,xlig,links$ligand,2.47),
                   nodes(receptors,xrec,links$receptor,.39))
links$available <- is.finite(links$support)
D <- ggplot(endpoints,aes(x,y)) +
  annotate("rect",xmin=.55,xmax=11.45,ymin=c(2.15,.07),ymax=c(2.79,.71),
           fill="white",colour="#888888",linewidth=.34) +
  geom_segment(data=links,aes(x=x+.10,xend=xe-.10,y=1.58,yend=1.25,linetype=available),
               inherit.aes=FALSE,colour="#212121",linewidth=.27,
               arrow=grid::arrow(length=grid::unit(1.3,"mm"),type="closed")) +
  geom_point(data=endpoints[is.na(endpoints$support),],shape=21,colour="#B3B3B3",fill="white",size=2.35,stroke=.35) +
  geom_point(data=endpoints[!is.na(endpoints$support),],aes(size=rate,fill=support),shape=21,stroke=0,alpha=.96) +
  geom_text(aes(y=ifelse(y>1,2.10,.76),label=gene),angle=90,
            hjust=ifelse(endpoints$y>1,1,0),size=1.85) +
  annotate("text",x=.42,y=c(2.47,.39),label=c("Ligands","Receptors"),hjust=1,size=2.25) +
  scale_fill_gradientn(colours=c("#CBD5E1","#F4A582","#D73027"),name="Peak -log10(p)",limits=c(0,4)) +
  scale_size_continuous(name="% tests\np < 0.05",limits=c(0,100),breaks=c(25,50,75),range=c(3.5,10.5)) +
  scale_linetype_manual(values=c("FALSE"="dashed","TRUE"="solid"),guide="none") +
  guides(fill=guide_colourbar(barwidth=grid::unit(1.8,"mm"),barheight=grid::unit(10,"mm")),
         size=guide_legend(override.aes=list(fill="#242424",alpha=1))) +
  coord_cartesian(xlim=c(-1.6,11.55),ylim=c(0,2.88),expand=FALSE) + labs(
    subtitle="CellPhoneDB support across tested Fib/T-cell pairs\nDashed links and open markers indicate unavailable statistics") +
  theme_void() + theme(legend.position="right",legend.title=element_text(size=5.8),
    legend.text=element_text(size=5.5),legend.key.height=grid::unit(3.0,"mm"),
    legend.margin=margin(0,0,0,0),legend.spacing.y=grid::unit(1,"mm"),
    plot.subtitle=element_text(size=5.6,margin=margin(b=3)),plot.margin=margin(19,2,3,6))
D <- panel_tag(D,"D")

spatial_expression <- function(d, candidates) {
  paths <- c("data_small/CAA_ST-umap.qs","data_small/st/caa_st_scored.qs")
  for (path in paths) {
    object <- qs::qread(file.path(paper_dir,path),nthreads=1)
    assay <- object[["Spatial"]]
    available <- intersect(candidates,rownames(assay))
    if(length(available)) {
      gene <- available[1]
      layer <- SeuratObject::LayerData(assay,layer="data",features=gene)
      if(is.null(layer) || !gene %in% rownames(layer)) {
        counts <- SeuratObject::LayerData(assay,layer="counts")
        layer <- log1p(counts[gene,,drop=FALSE] /
          rep(Matrix::colSums(counts),each=1)*1e4)
      }
      idx <- match(d$spot,colnames(layer))
      stopifnot(!anyNA(idx))
      message("Fig3E galectin: ",gene," present in ",path)
      return(list(gene=gene,expression=as.numeric(layer[gene,idx])))
    }
    message("Fig3E galectin: LGALS9 and LGALS3 absent in ",path)
    rm(object,assay)
    invisible(gc())
  }
  list(gene="LGALS9",expression=rep(NA_real_,nrow(d)))
}
galectin <- spatial_expression(st,c("LGALS9","LGALS3"))
st$galectin <- galectin$expression
sampled <- spot_grid(st,side=148L,square=FALSE)
joint_bg <- transform(sampled$grid,ink=ifelse(sampled$inside,"#D9C6D2","transparent"))
joint_high <- st[st$spatial_zone_fig3e=="ABCA8_lpFib_Tcell_joint_high",]
joint <- ggplot() +
  geom_raster(data=joint_bg,aes(x,y,fill=ink)) + scale_fill_identity() +
  geom_point(data=st,aes(imagecol,-imagerow),colour="#CDB4C5",size=.68,stroke=0) +
  geom_point(data=joint_high,aes(imagecol,-imagerow),colour="#D7191C",size=.9,stroke=0) +
  coord_equal() + labs(title="C10_lpFib_ABCA8 / T cell",subtitle="Joint high in red") +
  theme_umap_blank() + theme(legend.position="none",plot.subtitle=element_text(size=6,hjust=.5),
    panel.border=element_rect(fill=NA,colour="#C6BFC3",linewidth=.45))
E_fields <- c("galectin","HAVCR2","CD86","CTLA4")
E_titles <- c(if(galectin$gene=="LGALS3") "LGALS9/3 (LGALS3)" else "LGALS9/3",E_fields[-1])
E_small <- wrap_plots(lapply(seq_along(E_fields),function(i) {
  gene <- E_fields[i]
  if (!any(is.finite(st[[gene]]))) {
    return(ggplot() + annotate("text",x=.5,y=.52,label="Unavailable\nin CAA_ST",size=2.1,colour="#777777") +
      coord_cartesian(xlim=0:1,ylim=0:1) + labs(title=E_titles[i]) + theme_umap_blank() +
      theme(aspect.ratio=1,panel.border=element_rect(fill=NA,colour="black",linewidth=.6)))
  }
  area <- st[order(st[[gene]],na.last=FALSE),]
  upper <- quantile(area[[gene]],.97,na.rm=TRUE,names=FALSE)
  if(upper <= min(area[[gene]],na.rm=TRUE)) upper <- max(area[[gene]],na.rm=TRUE)
  spatial_panel(area,gene,expression_cols,E_titles[i],size=.94,frame=FALSE,fixed=FALSE,
                normalise=FALSE,limits=c(0,upper)) +
    theme(aspect.ratio=1,plot.title=element_text(size=7.4,face="plain"),
          panel.border=element_rect(fill=NA,colour="black",linewidth=.6))
}),ncol=2)
E <- wrap_plots(wrap_plots(joint,E_small,nrow=1,widths=c(.47,.53)),
                wrap_elements(full=bar_grob(expression_cols,"Expression")),
                ncol=1,heights=c(.91,.09))
E <- panel_tag(E,"E")

top <- wrap_plots(
  wrap_elements(full=wrap_plots(A,C,ncol=1,heights=c(.61,.39))),
  wrap_elements(full=wrap_plots(B,notice,ncol=1,heights=c(.90,.10))),
  nrow=1,widths=c(.48,.52))
fig <- wrap_plots(wrap_elements(full=top),
  wrap_elements(full=wrap_plots(D,E,nrow=1,widths=c(.46,.54))),
  ncol=1,heights=c(.68,.32))
save_replica(fig,"fig03_replica",9.6,9.0)
rm(list=ls()); invisible(gc())
