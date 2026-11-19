script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) {
  stop("Run this figure with Rscript --vanilla <figure-script.R>.")
}
script_dir <- dirname(sub("^--file=", "", script_arg))
source(file.path(script_dir, "..", "00c_style_and_manifold.R"))

fib <- read_step("step01_harmony_de","umap_fib")
traj <- read_step("step04_trajectory","traj_fib")
manifolds <- make_manifolds(c("fib","dm"))
umap <- manifolds$umap_fib
dm <- manifolds$dm_fib
tab <- match(umap$cell,fib$cell)
tissue <- function(value,title) {
  active <- umap[fib$tissue[tab]==value,]
  ggplot(umap,aes(x,y)) +
    manifold_points(size=.67,colour="#DCDCDC") +
    manifold_points(data=active,aes(colour=cluster),size=.58) +
    scale_colour_manual(values=fib_cols) + coord_equal() + labs(title=title) +
    theme_umap_blank(7) + theme(legend.position="none",plot.title=element_text(face="plain",size=7.4))
}
flegend <- data.frame(x=rep(c(1,2),each=7),y=rep(7:1,2),cluster=names(fib_cols))
flegend <- ggplot(flegend,aes(x,y)) +
  geom_point(aes(colour=cluster),size=1.55) +
  geom_text(aes(x=x+.07,label=cluster),hjust=0,size=1.7) +
  scale_colour_manual(values=fib_cols,guide="none") +
  coord_cartesian(xlim=c(.88,3.0),ylim=c(.55,7.45),expand=FALSE) + theme_void()
axis_a <- grid::grobTree(
  grid::segmentsGrob(x0=c(.25,.25),x1=c(.92,.25),y0=c(.22,.22),y1=c(.22,.92),
    arrow=grid::arrow(length=grid::unit(.95,"mm")),gp=grid::gpar(lwd=.8)),
  grid::textGrob("UMAP2D_1",x=.58,y=.05,gp=grid::gpar(fontsize=5.4)),
  grid::textGrob("UMAP2D_2",x=.12,y=.58,rot=90,gp=grid::gpar(fontsize=5.4)))
A <- panel_tag(wrap_plots(
  wrap_plots(tissue("Normal","Adjacent normal tissue") +
               inset_element(axis_a,.003,.013,.40,.275,align_to="full"),
             tissue("Tumor","Tumor"),nrow=1),
  flegend,ncol=1,heights=c(.69,.31)),"A")
modules <- c("lpCAF","mCAF","tCAF","ifnCAF")
B <- panel_tag(wrap_plots(lapply(modules,function(module) {
  umap$score <- scale01(fib[[paste0("score_",module)]][tab])^1.7
  feature_panel(umap,"score",module_cols,module,dots=.63,manifold=TRUE,limits=c(0,1),bar=TRUE,endpoints=TRUE) +
    theme(plot.title=element_text(face="plain",size=8.4),legend.text=element_text(size=5.7))
}),ncol=2),"B")

