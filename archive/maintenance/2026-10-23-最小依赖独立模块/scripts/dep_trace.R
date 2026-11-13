args <- commandArgs(trailingOnly=TRUE)
src <- args[1]; targets <- strsplit(args[2], ",")[[1]]; out <- args[3]
files <- list.files(file.path(src,"R"), pattern="[.]R$", full.names=TRUE)
env <- new.env(parent=globalenv())
for (f in files) {
  ex <- tryCatch(parse(f, keep.source=FALSE), error=function(e) NULL)
  if (is.null(ex)) { message("parse failed: ", f); next }
  for (e in ex) {
    if (is.call(e) && is.symbol(e[[1]]) && as.character(e[[1]]) %in% c("<-","=") && is.name(e[[2]])) {
      tryCatch(assign(as.character(e[[2]]), eval(e[[3]], envir=env), envir=env), error=function(err) NULL)
    }
  }
}
defined <- ls(env)
cat("defined functions:", length(defined), "\n")
res <- list()
for (t in targets) {
  if (!exists(t, envir=env)) { res[[t]] <- list(error="not found"); next }
  f <- get(t, envir=env)
  if (!is.function(f)) { res[[t]] <- list(error="not function"); next }
  seen <- character(); queue <- t; globals_all <- list()
  while(length(queue)) {
    cur <- queue[1]; queue <- queue[-1]
    if (cur %in% seen) next; seen <- c(seen,cur)
    fn <- tryCatch(get(cur, envir=env), error=function(e) NULL)
    if (is.null(fn) || !is.function(fn)) next
    g <- tryCatch(codetools::findGlobals(fn, merge=FALSE), error=function(e) list(functions=character(),variables=character()))
    inner <- intersect(g$functions, defined)
    queue <- c(queue, setdiff(inner, seen))
    globals_all[[cur]] <- list(functions=setdiff(g$functions, inner), variables=g$variables, body=paste(deparse(body(fn)), collapse="\n"))
  }
  res[[t]] <- list(seen=seen, globals=globals_all)
}
saveRDS(res, out)
cat("targets:", paste(targets, collapse=", "), "->", out, "\n")
