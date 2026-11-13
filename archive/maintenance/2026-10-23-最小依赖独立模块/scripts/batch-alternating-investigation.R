record <- 'E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块'
bundle <- 'E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'
load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')
future::plan('sequential'); options(future.globals.maxSize=4*1024^3); set.seed(11)
GetAssayData <- function(object, assay=NULL, slot=NULL, layer=NULL, ...) { if (is.null(layer) && !is.null(slot)) layer <- slot; SeuratObject::GetAssayData(object=object, assay=assay, layer=layer, ...) }
Assays <- function(object, slot=NULL, ...) { if (!is.null(slot)) return(methods::slot(object=object, name='assays')[[slot]]); SeuratObject::Assays(object=object, ...) }
srt <- pancreas_sub[,1:120]; srt$batch <- rep(c('A','B'), length.out=120)
old_env <- new.env(parent=globalenv()); sys.source(file.path(record,'before/知识库/methods/batch-integration/code/analysis.R'), envir=old_env)
new_env <- new.env(parent=globalenv()); setwd(file.path(record,'portability/batch-integration/code')); source('analysis.R', local=new_env); setwd(record)
call <- function(fn) tryCatch({fn(); 'PASS'}, error=function(e) paste('ERROR:', conditionMessage(e)))
old <- call(function() old_env$run_seurat_integration(srt, 'batch', bundle, list(nHVF=300, linear_reduction_dims=20, nonlinear_reduction_dims=2, cluster_resolution=0.5, IntegrateData_params=list(k.weight=30), seed=11)))
new <- call(function() new_env$run_seurat_integration(srt, 'batch', parameters=list(nHVF=300, linear_reduction_dims=20, nonlinear_reduction_dims=2, cluster_resolution=0.5, IntegrateData_params=list(k.weight=30), seed=11)))
cat('ORIGINAL_ALTERNATING=', old, '\n', sep='')
cat('NEW_ALTERNATING=', new, '\n', sep='')
jsonlite::write_json(list(case='120 cells, legal alternating A/B batch labels (interleaved cell order)', original=old, new=new,
  conclusion=if (startsWith(old,'ERROR') && startsWith(new,'ERROR')) 'both original and newly extracted branch fail identically with the Assay counts/data cell mismatch; continuous-block fixture passes; this does not prove all legal cell orders are supported and does not change statistical defaults' else 'differs'),
  'batch-alternating-investigation.json', auto_unbox=TRUE, pretty=TRUE)
