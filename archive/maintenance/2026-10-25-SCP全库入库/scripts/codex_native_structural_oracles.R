# Independent native-reference runs only. Does not validate any extracted module.
out <- 'E:/research-wiki-env/work/codex-scp-native-structures'
dir.create(out, recursive=TRUE, showWarnings=FALSE); setwd(out)
SCP_LOCAL_ROOT <- 'E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'
options(SCP.local.root=SCP_LOCAL_ROOT)
source(file.path(SCP_LOCAL_ROOT,'load_scp_local.R'))
# Override unsafe original environmental helpers AFTER loading; never install.
SCP_local$check_R <- function(packages, ...) {
  pkgs <- sub('@.*|==.*|>=.*','',packages)
  pkgs <- sub('^.*/','',pkgs)
  missing <- pkgs[!vapply(pkgs, requireNamespace, TRUE, quietly=TRUE)]
  if(length(missing))stop('missing R dependency; no-install native oracle: ',paste(missing,collapse=', '))
  invisible(TRUE)
}
for(nm in c('check_Python','PrepareEnv','conda_install','download'))
  SCP_local[[nm]] <- function(...)stop('environment/network action disabled in native oracle')
for(nm in c('check_R','check_Python','PrepareEnv','conda_install','download')) lockBinding(nm,SCP_local)
data_file <- 'E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda'
load(data_file)
before <- digest::digest(pancreas_sub,algo='sha256')
report <- if(file.exists('references.json')) jsonlite::read_json('references.json',simplifyVector=FALSE) else list(scope='native source reference only; localized infrastructure loader + locked no-install guards; no portability/scientific/author approval',cases=list())
run <- function(id, fn, args, w=8, h=6) {
 if(identical(report$cases[[id]]$state,'reference_generated'))return(invisible(NULL))
 set.seed(11)
 ans <- tryCatch({
   x <- do.call(SCP_local[[fn]], args)
   p <- if(is.list(x)&&!inherits(x,c('gg','ggplot','patchwork'))&&!is.null(x$plot))x$plot else x
   ggplot2::ggsave(paste0(id,'.png'),p,width=w,height=h,dpi=150,bg='white')
   ggplot2::ggsave(paste0(id,'.svg'),p,width=w,height=h,device=svglite::svglite,bg='white')
   list(state='reference_generated',class=class(x),files=c(paste0(id,'.png'),paste0(id,'.svg')))
 },error=function(e) list(state='reference_failed',error=conditionMessage(e)))
 ans$function_name <- fn
 ans$object_unchanged <- identical(before,digest::digest(pancreas_sub,algo='sha256'))
 report$cases[[id]] <<- ans
 jsonlite::write_json(report,'references.json',auto_unbox=TRUE,pretty=TRUE)
 cat(id,ans$state,ans$error %||% '', '\n')
}
features <- c('Sox9','Anxa2','Bicc1','Neurog3','Hes6','Fev','Neurod1','Rbp4','Pyy','Ins1','Gcg','Sst','Ghrl')
base <- list(srt=pancreas_sub,features=features,group.by='CellType',nlabel=0,show_row_names=TRUE)
run('group-violin-group','GroupHeatmap',c(base,list(add_violin=TRUE,cluster_rows=TRUE)))
run('group-violin-expression','GroupHeatmap',c(base,list(add_violin=TRUE,fill.by='expression',fill_palette='Blues',cluster_rows=TRUE)))
run('group-dot-flip','GroupHeatmap',c(base,list(add_dot=TRUE,add_bg=TRUE,flip=TRUE,column_title_rot=45)))
run('group-split-dot-reticle','GroupHeatmap',c(base,list(split.by='Phase',add_dot=TRUE,add_reticle=TRUE,cluster_columns=TRUE)))
run('group-annotation','GroupHeatmap',c(base,list(cell_annotation=c('Phase','G2M_score'),cell_annotation_palette=c('Dark2','Paired'))))
red <- grep('umap',names(pancreas_sub@reductions),ignore.case=TRUE,value=TRUE)[1]
for(shape in c('hull','ellipse','rect','circle'))
 run(paste0('cell-dim-mark-',shape),'CellDimPlot',list(srt=pancreas_sub,group.by='CellType',reduction=red,add_mark=TRUE,mark_type=shape))
graph_names <- names(pancreas_sub@graphs)
if(length(graph_names)) {
 g <- pancreas_sub@graphs[[graph_names[1]]]
 emb <- SeuratObject::Embeddings(pancreas_sub[[red]])
 ids <- intersect(rownames(g),rownames(emb))[seq_len(min(50,nrow(g)))]
 node <- data.frame(x=emb[ids,1],y=emb[ids,2],group=pancreas_sub@meta.data[ids,'CellType'],row.names=ids)
 edge <- as.matrix(g[ids,ids]); saveRDS(list(node=node,edge=edge), 'graph-real-subset.rds')
 for(line in c('straight','curved'))run(paste0('graph-',line),'GraphPlot',list(node=node,edge=edge,node_group='group',edge_line=line))
}
report$input_file_sha256 <- digest::digest(file=data_file,algo='sha256')
jsonlite::write_json(report,'references.json',auto_unbox=TRUE,pretty=TRUE)
