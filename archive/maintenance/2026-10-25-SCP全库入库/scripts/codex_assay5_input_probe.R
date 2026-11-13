# Independent concrete input-version boundary, real observed counts only.
outdir <- 'E:/research-wiki-env/work/codex-scp-assay5-probe'
dir.create(outdir,recursive=TRUE,showWarnings=FALSE)
x <- readRDS('E:/research-wiki/维护记录/2026-10-25-SCP全库入库/native-oracles/real-counts-subset.rds')
a5 <- SeuratObject::CreateAssay5Object(counts=x)
srt <- SeuratObject::CreateSeuratObject(counts=a5)
before <- digest::digest(srt,algo='sha256')
base <- 'E:/research-wiki-env/work/codex-scp-load-20261026T070334/celldensityplot'
e <- new.env(parent=baseenv())
r <- tryCatch({
 source(file.path(base,'code/module.R'),local=e)
 p <- e$CellDensityPlot(srt,features=rownames(x)[1],slot='counts')
 list(state='called',class=class(p))
},error=function(err)list(state='error',error=conditionMessage(err)))
r$scope <- 'Public extracted CellDensityPlot on an explicit counts-only Assay5 made from observed counts; input compatibility only, not algorithm/scientific verification'
r$assay_class <- class(srt[['RNA']])
r$object_unchanged <- identical(before,digest::digest(srt,algo='sha256'))
r$module_snapshot <- base
r$SeuratObject <- as.character(packageVersion('SeuratObject'))
jsonlite::write_json(r,file.path(outdir,'result.json'),auto_unbox=TRUE,pretty=TRUE)
cat(jsonlite::toJSON(r,auto_unbox=TRUE),'\n')
