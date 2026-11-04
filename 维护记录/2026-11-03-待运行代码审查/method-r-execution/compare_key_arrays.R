args <- commandArgs(trailingOnly = TRUE)
left <- readRDS(args[[1]])
right <- readRDS(args[[2]])
comparison <- all.equal(left, right, tolerance = 1e-12, check.attributes = TRUE)
jsonlite::write_json(list(matched = isTRUE(comparison), exact_identical = identical(left, right),
  tolerance = 1e-12, comparison = comparison, scope = "Actual metadata arrays, cell ordering and attributes; no automatic receipt promotion."),
  args[[3]], auto_unbox = TRUE, pretty = TRUE, null = "null", digits = NA)
if (!isTRUE(comparison)) quit(status = 1L)