legend_bar <- function(palette,label,labels=c("Min","Max"),vertical=FALSE,compact=FALSE) {
  colours <- grDevices::colorRampPalette(palette)(128)
  raster <- if(vertical) as.raster(matrix(rev(colours),ncol=1)) else as.raster(matrix(colours,nrow=1))
  if(vertical) {
    grid::grobTree(grid::textGrob(label,x=.5,y=.98,gp=grid::gpar(fontsize=5)),
      grid::rasterGrob(raster,x=.27,y=.43,width=.25,height=.59,interpolate=FALSE),
      grid::textGrob(labels[2],x=.43,y=.70,just="left",gp=grid::gpar(fontsize=5)),
      grid::textGrob(labels[1],x=.43,y=.14,just="left",gp=grid::gpar(fontsize=5)))
  } else {
    ends <- if(compact) c(.81,.985) else c(.49,.97)
    grid::grobTree(grid::textGrob(label,x=ends[1]-.025,y=.61,just="right",gp=grid::gpar(fontsize=5.8)),
      grid::rasterGrob(raster,x=mean(ends),y=.61,width=diff(ends),height=.23,interpolate=FALSE),
      grid::textGrob(labels,x=ends,y=.19,gp=grid::gpar(fontsize=5)))
  }
}
roe <- read_step("step02_progeny_roe_cox","roe_cox_fib")
roe <- roe[match(names(fib_cols),roe$canonical_subcluster),]
for (cohort in c("tcga","inhouse")) {
  published <- read_input("data_small","moesm",paste0("cox_",cohort,".csv"))
  idx <- match(roe$canonical_subcluster, published$variable)
  available <- !is.na(idx)
  stopifnot(isTRUE(all.equal(roe[[paste0(cohort,"_HR")]][available],published$HR[idx[available]])))
}
tile_colours <- function(values,palette,limits) {
  values <- pmax(0,pmin(1,(values-limits[1])/diff(limits)))
  grDevices::colorRampPalette(palette)(256)[1+round(values*255)]
}
cox_block <- function(cohort,label,row) {
  hr <- roe[[paste0(cohort,"_HR")]]
  p <- roe[[paste0(cohort,"_p_value")]]
  data.frame(x=seq_along(hr),y=row,label=ifelse(!is.na(p)&p<.05,"*",""),
             fill=ifelse(is.na(hr),"#D9D9D9",unname(cox_cols[ifelse(hr>1,"Risk","Protective")])),
             rowname=label)
}
numeric_block <- function(prefix,labels,y,palette,limits) {
  do.call(rbind,lapply(seq_along(labels),function(i) {
    value <- roe[[paste0(prefix,labels[i])]]
    data.frame(x=seq_along(value),y=y[i],label=ifelse(is.na(value),"",sprintf("%.1f",value)),
               fill=tile_colours(value,palette,limits),rowname=labels[i])
  }))
}
heat <- rbind(cox_block("tcga","TCGA cohort",10.45),cox_block("inhouse","Inhouse cohort",9.45),
  numeric_block("roe_subtype_",c("Normal","Luminal_A","Luminal_B","HER2","TNBC"),8:4,subtype_cols,c(0,2.5)),
  numeric_block("roe_tissue_",c("Normal","Tumor","Lymphnode"),c(2.73,1.73,.73),tissue_cols,c(0,2)))
C <- ggplot(heat,aes(x,y)) +
  geom_tile(aes(fill=fill),width=.99,height=.99,colour="#EEEEEE",linewidth=.18) +
  annotate("rect",xmin=.5,xmax=14.5,ymin=c(8.95,3.50,.23),ymax=c(10.95,8.50,3.23),
    fill=NA,colour="#656565",linewidth=.23) +
  geom_text(aes(label=label),size=1.98,na.rm=TRUE) +
  geom_text(data=unique(heat[c("y","rowname")]),aes(x=14.62,label=rowname),hjust=0,size=1.98) +
  scale_x_continuous(breaks=1:14,labels=roe$canonical_subcluster) +
  scale_fill_identity(na.value="#DFDFDF") +
  coord_cartesian(xlim=c(.35,18.8),ylim=c(.18,11),expand=FALSE,clip="off") + theme_void() +
  theme(axis.text.x=element_text(size=5.5,angle=90,hjust=1,vjust=.5,colour="#222222",
                                 margin=margin(t=3)),
        plot.margin=margin(6,4,5,11))
cox_key <- grid::grobTree(
  grid::rectGrob(x=.08,y=c(.76,.31),width=.14,height=.28,gp=grid::gpar(fill=unname(cox_cols),col=NA)),
  grid::textGrob(c("Risk factor","Protective factor"),x=.19,y=c(.76,.31),just="left",
                 gp=grid::gpar(fontsize=5)))
C <- C +
  inset_element(cox_key,.787,.138,.986,.232,align_to="full") +
  inset_element(legend_bar(subtype_cols,"Ro/e",c("0","2.5"),TRUE),
                .789,.023,.869,.134,align_to="full") +
  inset_element(legend_bar(tissue_cols,"Ro/e",c("0","2"),TRUE),
                .899,.023,.979,.134,align_to="full")
C <- panel_tag(C,"C")

chem <- read_step("step02_progeny_roe_cox","chemokine_zscore_fib")
desired <- list(
  Chemokines=c("CCL14","CCL2","CCL3","CCL17","CCL20","CCL26","CCL1","CXCL13","CCL11","CXCL11",
    "CXCL10","CCL19","CXCL9","CXCL8","CXCL1","CXCL3","CXCL2","CXCL6","CXCL12","CXCL5",
    "CCL3L1","CCL28","XCL1","CCL16","CCL8","CCL7","CCL21","CCL22","CCL15","CCL5",
    "CCL13","CCL23","CCL27","CCL24"),
  "MHC-I"=c("HLA-A","HLA-B","HLA-C","HLA-E","HLA-F","HLA-G","B2M","MICA","MICB"),
  "MHC-II"=c("HLA-DRB5","HLA-DOA","HLA-DOB","HLA-DQA1","HLA-DQB2","HLA-DRA","HLA-DRB1",
             "HLA-DPA1","HLA-DPB1"))
