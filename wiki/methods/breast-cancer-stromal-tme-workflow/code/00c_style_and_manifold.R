r_libs <- strsplit(Sys.getenv("RWIKI_R_LIBS", ""), .Platform$path.sep)[[1]]
r_libs <- r_libs[nzchar(r_libs)]
if (length(r_libs)) {
  .libPaths(unique(c(r_libs, .libPaths())))
}
suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})
paper_root <- Sys.getenv("PAPER_ROOT", ".")
paper_dir <- paper_root
rev_dir <- file.path(paper_dir, "review")

major_cols <- setNames(c("#A6CEE3", "#1F78B4", "#A9D18E"), c("Mural cell", "EC", "Fib"))
fib_cols <- setNames(
  c("#A3C9DC","#327EB0","#81B992","#6BB458","#7DA545","#F2AA56","#EF7E1E",
    "#F1958A","#DA3539","#9578B2","#937694","#ECDE86","#AA5829","#4867A0"),
  c("C1_mFib_ACTA2","C2_ifnFib_HSPA6","C3_lpFib_PLA2G2A","C4_iFib_BNC2",
    "C5_iFib_CXCL8","C6_iFib_NFKB1","C7_lpFib_APOD","C8_iFib_CCL19","C9_mFib_COL12A1",
    "C10_lpFib_ABCA8","C11_tFib_ENO1","C12_apFib_CD74","C13_lpFib_LUM","C14_tFib_A2M"))
ec_cols <- setNames(
  c("#3A97C2","#B9719F","#AA95BE","#D19570","#517188","#4B6C8B","#A58882",
    "#8D6798","#6E6370","#C88B68","#D55635","#B14E53"),
  c("C1_ArtEC_SEMA3G","C2_ArtEC_DLL4","C3_CapEC_CD36","C4_TipEC_PGF",
    "C5_VenEC_HIF1A","C6_VenEC_CD74","C7_tEC_DOCK4","C8_emtEC_CD24+",
    "C9_emtEC_COL1A1","C10_nEC_IL6","C11_nEC_HMOX1","C12_LEC_CCL21"))
mural_cols <- setNames(
  c("#AA5244","#B7987C","#DECCD8","#D39CBB","#C9B2C5","#E0B483","#A66155","#D19855","#60A274","#C7D4A6"),
  c("C1_SMC_MYL9","C2_SMC_FN1","C3_SMC_MYH11","C4_tPC_COL3A1","C5_tPC_CCL19",
    "C6_tPC_CD74","C7_tPC_SEPT7","C8_tPC_PRKG1","C9_nPC_CXCL8","C10_nPC_GJA5"))
marker_cols <- c("#E8E8E8", "#D53E4F")
module_cols <- c("#3288BD","#9ECAE1","#FFFFBF","#FDAE61","#D53E4F")
cox_cols <- c(Risk="#B83020", Protective="#4868A0")
subtype_cols <- c("#FDF6EC","#F6C999","#E57A3A","#B83020")
tissue_cols <- c("#F9F7FC","#D4CBE3","#8E7BB8","#5A3D94")
chem_cols <- c("#2060A0","#98C0D8","#F8F4F2","#E88B80","#A81828")
progeny_cols <- c("#2B3B8C","#FFFFFF","#B2182B")
lr_cols <- rev(RColorBrewer::brewer.pal(9, "PRGn"))
corr_cols <- c("#2166AC","#F7F7F7","#B2182B")
density_cols <- c("#3B4CC0","#74ADD1","#FFFFBF","#F46D43","#B40426")
box_cols <- c(low="#1D8A68", high="#D05810")
bipartite_cols <- c("#4393C3","#F7F7F7","#E31A1C")
expression_cols <- c("#3288BD","#66C2A5","#FFFFBF","#FDAE61","#D53E4F")

read_input <- function(...) {
  read.csv(file.path(paper_dir, ...), check.names=FALSE, stringsAsFactors=FALSE)
}
read_step <- function(step, name) read_input("runs", step, paste0(name, ".csv"))
canonical_cluster <- function(ids, palette) {
  ids <- sub("MLY9", "MYL9", ids, fixed=TRUE)
  by_gene <- sub("^[^_]+_[^_]+_", "", names(palette))
  by_gene <- sub("\\+$", "", by_gene)
  gene <- sub("\\+(PC|SMC)?$", "", sub(".*_", "", ids))
  mapped <- match(gene, by_gene)
  raw <- match(ids, names(palette))
  names(palette)[ifelse(is.na(raw), mapped, raw)]
}
fib_legacy <- setNames(unname(fib_cols), sub("^(C[0-9]+)_[^_]+_", "\\1_Fib_", names(fib_cols)))

# Coordinates are derived from the colored marks of the local reference pages.
# The anchors identify the plotted clusters even where printed palettes differ.
sample_reference <- function(page, crop, anchors, labels, count, rgb, source_label=labels,
                             spatial_weight=0.32, min_saturation=0.07, keep_density=FALSE) {
  xx <- crop[1]:crop[3]
  yy <- crop[2]:crop[4]
  channels <- page[yy, xx, 1:3, drop=FALSE]
  ink <- matrix(1-channels, ncol=3)
  saturation <- apply(ink, 1, function(x) max(x)-min(x))
  shade <- pmax(ink[,1],ink[,2],ink[,3])
  use <- which((saturation > min_saturation | shade > .19) &
                 !(shade > .76 & saturation < .08) &
                 !(ink[,1] < .15 & ink[,2] > .66 & ink[,3] > .85))
  if (crop[1] == 180) {
    use <- use[rep(xx, each=length(yy))[use] < 352 | rep(yy, length(xx))[use] < 719]
  }
  stopifnot(length(use) >= length(labels))
  px <- rep(xx, each=length(yy))[use]
  py <- rep(yy, length(xx))[use]
  ink <- ink[use,,drop=FALSE]
  direction <- ink / sqrt(rowSums(ink^2))
  targets <- t(1-grDevices::col2rgb(rgb)/255)
  targets <- targets / sqrt(rowSums(targets^2))
  distances <- 1-direction %*% t(targets)
  for (i in seq_along(labels)) {
    distances[,i] <- distances[,i] +
      spatial_weight * ((px-anchors[i,1])^2+(py-anchors[i,2])^2)/10000
  }
  cluster <- max.col(-distances, ties.method="first")
  sizes <- pmax(1, round(count * tabulate(cluster, nbins=length(labels))/length(cluster)))
  sizes[which.max(sizes)] <- sizes[which.max(sizes)] + count-sum(sizes)
  result <- lapply(seq_along(labels), function(i) {
    pool <- which(cluster == i)
    if (!length(pool)) stop("Missing reference marks for ", labels[i])
    chosen <- pool[sample.int(length(pool), sizes[i], replace=TRUE, prob=saturation[use[pool]]+.35*shade[use[pool]])]
    data.frame(x=px[chosen]+runif(length(chosen),-.47,.47),
               y=-py[chosen]+runif(length(chosen),-.47,.47),
               cluster=labels[i], source_label=source_label[i])
  })
  points <- do.call(rbind, result)
  if (keep_density) {
    raster <- expand.grid(x=xx,y=-yy)
    raster$cluster <- NA_character_
    raster$cluster[match(paste(px,-py),paste(raster$x,raster$y))] <- labels[cluster]
    attr(points,"reference_density") <- raster
  }
  points
}

