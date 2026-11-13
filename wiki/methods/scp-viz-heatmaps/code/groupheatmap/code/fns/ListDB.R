# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:2123-2148
# sha256(func-block)=3938ebcb073a82477fa863af9892b942f82c92f8cb5a634f8f1ca4156c600d44
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
ListDB <- function(species = "Homo_sapiens",
                   db = NULL) {
  stopifnot(length(species) == 1)
  pathnames <- dir(path = getCacheRootPath(), pattern = "[.]Rcache$", full.names = TRUE)
  if (length(pathnames) == 0) {
    return(NULL)
  }
  dbinfo <- lapply(pathnames, function(x) {
    info <- readCacheHeader(x)
    info[["date"]] <- as.character(info[["timestamp"]])
    info[["db_version"]] <- strsplit(info[["comment"]], "\\|")[[1]][1]
    info[["db_name"]] <- strsplit(info[["comment"]], "\\|")[[1]][2]
    return(info)
  })
  dbinfo <- do.call(rbind.data.frame, dbinfo)
  dbinfo[["file"]] <- pathnames

  if (is.null(db)) {
    db <- ".*"
  }
  patterns <- paste0("^", species, "-", db, "$")
  dbinfo <- dbinfo[unlist(lapply(patterns, function(pat) grep(pat, dbinfo[["db_name"]]))), , drop = FALSE]
  dbinfo <- dbinfo[order(dbinfo[["timestamp"]], decreasing = TRUE), , drop = FALSE]
  rownames(dbinfo) <- NULL
  return(dbinfo)
}
