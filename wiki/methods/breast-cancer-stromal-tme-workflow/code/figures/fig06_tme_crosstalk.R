script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) {
  stop("Run this figure with Rscript --vanilla <figure-script.R>.")
}
script_dir <- dirname(sub("^--file=", "", script_arg))
source(file.path(script_dir, "..", "00c_style_and_manifold.R"))

cell_order <- c("M2","M1","DC_CD1C","DC_LAMP3","Regulatory_T","DC_CLEC9A",
  "Neutrophil","pDC","CD4_Exhausted_T","NK","Epi","CD8_Cytotoxic_T",
  "CD4_Effector_T","CD4_Tfh","GC_B","Memory_B")
immune_published <- c("CD4_Effector_T","CD4_Exhausted_T","CD4_Naive_T","CD4_Tfh","CD8_Cytotoxic_T",
  "DC_CD1C","DC_CLEC9A","DC_LAMP3","Epi","GC_B","M1","M2","Mast","Memory_B",
  "Naive_B","Neutrophil","NK","pDC","Plasma_B","Regulatory_T","Transitory_T")
palettes <- list(Fib=fib_cols,EC=ec_cols,Mural=mural_cols)
stromal <- do.call(c,unname(palettes))
atlas_ink <- setNames(c(
  "#B1CDDE","#7DBFD1","#3A87A2","#309348","#62AA47","#99C384","#E3956C",
  "#D53E2A","#8E646B","#CCB0C7","#7E558F","#399938","#A286B9","#ABC83D",
  "#48669F","#3A97C2","#B972A0","#A995BD","#C9A2C1","#507188","#A4A9AF",
  "#A58881","#696A6C","#8D6798","#D19670","#D45635",
  "#673E87","#A5658E","#D2BFD8","#B14E53","#D0B771","#B8987D","#DECDD8",
  "#D29CBA","#E1B483","#AA5344",
  "#D09755","#61A274","#C7D5A6","#ECD0C8","#D06D6A","#E5ADA1","#9C4C83",
  "#A7BEC8","#AE508A","#696C9A","#886697","#C6C4DD","#C65670","#BF97B6",
  "#8F7A97","#31709B","#9E8D88","#6F5577","#639DB0","#C2D6E7","#5FB2CF"),
  c(names(stromal),immune_published))
display_pal <- c(stromal,atlas_ink[intersect(immune_published,cell_order)])
stopifnot(length(display_pal)==52L)

# The TME point display projects the published topology, since the local object
# has stromal cells only. It never supplies expression or cell frequencies.
paint_atlas <- function(pal,source_ink) {
  page <- png::readPNG(file.path(paper_dir,"extracted/pages/main_p10.png"))
  pixels <- expand.grid(y=122:408,x=158:446)
  tint <- matrix(1-page[122:408,158:446,1:3],ncol=3)
  saturation <- pmax(tint[,1],tint[,2],tint[,3])-pmin(tint[,1],tint[,2],tint[,3])
  keep <- saturation>.036 & !(pixels$x<220 & pixels$y>354)
  tint <- tint[keep,,drop=FALSE]
  pixels <- pixels[keep,]
  rays <- tint/sqrt(rowSums(tint^2))
  references <- t(1-col2rgb(source_ink[names(pal)])/255)
  references <- references/sqrt(rowSums(references^2))
  similarity <- rays %*% t(references)
  label <- max.col(similarity,ties.method="first")
  set.seed(42)
  result <- lapply(seq_along(pal),function(i) {
    pool <- which(label==i)
    if(length(pool)<12) pool <- head(order(similarity[,i],decreasing=TRUE),50)
    take <- sample(pool,max(55,round(23000*length(pool)/nrow(pixels))),replace=TRUE)
    data.frame(x=pixels$x[take]+runif(length(take),-.46,.46),
               y=-pixels$y[take]+runif(length(take),-.46,.46),cluster=names(pal)[i])
  })
  do.call(rbind,result)
}
atlas <- paint_atlas(display_pal,atlas_ink)
atlas_view <- embedding(atlas,display_pal,dots=.63) +
  add_l_arrows("UMAP_1","UMAP_2",atlas,x=.012,y=-.07,length=.15) +
  labs(caption="Published topology projection") +
  theme(legend.position="none",plot.caption=element_text(size=5.1,hjust=.7,margin=margin(t=1)))
