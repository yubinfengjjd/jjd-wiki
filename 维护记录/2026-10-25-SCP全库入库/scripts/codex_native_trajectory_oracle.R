# Native reference pipeline on the shipped, real pancreas fixture. Not a project conclusion.
out <- 'E:/research-wiki-env/work/codex-scp-native-trajectory'
dir.create(out,recursive=TRUE,showWarnings=FALSE);setwd(out)
SCP_LOCAL_ROOT <- 'E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'
options(SCP.local.root=SCP_LOCAL_ROOT)
source(file.path(SCP_LOCAL_ROOT,'load_scp_local.R'))
SCP_local$check_R <- function(packages,...) {
 p <- sub('^.*/','',sub('@.*|==.*|>=.*','',packages))
 missing <- p[!vapply(p,requireNamespace,TRUE,quietly=TRUE)]
 if(length(missing))stop('missing R dependency; never installs: ',paste(missing,collapse=', '))
 invisible(TRUE)
}
for(nm in c('check_Python','PrepareEnv','conda_install','download'))SCP_local[[nm]]<-function(...)stop('network/environment actions disabled')
for(nm in c('check_R','check_Python','PrepareEnv','conda_install','download'))lockBinding(nm,SCP_local)
input <- 'E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda'
load(input);original <- digest::digest(pancreas_sub,algo='sha256')
result <- list(scope='SCP localized native reference; default Slingshot root inferred by source algorithm, not a biological direction claim; no extracted-module validation or author confirmation',
 input_sha256=digest::digest(file=input,algo='sha256'),cases=list())
save_result <- function()jsonlite::write_json(result,'references.json',auto_unbox=TRUE,pretty=TRUE)
trajectory <- tryCatch({
 x <- SCP_local$RunSlingshot(pancreas_sub,group.by='SubCellType',reduction='UMAP',show_plot=FALSE,seed=11)
 saveRDS(x,'slingshot-pancreas-native.rds')
 cols <- grep('^Lineage[0-9]+$',colnames(x@meta.data),value=TRUE)
 stopifnot(length(cols)>0L)
 result$cases$slingshot <- list(state='reference_generated',lineages=cols,object_unchanged=identical(original,digest::digest(pancreas_sub,algo='sha256')),
   outputs=list('slingshot-pancreas-native.rds'=digest::digest(file='slingshot-pancreas-native.rds',algo='sha256')))
 save_result();x
},error=function(e){result$cases$slingshot<<-list(state='reference_failed',error=conditionMessage(e));save_result();NULL})
plotcase <- function(id,fn,args) {
 r <- tryCatch({
  x<-do.call(SCP_local[[fn]],args)
  p<-if(is.list(x)&&!inherits(x,c('gg','ggplot','patchwork'))&&!is.null(x$plot))x$plot else x
  ggplot2::ggsave(paste0(id,'.png'),p,width=8,height=6,dpi=150,bg='white')
  ggplot2::ggsave(paste0(id,'.svg'),p,width=8,height=6,device=svglite::svglite,bg='white')
  list(state='reference_generated',files=c(paste0(id,'.png'),paste0(id,'.svg')))
 },error=function(e)list(state='reference_failed',error=conditionMessage(e)))
 result$cases[[id]]<<-r;save_result();cat(id,r$state,r$error %||% '', '\n')
}
if(!is.null(trajectory)) {
 lineage <- result$cases$slingshot$lineages[1]
 plotcase('cell-dim-native-lineage','CellDimPlot',list(srt=trajectory,group.by='SubCellType',reduction='UMAP',lineages=lineage))
 plotcase('dynamic-native-curve','DynamicPlot',list(srt=trajectory,lineages=lineage,features='Nnat',group.by='SubCellType',compare_features=FALSE))
 plotcase('dynamic-native-heatmap','DynamicHeatmap',list(srt=trajectory,lineages=lineage,features=c('Sox9','Anxa2','Fev','Nnat','Gcg','Ins1'),
   use_fitted=FALSE,split_method='hclust',n_split=2,show_row_names=TRUE,cell_annotation='SubCellType'))
}
save_result()
