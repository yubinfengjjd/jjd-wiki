run_dynamic_monocle2_seurat5 <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  declaration <- "native/e003e60346ee69bd36f8f45848ddebc790bc56279d38f8f0ec891ba53f9a85ef.R"
  original <- parse(file.path(root,declaration),keep.source=TRUE,encoding="UTF-8")
  stopifnot(length(original)==1L,is.call(original[[1]][[3]]),identical(original[[1]][[3]][[1]],as.name("function")))
  replacements <- 0L
  adapt <- function(x) {
    if(!is.call(x))return(x)
    head <- x[[1]]
    if(is.call(head)&&identical(head[[1]],as.name("::"))&&identical(as.character(head[[2]]),"Seurat")&&identical(as.character(head[[3]]),"GetAssayData")) {
      x[[1]] <- as.name(".get_assay_data");replacements <<- replacements+1L
    }
    for(i in seq_along(x)[-1])if(!identical(x[[i]],quote(expr=)))x[i] <- list(adapt(x[[i]]))
    x
  }
  adapted <- adapt(original[[1]][[3]])
  if(replacements!=2L)stop("Source declaration changed: expected exactly two accessor bridges")
  function(...) {
    before_search <- search();before_options <- options();before_libs <- .libPaths()
    had_seed <- exists(".Random.seed",globalenv(),inherits=FALSE)
    before_seed <- if(had_seed)get(".Random.seed",globalenv())else NULL
    restored <- FALSE
    restore <- function() {
      if(restored)return(invisible(NULL))
      for(k in seq_len(4))for(pkg in rev(setdiff(search(),before_search)))try(detach(pkg,character.only=TRUE),silent=TRUE)
      added<-setdiff(names(options()),names(before_options));if(length(added))options(stats::setNames(rep(list(NULL),length(added)),added))
      options(before_options);.libPaths(before_libs)
      if(had_seed)assign(".Random.seed",before_seed,globalenv())else if(exists(".Random.seed",globalenv(),inherits=FALSE))rm(".Random.seed",envir=globalenv())
      restored<<-TRUE;invisible(NULL)
    }
    on.exit(restore(),add=TRUE)
    required <- c("Seurat","SeuratObject","Matrix","rlang","mgcv","ggplot2","patchwork","ggnewscale","RColorBrewer")
    for(pkg in required)if(!requireNamespace(pkg,quietly=TRUE))stop("Missing dependency: ",pkg,". No installation attempted.")
    env <- new.env(parent=baseenv());checks <- list()
    env$`%||%` <- getExportedValue("rlang","%||%")
    env$.data <- getExportedValue("rlang",".data")
    env$t <- getExportedValue("Matrix","t")
    env$colSums <- getExportedValue("Matrix","colSums")
    env$ave <- getExportedValue("stats","ave")
    env$.get_assay_data <- function(object,slot,assay=NULL,...) {
      if(is.null(assay))assay<-SeuratObject::DefaultAssay(object)
      if(length(assay)!=1L||!assay%in%names(object@assays))stop("Select one existing assay explicitly")
      a<-object[[assay]];layers<-SeuratObject::Layers(a,search=NA)
      if(length(slot)!=1L||!slot%in%layers)stop("Requested source slot is not one exact existing layer; no joining or partial matching performed")
      value<-SeuratObject::GetAssayData(object,assay=assay,layer=slot,...)
      legacy_equal<-NA
      if(inherits(a,"Assay")&&slot%in%methods::slotNames(a)) {
        legacy<-methods::slot(a,slot)
        legacy_equal<-identical(dimnames(value),dimnames(legacy))&&isTRUE(all.equal(value,legacy,tolerance=0))
        if(!legacy_equal)stop("Layer output differs from the original legacy slot")
      }
      checks[[length(checks)+1L]]<<-list(assay=assay,source_slot=slot,layer=slot,legacy_matrix_equal=legacy_equal)
      value
    }
    fn<-eval(adapted,envir=env)
    arguments<-list(...);theme_bridge<-FALSE
    if(is.null(arguments$theme_use)||identical(arguments$theme_use,ggplot2::theme_minimal)) {
      arguments$theme_use<-function(aspect.ratio=NULL,...)ggplot2::theme_minimal(...)+ggplot2::theme(aspect.ratio=aspect.ratio)
      theme_bridge<-TRUE
    }
    value<-do.call(fn,arguments,envir=env)
    restore()
    list(value=value,diagnostics=list(source_declaration=declaration,source_file_sha256="e19bccaa972faf21e01bf7d8dcc57981bbb2df46f9e1d546f2fcb9a2ac6f1fee",
      compatibility="Exactly two qualified accessor call heads bridged; Matrix generic bindings and a theme argument bridge restore source dependencies. Original model, transforms, grouping, missing handling and GAM fallback unchanged",
      theme_argument_bridge=theme_bridge,
      accessor_checks=checks,search_restored=identical(search(),before_search),options_restored=identical(options(),before_options),library_paths_restored=identical(.libPaths(),before_libs)))
  }
})
