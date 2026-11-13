required_pkgs <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    stop(
      paste0(
        "Missing required packages: ",
        paste(missing, collapse = ", "),
        "\nPlease install manually, e.g.: install.packages(c('",
        paste(missing, collapse = "','"),
        "')) or use renv."
      ),
      call. = FALSE
    )
  }
}
