# Original 3D visualization controls. HTML creation != interaction acceptance.
outdir <- 'E:/research-wiki-env/work/codex-scp-native-3d'
dir.create(outdir,recursive=TRUE,showWarnings=FALSE)
SCP_LOCAL_ROOT <- 'E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'
options(SCP.local.root=SCP_LOCAL_ROOT)
source(file.path(SCP_LOCAL_ROOT,'load_scp_local.R'))
SCP_local$check_R <- function(packages,...) {
 p <- sub('^.*/','',sub('@.*|==.*|>=.*','',packages))
 missing <- p[!vapply(p,requireNamespace,TRUE,quietly=TRUE)]
 if(length(missing))stop('missing dependency; no install: ',paste(missing,collapse=', '))
 invisible(TRUE)
}
for(nm in c('check_Python','PrepareEnv','conda_install','download'))SCP_local[[nm]]<-function(...)stop('environment/network operation disabled')
for(nm in c('check_R','check_Python','PrepareEnv','conda_install','download'))lockBinding(nm,SCP_local)
input <- 'E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda'
load(input)
before <- digest::digest(pancreas_sub,algo='sha256')
stopifnot(ncol(pancreas_sub[['PCA']]@cell.embeddings)>=3L)
cases <- list(
 cell=list(fn='CellDimPlot3D',args=list(srt=pancreas_sub,group.by='CellType',reduction='PCA',dims=1:3,width=900,height=650)),
 feature=list(fn='FeatureDimPlot3D',args=list(srt=pancreas_sub,features='Neurog3',reduction='PCA',dims=1:3,width=900,height=650))
)
report <- list(scope='original 3D objects and local HTML control on existing PCA1:3; not extracted-module/interactive/scientific/author acceptance',input_sha256=digest::digest(file=input,algo='sha256'),cases=list())
for(nm in names(cases)) {
 cs <- cases[[nm]]
 r <- tryCatch({
   p <- do.call(SCP_local[[cs$fn]],cs$args)
   b <- plotly::plotly_build(p)
   stopifnot(inherits(p,'plotly'),length(b$x$data)>0L)
   saveRDS(b$x$data,file.path(outdir,paste0(nm,'-traces.rds')))
   htmlwidgets::saveWidget(p,file.path(outdir,paste0(nm,'.html')),selfcontained=FALSE)
   list(state='reference_generated',traces=length(b$x$data),trace_types=unique(vapply(b$x$data,function(t)t$type %||% '',character(1))),input_unchanged=identical(before,digest::digest(pancreas_sub,algo='sha256')))
 },error=function(e)list(state='reference_failed',error=conditionMessage(e)))
 report$cases[[nm]] <- r
 jsonlite::write_json(report,file.path(outdir,'references.json'),auto_unbox=TRUE,pretty=TRUE)
 cat(nm,r$state,r$error %||% '', '\n')
}