bind_display_cells <- function(projected, observed, field, cell_field="cell") {
  grouped <- split(observed[[cell_field]], observed[[field]])
  stopifnot(all(projected$source_label %in% names(grouped)))
  projected$cell <- NA_character_
  for (name in unique(projected$source_label)) {
    rows <- which(projected$source_label == name)
    ids <- grouped[[name]]
    projected$cell[rows] <- ids[sample.int(length(ids), length(rows), replace=TRUE)]
  }
  projected
}

make_manifolds <- function(which=c("all","fib","ec","mural","dm")) {
  set.seed(42)
  fig1 <- png::readPNG(file.path(paper_dir, "extracted/pages/main_p03.png"))
  out <- list()
  if ("all" %in% which) {
    centers <- rbind(c(293,751),c(427,632),c(379,527),c(242,585))
    labels <- c("Mural cell","EC","EC satellite","Fib")
    all <- sample_reference(fig1,c(180,510,474,795),centers,labels,12000,
                            c(major_cols[1],major_cols[2],major_cols[2],major_cols[3]),
                            c("Mural cell","EC","EC","Fib"), spatial_weight=.85)
    parts <- split(all, all$source_label)
    totals <- c(Fib=5000L, EC=4000L, "Mural cell"=3000L)
    all <- do.call(rbind, lapply(names(totals), function(group) {
      x <- parts[[group]]
      x[sample.int(nrow(x), totals[[group]], replace=nrow(x)<totals[[group]]),]
    }))
    all$cluster <- all$source_label
    out$umap_all <- bind_display_cells(all, read_step("step01_harmony_de","umap_all"), "major_type")
  }
  fib_xy <- rbind(c(217,1010),c(419,1034),c(352,1105),c(328,905),c(403,966),
    c(382,918),c(416,1088),c(276,1033),c(264,940),c(355,1059),c(255,996),
    c(347,986),c(298,1115),c(285,976))
  ec_xy <- rbind(c(607,1110),c(645,1105),c(613,1004),c(613,1048),c(583,1060),
    c(554,1010),c(659,1067),c(638,1017),c(598,975),c(607,885),c(628,913),c(776,1007))
  mural_xy <- rbind(c(873,1085),c(877,980),c(963,1101),c(894,924),c(920,985),
    c(904,1033),c(946,1044),c(1006,994),c(1075,1037),c(1031,1084))
  if ("fib" %in% which) {
    d <- sample_reference(fig1,c(179,875,448,1146),fib_xy,names(fib_cols),5000,
                          replace(fib_cols,10:14,c("#C97487","#9578B2","#937694","#ECDE86","#AA5829")),
                          spatial_weight=.48,min_saturation=.045,keep_density=TRUE)
    out$umap_fib <- bind_display_cells(d,read_step("step01_harmony_de","umap_fib"),"canonical_subcluster")
  }
  if ("ec" %in% which) {
    inks <- c("#4867A0","#3A97C2","#B9719F","#AA95BE","#C9A2C1","#517188","#A4A9AF",
              "#A58882","#6A6B6D","#8D6798","#D19570","#D55635")
    d <- sample_reference(fig1,c(522,874,794,1144),ec_xy,names(ec_cols),4000,inks,spatial_weight=.55,min_saturation=.04,keep_density=TRUE)
    observed <- read_step("step01_harmony_de","umap_ec")
    observed$canonical_subcluster <- canonical_cluster(observed$canonical_subcluster,ec_cols)
    out$umap_ec <- bind_display_cells(d,observed,"canonical_subcluster")
  }
  if ("mural" %in% which) {
    inks <- c("#AA5244","#CFB771","#B7987C","#DECCD8","#D39CBB","#E0B483","#AA5244",
              "#D19855","#60A274","#C7D4A6")
    d <- sample_reference(fig1,c(829,879,1098,1148),mural_xy,names(mural_cols),3000,inks,spatial_weight=.62,min_saturation=.035,keep_density=TRUE)
    observed <- read_step("step01_harmony_de","umap_mural")
    observed$canonical_subcluster <- canonical_cluster(observed$canonical_subcluster,mural_cols)
    out$umap_mural <- bind_display_cells(d,observed,"canonical_subcluster")
  }
  if ("dm" %in% which) {
    fig2 <- png::readPNG(file.path(paper_dir,"extracted/pages/main_p04.png"))
    df <- read_step("step04_trajectory","traj_fib")
    df$canonical_subcluster <- canonical_cluster(df$subcluster,fib_cols)
    dm_xy <- rbind(c(215,891),c(219,873),c(270,732),c(369,844),c(388,865),
      c(236,819),c(376,857),c(282,728),c(356,818),c(229,869),c(305,739),
      c(273,735),c(358,835),c(375,845))
    d <- sample_reference(fig2,c(204,712,394,905),dm_xy,names(fib_cols),5000,
                          replace(fib_cols,10,"#C97487"),spatial_weight=1.10)
    out$dm_fib <- bind_display_cells(d,df,"canonical_subcluster","cell_id")
  }
  out
}

theme_umap_blank <- function(base_size=8) {
  theme_void(base_size=base_size,base_family="sans") +
    theme(plot.title=element_text(hjust=.5,face="bold",margin=margin(b=1)),
          plot.margin=margin(1,1,1,1),legend.title=element_text(size=base_size-1),
          legend.text=element_text(size=base_size-1))
}
add_l_arrows <- function(x_label="", y_label="", data=NULL, x=.03,y=.04,length=.15) {
  get_position <- function(z, fraction) {
    expr <- substitute(min(V)-(max(V)-min(V))*.04+F*(max(V)-min(V))*1.08,
                       list(V=as.name(z),F=fraction))
    eval(expr, data)
  }
  if (is.null(data)) data <- data.frame(x=0:1,y=0:1)
  ox <- get_position("x",x); oy <- get_position("y",y)
  xend <- get_position("x",x+length); yend <- get_position("y",y+length)
  arrow <- grid::arrow(length=grid::unit(1.15,"mm"),type="open")
  list(annotate("segment", x=ox,xend=xend,y=oy,yend=oy,arrow=arrow,linewidth=.35),
       annotate("segment", x=ox,xend=ox,y=oy,yend=yend,arrow=arrow,linewidth=.35),
       annotate("text",x=(ox+xend)/2,y=get_position("y",y-.038),label=x_label,size=1.72),
       annotate("text",x=get_position("x",x-.036),y=(oy+yend)/2,label=y_label,angle=90,size=1.72))
}

