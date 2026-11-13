# Independent contract checks; does not execute or approve Monocle algorithms.
args <- commandArgs(trailingOnly=TRUE)
code <- if(length(args)) args[1] else 'E:/research-wiki/知识库/methods/trajectory-inference/code'
e <- new.env(parent=globalenv())
source(file.path(code,'monocle2_core.R'),local=e)
source(file.path(code,'monocle3_core.R'),local=e)
failures <- character()
check <- function(label, ok) {
  cat(if(ok) 'PASS ' else 'FAIL ',label,'\n',sep='')
  if(!ok) failures <<- c(failures,label)
}
calls <- list()
walk <- function(node) {
  if(missing(node))return(invisible(NULL))
  if(is.call(node)) {
    if(is.call(node[[1]]) && identical(node[[1]][[1]],as.name('$')) &&
       identical(node[[1]][[3]],as.name('orderCells'))) calls[[length(calls)+1L]] <<- node
    for(child in as.list(node)) walk(child)
  } else if(is.expression(node) || is.pairlist(node)) for(child in as.list(node))walk(child)
}
walk(parse(file.path(code,'monocle2_core.R')))
check('Monocle2 keeps preliminary and rooted ordering calls',length(calls)==2L &&
  !('root_state' %in% names(calls[[1]])) && ('root_state' %in% names(calls[[2]])))
counts <- matrix(seq_len(20),nrow=5,dimnames=list(paste0('g',1:5),paste0('c',1:4)))
meta <- data.frame(type=rep('A',4),row.names=colnames(counts))
err <- function(...) tryCatch({e$run_monocle3_core(...); 'NO_ERROR'},error=conditionMessage)
missing_embedding <- err(counts,meta,use_partition=TRUE,root_cells='c1')
check('Monocle3 absent embedding rejected before dependency gate',grepl('reduced_dim|UMAP|embedding',missing_embedding))
bad <- matrix(1,nrow=3,ncol=2,dimnames=list(paste0('c',1:3),NULL))
bad_embedding <- err(counts,meta,reduced_dim=bad,use_partition=TRUE,root_cells='c1')
check('Monocle3 unmatched embedding rejected before dependency gate',grepl('reduced_dim|UMAP|embedding|cell',bad_embedding) &&
  !grepl('Missing R dependency',bad_embedding))
cat('Observed missing-embedding message: ',missing_embedding,'\n',sep='')
cat('Observed unmatched-embedding message: ',bad_embedding,'\n',sep='')
cat('Scope: static ordering and input rejection only; real Monocle remains not_run\n')
if(length(failures))quit(status=1)
