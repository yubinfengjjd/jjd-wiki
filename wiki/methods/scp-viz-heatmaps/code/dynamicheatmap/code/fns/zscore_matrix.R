# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7199-7201
# sha256(func-block)=ac786393cd2f8b9f651575b37420774422d5f386e8b9b3810a51628a7f78b24e
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
zscore_matrix <- function(matrix, ...) {
  t(scale(t(matrix), ...))
}
