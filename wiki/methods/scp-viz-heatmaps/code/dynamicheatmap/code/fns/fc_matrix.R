# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7196-7198
# sha256(func-block)=8a841e43b2071b931a1f1bf42e65e2c2ed1505d8bab16dc1f2165168a58c71fb
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
fc_matrix <- function(matrix) {
  matrix / rowMeans(matrix)
}
