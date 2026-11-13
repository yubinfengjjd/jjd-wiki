record <- 'E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块'
modules <- commandArgs(trailingOnly=TRUE)[1]
env <- new.env(parent=globalenv())
files <- c(
  'cell-quality-control/code/analysis.R','doublet-detection/code/analysis.R',
  'dimensionality-reduction/code/analysis.R','batch-integration/code/analysis.R',
  'cell-type-annotation/code/analysis.R','differential-expression/code/analysis.R',
  'gene-set-enrichment/code/analysis.R','gene-set-scoring/code/analysis.R',
  'trajectory-inference/code/analysis.R','trajectory-inference/code/monocle2.R',
  'trajectory-inference/code/monocle2_core.R','trajectory-inference/code/monocle2_plot.R',
  'trajectory-inference/code/monocle3.R','trajectory-inference/code/monocle3_core.R',
  'trajectory-inference/code/monocle3_plot.R',
  'dynamic-feature-analysis/code/analysis.R','reference-mapping/code/analysis.R',
  'reference-mapping/code/transfer.R','rna-velocity/code/analysis.R')
for (rel in files) source(file.path(modules, rel), local=env)
load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')
srt <- pancreas_sub[,1:80]
reference <- readRDS(file.path(record,'codex-reference.rds'))
answer <- tryCatch({
  value <- env$run_cell_quality_control(srt, parameters=reference$qc_parameters)
  stopifnot(identical(value$result@meta.data[,c('nCount_RNA','nFeature_RNA','CellQC'),drop=FALSE], reference$qc))
  'PASS'
}, error=function(e) paste('FAIL:', conditionMessage(e)))
cat('all_modules_same_env_then_QC=', answer, '\n', sep='')
cat('entry_points=', length(grep('^run_|^plot_', ls(env), value=TRUE)), '\n', sep='')
if (answer != 'PASS') quit(status=1)
