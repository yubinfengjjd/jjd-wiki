wf_pdf_info_safe <- function(path) if (requireNamespace("pdftools", quietly = TRUE) && file.exists(path)) tryCatch(pdftools::pdf_info(path), error = function(e) NULL) else NULL
