# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:1044-1048
# sha256(func-block)=40e8b3b1da695a167ab0e4c8d87fdb9f1e0cb51f750bc5ffe21026b276a14626
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
RGBA2RGB <- function(RGBA, BackGround = c(1, 1, 1)) {
  A <- RGBA[[length(RGBA)]]
  RGB <- RGBA[[-length(RGBA)]] * A + BackGround * (1 - A)
  return(RGB)
}
