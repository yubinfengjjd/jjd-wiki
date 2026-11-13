# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:647-674
# sha256(func-block)=81058057bd7a84e5aa073b9d8156abace16961ede8f1ff9a231632014d270c6f
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
try_get <- function(expr, max_tries = 5, error_message = "", retry_message = "Retrying...") {
  out <- simpleError("start")
  ntry <- 0
  while (inherits(out, "error")) {
    ntry <- ntry + 1
    # print(paste0("ntry: ", ntry, collapse = ""))
    out <- tryCatch(
      expr = eval.parent(substitute(expr)),
      error = function(error) {
        message(error)
        message("")
        message(error_message)
        Sys.sleep(1)
        return(error)
      }
    )
    if (inherits(out, "error") && ntry >= max_tries) {
      stop(out)
    } else {
      if (!inherits(out, "error")) {
        break
      } else {
        message(retry_message)
      }
    }
  }
  return(out)
}
