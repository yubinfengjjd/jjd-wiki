run_knk <- function(params_local) {
  params_call <- params_local
  nc_q <- params_call$nc_q
  params_call$nc_q <- NULL
  do.call(scTenifoldKnk::scTenifoldKnk, c(list(countMatrix = counts, gKO = ko_gene), params_call, list(nc_q = nc_q)))
}