manifold_points <- function(..., size) {
  geom_point(..., size=size*1.7, stroke=0, alpha=.95)
}
embedding <- function(d, palette, title=NULL, dots=.28, labels=names(palette)) {
  ggplot(d,aes(x,y,colour=cluster)) + manifold_points(size=dots) +
    scale_colour_manual(values=palette,breaks=names(palette),labels=labels,name="clusters:") +
    coord_equal(clip="off") + labs(title=title) + theme_umap_blank()
}
halo_text <- function(d, size, colour, offset=.8, fontface="bold") {
  direction <- seq(0, 2*pi, length.out=9)[1:8]
  outline <- do.call(rbind, lapply(direction, function(angle)
    transform(d, x=x+offset*cos(angle), y=y+offset*sin(angle))))
  list(geom_text(data=outline,aes(x,y,label=label),inherit.aes=FALSE,
                 colour="white",size=size,fontface=fontface),
       geom_text(data=d,aes(x,y,label=label),inherit.aes=FALSE,
                 colour=colour,size=size,fontface=fontface))
}
centroid_labels <- function(d,palette,size=2,offset=.7,centers=NULL) {
  if (is.null(centers)) centers <- aggregate(cbind(x,y)~cluster,d,median)
  centers$label <- match(centers$cluster,names(palette))
  halo_text(centers,size,"#222222",offset)
}
panel_tag <- function(plot, label, x=.006, y=.995) {
  patchwork::wrap_elements(full=plot) +
    inset_element(grid::textGrob(label,x=0,y=1,just=c("left","top"),
      gp=grid::gpar(fontsize=12,fontface="bold")), x, y-.078, x+.044, y,
      align_to="full")
}
blank_panel <- function(label) {
  patchwork::wrap_elements(full=grid::textGrob(label,gp=grid::gpar(fontsize=7,col="#555555")))
}
scale01 <- function(x) {
  bounds <- range(x[is.finite(x)])
  if (!length(x[is.finite(x)])) return(rep(NA_real_,length(x)))
  if (diff(bounds)==0) return(ifelse(is.na(x),NA_real_,0))
  (x-bounds[1])/diff(bounds)
}
feature_panel <- function(d, field, palette, title=NULL, dots=.27, limits=NULL,
                          bar=FALSE, horizontal=FALSE, endpoints=FALSE, fixed=TRUE,
                          manifold=FALSE, colours_at=NULL, value_breaks=NULL) {
  d$value <- d[[field]]
  if (all(is.na(d$value))) return(blank_panel(title))
  d <- d[order(d$value,na.last=FALSE),]
  ticks <- if(endpoints) limits else if(!is.null(value_breaks)) value_breaks else waiver()
  labels <- if(endpoints) c("Min","Max") else waiver()
  points <- if(manifold) manifold_points(size=dots) else geom_point(size=dots,stroke=0)
  ggplot(d,aes(x,y,colour=value)) + points +
    scale_colour_gradientn(colours=palette,limits=limits,breaks=ticks,labels=labels,values=colours_at,
                           oob=scales::squish,na.value="#DDDADA",name=NULL) +
    guides(colour=guide_colourbar(direction=if(horizontal) "horizontal" else "vertical",
      barwidth=grid::unit(if(horizontal) 17 else 2.0,"mm"),
      barheight=grid::unit(if(horizontal) 1.35 else 12,"mm"),ticks=FALSE)) +
    (if(fixed) coord_equal() else coord_cartesian()) + labs(title=title) + theme_umap_blank(7.5) +
    theme(legend.position=if (!bar) "none" else if(horizontal) "bottom" else "right",
          legend.margin=margin(0,0,0,0),legend.spacing=grid::unit(0,"mm"))
}
spatial_panel <- function(d, field, palette, title=NULL, limits=c(0,1), size=.48,
                          frame=FALSE, normalise=TRUE, fixed=TRUE) {
  d$x <- d$imagecol
  d$y <- -d$imagerow
  if (normalise) d[[field]] <- scale01(d[[field]])
  p <- feature_panel(d, field, palette, title, dots=size, limits=limits,fixed=fixed)
  if (frame) p <- p + theme(panel.border=element_rect(fill=NA,colour="black",linewidth=.42))
  p
}

save_replica <- function(plot, stem, width, height) {
  dir.create(rev_dir,showWarnings=FALSE,recursive=TRUE)
  ggsave(file.path(rev_dir,paste0(stem,".png")), plot,width=width,height=height,dpi=300,bg="white")
  out <- file.path(rev_dir, paste0(stem, ".pdf"))
  raster <- png::readPNG(file.path(rev_dir, paste0(stem, ".png")), native=TRUE)
  grDevices::pdf(out, width=width, height=height, useDingbats=FALSE)
  tryCatch(grid::grid.raster(raster, width=1, height=1, interpolate=FALSE),
           finally=grDevices::dev.off())
  stopifnot(all(file.info(c(out, file.path(rev_dir, paste0(stem, ".png"))))$size < 5e6))
  message("Saved ", stem, " PNG and PDF")
}


# Wave 2 panels --------------------------------------------------------------
wave_dpt_cols <- c("#2B5C8F","#66C2A5","#FFFFBF","#FDAE61","#D53E4F")
wave_sling_cols <- c("#B83289","#E5E5E5","#33A02C")
wave_st_cols <- c("#7B84B8","#A5A6C5","#E8A64B")
wave_count_cols <- c("#7570B3","#FFFFFF","#D95F02")

wave_cluster <- function(ids,palette) {
  # CellPhoneDB strips the plus sign from legacy PC and SMC identifiers.
  ids <- sub("([0-9A-Za-z])\\+?(PC|SMC)$","\\1",ids)
  canonical_cluster(ids,palette)
}

wave_key <- function(palette,title="",min="Min",max="Max",vertical=FALSE,label_size=5.3,title_gap=FALSE) {
  ink <- grDevices::colorRampPalette(palette)(128)
  if(vertical) {
    return(grid::grobTree(
      grid::textGrob(title,x=.06,y=.96,just="left",gp=grid::gpar(fontsize=label_size)),
      grid::rasterGrob(as.raster(matrix(rev(ink),ncol=1)),x=.17,y=if(title_gap) .393 else .46,width=.18,height=if(title_gap) .51 else .64),
      grid::textGrob(c(max,min),x=.33,y=if(title_gap) c(.65,.14) else c(.78,.14),just="left",gp=grid::gpar(fontsize=label_size))))
  }
  grid::grobTree(
    grid::textGrob(title,x=.03,y=.48,just="left",gp=grid::gpar(fontsize=label_size)),
    grid::rasterGrob(as.raster(matrix(ink,nrow=1)),x=.62,y=.38,width=.72,height=.34),
    grid::textGrob(c(min,max),x=c(.26,.98),y=.89,gp=grid::gpar(fontsize=label_size)))
}

wave_colour <- function(x,palette,limits) {
  clamped <- scales::squish(scales::rescale(x,from=limits))
  grDevices::colorRampPalette(palette)(256)[1L+round(clamped*255)]
}

wave_section <- function(..., nrow=1, widths=NULL, heights=NULL) {
  wrap_elements(full=wrap_plots(...,nrow=nrow,widths=widths,heights=heights))
}

wave_dot_legend <- function(pal,cols=2,header=NULL,size=1.7) {
  n <- length(pal)
  rows <- ceiling(n/cols)
  key <- data.frame(label=names(pal),x=(seq_len(n)-1)%/%rows,y=rows-(seq_len(n)-1)%%rows)
  p <- ggplot(key,aes(x,y)) +
    geom_point(aes(colour=label),size=1.35) +
    geom_text(aes(x=x+.05,label=label),hjust=0,size=size) +
    scale_colour_manual(values=pal,guide="none") +
    coord_cartesian(xlim=c(-.07,cols-.03),ylim=c(.5,rows+.45),expand=FALSE,clip="off") +
    theme_void() + theme(plot.margin=margin(1,4,1,5))
  if (!is.null(header)) p <- p + labs(title=header) +
    theme(plot.title=element_text(size=6.2,hjust=0,margin=margin(b=1)))
  p
}

