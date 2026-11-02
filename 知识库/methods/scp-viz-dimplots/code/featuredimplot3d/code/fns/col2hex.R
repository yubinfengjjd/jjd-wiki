# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:755-758
# sha256(func-block)=593503e1ffec123b8b8682107775564b337bfebf047030693d477d73d44d6895
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
col2hex <- function(cname) {
  colMat <- col2rgb(cname)
  rgb(red = colMat[1, ] / 255, green = colMat[2, ] / 255, blue = colMat[3, ] / 255)
}
