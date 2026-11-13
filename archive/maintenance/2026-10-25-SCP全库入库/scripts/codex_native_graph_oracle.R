# Original GraphPlot on an explicitly derived neighbour graph from real shipped cells.
# Fixture preparation is documented; these are software controls, no biological claims.
out <- 'E:/research-wiki-env/work/codex-scp-native-graph'
dir.create(out,recursive=TRUE,showWarnings=FALSE);setwd(out)
SCP_LOCAL_ROOT <- 'E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'
options(SCP.local.root=SCP_LOCAL_ROOT);source(file.path(SCP_LOCAL_ROOT,'load_scp_local.R'))
SCP_local$check_R <- function(packages,...) {
 p <- sub('^.*/','',sub('@.*|==.*|>=.*','',packages))
 missing <- p[!vapply(p,requireNamespace,TRUE,quietly=TRUE)]
 if(length(missing))stop('missing dependency; no install: ',paste(missing,collapse=', '))
 invisible(TRUE)
}
for(nm in c('check_Python','PrepareEnv','conda_install','download'))SCP_local[[nm]]<-function(...)stop('environment/network operation disabled')
for(nm in c('check_R','check_Python','PrepareEnv','conda_install','download'))lockBinding(nm,SCP_local)
input <- 'E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda'
load(input);before<-digest::digest(pancreas_sub,algo='sha256')
gobj <- Seurat::FindNeighbors(pancreas_sub,reduction='PCA',dims=1:10,k.param=20,compute.SNN=TRUE,verbose=FALSE)
graph_name<-grep('snn$',names(gobj@graphs),value=TRUE)[1]
stopifnot(!is.na(graph_name))
g<-gobj@graphs[[graph_name]];emb<-SeuratObject::Embeddings(pancreas_sub[['UMAP']])
ids<-intersect(rownames(g),rownames(emb))[1:50]
node<-data.frame(x=emb[ids,1],y=emb[ids,2],group=pancreas_sub@meta.data[ids,'CellType'],row.names=ids)
edge<-as.matrix(g[ids,ids]);stopifnot(identical(rownames(edge),rownames(node)))
saveRDS(list(node=node,edge=edge),'graph-real-neighbours.rds')
report<-list(scope='native source visual reference on an explicitly prepared REAL-data graph; not extracted module/algorithm/scientific/author approval',
 preparation='Seurat::FindNeighbors(pancreas_sub,reduction=PCA,dims=1:10,k.param=20,compute.SNN=TRUE); first 50 observed cells; node coords from existing UMAP; labels unchanged',
 graph_name=graph_name,node_count=nrow(node),nonzero_weights=sum(edge!=0),
 original_object_unchanged=identical(before,digest::digest(pancreas_sub,algo='sha256')),
 input_sha256=digest::digest(file=input,algo='sha256'),cases=list())
for(kind in c('straight','curved')) {
 r<-tryCatch({
   p<-SCP_local$GraphPlot(node=node,edge=edge,node_group='group',edge_line=kind)
   ggplot2::ggsave(paste0('graph-',kind,'.png'),p,width=8,height=6,dpi=150,bg='white')
   ggplot2::ggsave(paste0('graph-',kind,'.svg'),p,width=8,height=6,device=svglite::svglite,bg='white')
   list(state='reference_generated',files=c(paste0('graph-',kind,'.png'),paste0('graph-',kind,'.svg')))
 },error=function(e)list(state='reference_failed',error=conditionMessage(e)))
 report$cases[[kind]]<-r;cat(kind,r$state,r$error %||% '', '\n')
 jsonlite::write_json(report,'references.json',auto_unbox=TRUE,pretty=TRUE)
}
