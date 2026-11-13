files <- commandArgs(trailingOnly=TRUE)
for (f in files) {
  env <- new.env(parent=globalenv())
  setwd(dirname(f))
  source(basename(f), local=env)
  cat(basename(f), 'loaded; objects:', paste(ls(env), collapse=','), '\n')
}
