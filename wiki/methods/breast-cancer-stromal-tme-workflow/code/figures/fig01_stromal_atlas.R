script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) {
  stop("Run this figure with Rscript --vanilla <figure-script.R>.")
}
script_dir <- dirname(sub("^--file=", "", script_arg))
source(file.path(script_dir, "..", "00c_style_and_manifold.R"))

manifolds <- make_manifolds(c("all","fib","ec","mural"))
st <- read_input("data_small","st","caa_st_spots_scores.csv")
tissue_shape <- data.frame(x=c(2,12,13,18,22,21,19,18,13,9,7,5),
                           y=c(33,33,26,22,16,12,9,6,7,4,14,25))
nodule <- data.frame(x=c(13.9,16.1,17.7,17,15.2,13.2,12.3),
                     y=c(19.6,19,16.5,14.6,13.9,15,17.8))
mass <- data.frame(x=c(3.3,5.1,6.8,7.8,7.2,8.6,8,6.5,5.6),
                   y=c(32.8,32.8,23,16,11,5,4.2,12.5,21.8))
cohorts <- c("E-MTAB-10607 (14)","GSE148673 (8)","GSE161529 (69)","GSE176078 (26)",
             "GSE180286 (15)","GSE195861 (20)","GSE225600 (8)","GSE246613 (149)","in-house (40)")
pie_wedge <- function(start,end,colour) {
  theta <- seq(start,end,length.out=90)
  geom_polygon(data=data.frame(x=15.1+c(0,5.25*sin(theta)),
    y=5.4+c(0,5.25*cos(theta))),aes(x,y),fill=colour,colour="#65615C",linewidth=.22)
}
s_arrow <- function(x,y,x2,y2,dashed=FALSE) {
  annotate("segment",x=x,y=y,xend=x2,yend=y2,colour=if(dashed) "#999999" else "#181818",
    linetype=if(dashed) "dashed" else "solid",linewidth=.38,
    arrow=grid::arrow(type="closed",length=grid::unit(1.15,"mm")))
}
A <- ggplot() +
  geom_polygon(data=tissue_shape,aes(x,y),fill="#F6E5BB",colour="#B18470",linewidth=.52) +
  geom_polygon(data=mass,aes(x,y),fill="#AA7875",colour="#9E6664",linewidth=.26) +
  geom_polygon(data=nodule,aes(x,y),fill="#AB5141",colour="#982723",linewidth=.48) +
  annotate("curve", x=c(13.5,14,15.8,16.4,15,16.4),y=c(16,17,17,16.9,15.6,15.8),
    xend=c(10.7,10.8,15,20,19,21),yend=c(13,24.8,23.5,21,11.5,17),curvature=.32,
    colour=c("#AB241D","#487F57","#487F57","#AB241D","#AB241D","#AB241D"),linewidth=.62) +
  pie_wedge(.212*2*pi,2*pi,"#B5B2AF") + pie_wedge(0,.212*2*pi,"#4FB3C8") +
  annotate("text",x=c(18.9,8.7),y=c(10.1,3.5),label=c("in house data\n21.2%","Public data"),
           size=2,hjust=0) +
  annotate("rect",xmin=c(25.1,31.4,43.9,54.7,59.6),xmax=c(28.7,35,47.1,57.8,63),
    ymin=c(22,22,24,24,24),ymax=c(32.5,32.5,29.5,29.5,29.5),
    fill=c("#BBBBBB","#BBBBBB","#D6B7CF","#C2CBD8","#A6BAD0"),colour="#6B6770",linewidth=.24) +
  annotate("segment",x=25.6,xend=28.25,y=seq(23,31,1),yend=seq(23,31,1),linewidth=.33) +
  annotate("segment",x=31.9,xend=33.1,y=seq(23,31,1),yend=seq(23,31,1),linewidth=.33) +
  annotate("segment",x=seq(49,53.4,.4),xend=seq(49,53.4,.4),y=25.5,
    yend=rep(c(29,30,31),4),colour=rep(c("#3563A1","#D5AA22","#552681","#3D8A57"),3),linewidth=.9) +
  annotate("text",x=c(21.1,26.9,33.2,50.9,57,35,45.5,45.5,29),
    y=c(30.4,20,20,22,31,14.5,17.2,10.5,13.9),
    label=c("FFPE samples","Tissue\noptimization","Gene\nexpression","Spatial transcriptomics (ST)",
      "Sequencing","Tumor / adjacent tissue\nMetastatic lymph nodes","Dissociation","Single cell\nRNA-seq",""),
    size=c(2.1,1.65,1.65,1.7,1.65,1.95,2.05,2.05,1.65),fontface="bold") +
  annotate("point",x=c(36,36.4,37.1,36.5,35.6,45.7,46.2,44.8),
    y=c(8.2,6.5,7.8,9.2,7.9,14.7,15.6,15.6),
    colour=c("#477C8F","#974C58","#5B917D","#B56B5D","#7C6C99","#989197","#B79FBD","#A6B5C0"),size=2.6) +
  s_arrow(19.5,27,25.1,27,TRUE) + s_arrow(29,27,31,27) + s_arrow(35.3,27,43.5,27) +
  s_arrow(47.4,27,48.6,27) + s_arrow(53.8,27,54.6,27) + s_arrow(58,27,59.5,27) +
  s_arrow(38,12.8,43.5,12.8,TRUE) + s_arrow(47.4,12.8,53.1,12.8,TRUE) +
  annotate("rect",xmin=c(66.7,66.7),xmax=93.5,ymin=c(22,3.3),ymax=c(35.8,18.9),
    colour="#AAAAAA",fill=NA,linetype="dashed",linewidth=.25) +
  annotate("text",x=80.1,y=c(37.5,33.3,20.6),
    label=c("Spatial transcriptome","in-house (8 samples), public (43 samples)","Single cell profiling"),
    fontface="bold",size=c(3.25,2.2,3.25)) +
  annotate("text",x=c(rep(73.7,5),rep(87,4)),y=c(seq(16.4,5.2,length.out=5),seq(15.3,6.3,length.out=4)),
    label=cohorts,size=2.93,fontface="bold") +
  coord_cartesian(xlim=c(0,96),ylim=c(.1,39),expand=FALSE) + theme_void() +
  theme(plot.margin=margin(1,5,1,5))
