# Static AST audit only. It does not execute methods or prove an algorithm.
root <- 'E:/research-wiki/知识库'
families <- c('cell-quality-control','cell-clustering','doublet-detection',
  'dimensionality-reduction','batch-integration','cell-type-annotation',
  'differential-expression','gene-set-enrichment','gene-set-scoring',
  'trajectory-inference','dynamic-feature-analysis','reference-mapping','rna-velocity')
dirs <- c(file.path(root,'methods',families,'code'),
  file.path(list.dirs(file.path(root,'templates'),recursive=FALSE),'code'))
files <- unique(unlist(lapply(dirs,function(d)list.files(d,pattern='[.]R$',full.names=TRUE,recursive=TRUE))))
findings <- list()
walk <- function(node,file) {
  if(missing(node)) return(invisible(NULL))
  if(is.call(node)) {
    if(is.symbol(node[[1]]) && as.character(node[[1]]) %in% c('::',':::') &&
       length(node)>1 && identical(as.character(node[[2]]),'SCP')) {
      findings[[length(findings)+1]] <<- list(file=file,reason='SCP namespace reference')
    }
    for(value in as.list(node)) walk(value,file)
  } else if(is.expression(node) || is.pairlist(node)) {
    for(value in as.list(node)) walk(value,file)
  } else if(is.character(node)) {
    suspicious <- node[grepl('SCP[.]local[.]root|load_scp_local[.]R|methods/scp-local-source|E:[/\\]+research-wiki',node)]
    if(length(suspicious)) findings[[length(findings)+1]] <<- list(file=file,reason='full-source/root literal',literal=suspicious)
  }
}
for(file in files) walk(parse(file=file,keep.source=FALSE),file)
cat('R_FILES_PARSED:',length(files),'\n')
cat('STATIC_SCP_READ_FINDINGS:',length(findings),'\n')
if(length(findings)) {print(findings);quit(status=1)}
