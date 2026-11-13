safe_capture <- function(expr, default = NULL, label = "step") {
  tryCatch(expr, error = function(e) {
    log_message("%s failed: %s", label, conditionMessage(e))
    default
  })
}
