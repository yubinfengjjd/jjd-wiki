# Real pinned-source reference runs. These are oracles, not migration passes.
out <- 'E:/research-wiki/维护记录/2026-10-25-SCP全库入库/native-oracles'
dir.create(out,recursive=TRUE,showWarnings=FALSE);setwd(out)
SCP_LOCAL_ROOT <- 'E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'
options(SCP.local.root=SCP_LOCAL_ROOT)
source(file.path(SCP_LOCAL_ROOT,'load_scp_local.R'))
data_file <- 'E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda'
data_md5 <- unname(tools::md5sum(data_file));load(data_file)
before <- serialize(pancreas_sub,NULL)
report <- list(source_commit='b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0',purpose='real source-only reference generation; no standalone or scientific approval implied',cases=list())
reduction <- names(pancreas_sub@reductions)[grepl('umap',names(pancreas_sub@reductions),ignore.case=TRUE)][1]
if(is.na(reduction))reduction<-names(pancreas_sub@reductions)[1]
run <- function(id,fn,args,plot=TRUE){
 set.seed(11);started<-proc.time()[['elapsed']]
 result<-tryCatch({
   x<-do.call(SCP_local[[fn]],args)
   if(plot){
     p<-if(is.list(x)&&!inherits(x,c('gg','ggplot','patchwork'))&&!is.null(x$plot))x$plot else x
     ggplot2::ggsave(paste0(id,'.png'),p,width=8,height=6,dpi=150,bg='white')
     ggplot2::ggsave(paste0(id,'.svg'),p,width=8,height=6,device=svglite::svglite,bg='white')
     list(state='reference_generated',class=class(x),files=c(paste0(id,'.png'),paste0(id,'.svg')))
   }else{
     emb<-SeuratObject::Embeddings(x);loadings<-SeuratObject::Loadings(x)
     saveRDS(list(embeddings=emb,loadings=loadings),paste0(id,'.rds'))
     list(state='reference_generated',class=class(x),dim=dim(emb),finite=all(is.finite(emb)),files=paste0(id,'.rds'))
   }
 },error=function(e)list(state='reference_call_failed',error=conditionMessage(e)))
 result$function_name<-fn;result$elapsed_sec<-proc.time()[['elapsed']]-started
 report$cases[[id]]<<-result
 cat(id,result$state,if(is.null(result$error))'' else result$error,'\n')
 jsonlite::write_json(report,file.path(out,'references.json'),auto_unbox=TRUE,pretty=TRUE)
}
run('cell-dim-CellType','CellDimPlot',list(srt=pancreas_sub,group.by='CellType',reduction=reduction,label=TRUE))
run('feature-dim-Neurog3','FeatureDimPlot',list(srt=pancreas_sub,features='Neurog3',reduction=reduction))
for(type in c('violin','box','bar','dot','col'))run(paste0('feature-stat-',type),'FeatureStatPlot',list(srt=pancreas_sub,stat.by='Sox9',group.by='CellType',plot_type=type))
run('feature-cor-two-markers','FeatureCorPlot',list(srt=pancreas_sub,features=c('Sox9','Anxa2'),group.by='CellType'))
counts<-SeuratObject::GetAssayData(pancreas_sub,assay='RNA',layer='counts')
# Explicit fixture subset of REAL observed counts; no fabricated observations.
fixture<-as.matrix(counts[seq_len(min(300,nrow(counts))),seq_len(min(40,ncol(counts)))])
fixture<-fixture[rowSums(fixture)>0,colSums(fixture)>0,drop=FALSE]
fixture<-fixture[seq_len(min(60,nrow(fixture))),,drop=FALSE]
saveRDS(fixture,file.path(out,'real-counts-subset.rds'))
run('nmf-NMF-matrix','RunNMF.default',list(object=fixture,assay='RNA',nbes=3,nmf.method='NMF',verbose=FALSE,seed.use=11),FALSE)
run('mds-cmdscale-matrix','RunMDS.default',list(object=fixture,assay='RNA',nmds=3,mds.method='cmdscale',verbose=FALSE,seed.use=11),FALSE)
report$input_file_unchanged<-identical(data_md5,unname(tools::md5sum(data_file)))
report$object_unchanged<-identical(before,serialize(pancreas_sub,NULL))
report$reduction<-reduction
jsonlite::write_json(report,file.path(out,'references.json'),auto_unbox=TRUE,pretty=TRUE)
stopifnot(report$input_file_unchanged,report$object_unchanged)