deg <- read_input("data_small","moesm","deg_fib.csv")
deg$canonical <- canonical_cluster(deg$cluster,fib_cols)
srt <- qs::qread(file.path(paper_dir,"data_small/scrna_stromal_small.qs"),nthreads=1)
counts <- as.matrix(SeuratObject::GetAssayData(srt,layer="counts"))
available <- unique(c(chem$gene,rownames(counts),deg$gene))
desired$Chemokines <- unique(c(desired$Chemokines,grep("^(CCL|CXCL|CX3CL|XCL)[0-9]+[A-Z0-9]*$",available,value=TRUE)))
desired[["MHC-II"]] <- unique(c(desired[["MHC-II"]],grep("^HLA-D[MRQOP][AB][0-9]*$",available,value=TRUE)))
candidates <- unique(unlist(desired,use.names=FALSE))
present <- intersect(setdiff(candidates,chem$gene),rownames(counts))
expr <- log1p(sweep(counts[present,fib$cell,drop=FALSE],2,colSums(counts)[fib$cell],"/")*1e4)
means <- vapply(names(fib_cols),function(cl) rowMeans(expr[,fib$canonical_subcluster==cl,drop=FALSE]),
                numeric(length(present)))
z <- matrix(NA_real_,nrow=length(candidates),ncol=length(fib_cols),dimnames=list(candidates,names(fib_cols)))
if(length(present)) {
  zz <- t(scale(t(means)))
  zz[!is.finite(zz)] <- NA_real_
  z[present,] <- zz
}
reported <- intersect(candidates,chem$gene)
z[reported,] <- as.matrix(chem[match(reported,chem$gene),names(fib_cols)])
deg <- deg[deg$gene %in% candidates & !is.na(deg$canonical) & is.finite(deg$avg_log2FC),]
has_z <- rownames(z)[rowSums(is.finite(z))>0]
desired <- lapply(desired,intersect,union(has_z,deg$gene))
retained <- unlist(desired,use.names=FALSE)
stopifnot(all(lengths(desired)>0))
message("Fig2D genes: ",paste(names(desired),lengths(desired),collapse=", "),
        " (",length(retained)," total; ",sum(retained %in% has_z),
        " have Z values; published DEG only: ",paste(setdiff(retained,has_z),collapse=", "),")")
rm(srt,counts,expr,means)
xmap <- lapply(seq_along(desired),function(i) {
  genes <- desired[[i]]
  offset <- sum(lengths(desired)[seq_len(i-1)])+(i-1)*.55
  data.frame(gene=genes,x=offset+seq_along(genes),block=names(desired)[i])
})
xmap <- do.call(rbind,xmap)
chemplot <- merge(expand.grid(gene=xmap$gene,cluster=names(fib_cols)),xmap,by="gene",sort=FALSE)
chemplot$y <- 15-match(chemplot$cluster,names(fib_cols))
chemplot$z <- z[cbind(match(chemplot$gene,rownames(z)),match(chemplot$cluster,colnames(z)))]
deg_hits <- merge(deg,xmap,by="gene")
deg_hits$y <- 15-match(deg_hits$canonical,names(fib_cols))
brackets <- do.call(rbind,lapply(split(xmap,xmap$block),function(d)
  data.frame(block=d$block[1],start=min(d$x)-.45,end=max(d$x)+.45)))
