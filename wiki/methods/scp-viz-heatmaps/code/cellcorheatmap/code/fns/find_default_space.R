# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:36-46
# sha256(func-block)=02d743e28a1cf97cdbeaa12a1c659b30af751926c8db73951c65e541dc16cf61
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
find_default_space <- function(.df) {
  .df %>%
    dplyr::group_by(.data$n_x) %>%
    dplyr::reframe(
      n_groups = dplyr::n_distinct(.data$node),
      freq = sum(.data$freq, na.rm = TRUE)
    ) %>%
    dplyr::mutate(v = .data$freq / .data$n_groups / 4) %>%
    dplyr::pull(.data$v) %>%
    max()
}
