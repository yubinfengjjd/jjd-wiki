# Existing R library inventory only, not any algorithm's validation.
B <- 'E:/research-wiki-env/work/scp-full-ingest-20261025'
A <- 'E:/research-wiki/维护记录/2026-10-25-SCP全库入库'
pkgs <- character()
for(p in list.files(file.path(B,'coverage/modules'),pattern='runtime.json',recursive=TRUE,full.names=TRUE)) {
  m <- jsonlite::read_json(p,simplifyVector=FALSE)
  for(impl in m$implementations) {
    pkgs <- c(pkgs,unlist(impl$required_packages$R),names(impl$optional_packages$R))
  }
}
pkgs <- sort(unique(pkgs)); inst <- installed.packages()
result <- list(scope='installed.packages presence and version only; not load or algorithm validation',
 R_version=R.version.string,libpaths=.libPaths(),packages=list())
for(p in pkgs) {
  loc <- which(inst[,'Package']==p)
  result$packages[[p]] <- if(length(loc))list(present=TRUE,version=unname(inst[loc[1],'Version']),library=unname(inst[loc[1],'LibPath'])) else list(present=FALSE)
}
jsonlite::write_json(result,file.path(A,'codex-r-presence.json'),auto_unbox=TRUE,pretty=TRUE)
cat('Declared R packages:',length(pkgs),'present:',sum(pkgs%in%inst[,'Package']),'missing:',sum(!pkgs%in%inst[,'Package']),'\n')
cat('Missing:',paste(setdiff(pkgs,inst[,'Package']),collapse=', '),'\n')