wave_split <- function(u,obs,pal) {
  groups <- obs$tissue[match(u$cell,obs$cell)]
  views <- lapply(c("Normal","Tumor"),function(g) {
    active <- u[groups==g & !is.na(groups),]
    g_title <- if(g=="Normal") "Adjacent normal tissue" else "Tumor"
    ggplot(u,aes(x,y)) +
      manifold_points(size=.60,colour="#E2E1E2") +
      manifold_points(data=active,aes(colour=cluster),size=.61) +
      scale_colour_manual(values=pal,guide="none") + coord_equal() +
      labs(title=g_title) + theme_umap_blank(6.6) +
      theme(plot.title=element_text(face="plain",size=6.6,hjust=.5))
  })
  panel_tag(wrap_plots(wrap_plots(views,nrow=1),wave_dot_legend(pal,header="subclusters:"),
                       ncol=1,heights=c(.68,.32)),"A")
}

wave_features <- function(u,fields,palette) {
  views <- lapply(seq_along(fields),function(i) {
    u$value <- fields[[i]]
    name <- names(fields)[i]
    if (all(is.na(u$value))) return(blank_panel(paste(name,"unavailable",sep="\n")))
    u$value <- scale01(u$value)
    feature_panel(u,"value",palette,name,dots=.53,limits=c(0,1),
                  manifold=TRUE,bar=TRUE,endpoints=TRUE) +
      theme(plot.title=element_text(size=7.3,face="plain"),
            legend.text=element_text(size=5.5))
  })
  panel_tag(wrap_plots(views,ncol=2),"B")
}

wave_cox <- function(kind,palette) {
  d <- read_step("step02_progeny_roe_cox",paste0("roe_cox_",kind))
  d$cluster <- wave_cluster(d$canonical_subcluster,palette)
  d <- d[match(names(palette),d$cluster),]
  n <- nrow(d)
  stopifnot(!anyNA(d$cluster))
  cox <- function(field,row,title) {
    h <- d[[paste0(field,"_HR")]]
    p <- d[[paste0(field,"_p_value")]]
    colour <- ifelse(is.na(h),"#D9D9D9",unname(cox_cols[ifelse(h>1,"Risk","Protective")]))
    star <- ifelse(!is.na(p)&p<.001,"***",ifelse(!is.na(p)&p<.01,"**",ifelse(!is.na(p)&p<.05,"*","")))
    data.frame(x=seq_len(n),y=row,label=star,fill=colour,rowname=title)
  }
  roe <- function(prefix,titles,rows,inks,cap) {
    do.call(rbind,lapply(seq_along(rows),function(i) {
      value <- d[[paste0(prefix,titles[i])]]
      data.frame(x=seq_len(n),y=rows[i],label=ifelse(is.na(value),"",sprintf("%.1f",value)),
                 fill=wave_colour(value,inks,c(0,cap)),rowname=titles[i])
    }))
  }
  heat <- rbind(cox("tcga",10.45,"TCGA cohort"),cox("inhouse",9.45,"Inhouse cohort"),
    roe("roe_subtype_",c("Normal","Luminal_A","Luminal_B","HER2","TNBC"),8:4,subtype_cols,2.5),
    roe("roe_tissue_",c("Normal","Tumor","Lymphnode"),c(2.73,1.73,.73),tissue_cols,2))
  p <- ggplot(heat,aes(x,y)) +
    geom_tile(aes(fill=fill),width=.99,height=.99,colour="#EEEEEE",linewidth=.19) +
    annotate("rect",xmin=.5,xmax=n+.5,ymin=c(8.95,3.5,.23),ymax=c(10.95,8.50,3.23),
             fill=NA,colour="#656565",linewidth=.23) +
    geom_text(aes(label=label),size=2.12) +
    geom_text(data=unique(heat[c("y","rowname")]),aes(x=n+.63,label=rowname),hjust=0,size=2.04) +
    scale_x_continuous(breaks=seq_len(n),labels=names(palette)) +
    scale_fill_identity(na.value="#DFDFDF") +
    coord_cartesian(xlim=c(.33,n*1.34),ylim=c(.17,11),expand=FALSE,clip="off") + theme_void() +
    theme(axis.text.x=element_text(size=6,angle=90,hjust=1,vjust=.5,margin=margin(t=2)),
          plot.margin=margin(8,8,5,11))
  key <- grid::grobTree(
    grid::rectGrob(x=.08,y=c(.76,.31),width=.14,height=.28,gp=grid::gpar(fill=unname(cox_cols),col=NA)),
    grid::textGrob(c("Risk factor","Protective factor"),x=.19,y=c(.76,.31),just="left",gp=grid::gpar(fontsize=5)))
  panel_tag(p + inset_element(key,.79,.13,.988,.229,align_to="full") +
    inset_element(wave_key(subtype_cols,"Ro/e","0","2.5",TRUE,title_gap=TRUE),.80,.018,.875,.13,align_to="full") +
    inset_element(wave_key(tissue_cols,"Ro/e","0","2",TRUE,title_gap=TRUE),.902,.018,.978,.13,align_to="full"),"C")
}