D <- ggplot(chemplot,aes(x,y,fill=z)) +
  geom_tile(width=.96,height=.96,colour="white",linewidth=.15) +
  geom_point(data=deg_hits,aes(x,y),inherit.aes=FALSE,shape=1,colour="#2A2528",size=1.0,stroke=.31) +
  geom_segment(data=brackets,aes(x=start,xend=end,y=15.1,yend=15.1),inherit.aes=FALSE,linewidth=.52) +
  geom_text(data=brackets,aes(x=(start+end)/2,y=15.9,label=block),inherit.aes=FALSE,size=2.12,fontface="bold") +
  labs(caption="Open circles: published Fib DEGs") +
  scale_fill_gradientn(colours=chem_cols,limits=c(-2,2),oob=scales::squish,na.value="#EDEDED",name="Z-scale") +
  scale_y_continuous(position="right",breaks=14:1,labels=names(fib_cols),expand=expansion(add=c(.5,2.09))) +
  scale_x_continuous(breaks=xmap$x,labels=xmap$gene,expand=expansion(add=.51)) +
  guides(fill=guide_colourbar(direction="horizontal",barwidth=grid::unit(16,"mm"),barheight=grid::unit(2,"mm"))) +
  theme_void(base_size=7) +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=.5,size=5.8),
        axis.text.y=element_text(size=5.6),legend.position="bottom",legend.justification="right",
        legend.text=element_text(size=5.3),legend.title=element_text(size=5.4),
        plot.caption=element_text(size=5.4,hjust=0,margin=margin(t=0)),
        plot.margin=margin(2,1,0,6))
D <- panel_tag(D,"D")

prog <- read_step("step02_progeny_roe_cox","progeny_fib")
mat <- as.matrix(prog[match(names(fib_cols),prog$canonical_subcluster),-1])
rownames(mat) <- names(fib_cols)
path_order <- c("PI3K","VEGF","NFkB","TNFa","EGFR","MAPK","Hypoxia","Androgen",
                "Estrogen","p53","Trail","JAK-STAT","WNT","TGFb")
progplot <- expand.grid(cluster=names(fib_cols),path=rev(path_order))
progplot$z <- mat[cbind(match(progplot$cluster,rownames(mat)),match(progplot$path,colnames(mat)))]
E <- ggplot(progplot,aes(factor(cluster,levels=names(fib_cols)),factor(path,levels=rev(path_order)),fill=z)) +
  geom_tile(colour="#BCBAC0",linewidth=.14) +
  scale_y_discrete(position="right",expand=c(0,0)) + scale_x_discrete(expand=c(0,0)) +
  scale_fill_gradientn(colours=progeny_cols,limits=c(-1,2),values=c(0,1/3,1),
    oob=scales::squish,name="Z-scale") +
  guides(fill=guide_colourbar(barwidth=grid::unit(1.55,"mm"),barheight=grid::unit(12,"mm"))) +
  theme_void(base_size=7) +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=.5,size=5.45),
        axis.text.y=element_text(size=5.65),legend.position="right",
        legend.text=element_text(size=5),legend.title=element_text(size=5),
        plot.margin=margin(12,1,3,3),legend.margin=margin(0,0,0,1))
E <- panel_tag(E,"E")

sequence_dm <- c(1,2,10,6,3,12,8,11,9,13,4,14,7,5)
centers <- function(d,order) {
  cells <- aggregate(cbind(x,y)~cluster,d,median)
  cells[match(names(fib_cols)[order],cells$cluster),]
}
dm_line <- centers(dm,sequence_dm)
dm_centroids <- centers(dm,seq_along(fib_cols))
dm_label_pos <- transform(dm_centroids,
  x=x+c(-8,-10,-11,26,17,0,4,1,10,-14,7,9,-6,6),
  y=y+c(-7,7,5,1,-3,2,-7,13,1,-6,5,-5,-7,8))
stopifnot(nrow(dm_label_pos)==14,all(complete.cases(dm_label_pos)))
F <- embedding(dm,fib_cols,"Diffusion Map",dots=.65) +
  geom_path(data=dm_line,aes(x,y),inherit.aes=FALSE,colour="#555555",linewidth=.3,linetype="dashed") +
  geom_segment(data=transform(dm_centroids, tx=dm_label_pos$x,ty=dm_label_pos$y),
    aes(x=x,y=y,xend=tx,yend=ty),inherit.aes=FALSE,linewidth=.18,colour="#5E5757") +
  centroid_labels(dm,fib_cols,2.35,offset=.95,centers=dm_label_pos) + add_l_arrows("DC_1","DC_2",dm,x=-.065,y=-.064) +
  theme(legend.position="none",plot.title=element_text(face="plain",size=8.8))
F <- panel_tag(F,"F")

