# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7202-7204
# sha256(func-block)=005241d14a4dfca90aea6aba2c47796933e1e6cb960ad78011a3d8db51f38739
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
log2fc_matrix <- function(matrix) {
  log2(matrix / rowMeans(matrix))
}