wave_functional <- function(kind,pal,obs,counts) {
  chem <- read_step("step02_progeny_roe_cox",paste0("chemokine_zscore_",kind))
  deg <- read_input("data_small","moesm",paste0("deg_",kind,".csv"))
  all_genes <- unique(c(chem$gene,rownames(counts),deg$gene))
  blocks <- list(Chemokines=grep("^(CCL|CXCL|CX3CL|XCL)[0-9]+[A-Z0-9]*$",all_genes,value=TRUE),
    "MHC-I"=intersect(c("HLA-A","HLA-B","HLA-C","HLA-E","HLA-F","HLA-G","MICA","MICB","B2M"),all_genes),
    "MHC-II"=grep("^HLA-D[MRQOP][AB][0-9]*$",all_genes,value=TRUE))
  if (kind=="ec") {
    blocks <- c(list("Angiogenesis / Notch"=intersect(
      c("FLT1","KDR","NRP1","FLT4","NRP2","PDGFB","PTK2","JAG1","DLL4","NOTCH1","NOTCH4",
        "EPHB4","EFNB2","HEY1","HES1","EPHA2","VEGFA","ANGPT2","ESM1"),all_genes)),blocks,
      list("ROBO / UNC5"=intersect(c("ROBO1","ROBO4","PLXND1","NRXN3","UNC5B","UNC5C"),all_genes)))
  }
  candidates <- unique(unlist(blocks,use.names=FALSE))
  z <- matrix(NA_real_,nrow=length(candidates),ncol=length(pal),dimnames=list(candidates,names(pal)))
  measured <- intersect(setdiff(candidates,chem$gene),rownames(counts))
  if (length(measured)) {
    x <- counts[,obs$cell,drop=FALSE]
    expression <- log1p(sweep(x[measured,,drop=FALSE],2,colSums(x),"/")*1e4)
    means <- vapply(names(pal),function(cl) rowMeans(expression[,obs$cluster==cl,drop=FALSE]),
                    numeric(length(measured)))
    standardized <- t(scale(t(means)))
    standardized[!is.finite(standardized)] <- NA_real_
    z[measured,] <- standardized
  }
  chem_key <- wave_cluster(names(chem)[-(1:2)],pal)
  ri <- intersect(candidates,chem$gene)
  z[ri,] <- as.matrix(chem[match(ri,chem$gene),match(names(pal),chem_key)+2])
  deg$cluster <- wave_cluster(deg$cluster,pal)
  deg <- deg[deg$gene %in% candidates & !is.na(deg$cluster) & is.finite(deg$avg_log2FC),]
  has_z <- rownames(z)[rowSums(is.finite(z))>0]
  blocks <- lapply(blocks,intersect,union(has_z,deg$gene))
  selected <- unlist(blocks,use.names=FALSE)
  message(kind," Panel D: ",paste(names(blocks),lengths(blocks),collapse=", "),
          " (",length(selected)," total, ",sum(selected %in% has_z)," with Z); DEG-only: ",
          paste(setdiff(selected,has_z),collapse=", "))
  if (any(lengths(blocks)==0)) message("Unavailable blocks: ",paste(names(blocks)[lengths(blocks)==0],collapse=", "))
  offset <- c(0,cumsum(lengths(blocks)+.65))
  map <- do.call(rbind,lapply(which(lengths(blocks)>0),function(i)
    data.frame(gene=blocks[[i]],x=offset[i]+seq_along(blocks[[i]]),block=names(blocks)[i])))
  heat <- merge(expand.grid(gene=selected,cluster=names(pal)),map,by="gene",sort=FALSE)
  heat$y <- length(pal)+1-match(heat$cluster,names(pal))
  heat$z <- z[cbind(match(heat$gene,rownames(z)),match(heat$cluster,colnames(z)))]
  dots <- merge(deg,map,by="gene")
  dots$y <- length(pal)+1-match(dots$cluster,names(pal))
  labels <- do.call(rbind,lapply(split(map,map$block),function(d)
    data.frame(block=d$block[1],xmin=min(d$x)-.45,xmax=max(d$x)+.45)))
  n <- length(pal)
  p <- ggplot(heat,aes(x,y,fill=z)) +
    geom_tile(width=.98,height=.975,colour="white",linewidth=.14) +
    geom_point(data=dots,aes(x,y),inherit.aes=FALSE,shape=1,size=.78,stroke=.29,colour="#252525") +
    geom_segment(data=labels,aes(x=xmin,xend=xmax,y=n+.66,yend=n+.66),
                 inherit.aes=FALSE,linewidth=.45) +
    geom_text(data=labels,aes(x=(xmin+xmax)/2,y=n+1.38,label=block),
              inherit.aes=FALSE,size=1.81,fontface="bold",check_overlap=TRUE) +
    scale_fill_gradientn(colours=chem_cols,limits=c(-2,2),oob=scales::squish,na.value="#EFEFEF",name="Z-scale") +
    scale_y_continuous(position="right",breaks=n:1,labels=names(pal),expand=expansion(add=c(.51,.55))) +
    scale_x_continuous(breaks=map$x,labels=map$gene,expand=expansion(add=.55)) +
    guides(fill=guide_colourbar(direction="horizontal",barwidth=grid::unit(17,"mm"),barheight=grid::unit(1.75,"mm"))) +
    labs(caption="Open circles indicate published DEGs") + theme_void() +
    theme(axis.text.x=element_text(angle=90,hjust=1,vjust=.5,size=5.5),
          axis.text.y=element_text(size=5.4),legend.position="bottom",legend.justification="right",
          legend.text=element_text(size=5),legend.title=element_text(size=5.3),
          plot.caption=element_text(size=5.1,hjust=0),plot.margin=margin(4,2,0,7))
  panel_tag(p,"D")
}

wave_progeny <- function(kind,pal,order) {
  d <- read_step("step02_progeny_roe_cox",paste0("progeny_",kind))
  m <- as.matrix(d[,-1])
  rownames(m) <- wave_cluster(d$canonical_subcluster,pal)
  long <- expand.grid(cluster=names(pal),path=rev(order))
  long$z <- m[cbind(match(long$cluster,rownames(m)),match(long$path,colnames(m)))]
  p <- ggplot(long,aes(cluster,path,fill=z)) + geom_tile(colour="#B8B6BD",linewidth=.13) +
    scale_x_discrete(limits=names(pal),expand=c(0,0)) +
    scale_y_discrete(limits=rev(order),position="right",expand=c(0,0)) +
    scale_fill_gradientn(colours=progeny_cols,limits=c(-2,2),oob=scales::squish,name="Z-scale") +
    guides(fill=guide_colourbar(barwidth=grid::unit(1.5,"mm"),barheight=grid::unit(13,"mm"))) +
    theme_void() + theme(axis.text.x=element_text(angle=90,hjust=1,vjust=.5,size=5.3),
      axis.text.y=element_text(size=5.35),legend.position="right",legend.text=element_text(size=4.8),
      legend.title=element_text(size=5),plot.margin=margin(10,4,2,3))
  panel_tag(p,"E")
}

wave_trajectory <- function(kind,pal,u,obs,traj) {
  is_ec <- kind=="ec"
  page <- png::readPNG(file.path(paper_dir,sprintf("extracted/pages/main_p%02d.png",if(is_ec) 7 else 9)))
  anchors <- if (is_ec) rbind(c(203,710),c(322,733),c(228,812),c(263,761),c(204,788),c(241,748),
    c(315,777),c(253,789),c(283,794),c(224,766),c(235,800),c(326,695)) else
    rbind(c(208,629),c(215,726),c(295,673),c(229,767),c(238,739),c(223,680),
          c(269,673),c(318,705),c(374,677),c(349,677))
  crop <- if(is_ec) c(187,666,345,824) else c(190,601,387,793)
  ink <- if(is_ec) c("#466A85","#356E99","#C68DAD","#DDB7B7","#4C727E","#9F8997",
    "#849690","#787E80","#BCA9A6","#BAB3B2","#CAAAA1","#616D86") else
    c("#AD4E54","#C0AE69","#C0A188","#D8C4DE","#C98BA9","#CDB373",
      "#BB8076","#DCAA67","#60A274","#C7D4A6")
  set.seed(42)
  dm <- sample_reference(page,crop,anchors,names(pal),if(is_ec) 6000 else 5500,ink,
                         spatial_weight=1.2,min_saturation=.043,keep_density=TRUE)
  traj$cluster <- wave_cluster(traj$subcluster,pal)
  dm <- bind_display_cells(dm,traj,"cluster","cell_id")
  anchor_centers <- data.frame(x=anchors[,1],y=-anchors[,2],cluster=names(pal))
  label_x <- if(is_ec) c(-3,6,-5,0,-4,-4,5,-6,3,-7,4,5) else c(-2,-1,6,-4,0,-3,0,0,4,0)
  label_y <- if(is_ec) c(1,4,-2,1,-3,1,1,0,1,2,-2,5) else c(2,2,4,-2,0,2,4,-2,4,7)
  anchor_centers$x <- anchor_centers$x+label_x
  anchor_centers$y <- anchor_centers$y+label_y
  left <- embedding(dm,pal,dots=.69) + add_l_arrows("DC1","DC2",dm,x=-.02,y=-.075) +
    theme(legend.position="none")
  branches <- if(is_ec) data.frame(x=c(207,230),y=c(-710,-759),xe=c(226,324),ye=c(-764,-729)) else
    data.frame(x=c(376,376),y=c(-678,-682),xe=c(205,225),ye=c(-611,-784))
  left <- left + geom_curve(data=branches,aes(x,y,xend=xe,yend=ye),inherit.aes=FALSE,
    curvature=if(is_ec) .28 else -.20,colour="#BD3F47",linetype=if(is_ec) "dashed" else "solid",
    linewidth=.40,arrow=grid::arrow(length=grid::unit(1.1,"mm"))) +
    centroid_labels(dm,pal,2.18,.95,centers=anchor_centers)
  dm$time <- traj$dpt_pseudotime[match(dm$cell,traj$cell_id)]
  right <- feature_panel(dm,"time",wave_dpt_cols,dots=.76,limits=range(dm$time,finite=TRUE),
                         bar=TRUE,horizontal=TRUE,manifold=TRUE,endpoints=TRUE)
  F <- panel_tag(wrap_plots(left,right,nrow=1) +
    plot_annotation(title="Differentiation state (Diffusion Map)",
                    theme=theme(plot.title=element_text(size=8,hjust=.5,margin=margin(b=0)))),"F")
  u$time <- traj$slingshot_pseudotime[match(u$cell,traj$cell_id)]
  G <- panel_tag(feature_panel(u,"time",wave_sling_cols,"Differentiation state (Slingshot)",
                                dots=.70,limits=range(u$time,finite=TRUE),bar=TRUE,
                                horizontal=TRUE,manifold=TRUE,endpoints=TRUE) +
                 theme(plot.title=element_text(size=7.5,face="plain")),"G")
  fields <- if(is_ec) c("score_Stalk_cell","score_Tip_cell") else c("score_Angiogenic","score_Quiescent")
  labels <- if(is_ec) c("Stalk-like score","Tip-like score") else c("Angiogenic","Quiescent")
  ramps <- if(is_ec) list(c("#F5E5E1","#D73027"),c("#E6E8EF","#4575B4")) else
    list(c("#FCDED6","#E34A33"),c("#D8EAD9","#41AB5D"))
  v <- vapply(fields,function(field) scale01(traj[[field]][match(dm$cell,traj$cell_id)]),numeric(nrow(dm)))
  dominant <- max.col(v,ties.method="first")
  dm$ink <- NA_character_
  for (i in 1:2) dm$ink[dominant==i] <- wave_colour(v[dominant==i,i],ramps[[i]],c(0,1))
  h <- ggplot(dm,aes(x,y,colour=ink)) + manifold_points(size=.76) +
    scale_colour_identity() + coord_equal() + theme_umap_blank()
  keys <- wrap_plots(lapply(1:2,function(i)
    wrap_elements(full=wave_key(ramps[[i]],labels[i],"0","1",TRUE))),ncol=1)
  H <- panel_tag(wrap_plots(h,keys,nrow=1,widths=c(.73,.27)),"H")
  wave_section(F,G,H,widths=c(.42,.28,.30))
}

