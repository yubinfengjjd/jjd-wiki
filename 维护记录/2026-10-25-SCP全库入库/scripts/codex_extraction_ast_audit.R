# Independent parser comparison only; never evaluates source/installer functions.
root <- 'E:/research-wiki-env/sources/scp-2026-10-22'
B <- 'E:/research-wiki-env/work/scp-full-ingest-20261025'
A <- 'E:/research-wiki/维护记录/2026-10-25-SCP全库入库'
manifest <- jsonlite::read_json(file.path(B,'coverage/source-functions.json'),simplifyVector=FALSE)
expected <- list(); problems <- list()
for(p in list.files(file.path(root,'R'),pattern='\\.[Rr]$',full.names=TRUE)) {
  exprs <- parse(p,keep.source=TRUE)
  refs <- attr(exprs,'srcref')
  for(i in seq_along(exprs)) {
    ex <- exprs[[i]]
    if(!is.call(ex) || !as.character(ex[[1]])[1]%in%c('<-','=') || length(ex)!=3L || !is.symbol(ex[[2]]))next
    rhs <- ex[[3]]
    if(!is.call(rhs))next
    head <- paste(deparse(rhs[[1]]),collapse='')
    if(!head%in%c('function','ggproto','ggplot2::ggproto'))next
    name <- as.character(ex[[2]])
    expected[[name]] <- list(file=basename(p),start=as.integer(refs[[i]][1]),end=as.integer(refs[[i]][3]))
    rec <- manifest[[name]]
    if(is.null(rec)) { problems[[name]] <- list(error='missing from extracted manifest'); next }
    q <- file.path(B,rec$extracted)
    actual <- tryCatch(parse(q,keep.source=FALSE),error=function(e)e)
    if(inherits(actual,'error')) { problems[[name]] <- list(error=conditionMessage(actual)); next }
    if(length(actual)!=1L || !identical(ex,actual[[1]])) {
      # srcref attributes may be attached to the parsed original function body.
      canonical <- function(x)paste(deparse(x,control='all'),collapse='\n')
      if(length(actual)!=1L || !identical(canonical(ex),canonical(actual[[1]])))
        problems[[name]] <- list(error='extracted expression differs from native AST',file=q)
    }
  }
}
result <- list(scope='native AST vs unmodified extraction; not derived module or algorithm approval',
 expected_count=length(expected),extracted_count=length(manifest),missing=setdiff(names(expected),names(manifest)),
 unexpected=setdiff(names(manifest),names(expected)),problems=problems,definitions=expected)
jsonlite::write_json(result,file.path(A,'codex-extraction-ast.json'),auto_unbox=TRUE,pretty=TRUE)
cat('Native function/ggproto definitions:',length(expected),'Manifest:',length(manifest),'Problems:',length(problems),'\n')
for(nm in names(problems))cat(nm,problems[[nm]]$error,'\n')
