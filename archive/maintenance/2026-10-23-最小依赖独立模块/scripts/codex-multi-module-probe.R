record <- 'E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块'
env <- new.env(parent=globalenv())
args <- commandArgs(trailingOnly=TRUE)
modules <- if(length(args)) args[1] else file.path(record,'pilot2')
source(file.path(modules,'cell-quality-control/code/analysis.R'),local=env)
first <- env$run_cell_quality_control
source(file.path(modules,'gene-set-scoring/code/analysis.R'),local=env)
load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')
srt <- pancreas_sub[,seq_len(80)]
reference <- readRDS(file.path(record,'codex-reference.rds'))
answer <- tryCatch({
  value <- first(srt,parameters=reference$qc_parameters)
  stopifnot(identical(value$result@meta.data[,c('nCount_RNA','nFeature_RNA','CellQC'),drop=FALSE],reference$qc))
  'PASS'
}, error=function(e) paste('FAIL:',conditionMessage(e)))
cat('load_QC_then_scoring_then_call_QC=',answer,'\n',sep='')
if(answer!='PASS') quit(status=1)
