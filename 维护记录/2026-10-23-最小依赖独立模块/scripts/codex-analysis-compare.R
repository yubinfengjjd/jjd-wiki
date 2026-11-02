# Reviewer-run numeric comparison to the pre-change original wrapper baseline.
# Packaged SCP demonstration data only, not an author's research validation.
record <- 'E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块'
methods_root <- 'E:/research-wiki/知识库/methods'
reference <- readRDS(file.path(record, 'codex-reference.rds'))
load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')
future::plan('sequential')
env <- new.env(parent = globalenv())
exports <- c('cell-quality-control'='run_cell_quality_control',
             'gene-set-scoring'='run_gene_set_scoring',
             'differential-expression'='run_differential_expression')
for (family in names(exports)) {
  source(file.path(methods_root, family, 'code/analysis.R'), local=env)
}
invoke <- function(family, object, parameters) {
  before <- serialize(object, NULL)
  search_before <- search()
  result <- env[[exports[[family]]]](object, parameters=parameters)$result
  stopifnot(identical(before, serialize(object, NULL)), identical(search_before, search()))
  cat('INPUT_AND_SEARCH_UNCHANGED', family, '\n')
  result
}
s80 <- pancreas_sub[, seq_len(80)]
qc <- invoke('cell-quality-control', s80, reference$qc_parameters)
stopifnot(identical(reference$qc, qc@meta.data[, colnames(reference$qc), drop=FALSE]))
cat('PASS QC: all recorded metadata values match original\n')
score_params <- reference$score_parameters
score_params$BPPARAM <- BiocParallel::SerialParam()
score <- invoke('gene-set-scoring', s80, score_params)
stopifnot(isTRUE(all.equal(reference$score,
  score@meta.data[, colnames(reference$score), drop=FALSE], tolerance=1e-12)))
cat('PASS scoring: every score matches original\n')
de_params <- reference$de_parameters
de_params$BPPARAM <- BiocParallel::SerialParam()
normalized <- Seurat::NormalizeData(pancreas_sub, verbose=FALSE)
de <- invoke('differential-expression', normalized, de_params)
candidate <- de@tools$DEtest_custom$AllMarkers_wilcox
stopifnot(nrow(candidate)>0, identical(reference$de, candidate))
cat('PASS DE: full result table identical to original, rows=', nrow(candidate), '\n')
cat('CODEX_REAL_COMPARISON_PASS; packaged example, serial execution, no SCP bundle supplied\n')
