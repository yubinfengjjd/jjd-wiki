args <- commandArgs(trailingOnly=TRUE)
before <- args[1]; bundle <- args[2]; fixture <- args[3]
load(fixture)
GetAssayData <- function(object, assay=NULL, slot=NULL, layer=NULL, ...) { if (is.null(layer) && !is.null(slot)) layer <- slot; SeuratObject::GetAssayData(object=object, assay=assay, layer=layer, ...) }
Assays <- function(object, slot=NULL, ...) { if (!is.null(slot)) return(methods::slot(object=object, name="assays")[[slot]]); SeuratObject::Assays(object=object, ...) }
env <- new.env(parent=globalenv()); sys.source(file.path(before,"trajectory-inference/code/analysis.R"), envir=env)
x <- tryCatch({ env$run_trajectory_inference(load(fixture), bundle, list()) }, error=function(e) conditionMessage(e))
load(fixture); srt <- pancreas_sub[,1:80]
x <- tryCatch({ env$run_trajectory_inference(srt, bundle, list(group.by="CellType", reduction="UMAP", dims=1:2, show_plot=TRUE, seed=11)); "OK" }, error=function(e) conditionMessage(e))
cat("PLOT_RESULT:", if (is.character(x)) x else "OK", "\n")
