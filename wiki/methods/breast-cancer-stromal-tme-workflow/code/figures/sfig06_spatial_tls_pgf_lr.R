script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) {
  stop("Run this figure with Rscript --vanilla <figure-script.R>.")
}
script_dir <- dirname(sub("^--file=", "", script_arg))
source(file.path(script_dir, "..", "00c_style_and_manifold.R"))

st <- read_step("step03_spatial","st_spots_sfig6abc")
features <- c("C8_iFib_CCL19","C4_TipEC_PGF","M1","M2","CD4_Effector_T","CD4_Exhausted_T",
              "CD8_Cytotoxic_T","Treg","Transitory_T")
fields <- paste0("score_",features)
density_pal <- c("#46468A","#5CB874","#F7DC6F","#C0392B")
stopifnot(all(c(fields,"CCL19","CCR7","CD8A","CD79A","CD19","CD3E") %in% names(st)))
scale_ranges <- lapply(st[fields],function(x) quantile(x,c(.025,.985),na.rm=TRUE,names=FALSE))
st$density_region <- cut(st$imagerow,quantile(st$imagerow,0:3/3),include.lowest=TRUE,labels=FALSE)
segmented <- split(st,st$density_region)
density <- do.call(rbind,lapply(segmented,function(d) {
  xy <- cbind(d$imagecol,-d$imagerow)
  grid <- expand.grid(x=seq(min(xy[,1]),max(xy[,1]),length.out=87),
                      y=seq(min(xy[,2]),max(xy[,2]),length.out=87))
  nn <- RANN::nn2(xy,as.matrix(grid),k=4)
  spacing <- median(RANN::nn2(xy,k=2)$nn.dists[,2])
  mask <- nn$nn.dists[,1] <= 1.01*spacing
  w <- exp(-.5*(nn$nn.dists/(.42*spacing))^2)
  do.call(rbind,lapply(seq_along(fields),function(i) {
    value <- matrix(d[[fields[i]]][nn$nn.idx],nrow=nrow(nn$nn.idx))
    value <- rowSums(value*w)/rowSums(w)
    value[!mask] <- NA_real_
    transform(grid,x=round(scale01(x),8),y=round(scale01(y),8),
      intensity=scales::squish(scales::rescale(value,from=scale_ranges[[i]])),
      region=factor(d$density_region[1],levels=1:3,labels=paste("Region",1:3)),
      feature=factor(features[i],levels=features))
  }))
}))
grids <- ggplot(density,aes(x,y,fill=intensity)) +
  geom_raster(interpolate=TRUE) +
  facet_grid(region~feature,switch="y") +
  scale_fill_gradientn(colours=density_pal,limits=c(0,1),na.value="white",guide="none") +
  coord_cartesian(xlim=c(-.024,1.024),ylim=c(-.024,1.024),expand=FALSE) +
  theme_void() + theme(aspect.ratio=1,strip.placement="outside",
    strip.text.x=element_text(size=7.65,hjust=.5,margin=margin(b=4)),
    strip.text.y.left=element_text(size=6.3,angle=90,margin=margin(r=3)),
    panel.border=element_rect(fill=NA,colour="#171717",linewidth=.56),
    panel.spacing=grid::unit(2.4,"mm"),plot.margin=margin(1,2,1,4))
subhead <- wrap_elements(full=grid::textGrob("CAA_ST  |  Three regions of one Visium section",
  x=.043,just="left",gp=grid::gpar(fontsize=6.9,col="#4D484B")))
a_body <- wrap_plots(subhead,wrap_elements(full=grids),wrap_elements(),
                    ncol=1,heights=c(.065,.888,.047))
density_key <- grid::grobTree(
  grid::textGrob("Cell density",x=.282,y=.43,just="right",gp=grid::gpar(fontsize=6.45)),
  grid::rasterGrob(as.raster(matrix(colorRampPalette(density_pal)(128),nrow=1)),
    x=.651,y=.42,width=.648,height=.30),
  grid::textGrob(c("Min","Max"),x=c(.328,.975),y=.86,gp=grid::gpar(fontsize=5.4)))
a_body <- wrap_elements(full=a_body) +
  inset_element(density_key,
                .826,.001,.996,.054,align_to="full")
A <- panel_tag(a_body,"A")

st$half <- 1L+(st$imagecol>median(st$imagecol))
st$band <- ave(st$imagerow,st$half,FUN=function(y)
  cut(y,quantile(y,0:4/4),labels=FALSE,include.lowest=TRUE))
