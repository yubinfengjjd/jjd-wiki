# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:6666-6683
# sha256(func-block)=b2a46c1927df13c37ee0dec95a14f1b218921be3ef98d7859bf1e4e7153122c3
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
segementsDf <- function(data, shorten_start, shorten_end, offset) {
  data$dx <- data$xend - data$x
  data$dy <- data$yend - data$y
  data$dist <- sqrt(data$dx^2 + data$dy^2)
  data$px <- data$dx / data$dist
  data$py <- data$dy / data$dist

  data$x <- data$x + data$px * shorten_start
  data$y <- data$y + data$py * shorten_start
  data$xend <- data$xend - data$px * shorten_end
  data$yend <- data$yend - data$py * shorten_end
  data$x <- data$x - data$py * offset
  data$xend <- data$xend - data$py * offset
  data$y <- data$y + data$px * offset
  data$yend <- data$yend + data$px * offset

  return(data)
}