mapped <- match(umap$cell,traj$cell_id)
umap$dpt <- traj$dpt_pseudotime[mapped]
umap$slingshot <- traj$slingshot_pseudotime[mapped]
sling_centers <- aggregate(cbind(x,y,slingshot,dpt)~cluster,umap,median)
pairwise <- as.matrix(dist(sling_centers[c("x","y")]))
tree <- data.frame()
joined <- which.min(sling_centers$slingshot)
while (length(joined)<nrow(sling_centers)) {
  rest <- setdiff(seq_len(nrow(sling_centers)),joined)
  dist_subset <- pairwise[joined,rest,drop=FALSE]
  nearest <- which(dist_subset==min(dist_subset),arr.ind=TRUE)[1,]
  from <- joined[nearest[1]]; to <- rest[nearest[2]]
  tree <- rbind(tree,data.frame(x=sling_centers$x[from],y=sling_centers$y[from],
                                xe=sling_centers$x[to],ye=sling_centers$y[to]))
  joined <- c(joined,to)
}
G <- feature_panel(umap,"dpt",c("#2B5C8F","#44AA99","#DDCC77","#D55E00"),
                   "Differentiation state (DPT)",dots=.69,bar=TRUE,horizontal=TRUE,manifold=TRUE) +
  labs(subtitle="Display guides from cluster DPT medians") +
  theme(plot.title=element_text(face="plain",size=8.8),plot.subtitle=element_text(size=5,hjust=.5,margin=margin(b=.2)))
edges <- transform(tree,t0=sling_centers$dpt[match(x,sling_centers$x)],
                   t1=sling_centers$dpt[match(xe,sling_centers$x)])
forward <- edges$t0 <= edges$t1
G <- G + geom_curve(data=edges,aes(x=ifelse(forward,x,xe),y=ifelse(forward,y,ye),
    xend=ifelse(forward,xe,x),yend=ifelse(forward,ye,y)),inherit.aes=FALSE,
    curvature=.14,linewidth=.24,lineend="round",colour="#353535",
    arrow=grid::arrow(length=grid::unit(.92,"mm"),type="closed"))
G <- panel_tag(G,"G")
H <- feature_panel(umap,"slingshot",c("#440154","#B83289","#FDE725"),
                   "Differentiation state (Slingshot)",dots=.69,bar=TRUE,horizontal=TRUE,manifold=TRUE) +
  geom_segment(data=tree,aes(x,y,xend=xe,yend=ye),inherit.aes=FALSE,linewidth=.36,colour="black") +
  labs(subtitle="Cluster-center guide") + theme(plot.title=element_text(face="plain",size=8.8),plot.subtitle=element_text(size=5,hjust=.5,margin=margin(b=.2)))
H <- panel_tag(H,"H")

module_fields <- c(mCAF="score_mCAF",ifnCAF="score_ifnCAF",iCAF="score_iCAF",lpCAF="score_LipCAF")
module_ramps <- list(c("#F2EFF4","#BF3347"),c("#F3F6F1","#328D40"),
                     c("#EDF2FB","#397BB9"),c("#F3EEF7","#825097"))
score <- vapply(module_fields,function(field) scale01(traj[[field]][match(dm$cell,traj$cell_id)]),
                numeric(nrow(dm)))
dominant <- max.col(score,ties.method="first")
dm$ink <- vapply(seq_len(nrow(dm)),function(i)
  tile_colours(score[i,dominant[i]],module_ramps[[dominant[i]]],c(0,1)),character(1))
I <- ggplot(dm,aes(x,y,colour=ink)) + manifold_points(size=.57) +
  scale_colour_identity() + coord_equal(clip="off") + theme_umap_blank() +
  add_l_arrows("DC_1","DC_2",dm,x=-.065,y=-.064) + labs(title="CAF module scores")
for(i in seq_along(module_ramps)) {
  x <- .30+.167*(i-1)
  I <- I + inset_element(legend_bar(module_ramps[[i]],names(module_fields)[i],c("0","1"),TRUE),
      x,.015,x+.163,.238,align_to="full")
}
I <- panel_tag(I,"I")