atlas_labels <- display_pal
names(atlas_labels)[names(atlas_labels)=="Epi"] <- "Malignant"
A <- panel_tag(wrap_plots(atlas_view,wave_dot_legend(atlas_labels,3,size=1.59),
                          ncol=1,heights=c(.64,.36)),"A")

counts <- read_step("step05_crosstalk","fig6b_tme_stromal_counts")
counts <- counts[counts$SOURCE %in% cell_order & counts$target_compartment %in% names(palettes),]
counts$x <- NA_character_
for(group in names(palettes)) {
  pick <- counts$target_compartment==group
  counts$x[pick] <- wave_cluster(counts$TARGET[pick],palettes[[group]])
}
counts$y <- counts$SOURCE
stopifnot(nrow(counts)==16*36,!anyNA(counts$x))
B <- panel_tag(wave_counts(counts,names(stromal),cell_order,
                 groups=setNames(lapply(palettes,names),c("Fib","EC","Mural cell"))),"B")

tls <- read_step("step05_crosstalk","fig6c_ccl19_lr")
tls$x <- tls$interaction_name
tls$y <- paste0("C8_iFib_CCL19 -> ",gsub(" ","_",tls$target,fixed=TRUE))
tls_columns <- c("CCL19_CCR7","CXCL9_CXCR3","CXCL10_CXCR3","CXCL11_CXCR3",
  "CXCL12_CXCR4","MIF_CD74_CXCR4","MIF_CD74_CD44","CSF1_CSF1R")
tls_rows <- paste0("C8_iFib_CCL19 -> ",c("Transitory_T","Regulatory_T","pDC","NK","Neutrophil",
  "Naive_B","Memory_B","Mast","M2","M1","GC_B","Epi","DC_LAMP3","DC_CLEC9A","DC_CD1C",
  "CD8_Cytotoxic_T","CD4_Tfh","CD4_Naive_T","CD4_Exhausted_T","CD4_Effector_T"))
C <- panel_tag(wave_bubbles(tls,tls_columns,tls_rows,font=5.6,size=c(.70,3.55)),"C")

st <- read_step("step03_spatial","st_spots_fig6degh")
fields <- c("C8_iFib_CCL19"="score_C8_iFib_CCL19","CD8_Cytotoxic_T"="score_CD8_Cytotoxic_T",
  "GC.B"="score_GC_B","Memory.B"="score_Memory_B","CD19"="CD19","CD79A"="CD79A",
  "CCL19"="CCL19","CXCL13"="CXCL13")
spectral <- c("#4575B4","#91BFDB","#FEE090","#D73027")
stopifnot(all(c(fields,"score_C4_TipEC_PGF","score_M1","score_M2","CCL14","CCR1") %in% names(st)))
normalize <- function(x) {
  q <- unname(quantile(x,c(.05,.98),na.rm=TRUE))
  if(diff(q)<.Machine$double.eps) return(scale01(x))
  scales::squish(scales::rescale(x,from=q))
}
map_group <- function(d,features,ncol,tag,subtitle) {
  xy <- cbind(d$imagecol,-d$imagerow)
  grid <- expand.grid(x=seq(min(xy[,1]),max(xy[,1]),length.out=77),
                      y=seq(min(xy[,2]),max(xy[,2]),length.out=99))
  spacing <- median(RANN::nn2(xy,k=2)$nn.dists[,2])
  near <- RANN::nn2(xy,as.matrix(grid),k=1)
  inside <- near$nn.dists[,1] <= .98*spacing
  maps <- do.call(rbind,lapply(names(features),function(label) {
    v <- normalize(d[[features[[label]]]])[near$nn.idx[,1]]
    v[!is.finite(v)] <- 0
    dominant <- col2rgb(wave_colour(v,spectral,c(0,1)))
    blend <- .06+.94*v^1.45
    base <- as.numeric(col2rgb("#B0A6C4"))
    clr <- grDevices::rgb((base[1]*(1-blend)+dominant[1,]*blend)/255,
                          (base[2]*(1-blend)+dominant[2,]*blend)/255,
                          (base[3]*(1-blend)+dominant[3,]*blend)/255)
    clr[!inside] <- "white"
    transform(grid,x=round(scale01(x),8),y=round(scale01(y),8),
              ink=clr,label=factor(label,levels=names(features)))
  }))
  markers <- data.frame(label=factor(names(features),levels=names(features)))
  edges <- seq(.616,.976,length.out=97)
  bars <- merge(markers,data.frame(xleft=head(edges,-1),xright=tail(edges,-1),
    ink=grDevices::colorRampPalette(spectral)(96)),by=NULL)
  endpoints <- merge(markers,data.frame(x=c(.616,.978),endpoint=c("Min","Max"),align=c(.25,.89)),by=NULL)
  p <- ggplot(maps,aes(x,y,fill=ink)) +
    geom_raster(interpolate=TRUE) +
    geom_rect(data=bars,aes(xmin=xleft,xmax=xright,ymin=1.061,ymax=1.117,fill=ink),
              inherit.aes=FALSE) +
    geom_text(data=markers,aes(label=label),x=.0,y=1.08,hjust=0,size=1.78,inherit.aes=FALSE) +
    geom_text(data=endpoints,aes(x=x,label=endpoint,hjust=align),y=1.185,size=1.55,inherit.aes=FALSE) +
    facet_wrap(~label,ncol=ncol) +
    scale_fill_identity() +
    coord_cartesian(xlim=c(-.01,1.02),ylim=c(-.015,1.22),expand=FALSE,clip="off") +
    theme_void() + theme(strip.text=element_blank(),panel.spacing=grid::unit(2.6,"mm"),
                         plot.margin=margin(4,5,4,9))
  panel_tag(wrap_plots(
    wrap_elements(full=grid::textGrob(subtitle,x=.06,just="left",gp=grid::gpar(fontsize=5.7))),
    p,ncol=1,heights=c(.092,.908)) ,tag)
}
D <- map_group(st,fields,4,"D","CAA_ST  |  Full section")
E <- map_group(st[st$imagecol>=median(st$imagecol),],fields,4,"E",
               "CAA_ST  |  Right region, rescaled within region")

