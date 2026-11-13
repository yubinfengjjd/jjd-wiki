# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:7675-7678
# sha256(func-block)=5162a842d277a50b7646b6de71e6a00b3b3da7507350016e38c6d4c05af315f3
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
standardise <- function(data) {
  data[] <- t(apply(data, 1, scale))
  return(data)
}