st$region <- (st$half-1L)*4L+st$band
areas <- split(st,st$region)
view_order <- c(1,2,3,4,5,6,7,8)
positions <- lapply(areas,function(d) {
  d$x <- scale01(d$imagecol)
  d$y <- scale01(-d$imagerow)
  d
})
positions <- do.call(rbind,positions)
positions$region <- factor(positions$region,levels=view_order,labels=paste("Area",view_order))
footprint <- do.call(rbind,lapply(areas,function(d) {
  xy <- cbind(d$imagecol,-d$imagerow)
  grid <- expand.grid(x=seq(min(xy[,1]),max(xy[,1]),length.out=70),
                      y=seq(min(xy[,2]),max(xy[,2]),length.out=70))
  spacing <- median(RANN::nn2(xy,k=2)$nn.dists[,2])
  gap <- RANN::nn2(xy,as.matrix(grid),k=1)$nn.dists[,1]
  transform(grid,x=round(scale01(x),8),y=round(scale01(y),8),
    ink=ifelse(gap<.93*spacing,"#F4F2F4","white"),
    region=factor(paste("Area",d$region[1]),levels=paste("Area",view_order)))
}))
scale_signals <- function(channels) {
  setNames(vapply(channels,function(gene) {
    p <- quantile(st[[gene]],.99,na.rm=TRUE,names=FALSE)
    if(p<=0) max(st[[gene]],na.rm=TRUE) else p
  },numeric(1)),channels)
}

tls_grid <- function(inks,tag,title) {
  high <- scale_signals(names(inks))
  offsets <- if (length(inks)==2L) rbind(c(-1,0),c(1,0)) else
    rbind(c(-1,1),c(1,1),c(-1,-1),c(1,-1))
  dots <- do.call(rbind,lapply(seq_along(inks),function(i) {
    gene <- names(inks)[i]
    v <- scales::squish(positions[[gene]]/high[[gene]])
    value <- transform(positions,x=x+offsets[i,1]*.009,y=y+offsets[i,2]*.009,
                       level=v,ink=unname(inks[i]))
    value[is.finite(value$level)&value$level>0,]
  }))
  maps <- ggplot(positions,aes(x,y)) +
    geom_raster(data=footprint,aes(x,y,fill=ink),inherit.aes=FALSE,interpolate=TRUE) +
    scale_fill_identity() +
    geom_point(colour="#E0DFE1",size=.63,stroke=0) +
    geom_point(data=dots[order(dots$level),],aes(colour=ink,alpha=level^1.25),size=.48,stroke=0) +
    scale_colour_identity() + scale_alpha_continuous(range=c(.07,.88),limits=c(0,1),guide="none") +
    facet_wrap(~region,ncol=4) +
    coord_cartesian(xlim=c(-.032,1.032),ylim=c(-.035,1.035),expand=FALSE) +
    theme_void() + theme(aspect.ratio=1,strip.text=element_text(size=6.3,margin=margin(b=2)),
      panel.border=element_rect(fill=NA,colour="#A39EA2",linewidth=.43),
      panel.spacing=grid::unit(2.2,"mm"),plot.margin=margin(0,1,0,4))
  keys <- wrap_plots(lapply(names(inks),function(gene)
    wrap_elements(full=wave_key(c("#F3EFF1",inks[[gene]]),title=gene,min="0",
      max=format(round(high[[gene]],2),trim=TRUE,nsmall=1),
      vertical=TRUE,label_size=6.0,title_gap=length(inks)>2L))),ncol=1)
  tag_body <- wrap_plots(
    wrap_elements(full=grid::textGrob(title,x=.085,just="left",
      gp=grid::gpar(fontsize=6.75,col="#4B444A"))),
    wave_section(wrap_elements(full=maps),wrap_elements(full=keys),widths=c(.881,.119)),
    ncol=1,heights=c(.068,.932))
  panel_tag(tag_body,tag)
}
B <- tls_grid(c(CCL19="#3B7EB6",CCR7="#D73027"),"B","CAA_ST  |  CCL19 and CCR7")
C <- tls_grid(c(CD8A="#D73027",CD79A="#31A354",CD19="#3B7EB6",CD3E="#8856A7"),
              "C","CAA_ST  |  TLS lymphocyte markers")

targets <- c("Regulatory T","Transitory_T","Plasma B","pDC","NK","Neutrophil","Naive B",
  "Memory B","Mast","M2","M1","GC B","Epi","DC_LAMP3","DC_CLEC9A","DC_CD1C",
  "CD8_Cytotoxic_T","CD4_Tfh","CD4_Naive_T","CD4_Exhausted_T","CD4_Effector_T")
