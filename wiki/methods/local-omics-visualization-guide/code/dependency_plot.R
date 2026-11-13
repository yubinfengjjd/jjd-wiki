run_omics_dependency_plot <- local({
  routes <- list(
    irgsea_heatmap=c("irGSEA","irGSEA.heatmap"),
    scp_cell_dim=c("SCP","CellDimPlot"),scp_feature_dim=c("SCP","FeatureDimPlot"),
    scp_feature_stat=c("SCP","FeatureStatPlot"),scp_feature_heatmap=c("SCP","FeatureHeatmap"),
    seurat_dim=c("Seurat","DimPlot"),seurat_feature=c("Seurat","FeaturePlot"),
    seurat_violin=c("Seurat","VlnPlot"),seurat_dot=c("Seurat","DotPlot"),
    seurat_spatial_dim=c("Seurat","SpatialDimPlot"),seurat_spatial_feature=c("Seurat","SpatialFeaturePlot"),
    cellchat_circle=c("CellChat","netVisual_circle"),cellchat_bubble=c("CellChat","netVisual_bubble"),
    cellchat_aggregate=c("CellChat","netVisual_aggregate"),cellchat_heatmap=c("CellChat","netVisual_heatmap"),
    cellchat_role_heatmap=c("CellChat","netAnalysis_signalingRole_heatmap"),
    cellchat_role_scatter=c("CellChat","netAnalysis_signalingRole_scatter")
  )
  function(branch, arguments) {
    route <- routes[[branch]]
    if(is.null(route))stop("Unknown dependency plot branch: ",branch)
    if(!is.list(arguments)||!length(arguments))stop("Supply the original plot function arguments explicitly as a list")
    before_search <- search();before_options <- options()
    on.exit({
      for(attempt in seq_len(4))for(pkg in rev(setdiff(search(),before_search)))try(detach(pkg,character.only=TRUE),silent=TRUE)
      added <- setdiff(names(options()),names(before_options));if(length(added))options(stats::setNames(rep(list(NULL),length(added)),added));options(before_options)
    },add=TRUE)
    if(!requireNamespace(route[[1]],quietly=TRUE))stop("Missing dependency: ",route[[1]],". No installation was attempted.")
    if(!route[[2]]%in%getNamespaceExports(route[[1]]))stop("Dependency API not exported: ",paste(route,collapse="::"))
    do.call(getExportedValue(route[[1]],route[[2]]),arguments)
  }
})
