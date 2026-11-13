extract_scale_factors <- function(obj) {
  img_name <- names(obj@images)[[1]]
  img <- obj@images[[img_name]]
  sf <- tryCatch(img@scale.factors, error = function(e) NULL)
  spot_val <- if (!is.null(sf) && "spot" %in% names(sf)) as.numeric(sf$spot[[1]]) else NA_real_
  tibble(
    image_name = img_name,
    image_class = class(img)[[1]],
    spot = spot_val,
    spot_diameter = spot_val,
    fiducial = if (!is.null(sf) && "fiducial" %in% names(sf)) as.numeric(sf$fiducial[[1]]) else NA_real_,
    hires = if (!is.null(sf) && "hires" %in% names(sf)) as.numeric(sf$hires[[1]]) else NA_real_,
    lowres = if (!is.null(sf) && "lowres" %in% names(sf)) as.numeric(sf$lowres[[1]]) else NA_real_
  )
}
