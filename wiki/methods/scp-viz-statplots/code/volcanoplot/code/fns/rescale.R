# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:723-729
# sha256(func-block)=0b88033c4fe4f4e4aeda87ecc84b37cd90af1eac13d82b2d176f49e8d2713a84
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
rescale <- function(x, from = range(x, na.rm = TRUE, finite = TRUE), to = c(0, 1)) {
  if (zero_range(from) || zero_range(to)) {
    return(ifelse(is.na(x), NA, mean(to)))
  } else {
    return((x - from[1]) / diff(from) * diff(to) + to[1])
  }
}
