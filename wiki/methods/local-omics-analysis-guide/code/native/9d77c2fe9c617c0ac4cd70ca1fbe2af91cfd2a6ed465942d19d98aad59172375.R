wf_pretty_breaks <- function(limits, n = 4, include_zero = TRUE) {
  limits <- as.numeric(limits)
  if (length(limits) != 2 || !all(is.finite(limits)) || diff(limits) <= 0) return(c(0, 1))
  brks <- pretty(limits, n = n)
  brks <- brks[is.finite(brks) & brks >= limits[1] & brks <= limits[2]]
  if (isTRUE(include_zero) && limits[1] >= 0) brks <- sort(unique(c(0, brks)))
  if (length(brks) < 3) brks <- seq(limits[1], limits[2], length.out = 4)
  unique(brks)
}
