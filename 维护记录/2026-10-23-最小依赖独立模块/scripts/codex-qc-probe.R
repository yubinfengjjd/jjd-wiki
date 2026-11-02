record <- 'E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块'
args <- commandArgs(trailingOnly=TRUE)
module <- if(length(args)) args[1] else file.path(record,'pilot/cellqc/code')
project <- file.path(record,'codex-probes/qc/code')
dir.create(project, recursive=TRUE, showWarnings=FALSE)
for(path in list.files(module,full.names=TRUE)) {
  if(file.info(path)$isdir) next
  stopifnot(file.copy(path,project,overwrite=TRUE))
}
load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')
srt <- pancreas_sub[,seq_len(80)]
original <- serialize(srt,NULL)
reference <- readRDS(file.path(record,'codex-reference.rds'))
env <- new.env(parent=globalenv())
source(file.path(project,'analysis.R'),local=env)
before_search <- search()
before_future <- getOption('future.globals.maxSize')
answer <- env$run_cell_quality_control(srt,parameters=reference$qc_parameters)
first_after <- search()
stopifnot(identical(original,serialize(srt,NULL)))
observed <- answer$result@meta.data[,c('nCount_RNA','nFeature_RNA','CellQC'),drop=FALSE]
stopifnot(identical(observed,reference$qc))
cat('QC_NUMERICAL_EQUIVALENCE=PASS\nINPUT_UNCHANGED=PASS\nNO_BUNDLE_ARGUMENT=PASS\n')
cat('SEARCH_BEFORE:',paste(before_search,collapse=','),'\n')
cat('SEARCH_AFTER:',paste(search(),collapse=','),'\n')
cat('SEARCH_RESTORED:',identical(before_search,search()),'\n')
cat('FUTURE_OPTION_RESTORED:',identical(before_future,getOption('future.globals.maxSize')),'\n')
first_restored <- identical(before_search,search())
changed <- SeuratObject::RenameCells(srt[,seq_len(25)],new.names=paste0('project-cell-',seq_len(25)))
changed_initial <- serialize(changed,NULL)
changed_answer <- env$run_cell_quality_control(changed,parameters=reference$qc_parameters)
stopifnot(identical(changed_initial,serialize(changed,NULL)),
          identical(colnames(changed_answer$result),colnames(changed)))
for(column in c('nCount_RNA','nFeature_RNA','CellQC')) {
  stopifnot(identical(as.character(changed_answer$result@meta.data[[column]]),
                     as.character(reference$qc[[column]][seq_len(25)])))
}
cat('QC_CHANGED_SIZE_AND_CELL_IDS=PASS\n')
held_search <- search()
bad <- reference$qc_parameters
bad$assay <- '__missing_assay__'
failure <- tryCatch({env$run_cell_quality_control(srt,parameters=bad);NA_character_},
                    error=function(e)conditionMessage(e))
stopifnot(!is.na(failure),identical(search(),held_search),identical(original,serialize(srt,NULL)))
cat('UPSTREAM_ERROR_PATH_RESTORED=PASS\n')
suppressPackageStartupMessages(library(Seurat))
held_search <- search()
held_answer <- env$run_cell_quality_control(srt,parameters=reference$qc_parameters)
stopifnot(identical(search(),held_search),
          identical(held_answer$result@meta.data[,c('nCount_RNA','nFeature_RNA','CellQC'),drop=FALSE],reference$qc))
cat('USER_PREATTACHED_PACKAGES_PRESERVED=PASS\n')
saveRDS(list(qc=observed,search_before=before_search,search_after=first_after,
  source_hashes=tools::md5sum(list.files(project,full.names=TRUE))),
  if(length(args)>1) args[2] else file.path(record,'codex-qc-pilot.rds'))
if(!first_restored) quit(status=1)
