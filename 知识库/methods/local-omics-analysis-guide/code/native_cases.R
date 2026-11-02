native_normalize <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  env <- new.env(parent=baseenv());source(file.path(root,"native.R"),local=env)
  native <- env$run_local_r_function
  function(..., bindings=list()) native("r-3159ac3f7a9e-112",arguments=list(...),bindings=bindings)
})

native_gini <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  env <- new.env(parent=baseenv());source(file.path(root,"native.R"),local=env)
  native <- env$run_local_r_function
  function(..., bindings=list()) native("r-ddf2ce7f0734-16",arguments=list(...),bindings=bindings)
})

native_combinations <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  env <- new.env(parent=baseenv());source(file.path(root,"native.R"),local=env)
  native <- env$run_local_r_function
  function(..., bindings=list()) native("r-51aa04641949-147",arguments=list(...),bindings=bindings)
})

native_gmt <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  env <- new.env(parent=baseenv());source(file.path(root,"native.R"),local=env)
  native <- env$run_local_r_function
  function(..., bindings=list()) native("r-a9eb819f531a-263",arguments=list(...),bindings=bindings)
})

native_dynamic <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  env <- new.env(parent=baseenv());source(file.path(root,"native.R"),local=env)
  native <- env$run_local_r_function
  function(..., bindings=list()) native("r-e19bccaa972f-10",arguments=list(...),bindings=bindings)
})

native_score_dot <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  env <- new.env(parent=baseenv());source(file.path(root,"native.R"),local=env)
  native <- env$run_local_r_function
  function(..., bindings=list()) native("r-7bdff16edf6f-1",arguments=list(...),bindings=bindings)
})

native_cellchat <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  env <- new.env(parent=baseenv());source(file.path(root,"native.R"),local=env)
  native <- env$run_local_r_function
  function(..., bindings=list()) native("r-dd56ed170e8f-72",arguments=list(...),bindings=bindings)
})

native_singscore <- local({
  paths <- vapply(sys.frames(),function(x)if(is.null(x$ofile)) "" else as.character(x$ofile),character(1))
  paths <- paths[nzchar(paths)]
  if(!length(paths))stop("Use source(file, local=...), not sys.source without ofile")
  root <- dirname(normalizePath(utils::tail(paths,1),winslash="/",mustWork=TRUE))
  env <- new.env(parent=baseenv());source(file.path(root,"native.R"),local=env)
  native <- env$run_local_r_function
  function(..., bindings=list()) native("r-e61811aa608f-12",arguments=list(...),bindings=bindings)
})
