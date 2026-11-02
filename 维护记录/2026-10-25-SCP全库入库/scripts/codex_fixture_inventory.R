# Existing published package fixtures: structural inventory, no inference.
root <- 'E:/research-wiki-env/sources/scp-2026-10-22/data'
A <- 'E:/research-wiki/维护记录/2026-10-25-SCP全库入库'
out <- list()
for(fn in c('pancreas_sub.rda','ifnb_sub.rda','panc8_sub.rda')) {
 e <- new.env(); loaded <- load(file.path(root,fn),envir=e)
 for(nm in loaded) {
  o <- e[[nm]]
  if(!inherits(o,'Seurat'))next
  out[[nm]] <- list(file=fn,dimensions=dim(o),assays=names(o@assays),reductions=names(o@reductions),graphs=names(o@graphs),
    metadata=colnames(o@meta.data),tools=names(o@tools),misc=names(o@misc),sha256=digest::digest(file=file.path(root,fn),algo='sha256'))
 }
}
jsonlite::write_json(out,file.path(A,'codex-fixture-inventory.json'),auto_unbox=TRUE,pretty=TRUE)
for(nm in names(out))cat(nm,paste(out[[nm]]$dimensions,collapse='x'),'assays',paste(out[[nm]]$assays,collapse=','),'tools',paste(out[[nm]]$tools,collapse=','),'\n')
