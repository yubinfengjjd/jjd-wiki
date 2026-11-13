# Independent reviewer baseline: original wrappers from the immutable before copy.
record <- 'E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块'
options(error=function(){traceback(15); quit(status=1)})
before <- file.path(record, 'before/知识库/methods')
bundle <- 'E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'
load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')
stopifnot(inherits(pancreas_sub, 'Seurat'))
out <- list()
call_original <- function(family, fun, object, parameters) {
  env <- new.env(parent=globalenv())
  sys.source(file.path(before, family, 'code/analysis.R'), envir=env)
  initial <- serialize(object, NULL)
  result <- do.call(env[[fun]], list(object, bundle, parameters))
  stopifnot(identical(initial, serialize(object, NULL)))
  cat('REFERENCE_OK:', family, '\n')
  result$result
}
s80 <- pancreas_sub[, seq_len(80)]
out$qc_parameters <- list(qc_metrics=c('umi','gene','mito'), UMI_threshold=0,
  gene_threshold=0, mito_threshold=100, return_filtered=FALSE, assay='RNA', seed=11)
qc <- call_original('cell-quality-control', 'run_cell_quality_control', s80, out$qc_parameters)
out$qc <- qc@meta.data[, c('nCount_RNA','nFeature_RNA','CellQC'), drop=FALSE]
saveRDS(out,file.path(record,'codex-reference.rds'))
out$score_parameters <- list(features=list(Endocrine=c('Gcg','Sst'), Ductal=c('Krt19','Krt8','Epcam')),
  method='Seurat', classification=FALSE, name='X', slot='data', assay='RNA', seed=11,
  BPPARAM=BiocParallel::SerialParam())
score <- call_original('gene-set-scoring','run_gene_set_scoring',s80,out$score_parameters)
cat('STAGE: extract score metadata\n')
out$score <- score@meta.data[, c('X_Endocrine','X_Ductal'), drop=FALSE]
cat('STAGE: save score checkpoint\n')
out$score_parameters$BPPARAM <- NULL
saveRDS(out,file.path(record,'codex-reference.rds'))
cat('STAGE: normalize DE input\n')
out$de_parameters <- list(group_by='CellType', group1='Ductal', group2='Endocrine',
  test.use='wilcox', only.pos=FALSE, fc.threshold=1, min.pct=0.1,
  p.adjust.method='bonferroni', slot='data', assay='RNA', verbose=FALSE,
  BPPARAM=BiocParallel::SerialParam())
normalized <- Seurat::NormalizeData(pancreas_sub, verbose=FALSE)
de <- call_original('differential-expression','run_differential_expression',normalized,out$de_parameters)
out$de <- de@tools$DEtest_custom$AllMarkers_wilcox
stopifnot(nrow(out$de)>0)
out$de_parameters$BPPARAM <- NULL
saveRDS(out,file.path(record,'codex-reference.rds'))
cat('REFERENCE_COMPLETE: QC 80 cells, scoring 80 cells, DE packaged pancreas example; not project validation\n')
