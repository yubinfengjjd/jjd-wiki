try_adjust_nc_q <- function(res, params_local) {
  tn <- res$tensorNetworks
  if (is.null(tn)) return(list(res = res, params = params_local, adjusted = FALSE, density = NA_real_))
  net0 <- NULL
  if (is.list(tn) && ("WT" %in% names(tn)) && is.list(tn$WT) && length(tn$WT) >= 1) net0 <- tn$WT[[1]]
  if (is.null(net0) && is.list(tn) && length(tn) >= 1) net0 <- tn[[1]]
  dens <- estimate_density(net0)
  if (is.na(dens)) return(list(res = res, params = params_local, adjusted = FALSE, density = dens))

  if (dens < 0.001 && params_local$nc_q > 0.85) {
    params2 <- params_local
    params2$nc_q <- 0.85
    log_msg("Network too sparse (density=", sprintf("%.4f", dens), "); re-running with nc_q=0.85")
    res2 <- time_it("Re-run scTenifoldKnk (nc_q adjust)", function() run_knk(params2))
    return(list(res = res2, params = params2, adjusted = TRUE, density = dens))
  }
  list(res = res, params = params_local, adjusted = FALSE, density = dens)
}
