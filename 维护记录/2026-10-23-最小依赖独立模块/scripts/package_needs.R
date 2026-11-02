ns <- readLines("E:/research-wiki/知识库/methods/scp-local-source/source/NAMESPACE", warn=FALSE)
imp <- do.call(rbind, lapply(grep("^importFrom", ns, value=TRUE), function(x) {
  m <- regmatches(x, regexec('^importFrom[(]([^,]+),"?([^")]+)"?[)]$', x))[[1]]
  if (length(m)==3) data.frame(pkg=m[2], name=m[3], stringsAsFactors=FALSE) else NULL
}))
base_names <- c(ls(baseenv()), getNamespaceExports("stats"), getNamespaceExports("utils"),
                getNamespaceExports("methods"), getNamespaceExports("grDevices"),
                getNamespaceExports("graphics"), getNamespaceExports("grid"))
allr <- c(readRDS("scripts/dep_trace.rds"), readRDS("scripts/dep_trace_extra.rds"))
ext <- function(fn) {
  for (t in names(allr)) {
    x <- allr[[t]]
    if (!is.null(x$globals) && fn %in% names(x$globals)) return(x$globals[[fn]]$functions)
  }
  character()
}
mods <- list.files("extracted", pattern="_closure.json$", full.names=TRUE)
for (f in mods) {
  txt <- paste(readLines(f, warn=FALSE), collapse="\n")
  pairs <- regmatches(txt, gregexpr('"name": "[^"]+", "file": "[^"]+"', txt))[[1]]
  nms <- sub('"name": "([^"]+)".*', '\\1', pairs)
  fmap <- setNames(sub('.*"file": "([^"]+)"', '\\1', pairs), nms)
  plotfns <- nms[fmap[nms] == "SCP-plot.R"]
  corefns <- setdiff(nms, plotfns)
  core_ext <- unique(unlist(lapply(corefns, ext)))
  plot_ext <- unique(unlist(lapply(plotfns, ext)))
  pkg_of <- function(nm) {
    if (nm %in% base_names) return(NA_character_)
    hit <- imp$pkg[imp$name == nm]
    if (length(hit)) return(hit[1]) else return("UNMAPPED")
  }
  core_map <- vapply(core_ext, pkg_of, "")
  core_pkgs <- sort(unique(na.omit(core_map)))
  plot_pkgs <- sort(unique(na.omit(vapply(setdiff(plot_ext, core_ext), pkg_of, ""))))
  cat("=====", basename(f), "=====\n")
  cat("core functions:", paste(corefns, collapse=", "), "\n")
  cat("plot functions:", paste(plotfns, collapse=", "), "\n")
  cat("core packages:", paste(core_pkgs, collapse=", "), "\n")
  cat("plot packages:", paste(plot_pkgs, collapse=", "), "\n")
  cat("UNMAPPED core:", paste(core_ext[core_map == "UNMAPPED"], collapse=", "), "\n\n")
}
