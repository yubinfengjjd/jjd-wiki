# Fault-injection test of failure propagation only. No scDblFinder algorithm
# is run or claimed verified; the real missing-dependency branch stays not_run.
record <- 'E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块'
args <- commandArgs(trailingOnly=TRUE)
module <- if(length(args)) args[1] else file.path(record,'pilot3/doublet-detection/code/analysis.R')
env <- new.env(parent=globalenv())
source(module,local=env)
private <- environment(env$run_doublet_detection)
impl <- get('impl',envir=private,inherits=FALSE)
# Simulate an installed backend that fails after dispatch. This test bypasses
# the package feature gate, not the product's Seurat/data/dispatch checks.
assign('features_fn',function(parameters) character(),envir=private)
impl$db_scDblFinder <- function(...) stop('INJECTED_BACKEND_FAILURE',call.=FALSE)
load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')
srt <- pancreas_sub[,seq_len(20)]
srt[['db.scDblFinder_class']] <- 'singlet'
srt[['db.scDblFinder_score']] <- 0.1
before <- serialize(srt,NULL)
observed <- tryCatch({
  env$run_doublet_detection(srt,parameters=list(db_method='scDblFinder',db_rate=0.01))
  'RETURNED_SUCCESS_WITH_OLD_COLUMNS'
},error=function(e) conditionMessage(e))
stopifnot(identical(before,serialize(srt,NULL)))
cat('FAULT_INJECTION_ONLY; real scDblFinder remains not_run\n')
cat('observed=',observed,'\n',sep='')
if(!grepl('INJECTED_BACKEND_FAILURE',observed,fixed=TRUE)) quit(status=1)
cat('BACKEND_ERROR_PROPAGATES=PASS\n')