thumbnail_ramps <- list(COL1A1=c("#DFB4C8","#9E6B8A"),
  score_Fib_core=c("#383E64","#5C6690"),
  score_Tumor_cell=c("#383E64","#7AC27E","#F1DF5B"))
for (i in seq_along(thumbnail_ramps)) {
  field <- names(thumbnail_ramps)[i]
  thumb <- st
  thumb[[field]] <- scale01(thumb[[field]])^if(i==3) 4 else 1
  mini <- spatial_panel(thumb,field,thumbnail_ramps[[i]],size=.64,normalise=FALSE)
  x <- .718+(i-1)*.077
  A <- A + inset_element(mini,x,.57,x+.075,.82,align_to="full")
}
atlas <- manifolds$umap_all
mini_atlas <- embedding(atlas,major_cols,dots=.44) + theme(legend.position="none")
A <- A + inset_element(mini_atlas,.561,.09,.681,.55,align_to="full")
A <- panel_tag(A,"A")

B <- embedding(atlas,major_cols,dots=.91,labels=paste0(1:3,": ",names(major_cols))) + centroid_labels(atlas,major_cols,2.85,offset=.8) +
  add_l_arrows(data=atlas,x=-.01,y=-.035,length=.155) +
  guides(colour=guide_legend(override.aes=list(size=2.4,alpha=1))) +
  theme(legend.position="inside",legend.position.inside=c(.82,.135),legend.key.size=grid::unit(2.9,"mm"),
        legend.background=element_rect(fill="white",colour=NA))
B <- panel_tag(B,"B")

markers <- c("COL1A1","COL1A2","DCN","PECAM1","VWF","CD34","ACTA2","PDGFRB","MCAM")
srt <- qs::qread(file.path(paper_dir,"data_small/scrna_stromal_small.qs"), nthreads=1)
counts <- as.matrix(SeuratObject::GetAssayData(srt,layer="counts"))
library_size <- colSums(counts)
expr <- log1p(sweep(counts[markers,atlas$cell,drop=FALSE],2,library_size[atlas$cell],"/")*1e4)
features <- lapply(seq_along(markers), function(i) {
  atlas$expression <- as.numeric(expr[i,])
  mural_marker <- markers[i] %in% c("ACTA2","PDGFRB","MCAM")
  upper <- quantile(atlas$expression,.995,names=FALSE)
  ramp <- if(mural_marker) c("#DAD8D8","#DDDADA","#E8C9D0",marker_cols[2]) else
    c(marker_cols[1],"#D6D4D2","#E6DDDE","#F1CED2",marker_cols[2])
  feature_panel(atlas,"expression",ramp,markers[i],dots=.42,bar=TRUE,manifold=TRUE,
    limits=c(0,upper),colours_at=if(mural_marker) c(0,.63,.92,1) else NULL) +
    theme(plot.title=element_text(size=9.2,face="bold"))
})
C <- panel_tag(wrap_plots(features,ncol=3),"C")
rm(srt,counts,expr,features)

