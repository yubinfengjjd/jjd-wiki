# Pinned FR source control on a graph derived from real pancreas observations.
out <- 'E:/research-wiki-env/work/codex-scp-native-fr'
dir.create(out,recursive=TRUE,showWarnings=FALSE)
suppressPackageStartupMessages(library(jsonlite))
raw <- readRDS('E:/research-wiki-env/work/codex-scp-native-graph/graph-real-neighbours.rds')
g <- SeuratObject::as.Graph(raw$edge)
SeuratObject::DefaultAssay(g) <- 'RNA'
before <- digest::digest(g,algo='sha256')
e <- new.env(parent=baseenv())
e$graph_from_adjacency_matrix <- igraph::graph_from_adjacency_matrix
e$layout_with_fr <- igraph::layout_with_fr
e$as.Graph <- SeuratObject::as.Graph
e$CreateDimReducObject <- SeuratObject::CreateDimReducObject
f <- 'E:/research-wiki-env/work/scp-full-ingest-20261025/coverage/extracted/Seurat-function/RunFR.default.R'
sys.source(f,envir=e)
params <- list(ndim=2L,niter=100L,seed.use=11L,verbose=FALSE)
r <- tryCatch({
  y <- do.call(e$RunFR.default,c(list(object=g),params))
  stopifnot(nrow(y@cell.embeddings)==nrow(g),ncol(y@cell.embeddings)==2L,all(is.finite(y@cell.embeddings)),identical(rownames(y@cell.embeddings),rownames(g)))
  saveRDS(list(embeddings=y@cell.embeddings,parameters=params,input=g),file.path(out,'fr-native.rds'))
  list(state='passed',observations=nrow(g),input_unchanged=identical(before,digest::digest(g,algo='sha256')))
},error=function(err)list(state='error',error=conditionMessage(err)))
r$plain_matrix <- tryCatch({ e$RunFR.default(raw$edge,ndim=2,niter=100,seed.use=11,verbose=FALSE);list(state='unexpectedly_accepted') },error=function(err)list(state='rejected',error=conditionMessage(err)))
r$scope <- 'pinned-source FR force-directed graph layout; prepared real-data Seurat Graph, not community detection or scientific validation'
r$preparation <- 'Existing explicit FindNeighbors-derived 50-cell SNN adjacency; as.Graph and assay.used=RNA added to satisfy native contract, no edge changes'
r$source_sha256 <- digest::digest(file=f,algo='sha256')
r$input_sha256 <- before
r$parameters <- params
r$versions <- list(R=R.version.string,igraph=as.character(packageVersion('igraph')),SeuratObject=as.character(packageVersion('SeuratObject')))
writeLines(toJSON(r,auto_unbox=TRUE,pretty=TRUE),file.path(out,'fr-native.json'))
cat(toJSON(r,auto_unbox=TRUE,pretty=FALSE),'\n')
