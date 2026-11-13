run_local_r_function <- local({
  frames <- sys.frames()
  paths <- vapply(frames,function(x) if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if (!length(paths)) stop("Source native.R with source(file, local=...), not sys.source without ofile.")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  registry <- readRDS(file.path(root,"registry.rds"))
  defaults <- c("stats","utils","graphics","grDevices","methods","grid")
  function(function_id, arguments=list(), bindings=list()) {
    if (!is.list(arguments)||!is.list(bindings)) stop("arguments and bindings must be explicit lists")
    rec <- registry$functions[[function_id]]
    if (is.null(rec)) stop("Unknown function_id: ",function_id)
    if (isTRUE(rec$blocked)) stop("Source function requires separate review: ",paste(rec$block_reasons,collapse="; "))
    before_search <- search();before_options <- options();before_libs <- .libPaths()
    had_seed <- exists(".Random.seed",envir=globalenv(),inherits=FALSE)
    before_seed <- if(had_seed)get(".Random.seed",envir=globalenv())else NULL
    restored <- FALSE
    restore <- function() {
      if(restored)return(invisible(NULL))
      for(attempt in seq_len(4))for(pkg in rev(setdiff(search(),before_search)))try(detach(pkg,character.only=TRUE),silent=TRUE)
      added <- setdiff(names(options()),names(before_options))
      if(length(added))options(stats::setNames(rep(list(NULL),length(added)),added))
      options(before_options);.libPaths(before_libs)
      if(had_seed)assign(".Random.seed",before_seed,envir=globalenv())else if(exists(".Random.seed",globalenv(),inherits=FALSE))rm(".Random.seed",envir=globalenv())
      restored <<- TRUE
      invisible(NULL)
    }
    on.exit(restore(),add=TRUE)
    env <- new.env(parent=baseenv());resolved <- list();loaded <- character()
    ids <- unlist(rec$closure,use.names=FALSE)
    if(any(vapply(registry$functions[ids],function(x)isTRUE(x$blocked),logical(1))))stop("Closure contains a blocked helper")
    # Only function declarations are evaluated. Project top-level scripts are never sourced.
    for(id in ids) {
      r <- registry$functions[[id]]
      expressions <- parse(file.path(root,r$file),keep.source=TRUE,encoding="UTF-8")
      if(length(expressions)!=1L || !is.call(expressions[[1]]) || !as.character(expressions[[1]][[1]]) %in% c("<-","=") || !is.call(expressions[[1]][[3]]) || !identical(expressions[[1]][[3]][[1]],as.name("function")))stop("Invalid native declaration: ",id)
      fn <- eval(expressions[[1]][[3]],envir=env)
      assign(r$name,fn,envir=env)
    }
    # Resolve source package symbols lazily in original library-order precedence.
    # Optional ambient themes/palettes remain explicit bindings, preserving the source fallback.
    symbols <- unique(unlist(lapply(registry$functions[ids],function(x)x$function_symbols),use.names=FALSE))
    packages <- unique(c(defaults,rec$packages))
    for(symbol in setdiff(symbols,c(ls(env,all.names=TRUE),"theme_scp","palette_scp"))) {
      if(exists(symbol,envir=baseenv(),inherits=FALSE))next
      local({
        sym <- symbol
        makeActiveBinding(sym,function(value) {
          if(!missing(value))stop("Cannot overwrite dependency binding: ",sym)
          if(!is.null(bindings[[sym]]))return(bindings[[sym]])
          missing_packages <- character()
          for(pkg in rev(packages)) {
            pkg_root <- system.file(package=pkg)
            if(!nzchar(pkg_root)){missing_packages<-c(missing_packages,pkg);next}
            nsfile <- file.path(pkg_root,"Meta","nsInfo.rds")
            if(file.exists(nsfile)) {
              nsmeta <- tryCatch(readRDS(nsfile),error=function(e)NULL)
              if(!is.null(nsmeta)&&!sym%in%nsmeta$exports&&!length(nsmeta$exportPatterns))next
            }
            if(!requireNamespace(pkg,quietly=TRUE)){missing_packages<-c(missing_packages,pkg);next}
            if(sym %in% getNamespaceExports(pkg)) {
              resolved[[sym]] <<- pkg;loaded <<- unique(c(loaded,pkg))
              return(getExportedValue(pkg,sym))
            }
          }
          stop("Unresolved source symbol '",sym,"'; pass an explicit binding. Unavailable source packages: ",paste(unique(missing_packages),collapse=", "))
        },env)
      })
    }
    if(length(bindings)) {
      if(is.null(names(bindings))||any(!nzchar(names(bindings)))||anyDuplicated(names(bindings)))stop("bindings must have unique names")
      own <- vapply(registry$functions[ids],function(x)x$name,character(1))
      if(any(names(bindings)%in%own))stop("bindings cannot replace native algorithms")
      for(nm in names(bindings))if(!exists(nm,env,inherits=FALSE)||!bindingIsActive(nm,env))assign(nm,bindings[[nm]],env)
    }
    # dplyr/ggplot2 data masks use the original .data pronoun, not inferred column mappings.
    needs_data_pronoun <- any(vapply(registry$functions[ids],function(x)".data" %in% unlist(x$external_variable_candidates,use.names=FALSE),logical(1)))
    if(needs_data_pronoun&&!exists(".data",env,inherits=FALSE)&&requireNamespace("rlang",quietly=TRUE))assign(".data",getExportedValue("rlang",".data"),env)
    value <- do.call(get(rec$name,envir=env,inherits=FALSE),arguments,envir=env)
    restore()
    list(value=value,diagnostics=list(function_id=function_id,source_sha256=rec$source_sha256,
      resolved_symbols=resolved,loaded_namespaces=loaded,search_restored=identical(search(),before_search),
      options_restored=identical(options(),before_options),library_paths_restored=identical(.libPaths(),before_libs),
      algorithm_scope="Only this function, explicit arguments/bindings and actual dependency versions; no family-wide validation implied."))
  }
})
