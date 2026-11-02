time_it <- function(label, f) {
  t0 <- Sys.time()
  on.exit({
    dt <- difftime(Sys.time(), t0, units = "secs")
    log_msg(label, " took ", sprintf("%.1f", as.numeric(dt)), " s")
  }, add = TRUE)
  f()
}
