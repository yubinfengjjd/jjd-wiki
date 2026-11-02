# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:13441-13502
# sha256(func-block)=df87fdb9b69a2ac4dbb807ae97b0a8fede840f83fd4ae8b1307c9b84cd1ff9e8
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
adjustlayout <- function(graph, layout, width, height = 2, scale = 100, iter = 100) {
  w <- width / 2
  layout[, 1] <- layout[, 1] / diff(range(layout[, 1])) * scale
  layout[, 2] <- layout[, 2] / diff(range(layout[, 2])) * scale

  adjusted <- c()
  # for (i in seq_len(iter)) {
  for (v in order(degree(graph), decreasing = TRUE)) {
    adjusted <- c(adjusted, v)
    neighbors <- as.numeric(neighbors(graph, V(graph)[v]))
    neighbors <- setdiff(neighbors, adjusted)
    x <- layout[v, 1]
    y <- layout[v, 2]
    r <- w[v]
    for (neighbor in neighbors) {
      nx <- layout[neighbor, 1]
      ny <- layout[neighbor, 2]
      ndist <- sqrt((nx - x)^2 + (ny - y)^2)
      nr <- w[neighbor]
      expect <- r + nr
      if (ndist < expect) {
        dx <- (x - nx) * (expect - ndist) / ndist
        dy <- (y - ny) * (expect - ndist) / ndist
        layout[neighbor, 1] <- nx - dx
        layout[neighbor, 2] <- ny - dy
        adjusted <- c(adjusted, neighbor)
      }
    }
  }
  # }

  for (i in seq_len(iter)) {
    dist_matrix <- as_matrix(dist(layout))
    nearest_neighbors <- apply(dist_matrix, 2, function(x) which(x == min(x[x > 0])), simplify = FALSE)
    # nearest_neighbors <- apply(dist_matrix, 2, function(x) {
    #   head(order(x), 3)[-1]
    # }, simplify = FALSE)
    for (v in sample(seq_len(nrow(layout)))) {
      neighbors <- unique(nearest_neighbors[[v]])
      x <- layout[v, 1]
      y <- layout[v, 2]
      r <- w[v]
      for (neighbor in neighbors) {
        nx <- layout[neighbor, 1]
        ny <- layout[neighbor, 2]
        nr <- w[neighbor]
        if (abs(nx - x) < (r + nr) && abs(ny - y) < height) {
          dx <- r + nr - (nx - x)
          dy <- height - (ny - y)
          if (sample(c(1, 0), 1) == 1) {
            dx <- 0
          } else {
            dy <- 0
          }
          layout[neighbor, 1] <- nx - dx
          layout[neighbor, 2] <- ny - dy
        }
      }
    }
  }
  return(layout)
}
