# Independent pinned-source control using actual shipped pancreas counts.
# This produces a software reference only, not biological/project validation.
args <- commandArgs(trailingOnly=TRUE)
outdir <- args[1]
dir.create(outdir,recursive=TRUE,showWarnings=FALSE)
suppressPackageStartupMessages(library(jsonlite))
root <- 'E:/research-wiki/维护记录/2026-10-25-SCP全库入库'
input <- readRDS(file.path(root,'native-oracles/real-counts-subset.rds'))
x <- t(as.matrix(input)) # observations x features, as uwot::lvish requires
before <- digest::digest(x,algo='sha256')
e <- new.env(parent=baseenv())
e$CreateDimReducObject <- SeuratObject::CreateDimReducObject
f <- 'E:/research-wiki-env/work/scp-full-ingest-20261025/coverage/extracted/Seurat-function/RunLargeVis.default.R'
sys.source(f,envir=e)
params <- list(assay='RNA',perplexity=3,n_neighbors=10,n_components=2,n_epochs=100,n_threads=1,n_sgd_threads=1,seed.use=11L,verbose=FALSE)
r <- tryCatch({
  y <- do.call(e$RunLargeVis.default,c(list(object=x),params))
  stopifnot(nrow(y@cell.embeddings)==nrow(x),ncol(y@cell.embeddings)==2L,all(is.finite(y@cell.embeddings)),identical(rownames(y@cell.embeddings),rownames(x)))
  saveRDS(list(embeddings=y@cell.embeddings,parameters=params,input_sha256=before),file.path(outdir,'largevis-native.rds'))
  list(state='passed',observations=nrow(x),features=ncol(x),dimensions=ncol(y@cell.embeddings),input_unchanged=identical(before,digest::digest(x,algo='sha256')))
},error=function(err)list(state='error',error=conditionMessage(err)))
r$scope <- 'pinned original RunLargeVis.default, R uwot::lvish, observed pancreas subset; not extracted-module acceptance or scientific validation'
r$source <- f
r$source_sha256 <- digest::digest(file=f,algo='sha256')
r$input_sha256 <- before
r$parameters <- params
r$versions <- list(R=R.version.string,uwot=as.character(packageVersion('uwot')),SeuratObject=as.character(packageVersion('SeuratObject')))
writeLines(toJSON(r,auto_unbox=TRUE,pretty=TRUE),file.path(outdir,'largevis-native.json'))
cat(toJSON(r,auto_unbox=TRUE,pretty=FALSE),'\n')
