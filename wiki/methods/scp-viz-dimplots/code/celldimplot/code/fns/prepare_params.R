# SCP 0.5.6 commit b9b0eb7a | source R/ggsankey.R:8-34
# sha256(func-block)=4a2cd158aa2e214b6dde3168433812b53e91b70cb3dac3e38cc2c31c466b9897
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
prepare_params <- function(...) {
  # Prepare aesthics for flow lines
  flow.aes <- list(...)
  removes <- names(flow.aes) %>%
    stringr::str_extract_all(., "(?<=flow.).*") %>%
    unlist()
  removes2 <- names(flow.aes) %>%
    stringr::str_subset(., "node") %>%
    unlist()
  flow.aes[c(removes, removes2)] <- NULL
  names(flow.aes) <- names(flow.aes) %>%
    stringr::str_replace_all("flow.", "")

  # Prepare aesthics for node boxes
  node.aes <- list(...)
  removes <- names(node.aes) %>%
    stringr::str_extract_all(., "(?<=node.).*") %>%
    unlist()
  removes2 <- names(node.aes) %>%
    stringr::str_subset(., "flow") %>%
    unlist()
  node.aes[c(removes, removes2)] <- NULL
  names(node.aes) <- names(node.aes) %>%
    stringr::str_replace_all(., "node.", "")

  return(list(flow.aes, node.aes))
}
