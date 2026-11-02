# SCP 0.5.6 commit b9b0eb7a | source R/utils.R:852-870
# sha256(func-block)=df63141491f4ef0ae3ddcf3a64faecf9453f300989ad08cdd00f9b8f6b1917c7
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
capitalize <- function(x, force_tolower = FALSE) {
  if (is.null(x)) {
    return(NULL)
  }
  if (inherits(x, "factor")) {
    x <- as.character(x)
  }
  if (!inherits(x, "character")) {
    stop("x must be the type of character.")
  }
  if (isTRUE(force_tolower)) {
    x <- paste(toupper(substr(x, 1, 1)), tolower(substr(x, 2, nchar(x))), sep = "")
  } else {
    first_word <- sapply(strsplit(x, "\\s|-"), function(s) s[1])
    index <- which(first_word == tolower(first_word))
    x[index] <- paste(toupper(substr(x[index], 1, 1)), substr(x[index], 2, nchar(x[index])), sep = "")
  }
  return(x)
}
