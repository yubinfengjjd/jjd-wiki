# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:872-881
# sha256(func-block)=d4fe31463fab58ff50379f23174975a372a9320ffe67f26b26ea5170edaae653
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
str_wrap <- function(x, width = 80) {
  if (is.null(x)) {
    return(NULL)
  }
  if (inherits(x, "factor")) {
    x <- as.character(x)
  }
  x_wrap <- unlist(lapply(x, function(i) paste0(strwrap(i, width = width), collapse = "\n")))
  return(x_wrap)
}
