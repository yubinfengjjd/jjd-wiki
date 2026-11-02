# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:70-108
# sha256(func-block)=083daa7eadfcf90ff2dd13b7afcef4a47187ab05adf2bf145613fa28fc550104
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
make_long <- function(.df, ..., value = NULL) {
  if ("..r" %in% names(.df)) stop("The column name '..r' is not allowed")
  .vars <- dplyr::quos(...)

  if (!missing(value)) {
    value_var <- dplyr::enquo(value)
    out <- .df %>%
      dplyr::select(!!!.vars, value = !!value_var) %>%
      dplyr::mutate(..r = dplyr::row_number()) %>%
      tidyr::gather(x, node, -..r, -value) %>%
      dplyr::arrange(.data$..r) %>%
      dplyr::group_by(.data$..r) %>%
      dplyr::mutate(
        next_x = dplyr::lead(.data$x),
        next_node = dplyr::lead(.data$node)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(-..r) %>%
      dplyr::relocate(value, .after = dplyr::last_col())
  } else {
    out <- .df %>%
      dplyr::select(!!!.vars) %>%
      dplyr::mutate(..r = dplyr::row_number()) %>%
      tidyr::gather(x, node, -..r) %>%
      dplyr::arrange(.data$..r) %>%
      dplyr::group_by(.data$..r) %>%
      dplyr::mutate(
        next_x = dplyr::lead(.data$x),
        next_node = dplyr::lead(.data$node)
      ) %>%
      dplyr::ungroup() %>%
      dplyr::select(-..r)
  }

  levels <- unique(out$x)

  out %>%
    dplyr::mutate(dplyr::across(c(x, next_x), ~ factor(., levels = levels)))
}
