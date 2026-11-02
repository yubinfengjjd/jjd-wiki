
suppressPackageStartupMessages(library(jsonlite))
x <- readRDS("E:/research-wiki/维护记录/2026-10-25-SCP全库入库/native-oracles/real-counts-subset.rds")
before <- digest::digest(x, algo="sha256")
env <- new.env(parent=baseenv())
res <- list()
try_record <- function(name, expr) {
  res[[name]] <<- tryCatch({ force(expr); list(state="passed") },
                          error=function(e) list(state="error", error=conditionMessage(e)))
}
try_record("nested_source_MDS", {
  source("RunMDS/code/module.R", local=env)
  y <- env$RunMDS(x, assay="RNA", nmds=3, verbose=FALSE)
})
try_record("direct_default_MDS", {
  # Source text directly so the outer-source path bug does not hide other issues.
  source("RunMDS/code/module.R", local=env, chdir=FALSE)
  f <- attr(env$RunMDS, "scp_module_env")$RunMDS.default
  y <- f(x, assay="RNA", nmds=3, verbose=FALSE)
})
res$input_unchanged <- identical(before, digest::digest(x, algo="sha256"))
writeLines(toJSON(res, auto_unbox=TRUE, pretty=TRUE), "probe-result.json")