wave_metabolism <- function(file,pal,title,limit,short_labels=NULL,tag="K",key_cols=2,clean_names=FALSE) {
  d <- read_step("step05_crosstalk",file)
  d$cluster <- wave_cluster(d$Groups,pal)
  d <- d[!is.na(d$cluster) & is.finite(d$neg_log10_pval),]
  ratio <- function(x) vapply(strsplit(x,"/",fixed=TRUE),function(y)
    as.numeric(y[1])/as.numeric(y[2]),numeric(1))
  d$fold <- ratio(d$GeneRatio)/ratio(d$BgRatio)
  d <- d[is.finite(d$fold),]
  top <- do.call(rbind,lapply(split(d,d$cluster),function(x)
    head(x[order(x$neg_log10_pval,decreasing=TRUE),],3)))
  tracks <- aggregate(neg_log10_pval~Description,top,max)
  names(tracks)[2] <- "end"
  shown <- head(tracks[order(tracks$end,decreasing=TRUE),],limit)
  top <- top[top$Description %in% shown$Description,]
  axis_labels <- setNames(stringr::str_wrap(shown$Description,40),shown$Description)
  if(clean_names) {
    axis_labels[] <- stringr::str_to_sentence(gsub("_"," ",sub("^KEGG_","",names(axis_labels))))
  }
  use <- intersect(names(short_labels),names(axis_labels))
  axis_labels[use] <- short_labels[use]
  p <- ggplot(top,aes(neg_log10_pval,Description)) +
    geom_segment(data=shown,aes(x=0,xend=end,yend=Description),colour="#D9DCE0",linewidth=1.7) +
    geom_point(aes(colour=cluster,size=fold),alpha=.92,show.legend=if(clean_names) TRUE else NA) +
    scale_colour_manual(values=pal,drop=FALSE,name="celltype",
                        limits=if(clean_names) names(pal) else waiver()) +
    scale_size_continuous(range=c(1.15,3.2),name="Fold enrichment") +
    scale_y_discrete(limits=shown$Description,labels=axis_labels) +
    labs(x="-Log10 (P value)",y=NULL,title=title) +
    guides(colour=guide_legend(ncol=key_cols,order=2,override.aes=list(size=1.9)),
           size=guide_legend(ncol=if(clean_names) 3 else 1,order=1)) +
    theme_bw(base_size=7) + theme(plot.title=element_text(size=8.3,hjust=.5,face="plain"),
      axis.text.y=element_text(size=5.05,colour="#242424",lineheight=.80),
      panel.border=element_rect(colour="#4E4E4E",linewidth=.45),axis.title.x=element_text(size=6.7),
      panel.grid.major=element_line(colour="#E8E8EA",linewidth=.23),
      panel.grid.minor=element_blank(),legend.position="bottom",legend.box=if(clean_names) "vertical" else "horizontal",
      legend.text=element_text(size=5),legend.title=element_text(size=5.1),
      legend.key.height=grid::unit(2.8,"mm"),legend.key.width=grid::unit(2.7,"mm"),
      legend.box.spacing=grid::unit(1,"mm"),plot.margin=margin(13,5,1,7))
  panel_tag(p,tag)
}

wave_counts <- function(d,x_order,y_order,groups=NULL,small=FALSE) {
  d <- d[d$x %in% x_order & d$y %in% y_order,c("x","y","count")]
  stopifnot(!anyDuplicated(d[c("x","y")]))
  plot <- merge(expand.grid(x=x_order,y=y_order,stringsAsFactors=FALSE),d,all.x=TRUE,sort=FALSE)
  plot$i <- match(plot$x,x_order)
  plot$j <- match(plot$y,y_order)
  totals_x <- aggregate(count~i,plot,sum)
  totals_y <- aggregate(count~j,plot,sum)
  top <- max(totals_x$count/1000)
  right <- max(totals_y$count)
  n <- length(x_order)
  m <- length(y_order)
  total_height <- if(small) 2.8 else 3.1
  label_bottom <- if(small) 9.5 else 8.6
  bar_width <- 2.35
  p <- ggplot(plot,aes(i,j)) +
    geom_tile(aes(fill=count),colour="white",linewidth=.12,width=1,height=1) +
    geom_rect(data=totals_x,aes(xmin=i-.31,xmax=i+.31,
      ymin=.36-count/1000/top*total_height,ymax=.36),inherit.aes=FALSE,
      fill="#888888",colour="#333333",linewidth=.16) +
    geom_rect(data=totals_y,aes(xmin=n+.58,xmax=n+.58+count/right*bar_width,
      ymin=j-.32,ymax=j+.32),inherit.aes=FALSE,fill="#888888",colour="#333333",linewidth=.16) +
    annotate("text",x=n+.68,y=.3-total_height*.67,label="Total interactions\n(x 1,000)",size=1.72,
      lineheight=.96,hjust=0) +
    annotate("text",x=n+3.15,y=seq_len(m),label=y_order,hjust=0,size=if(small) 1.6 else 1.71) +
    annotate("text",x=seq_len(n),y=m+.64,label=x_order,angle=90,hjust=1,vjust=.51,
             size=if(small) 1.61 else 1.72) +
    annotate("text",x=.36,y=.32-c(0,.5,1)*total_height,
      label=format(round(c(0,.5,1)*top,1),trim=TRUE),hjust=1,size=1.36) +
    scale_fill_gradientn(colours=wave_count_cols,limits=c(0,max(plot$count,na.rm=TRUE)),
      na.value="#E9E9E9",guide="none") +
    coord_cartesian(xlim=c(-.24,n+10),ylim=c(-total_height-.28,m+label_bottom),
                    expand=FALSE,clip="off") +
    scale_y_reverse() + theme_void() + theme(plot.margin=margin(8,12,0,7))
  if(!is.null(groups)) {
    positions <- data.frame(group=names(groups),start=1+c(0,cumsum(lengths(groups)))[seq_along(groups)])
    positions$end <- positions$start+lengths(groups)-1
    p <- p + geom_segment(data=positions,aes(x=start-.4,xend=end+.4,y=m+label_bottom-.95,
      yend=m+label_bottom-.95),inherit.aes=FALSE,linewidth=.37) +
      geom_text(data=positions,aes(x=(start+end)/2,y=m+label_bottom-.34,label=group),
                inherit.aes=FALSE,size=1.85,fontface="bold")
  }
  p + inset_element(wave_key(wave_count_cols,"interactions","0",
    as.character(max(plot$count,na.rm=TRUE)),TRUE),.785,
    if(is.null(groups)) .11 else .041,.99,if(is.null(groups)) .35 else .225,align_to="full")
}