enclose_groups <- function(d, groups, positions) {
  curves <- lapply(seq_along(groups),function(i) {
    points <- d[match(d$cluster,unique(positions$cluster)) %in% groups[[i]],c("x","y")]
    stopifnot(nrow(points)>3)
    mid <- colMeans(points)
    dist <- sqrt(rowSums(sweep(as.matrix(points),2,mid)^2))
    points <- points[dist <= quantile(dist,.96),]
    h <- chull(points)
    scaled <- 1.075*sweep(as.matrix(points[h,]),2,mid)
    scaled <- sweep(scaled,2,mid,"+")
    closed <- rbind(scaled,scaled[1,])
    bx <- stats::spline(seq_len(nrow(closed)),closed[,1],n=120,method="periodic")$y
    by <- stats::spline(seq_len(nrow(closed)),closed[,2],n=120,method="periodic")$y
    data.frame(x=bx,y=by,group=i)
  })
  geom_polygon(data=do.call(rbind,curves),aes(x,y,group=group),inherit.aes=FALSE,
               colour="#D63A2F",fill=NA,linetype="dashed",linewidth=.32)
}
sub_panel <- function(d,pal,title,groups,x,y) {
  lookup <- data.frame(cluster=names(pal))
  text <- data.frame(x=x,y=-y,label=names(groups))
  ggplot(d,aes(x,y,colour=cluster)) +
    geom_raster(data=attr(d,"reference_density"),aes(x,y,fill=cluster),
                inherit.aes=FALSE,alpha=.76,interpolate=TRUE) +
    scale_fill_manual(values=pal,guide="none",na.value="transparent") + manifold_points(size=.81) +
    scale_colour_manual(values=pal,guide="none") + coord_equal(clip="off") +
    labs(title=title) + theme_umap_blank() + enclose_groups(d,groups,lookup) +
    centroid_labels(d,pal,3.05,offset=.95) +
    halo_text(text,2.55,"#D63A2F",offset=1.05) +
    theme(legend.position="none",plot.title=element_text(size=9.5,face="bold"))
}
D <- panel_tag(wrap_plots(
  sub_panel(manifolds$umap_fib,fib_cols,"Fib",
    list(mFib=c(1,9),tFib=c(11,14),apFib=12,iFib=c(4,5,6),ifnFib=2,lpFib=c(3,7,10,13)),
    c(195,298,335,431,454,393),c(1076,956,1028,986,1038,1140)),
  sub_panel(manifolds$umap_ec,ec_cols,"EC",
    list(infEC=10:11,VenEC=5:6,CapEC=3,TipEC=4,emtEC=c(8,9),tEC=7,ArtEC=1:2,LEC=12),
    c(633,550,594,608,672,688,649,777),c(950,1040,1018,1068,1024,1093,1144,1055)),
  sub_panel(manifolds$umap_mural,mural_cols,"Mural cell",
    list(tPC=4:8,SMC=1:3,nPC=9:10),c(935,870,1027),c(916,993,1126)),nrow=1),"D")

items <- c("Fib",names(fib_cols),"EC",names(ec_cols),"Mural cell",names(mural_cols))
labels <- data.frame(label=items,x=rep(0:3,c(10,10,10,9)),y=rep(10:1,4)[-40])
pal <- c(fib_cols,ec_cols,mural_cols)
labels$ink <- unname(pal[labels$label])
legend <- ggplot(labels,aes(x,y)) +
  geom_point(data=labels[!is.na(labels$ink),],aes(colour=ink),size=3.4) +
  geom_text(aes(x=x+.075,label=label,fontface=ifelse(is.na(ink),"bold","plain")),hjust=0,size=3.46) +
  scale_colour_identity() + coord_cartesian(xlim=c(-.12,3.83),ylim=c(.6,10.65),expand=FALSE) +
  theme_void() + theme(plot.margin=margin(0,4,1,7))

fig <- wrap_plots(A,wrap_plots(B,C,nrow=1,widths=c(.38,.62)),D,legend,
                  ncol=1,heights=c(.24,.28,.31,.17))
save_replica(fig,"fig01_replica",9.6,12.2)
rm(list=ls()); invisible(gc())
