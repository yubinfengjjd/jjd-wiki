# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7228-7234
# sha256(func-block)=c23a3b7315c4ae1b0aa73ddb2fd4202469207a8f9fb12ee74abecf580c14c8bf
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
extractgrobs <- function(vlnplots, x_nm, y_nm, x, y) {
  grobs <- vlnplots[paste0(x_nm[x], ":", y_nm[y])]
  if (length(grobs) == 1) {
    grobs <- grobs[[1]]
  }
  return(grobs)
}