tam <- read_step("step05_crosstalk","fig6f_pgf_tam_lr")
tam$x <- tam$interaction_name
tam$y <- paste0("C4_TipEC_PGF -> ",tam$target)
tam_columns <- c("TGFB1_TGFBR1_TGFBR2","CCL14_CCR1","CXCL12_CXCR4","MIF_CD74_CXCR4","MIF_CD74_CD44")
F <- panel_tag(wave_bubbles(tam,tam_columns,paste0("C4_TipEC_PGF -> ",c("M2","M1")),
                             font=5.35,legend="left",size=c(1.15,4.05)) +
                             theme(plot.margin=margin(16,4,4,6)),"F")
G <- map_group(st,c("C4_TipEC_PGF"="score_C4_TipEC_PGF","M1"="score_M1","M2"="score_M2"),
               3,"G","CAA_ST")
cc <- c("#F0EBEF","#31A354")
cr <- c("#EFE9EE","#DE2D26")
st$m1 <- normalize(st$CCL14)
st$m2 <- normalize(st$CCR1)
st$ccl14 <- wave_colour(st$m1,cc,c(0,1))
st$ccr1 <- wave_colour(st$m2,cr,c(0,1))
st <- st[order(st$m1+st$m2),]
coexpress <- ggplot(st,aes(imagecol,-imagerow)) +
  geom_point(colour="#D8D0DC",size=.68,stroke=0) +
  geom_point(aes(fill=ccl14,colour=ccr1),size=.64,shape=21,stroke=.20,alpha=.89) +
  scale_fill_identity() + scale_colour_identity() + coord_equal() +
  labs(title="CCL14-CCR1") + theme_umap_blank() +
  theme(plot.title=element_text(size=6.8,face="plain"),
        panel.border=element_rect(fill=NA,colour="#BEB8BD",linewidth=.46))
channels <- wrap_plots(wrap_elements(full=wave_key(cc,"CCL14","Min","Max",TRUE)),
                       wrap_elements(full=wave_key(cr,"CCR1","Min","Max",TRUE)),
                       ncol=1,heights=c(1,1))
H <- panel_tag(wrap_plots(coexpress,channels,nrow=1,widths=c(.72,.28)),"H")
fig6 <- wrap_plots(wave_section(A,B,widths=c(.36,.64)),
                  wave_section(C,wave_section(D,E,nrow=2,heights=c(.5,.5)),widths=c(.38,.62)),
                  wave_section(F,G,H,widths=c(.38,.42,.20)),
                  ncol=1,heights=c(.30,.46,.24))
save_replica(fig6,"fig06_replica",9.6,12.2)
rm(list=ls()); invisible(gc())

