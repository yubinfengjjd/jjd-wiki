# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7680-7686
# sha256(func-block)=a4688acfa4bf79fa9b221d46d4b516a355dd90af1c63607cad7707f4455df33a
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
mestimate <- function(data) {
  N <- nrow(data)
  D <- ncol(data)
  m.sj <- 1 + (1418 / N + 22.05) * D^(-2) + (12.33 / N + 0.243) *
    D^(-0.0406 * log(N) - 0.1134)
  return(m.sj)
}