st <- read_step("step03_spatial","st_spots_fig2j")
st_fields <- paste0("score_",names(fib_legacy))
sp_palette <- c("#7B84B8","#A5A6C5","#E8A64B")
stopifnot(all(st_fields %in% names(st)))
mat <- as.matrix(st[,st_fields])
shifted <- apply(mat,2,function(value) pmax(0,value-quantile(value,.05,na.rm=TRUE)))
weighted <- st
weighted[,st_fields] <- shifted/pmax(rowSums(shifted),.Machine$double.eps)
sp_grid <- function(d) wrap_plots(lapply(seq_along(st_fields),function(i)
  spatial_panel(d,st_fields[i],sp_palette,names(fib_cols)[i],size=.44,fixed=FALSE) + theme(plot.title=element_text(size=4.6,face="plain",hjust=.5,margin=margin(0,0,1,0)),
                         panel.spacing=grid::unit(1.5,"pt"),
                         plot.margin=margin(.75,.75,.75,.75))),ncol=7)
label_grob <- function(value) wrap_elements(full=grid::textGrob(value,x=.062,just="left",
    gp=grid::gpar(fontsize=6,col="#333333")))
J <- wrap_plots(label_grob("CAA_ST  |  Fib signature scores"),sp_grid(st),
                label_grob("CAA_ST  |  Relative signature weights (same section)"),sp_grid(weighted),
                wrap_elements(full=legend_bar(sp_palette,"Cell density proxy",compact=TRUE)),
                ncol=1,heights=c(.059,.421,.047,.421,.052))
J <- panel_tag(J,"J")

lr <- read_step("step05_crosstalk","fig2k_fib_malignant_lr")
ligands <- c("COL1A1","COL1A2","COL6A1","COL6A2","COL6A3")
pairs <- c(paste0(ligands,"_CD44"),paste0(ligands,"_SDC4"))
lr <- lr[lr$interaction_name %in% pairs & lr$target=="Epi",]
lr$source <- canonical_cluster(lr$source,fib_cols)
rows <- names(fib_cols)[c(9,8,7,6,4,3,2,13,10,12,11,14,1,5)]
lr <- aggregate(prob~source+interaction_name,lr,max)
lr$source <- factor(lr$source,levels=rev(rows))
lr$interaction_name <- factor(lr$interaction_name,levels=pairs)
emphasis <- names(fib_cols)[c(9,8,3,13,10,11,1)]
label_ink <- ifelse(rev(rows) %in% emphasis,"#D6352E","#242424")
row_labels <- paste0("<span style=",intToUtf8(34),"color:",label_ink,intToUtf8(34),">",
                     rev(rows),"-&gt;Malignant</span>")
K <- ggplot(lr,aes(interaction_name,source,fill=prob,size=prob)) +
  geom_point(shape=21,colour="black",stroke=.45) +
  scale_x_discrete(drop=FALSE,expand=expansion(add=.55)) +
  scale_y_discrete(drop=FALSE,labels=row_labels,expand=expansion(add=.55)) +
  scale_fill_gradientn(colours=lr_cols,name="Communication\nProbability") +
  scale_size_continuous(name="prob",range=c(1.2,3.9)) +
  guides(size=guide_legend(order=1,override.aes=list(fill="black")),
         fill=guide_colourbar(order=2,barwidth=grid::unit(2,"mm"),barheight=grid::unit(12,"mm"))) +
  theme_bw(base_size=6) +
  theme(axis.title=element_blank(),axis.ticks=element_blank(),axis.text.x=element_text(angle=90,hjust=1,vjust=.5),
    axis.text.y=ggtext::element_markdown(size=5.7),panel.border=element_rect(colour="black",linewidth=.45),
    panel.grid=element_line(colour="#E4E4E4",linewidth=.18),legend.position="left",
    legend.title=element_text(size=5),legend.text=element_text(size=5),legend.spacing.y=grid::unit(1,"mm"),
    legend.key.height=grid::unit(3,"mm"),plot.margin=margin(10,4,5,1))
K <- panel_tag(K,"K")

fig <- wrap_plots(wrap_elements(full=wrap_plots(A,B,C,nrow=1,widths=c(.25,.26,.49))),
  wrap_elements(full=wrap_plots(D,E,nrow=1,widths=c(.68,.32))),
  wrap_elements(full=wrap_plots(F,G,H,I,nrow=1,widths=c(.24,.28,.24,.24))),
  wrap_elements(full=wrap_plots(J,K,nrow=1,widths=c(.62,.38))),
  ncol=1,heights=c(.24,.23,.19,.34))
save_replica(fig,"fig02_replica",9.6,12.2)
rm(list=ls()); invisible(gc())