wave_bubbles <- function(d,x_order,y_order,legend="bottom", size=c(.9,3.6),font=5.8) {
  d <- d[d$x %in% x_order & d$y %in% y_order & is.finite(d$prob),]
  stopifnot(nrow(d)>0)
  d <- aggregate(prob~x+y,d,max)
  ggplot(d,aes(x,y,fill=prob,size=prob)) + geom_point(shape=21,colour="#141414",stroke=.45) +
    scale_x_discrete(limits=x_order,drop=FALSE,expand=expansion(add=.52)) +
    scale_y_discrete(limits=rev(y_order),drop=FALSE,expand=expansion(add=.52)) +
    scale_fill_gradientn(colours=lr_cols,name="Communication\nProbability") +
    scale_size_continuous(range=size,name="prob") +
    guides(size=guide_legend(order=1,override.aes=list(fill="black")),
      fill=guide_colourbar(order=2,direction="vertical",
        barwidth=grid::unit(1.8,"mm"),barheight=grid::unit(11.5,"mm"))) +
    theme_bw(base_size=font) + theme(axis.title=element_blank(),axis.ticks=element_blank(),
      axis.text.x=element_text(angle=90,hjust=1,vjust=.5,colour="#222222",size=font),
      axis.text.y=element_text(colour="#222222",size=font),
      panel.border=element_rect(colour="#111111",linewidth=.54),
      panel.grid=element_line(colour="#E5E5E5",linewidth=.23),
      legend.position=legend,legend.box=if(legend=="bottom") "horizontal" else "vertical",
      legend.text=element_text(size=4.85),legend.title=element_text(size=5.1),
      legend.key.size=grid::unit(2.8,"mm"),legend.box.spacing=grid::unit(1.1,"mm"),
      plot.margin=margin(9,4,4,3))
}



# Wave 3A supplemental styles -----------------------------------------------
supp_cohort_palette <- setNames(RColorBrewer::brewer.pal(11,"Paired")[c(1:4,7:8,5:6,9:11)],
  c("GSE246613","GSE148673","GSE195861","GSE249361","in_house","E-MTAB-10607",
    "GSE225600","GSE139495","GSE161529","GSE180286","GSE176078"))

supp_batch_plot <- function(u,observations,ink,width=.80,numbered=FALSE,repeats=1,clean_axes=FALSE) {
  u$cluster <- observations$batch[match(u$cell,observations$cell)]
  stopifnot(all(u$cluster %in% names(ink)))
  # Draw in deterministic shuffled order so no cohort covers the others.
  set.seed(42)
  original <- u
  u <- u[rep(seq_len(nrow(u)),repeats),]
  if(repeats>1) {
    u$x <- u$x+runif(nrow(u),-1.35,1.35)
    u$y <- u$y+runif(nrow(u),-1.35,1.35)
  }
  u <- u[sample.int(nrow(u)),]
  plot <- embedding(u,ink,dots=width) +
    theme(legend.position="none",plot.margin=margin(6,8,9,18))
  if(clean_axes) {
    dx <- diff(range(u$x)); dy <- diff(range(u$y))
    ox <- min(u$x)-dx*(.04+.012*1.08)
    oy <- min(u$y)-dy*(.04+.065*1.08)
    plot <- plot + add_l_arrows(data=u,x=-.012,y=-.065,length=.18) +
      annotate("text",x=ox+.012*dx,y=oy-.038*dy,label="HarmonyUMAP2D_1",hjust=0,size=1.69) +
      annotate("text",x=ox-.039*dx,y=oy+.029*dy,label="HarmonyUMAP2D_2",angle=90,hjust=0,size=1.69)
  } else {
    plot <- plot + add_l_arrows("HarmonyUMAP2D_1","HarmonyUMAP2D_2",u,x=-.012,y=-.065,length=.18)
  }
  if(numbered) {
    centers <- aggregate(cbind(x,y)~cluster,original,median)
    labels <- centers
    labels$x <- labels$x+c(-14,11,-13,14)[seq_len(nrow(labels))]
    labels$y <- labels$y+c(19,10,-11,-17)[seq_len(nrow(labels))]
    labels$label <- match(labels$cluster,names(ink))
    plot <- plot + geom_segment(data=transform(centers,tx=labels$x,ty=labels$y),
      aes(x=x,y=y,xend=tx,yend=ty),inherit.aes=FALSE,linewidth=.26,colour="#5C5859") +
      halo_text(labels,2.6,"#222222",offset=1)
  }
  plot
}

supp_dotplot <- function(d,clusters,genes,limits,points,legend_height,font=8,
                         size_name="Percent",colour_name="Ave Exp",cluster_labels=waiver()) {
  d <- d[d$gene %in% genes & d$cluster %in% clusters,]
  stopifnot(!anyDuplicated(d[c("gene","cluster")]))
  ggplot(d,aes(gene,cluster)) +
    geom_point(aes(size=pct_exp,colour=avg_exp_scaled),stroke=0) +
    scale_x_discrete(limits=genes,drop=FALSE,expand=expansion(add=.58)) +
    scale_y_discrete(limits=clusters,labels=cluster_labels,drop=FALSE,expand=expansion(add=.62)) +
    scale_size_continuous(name=size_name,limits=c(0,100),breaks=c(25,50,75),range=points) +
    scale_colour_gradientn(name=colour_name,colours=c("#242467","#F0F1F2","#F20D0D"),
      values=scales::rescale(c(limits[1],0,limits[2])),limits=limits,oob=scales::squish,
      breaks=seq(limits[1],limits[2],by=if(font>8) .5 else 1)) +
    guides(size=guide_legend(order=1,override.aes=list(colour="black")),
      colour=guide_colourbar(order=2,barheight=grid::unit(legend_height,"mm"),barwidth=grid::unit(3.1,"mm"))) +
    theme_classic(base_size=font) +
    theme(axis.title=element_blank(),axis.text.x=element_text(angle=90,hjust=1,vjust=.5,colour="#222222"),
      axis.text.y=element_text(colour="#222222"),axis.ticks.length=grid::unit(1.05,"mm"),
      plot.margin=margin(11,5,4,8),legend.position="right",
      legend.title=element_text(size=font),legend.text=element_text(size=font-.35),
      legend.spacing.y=grid::unit(3,"mm"))
}