interactions <- c("TGFB1_TGFBR1_TGFBR2","CCL14_CCR1","CXCL12_CXCR4","MIF_CD74_CXCR4",
  "MIF_CD74_CD44","LGALS9_CD45","LGALS9_HAVCR2","LGALS9_CD44","LGALS9_P4HB",
  "LAMA4_CD44","LAMA5_CD44","LAMB1_CD44","LAMB2_CD44","LAMC1_CD44")
pick_lr <- function(x) {
  x$target <- sub("^(GC|Memory|Naive|Plasma|Regulatory)_([BT])$","\\1 \\2",x$target)
  x[grepl("^C4_tips_PGF",x$source)& x$target %in% targets &
      x$interaction_name %in% interactions & is.finite(x$prob),]
}
panel <- pick_lr(read_step("step05_crosstalk","sfig6d_pgf_tme_lr"))
official <- pick_lr(read_input("data_small","moesm","cellchat_edges.csv"))
key <- function(d) paste(d$target,d$interaction_name,sep="|")
missing <- !key(official) %in% key(panel)
lr <- rbind(panel[c("target","interaction_name","prob")],
            official[missing,c("target","interaction_name","prob")])
lr$x <- lr$interaction_name
lr$x[lr$x=="TGFB1_TGFBR1_TGFBR2"] <- "TGFB1_TGFBR1/2"
lr$y <- paste0("C4_TipEC_PGF -> ",lr$target)
shown_cols <- interactions
shown_cols[1] <- "TGFB1_TGFBR1/2"
shown_rows <- paste0("C4_TipEC_PGF -> ",targets)
stopifnot(all(shown_rows %in% lr$y),all(shown_cols %in% lr$x))
message("Supplementary Figure 6D: ",length(shown_rows)," targets x ",length(shown_cols),
  " interactions; ",length(unique(key(lr)))," populated cells (",nrow(panel)," from subset table)")

bubble <- ggplot(aggregate(prob~x+y,lr,max),aes(x,y,fill=prob,size=prob)) +
  geom_point(shape=21,colour="#151515",stroke=.42) +
  scale_x_discrete(limits=shown_cols,expand=expansion(add=.57),drop=FALSE) +
  scale_y_discrete(limits=rev(shown_rows),expand=expansion(add=.57),drop=FALSE) +
  scale_fill_gradientn(colours=lr_cols,breaks=c(.04,.08,.12),name="Communication\nProbability") +
  scale_size_continuous(range=c(1.03,4.35),breaks=c(.04,.08,.12),name="prob") +
  guides(size=guide_legend(order=1,ncol=1,override.aes=list(fill="#0E0E0E")),
    fill=guide_colourbar(order=2,direction="vertical",barwidth=grid::unit(2.3,"mm"),
                         barheight=grid::unit(16,"mm"))) +
  theme_bw(base_size=7) +
  theme(axis.title=element_blank(),axis.ticks=element_blank(),
    axis.text.x=element_text(angle=90,hjust=1,vjust=.5,colour="#262326",size=6.55,margin=margin(t=2)),
    axis.text.y=element_text(colour="#262326",size=6.15),
    panel.border=element_rect(colour="#111111",linewidth=.52),
    panel.grid=element_line(colour="#E3E3E5",linewidth=.37),
    legend.position="bottom",legend.box="horizontal",legend.box.just="left",
    legend.title=element_text(size=7),legend.text=element_text(size=6.3),
    legend.key.size=grid::unit(3.5,"mm"),legend.box.spacing=grid::unit(1.25,"mm"),
    plot.margin=margin(30,8,4,8))
grDevices::pdf(NULL)
g <- tryCatch(ggplotGrob(bubble),finally=invisible(grDevices::dev.off()))
i <- match("guide-box-bottom",g$layout$name)
stopifnot(!is.na(i))
legend <- g$grobs[[i]]
bubble <- bubble+theme(legend.position="none",plot.margin=margin(30,8,60,8))
D <- panel_tag(wrap_elements(full=bubble) +
  inset_element(legend,.005,.010,.279,.158,align_to="full"),"D")
figure <- wrap_plots(wrap_elements(full=A),
  wave_section(wave_section(B,C,nrow=2,heights=c(.5,.5)),D,widths=c(.54,.46)),
  ncol=1,heights=c(.42,.58))
save_replica(figure,"sfig06_replica",12.0,11.2)
rm(list=ls()); invisible(gc())

