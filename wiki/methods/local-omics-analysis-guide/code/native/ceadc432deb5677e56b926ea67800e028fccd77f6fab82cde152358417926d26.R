scale_mse_to_r2 <- function(x) {
	(x - mse_min) / (mse_max - mse_min) * (r2_max - r2_min) + r2_min
}
