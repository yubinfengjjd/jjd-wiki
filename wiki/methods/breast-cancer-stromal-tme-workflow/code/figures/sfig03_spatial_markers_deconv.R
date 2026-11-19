script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) {
  stop("Run this figure with Rscript --vanilla <figure-script.R>.")
}
script_dir <- dirname(sub("^--file=", "", script_arg))
source(file.path(script_dir, "..", "00c_style_and_manifold.R"))

st <- read_step("step03_spatial","st_spots_sfig3")
genes <- c("COL1A1","COL1A2","DCN")
weights <- c("C10_lpFib_ABCA8"="weight_C10_lpFib_ABCA8","CD8_Cytotoxic_T"="weight_CD8_Cytotoxic_T")
stopifnot(all(c("spot","imagecol","imagerow",genes,weights) %in% names(st)))
expr_ink <- c("#3288BD","#E6F598","#FEE08B","#F46D43","#9E0142")
density_ink <- c("#46468A","#5CB874","#F7DC6F","#C0392B")

quantile01 <- function(x,p=c(.05,.95)) {
  bounds <- quantile(x,p,na.rm=TRUE,names=FALSE)
  if (diff(bounds)<.Machine$double.eps) return(scale01(x))
  scales::squish(scales::rescale(x,from=bounds))
}

st$x_half <- 1L+(st$imagecol>median(st$imagecol))
st$y_band <- ave(st$imagerow,st$x_half,FUN=function(y)
  cut(y,quantile(y,0:4/4),labels=FALSE,include.lowest=TRUE))
st$region <- (st$x_half-1L)*4L+st$y_band
stopifnot(length(unique(st$region))==8L)
for (gene in genes) st[[paste0(gene,"_display")]] <- quantile01(st[[gene]])

expr_block <- function(region_order) {
  s <- st[st$region %in% region_order,]
  s$region_label <- factor(paste("Region",s$region),levels=paste("Region",region_order))
  long <- do.call(rbind,lapply(genes,function(gene)
    transform(s,gene=factor(gene,levels=genes),signal=s[[paste0(gene,"_display")]])))
  long <- do.call(rbind,lapply(split(long,long$region),function(d) {
    transform(d,x=scale01(imagecol),y=scale01(-imagerow))
  }))
  ground <- do.call(rbind,lapply(split(s,s$region),function(d) {
    xy <- cbind(d$imagecol,-d$imagerow)
    grid <- expand.grid(x=seq(min(xy[,1]),max(xy[,1]),length.out=92),
                        y=seq(min(xy[,2]),max(xy[,2]),length.out=92))
    near <- RANN::nn2(xy,as.matrix(grid),k=1)
    spacing <- median(RANN::nn2(xy,k=2)$nn.dists[,2])
    do.call(rbind,lapply(genes,function(gene) {
      score <- d[[paste0(gene,"_display")]][near$nn.idx[,1]]
      ink <- wave_colour(score,expr_ink,c(0,1))
      rgb <- col2rgb(ink)
      ink <- grDevices::rgb((.72*255+.28*rgb[1,])/255,
                            (.72*255+.28*rgb[2,])/255,
                            (.72*255+.28*rgb[3,])/255)
      ink[near$nn.dists[,1]>.93*spacing] <- "white"
      transform(grid,x=round(scale01(x),8),y=round(scale01(y),8),ink=ink,
                region_label=d$region_label[1],gene=factor(gene,levels=genes))
    }))
  }))
  ggplot(long[order(long$signal),],aes(x,y,colour=signal)) +
    geom_raster(data=ground,aes(x,y,fill=ink),inherit.aes=FALSE,interpolate=TRUE) +
    scale_fill_identity() +
    geom_point(size=1.02,stroke=0,alpha=.91) +
    facet_grid(region_label~gene,switch="y") +
    scale_colour_gradientn(colours=expr_ink,limits=c(0,1),guide="none") +
    coord_cartesian(xlim=c(-.038,1.038),ylim=c(-.038,1.038),expand=FALSE) +
    theme_void() + theme(aspect.ratio=1,panel.border=element_rect(fill=NA,colour="#141414",linewidth=.54),
      strip.text.x=element_text(size=10.1,margin=margin(b=4)),
      strip.text.y.left=element_text(size=8.7,angle=90,margin=margin(r=4)),
      strip.placement="outside",panel.spacing=grid::unit(1.9,"mm"),plot.margin=margin(4,3,2,5))
}
expression <- wrap_plots(wrap_elements(full=expr_block(1:4)),
                          wrap_elements(full=expr_block(5:8)),nrow=1)
title <- wrap_elements(full=grid::textGrob("CAA_ST  |  Eight regions of one Visium section",
  x=.055,just="left",gp=grid::gpar(fontsize=7.2,col="#444444")))
A <- wrap_elements(full=wrap_plots(title,expression,ncol=1,heights=c(.045,.955))) +
  inset_element(wave_key(expr_ink,min="Min",max="Max"),.448,.953,.551,.998,align_to="full")
