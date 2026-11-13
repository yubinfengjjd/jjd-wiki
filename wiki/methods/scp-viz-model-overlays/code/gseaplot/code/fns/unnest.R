# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:800-817
# sha256(func-block)=838c55b7a06b1a2f5f36cf0efe83907e47c3de23a6cdb82e6cd2bae422daac72
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
unnest <- function(data, cols, keep_empty = FALSE) {
  if (nrow(data) == 0 || length(cols) == 0) {
    return(data)
  }
  for (col in cols) {
    col_expand <- unlist(data[[col]])
    expand_times <- sapply(data[[col]], length)
    if (isTRUE(keep_empty)) {
      data[[col]][expand_times == 0] <- NA
      col_expand <- unlist(data[[col]])
      expand_times[expand_times == 0] <- 1
    }
    data <- data[rep(seq_len(nrow(data)), times = expand_times), ]
    data[, col] <- col_expand
  }
  rownames(data) <- NULL
  return(data)
}
