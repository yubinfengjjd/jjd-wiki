scale_r2_to_mse <- function(x) {
  (x - r2_min) / (r2_max - r2_min) * (mse_max - mse_min) + mse_min
}