A <- panel_tag(A,"A")

# The original low-resolution H&E channels are stored in the raw object.
# Check the barcode-level alignment before displaying histology and scores.
suppressPackageStartupMessages(library(Seurat))
object <- qs::qread(file.path(paper_dir,"data_small/CAA_ST-umap.qs"),nthreads=1)
image_names <- SeuratObject::Images(object)
stopifnot(length(image_names)==1L)
image <- object[[image_names[1]]]
he <- methods::slot(image,"image")
co <- SeuratObject::GetTissueCoordinates(image,scale="lowres")
idx <- match(st$spot,rownames(co))
stopifnot(length(dim(he))==3,dim(he)[3]==3,!anyNA(idx),
  max(abs(st$imagecol-co$imagecol[idx]))<.001,
  max(abs(st$imagerow-co$imagerow[idx]))<.001)
message("Supplementary Figure 3: aligned ",length(idx)," spots to H&E ",image_names[1],
        " (",dim(he)[2]," x ",dim(he)[1],")")
rm(object,image,co)
invisible(gc())

st$quadrant <- 1L+2L*(st$x_half-1L)+(st$imagerow>median(st$imagerow))
for (field in weights) {
  st[[paste0(field,"_display")]] <- quantile01(st[[field]],p=c(0,.995))^1.65
}
crop_bounds <- function(d) {
  x <- seq(max(1,floor(min(d$imagecol)-7)),min(dim(he)[2],ceiling(max(d$imagecol)+7)))
  y <- seq(max(1,floor(min(d$imagerow)-7)),min(dim(he)[1],ceiling(max(d$imagerow)+7)))
  list(x=x,y=y)
}
tissue_crop <- function(bounds) {
  grid::rasterGrob(as.raster(he[bounds$y,bounds$x,,drop=FALSE]),interpolate=TRUE)
}
density_tile <- function(d,field,bounds) {
  d$score <- d[[paste0(field,"_display")]]
  d <- d[order(d$score),]
  xy <- cbind(d$imagecol,-d$imagerow)
  grid <- expand.grid(x=seq(min(bounds$x),max(bounds$x),length.out=95),
                      y=seq(-max(bounds$y),-min(bounds$y),length.out=95))
  near <- RANN::nn2(xy,as.matrix(grid),k=1)
  spacing <- median(RANN::nn2(xy,k=2)$nn.dists[,2])
  grid$score <- d$score[near$nn.idx[,1]]
  grid$score[near$nn.dists[,1]>.85*spacing] <- NA_real_
  ggplot(d,aes(imagecol,-imagerow,colour=score)) +
    geom_raster(data=grid,aes(x,y,fill=score),inherit.aes=FALSE,interpolate=TRUE) +
    geom_point(size=.99,stroke=0) +
    scale_fill_gradientn(colours=density_ink,limits=c(0,1),na.value="white",guide="none") +
    scale_colour_gradientn(colours=density_ink,limits=c(0,1),guide="none") +
    coord_fixed(xlim=range(bounds$x),ylim=range(-bounds$y),expand=FALSE) +
    theme_void() + theme(plot.margin=margin(0,0,0,0))
}
score_header <- function(label) {
  colours <- grDevices::colorRampPalette(density_ink)(96)
  grid::grobTree(
    grid::textGrob(label,x=.01,y=.55,just="left",gp=grid::gpar(fontsize=5.3)),
    grid::rasterGrob(as.raster(matrix(colours,nrow=1)),x=.79,y=.58,width=.34,height=.31),
    grid::textGrob(c("Min","Max"),x=c(.62,.96),y=.19,gp=grid::gpar(fontsize=4.45)))
}
B <- ggplot()+theme_void()+theme(plot.margin=margin(0,0,0,0))
order <- c(1L,3L,2L,4L)
for (i in seq_along(order)) {
  q <- order[i]
  d <- st[st$quadrant==q,]
  bounds <- crop_bounds(d)
  origin_x <- if(i%%2L==0) .506 else .013
  origin_y <- if(i>2L) .01 else .512
  he_header <- grid::textGrob(paste("H&E  |  Section quadrant",q),
                              gp=grid::gpar(fontsize=5.8,col="#454045"))
  tops <- list(he_header,score_header(names(weights)[1]),score_header(names(weights)[2]))
  maps <- list(tissue_crop(bounds),density_tile(d,weights[1],bounds),density_tile(d,weights[2],bounds))
  for(j in seq_along(maps)) {
    a <- origin_x+(j-1L)*.159
    b <- a+.151
    B <- B + inset_element(tops[[j]],a,origin_y+.398,b,origin_y+.471,align_to="full") +
      inset_element(maps[[j]],a,origin_y+.006,b,origin_y+.390,align_to="full")
  }
}
B <- panel_tag(B,"B")
figure <- wrap_plots(wrap_elements(full=A),wrap_elements(full=B),ncol=1,heights=c(.68,.32))
save_replica(figure,"sfig03_replica",10.8,11.0)
rm(list=ls()); invisible(gc())

