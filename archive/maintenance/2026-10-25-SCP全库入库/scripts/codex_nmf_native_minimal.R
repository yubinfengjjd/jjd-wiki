# Oracle: unchanged pinned RunNMF.default body + only its dense-input imports.
root<-'E:/research-wiki-env/sources/scp-2026-10-22'
out<-'E:/research-wiki/维护记录/2026-10-25-SCP全库入库/native-oracles'
e<-new.env(parent=baseenv())
load_one<-function(file,name){
 for(z in parse(file.path(root,'R',file))){
  if(is.call(z)&&identical(z[[1]],as.name('<-'))&&is.symbol(z[[2]])&&identical(as.character(z[[2]]),name)){
   eval(z,e);return(invisible(NULL))
  }
 }
 stop('pinned definition absent:',name)
}
stopifnot(requireNamespace('NMF',quietly=TRUE),requireNamespace('SeuratObject',quietly=TRUE))
load_one('utils.R','as_matrix');load_one('Seurat-function.R','RunNMF.default')
e$check_R<-function(packages,...){for(p in packages)if(!requireNamespace(p,quietly=TRUE))stop('Missing required existing package:',p);invisible(NULL)}
e$CreateDimReducObject<-SeuratObject::CreateDimReducObject
e$capture.output<-utils::capture.output
x<-readRDS(file.path(out,'real-counts-subset.rds'))
r<-tryCatch(e$RunNMF.default(object=x,assay='RNA',nbes=3,nmf.method='NMF',verbose=FALSE,seed.use=11),error=function(err)err)
result<-list(original_function_unchanged=TRUE,limited_imports=c('NMF','SeuratObject','utils::capture.output','pinned as_matrix'),installation_disabled=TRUE,ok=!inherits(r,'error'))
if(inherits(r,'error'))result$error<-conditionMessage(r) else {
 saveRDS(list(embeddings=SeuratObject::Embeddings(r),loadings=SeuratObject::Loadings(r)),file.path(out,'nmf-native-minimal.rds'))
 result$class<-class(r)
}
jsonlite::write_json(result,file.path(out,'nmf-native-minimal.json'),auto_unbox=TRUE,pretty=TRUE)
cat(jsonlite::toJSON(result,auto_unbox=TRUE),'\n')
