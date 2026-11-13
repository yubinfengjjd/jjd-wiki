# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:48-55
# sha256(func-block)=f04b73049c83a292e75b18ee21145e5fd5f3ea963cdae8b470e2437dd3269061
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
sigmoid <- function(x_from, x_to, y_from, y_to, smooth = 5, n = 300) {
  x <- seq(-smooth, smooth, length = n)
  y <- exp(x) / (exp(x) + 1)
  out <- data.frame(
    x = (x + smooth) / (smooth * 2) * (x_to - x_from) + x_from,
    y = y * (y_to - y_from) + y_from
  )
}