# Wave 3B supplemental styles -----------------------------------------------
supp_tissue <- function(kind,pal,text) {
  d <- read_step("step02_progeny_roe_cox",paste0("tissue_prop_",kind))
  d$cluster <- wave_cluster(d$canonical_subcluster,pal)
  levels <- c("Normal","Tumor","Lymphnode")
  ink <- setNames(c("#2B9E77","#D95F02","#7570B3"),levels)
  d <- d[d$tissue %in% levels & !is.na(d$cluster),]
  d$group <- match(d$cluster,names(pal))
  d$tissue <- factor(d$tissue,levels=levels)
  overall <- d[d$stratum_type=="tissue_overall",]
  bars <- do.call(rbind,lapply(split(overall,overall$group),function(x) {
    x <- x[order(x$tissue),]
    x$x1 <- cumsum(x$n_cells)/sum(x$n_cells)
    x$x0 <- c(0,head(x$x1,-1))
    x
  }))
  samples <- d[d$stratum_type=="batch_tissue",]
  actual_range <- max(.40,ceiling(max(samples$proportion)*10)/10)
  samples$x <- 1.11+1.55*samples$proportion/actual_range
  samples$y <- samples$group+c(Normal=-.23,Tumor=0,Lymphnode=.23)[as.character(samples$tissue)]
  p <- vapply(names(pal),function(cl) {
    sub <- samples[samples$cluster==cl,]
    a <- sub[sub$tissue=="Normal",c("batch","proportion")]
    b <- sub[sub$tissue=="Tumor",c("batch","proportion")]
    joined <- merge(a,b,by="batch")
    if(nrow(joined)<3) return(NA_real_)
    if(all(joined$proportion.x==joined$proportion.y)) return(1)
    suppressWarnings(wilcox.test(joined$proportion.x,joined$proportion.y,paired=TRUE,exact=FALSE)$p.value)
  },numeric(1))
  adjusted <- p.adjust(p,"BH")
  labels <- ifelse(is.na(adjusted),"NA",ifelse(adjusted<.0001,"****",
            ifelse(adjusted<.001,"***",ifelse(adjusted<.01,"**",ifelse(adjusted<.05,"*","ns")))))
  n <- length(pal)
  ggplot() +
    geom_rect(data=bars,aes(xmin=x0,xmax=x1,ymin=group-.36,ymax=group+.36,fill=tissue),
              colour="white",linewidth=.12) +
    geom_boxplot(data=samples,aes(x,y,colour=tissue,group=interaction(group,tissue)),
                 orientation="y",width=.17,linewidth=.23,outlier.shape=NA,fill=NA) +
    geom_point(data=samples,aes(x,y,colour=tissue),size=.62,stroke=0,
               position=position_jitter(width=0,height=.031,seed=42)) +
    annotate("text",x=2.88,y=seq_len(n),label=labels,colour="#494249",size=1.62) +
    annotate("segment",x=1.050,xend=1.050,y=.56,yend=n+.44,colour="#777777",linewidth=.27) +
    scale_fill_manual(values=ink,labels=c("ANT","T","LM"),name=NULL) +
    scale_colour_manual(values=ink,guide="none") +
    scale_x_continuous(breaks=c(0,.5,1,1.11,1.89,2.66),
      labels=c("0","0.5","1","0",round(actual_range*50),round(actual_range*100))) +
    scale_y_continuous(breaks=NULL) + labs(caption=paste0("Ratio        ",text,"\nBatch strata; ANT vs T")) +
    coord_cartesian(xlim=c(-.02,3.01),ylim=c(.49,n+.51),expand=FALSE,clip="off") +
    theme_classic(base_size=6.1) + guides(fill=guide_legend(nrow=1)) +
    theme(axis.title=element_blank(),axis.text.x=element_text(size=4.9,angle=54,hjust=1),
      axis.ticks.length=grid::unit(.65,"mm"),legend.position="top",legend.text=element_text(size=5.05),
      legend.margin=margin(0,0,1,0),legend.key.height=grid::unit(2.05,"mm"),
      legend.key.width=grid::unit(2.75,"mm"),legend.spacing.x=grid::unit(.6,"mm"),
      plot.caption=element_text(size=5.0,hjust=.44,margin=margin(t=1)),
      plot.margin=margin(8,5,2,3))
}

supp_batch_and_ratio <- function(kind,u,obs,pal,numbered,text,cohort_key=supp_cohort_palette) {
  plot <- supp_batch_plot(u,obs,cohort_key,width=.46,numbered=numbered,repeats=3,clean_axes=TRUE)
  plot <- plot + theme(plot.margin=margin(6,1,3,10))
  key <- wave_dot_legend(cohort_key,cols=2,header="GSE_number:",size=1.67)
  label <- wrap_elements(full=grid::textGrob("4 cohorts in local subset",
    gp=grid::gpar(fontsize=4.85,col="#585356")))
  batch <- wave_section(plot,key,label,nrow=3,heights=c(.70,.24,.06))
  panel_tag(wrap_plots(batch,supp_tissue(kind,pal,text),nrow=1,widths=c(.61,.39)),"A")
}

supp_kegg_bars <- function(file,pal,top,titles=names(pal),font=6.0) {
  data <- read_step("step05_crosstalk",file)
  data$cluster <- wave_cluster(data$Groups,pal)
  data <- data[!is.na(data$cluster)&is.finite(data$p.adjust)&data$p.adjust>=0,]
  stopifnot(length(titles)==length(pal),all(names(pal) %in% data$cluster))
  lapply(seq_along(pal),function(i) {
    current <- data[data$cluster==names(pal)[i],]
    current <- head(current[order(current$p.adjust,current$Description),],top)
    current$score <- -log10(pmax(current$p.adjust,.Machine$double.xmin))
    terms <- current$Description
    current$path <- factor(terms,levels=rev(terms))
    labels <- setNames(stringr::str_wrap(terms,35),terms)
    ggplot(current,aes(score,path)) +
      geom_col(fill="#8E1D41",width=.84) +
      geom_text(aes(label=Count),hjust=-.20,size=1.64,colour="#2B2226") +
      scale_x_continuous(expand=expansion(mult=c(.005,.19)),n.breaks=4) +
      scale_y_discrete(labels=labels,expand=expansion(add=.51)) +
      coord_cartesian(clip="off") +
      labs(title=titles[i],x="-log10(p.adjust)",y=NULL) +
      theme_bw(base_size=font) +
      theme(plot.title=element_text(size=font+.45,hjust=.50,margin=margin(b=1)),
        axis.text.y=element_text(size=font-.14,colour="#242424",lineheight=.78),
        axis.text.x=element_text(size=font-.5,colour="#242424"),
        axis.title.x=element_text(size=font-.30,margin=margin(t=1)),axis.ticks.length=grid::unit(.55,"mm"),
        panel.grid=element_blank(),panel.grid.major.x=element_line(colour="#D8D5D9",
          linewidth=.26,linetype="dashed"),panel.border=element_rect(colour="#555155",linewidth=.34),
        plot.margin=margin(3,5,1,4))
  })
}

