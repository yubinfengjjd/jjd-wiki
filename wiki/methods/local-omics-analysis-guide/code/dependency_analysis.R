run_omics_dependency_analysis <- local({
  routes <- list(
    irgsea_score=c("irGSEA","irGSEA.score"),
    irgsea_integrate=c("irGSEA","irGSEA.integrate"),
    consensus_cluster=c("ConsensusClusterPlus","ConsensusClusterPlus"),
    cellchat_create=c("CellChat","createCellChat"),
    gsva=c("GSVA","gsva")
  )
  function(branch, arguments) {
    route <- routes[[branch]]
    if(is.null(route))stop("Unknown dependency analysis branch: ",branch)
    if(!is.list(arguments)||!length(arguments))stop("Supply the original function arguments explicitly as a list")
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
