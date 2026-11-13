adapter <- new.env(parent=globalenv())
source('E:/research-wiki/开发/staged/research-wiki/assets/input_binding.R',local=adapter,encoding='UTF-8')
adapter$requireNamespace <- function(package,quietly=FALSE,...) {
  if(package=='fs') return(FALSE)
  base::requireNamespace(package,quietly=quietly,...)
}
root <- tempfile('codex-r-nofs-',tmpdir='E:/research-wiki-env/tmp');dir.create(root)
src <- file.path(root,'source.csv');writeLines(c('n','2'),src)
out <- file.path(root,'out');dir.create(out)
stopifnot(file.link(src,file.path(out,'values.csv')))
before <- unname(tools::md5sum(src))
result <- tryCatch(adapter$prepare_binding_table(list(value=list(type='int',description='count')),
  'source.csv',root,out,'values',list(value='n')),error=function(e) conditionMessage(e))
cat('outcome:',if(is.list(result)) 'accepted' else result,'\n')
cat('source_changed:',!identical(before,unname(tools::md5sum(src))),'\n')
