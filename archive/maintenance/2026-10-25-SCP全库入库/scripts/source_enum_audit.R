# Independent read-only AST inventory, not algorithm execution evidence.
root <- 'E:/research-wiki-env/sources/scp-2026-10-22'
out <- 'E:/research-wiki/维护记录/2026-10-25-SCP全库入库'
namespace <- readLines(file.path(root,'NAMESPACE'),warn=FALSE)
exports <- sub('^export\\((.*)\\)$','\\1',grep('^export\\(',namespace,value=TRUE))
exports <- gsub('^"|"$','',exports)
definitions <- list()
for(p in list.files(file.path(root,'R'),pattern='\\.[Rr]$',full.names=TRUE)) {
  expressions <- parse(p,keep.source=TRUE)
  refs <- attr(expressions,'srcref')
  for(i in seq_along(expressions)) {
    expr <- expressions[[i]]
    if(!is.call(expr)||!as.character(expr[[1]])[1]%in%c('<-','=')) next
    if(length(expr)!=3L||!is.symbol(expr[[2]])||!is.call(expr[[3]])||!identical(expr[[3]][[1]],as.name('function'))) next
    name <- as.character(expr[[2]])
    if(!name%in%exports)next
    fm <- expr[[3]][[2]]
    enums <- list()
    for(n in names(fm)){
      if(identical(fm[[n]],quote(expr=)))next
      arg <- fm[[n]]
      if(is.call(arg)&&identical(arg[[1]],as.name('c'))&&length(arg)>1L&&all(vapply(as.list(arg)[-1],is.character,logical(1)))) enums[[n]]<-eval(arg,baseenv())
    }
    definitions[[name]]<-list(file=paste0('R/',basename(p)),start=as.integer(refs[[i]][1]),end=as.integer(refs[[i]][3]),enum_defaults=enums)
  }
}
visual <- c('CellCorHeatmap','CellDensityPlot','CellDimPlot','CellDimPlot3D','CellStatPlot','DynamicHeatmap','DynamicPlot','EnrichmentPlot','FeatureCorPlot','FeatureDimPlot','FeatureDimPlot3D','FeatureHeatmap','FeatureStatPlot','GSEAPlot','GraphPlot','GroupHeatmap','LineagePlot','PAGAPlot','ProjectionPlot','StatPlot','VelocityPlot','VolcanoPlot')
result<-list(note='Exact exports and literal enum defaults only; enum choice does not establish tested support.',export_count=length(exports),export_names=exports,native_visual_entries=visual,definitions=definitions)
jsonlite::write_json(result,file.path(out,'codex-source-enums.json'),pretty=TRUE,auto_unbox=TRUE,null='null')
cat('Exports:',length(exports),'Native primary visualization APIs:',length(visual),'Defined export functions:',length(definitions),'\n')
for(n in c('StatPlot','FeatureStatPlot','EnrichmentPlot','VelocityPlot','GSEAPlot','RunDimReduction','RunDoubletCalling','Integration_SCP')){
 cat(n,':',jsonlite::toJSON(definitions[[n]]$enum_defaults,auto_unbox=TRUE),'\n')
}
