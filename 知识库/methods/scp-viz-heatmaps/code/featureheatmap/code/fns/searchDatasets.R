# SCP 0.5.6 commit b9b0eb7a | source R/SCP-analysis.R:442-451
# sha256(func-block)=bc0fa90160aaae9d0fa21dc6c6bd09237b4a8f2f011e3736d2f4ebe76f08df09
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
searchDatasets <- function(datasets, pattern) {
  colIdx <- vapply(datasets, FUN = function(x) grepl(pattern = pattern, x = x, ignore.case = TRUE), FUN.VALUE = logical(length = nrow(datasets)))
  rowIdx <- apply(colIdx, 1, any)
  if (any(rowIdx)) {
    return(datasets[rowIdx, , drop = FALSE])
  } else {
    message("No matching datasets found")
    return(NULL)
  }
}
