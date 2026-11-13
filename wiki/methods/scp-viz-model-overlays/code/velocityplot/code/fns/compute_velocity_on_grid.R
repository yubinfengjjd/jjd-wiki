# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:6963-7039
# sha256(func-block)=5270db062de0d35897b4356232dbf66e0df0e11c7760a0f1a4bb356dc3d99eb9
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
compute_velocity_on_grid <- function(X_emb, V_emb,
                                     density = NULL, smooth = NULL, n_neighbors = NULL, min_mass = NULL,
                                     scale = 1, adjust_for_stream = FALSE, cutoff_perc = NULL) {
  n_obs <- nrow(X_emb)
  n_dim <- ncol(X_emb)

  density <- density %||% 1
  smooth <- smooth %||% 0.5
  n_neighbors <- n_neighbors %||% ceiling(n_obs / 50)
  min_mass <- min_mass %||% 1
  cutoff_perc <- cutoff_perc %||% 5

  grs <- list()
  for (dim_i in 1:n_dim) {
    m <- min(X_emb[, dim_i], na.rm = TRUE)
    M <- max(X_emb[, dim_i], na.rm = TRUE)
    # m <- m - 0.01 * abs(M - m)
    # M <- M + 0.01 * abs(M - m)
    gr <- seq(m, M, length.out = ceiling(50 * density))
    grs <- c(grs, list(gr))
  }
  X_grid <- as_matrix(expand.grid(grs))

  d <- dist(
    x = as.sparse(X_emb),
    y = as.sparse(X_grid),
    method = "euclidean",
    use_nan = TRUE
  )
  neighbors <- t(as_matrix(apply(d, 2, function(x) order(x, decreasing = FALSE)[1:n_neighbors])))
  dists <- t(as_matrix(apply(d, 2, function(x) x[order(x, decreasing = FALSE)[1:n_neighbors]])))

  # ggplot() +
  #   annotate(geom = "point", x = X_grid[, 1], y = X_grid[, 2]) +
  #   annotate(geom = "point", x = X_grid[1, 1], y = X_grid[1, 2], color = "blue") +
  #   annotate(geom = "point", x = X_grid[neighbors[1, ], 1], y = X_grid[neighbors[1, ], 2], color = "red")

  weight <- dnorm(dists, sd = mean(sapply(grs, function(g) g[2] - g[1])) * smooth)
  p_mass <- p_mass_V <- rowSums(weight)
  p_mass_V[p_mass_V < 1] <- 1

  # qplot(dists[,1],weight[,1])
  # qplot(py$dists[,1],py$weight[,1])

  neighbors_emb <- array(V_emb[neighbors, seq_len(ncol(V_emb))],
    dim = c(dim(neighbors), dim(V_emb)[2])
  )
  V_grid <- apply((neighbors_emb * c(weight)), c(1, 3), sum)
  V_grid <- V_grid / p_mass_V

  # qplot(V_grid[,1],V_grid[,2])
  # qplot(py$V_grid[,1],py$V_grid[,2])

  if (isTRUE(adjust_for_stream)) {
    X_grid <- matrix(c(unique(X_grid[, 1]), unique(X_grid[, 2])), nrow = 2, byrow = TRUE)
    ns <- floor(sqrt(length(V_grid[, 1])))
    V_grid <- reticulate::array_reshape(t(V_grid), c(2, ns, ns))

    mass <- sqrt(apply(V_grid**2, c(2, 3), sum))
    min_mass <- 10**(min_mass - 6) # default min_mass = 1e-5
    min_mass[min_mass > max(mass, na.rm = TRUE) * 0.9] <- max(mass, na.rm = TRUE) * 0.9
    cutoff <- reticulate::array_reshape(mass, dim = c(ns, ns)) < min_mass

    length <- t(apply(apply(abs(neighbors_emb), c(1, 3), mean), 1, sum))
    length <- reticulate::array_reshape(length, dim = c(ns, ns))
    cutoff <- cutoff | length < quantile(length, cutoff_perc / 100)
    V_grid[1, , ][cutoff] <- NA
  } else {
    min_mass <- min_mass * quantile(p_mass, 0.99) / 100
    X_grid <- X_grid[p_mass > min_mass, ]
    V_grid <- V_grid[p_mass > min_mass, ]
    if (!is.null(scale)) {
      V_grid <- V_grid * scale
    }
  }
  return(list(X_grid = X_grid, V_grid = V_grid))
}
