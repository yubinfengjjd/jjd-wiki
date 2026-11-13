# Compare function syntax before any original-versus-wrapper execution.
args <- commandArgs(trailingOnly = TRUE)
config <- jsonlite::read_json(args[[1]], simplifyVector = FALSE)
extract_function <- function(path, name) {
  expressions <- parse(path, keep.source = FALSE)
  matches <- Filter(function(expression) {
    is.call(expression) && as.character(expression[[1]]) %in% c("<-", "=") &&
      length(expression) == 3L && is.symbol(expression[[2]]) &&
      identical(as.character(expression[[2]]), name) &&
      is.call(expression[[3]]) && identical(expression[[3]][[1]], as.name("function"))
  }, as.list(expressions))
  if (length(matches) != 1L) stop("Expected one function definition: ", name, " in ", path)
  eval(matches[[1]][[3]], envir = new.env(parent = baseenv()))
}
canonical <- function(fn) list(formals = paste(deparse(formals(fn), width.cutoff = 500L), collapse = "\n"),
                             body = paste(deparse(body(fn), width.cutoff = 500L), collapse = "\n"))
hash <- function(value) digest::digest(value, algo = "sha256", serialize = TRUE)
description <- utils::packageDescription("SCP")
package_identity <- list(version = as.character(utils::packageVersion("SCP")),
                         remote_sha = description$RemoteSha)
records <- lapply(config$comparisons, function(spec) {
  archive <- canonical(extract_function(spec$archive, spec$name))
  native <- canonical(extract_function(spec$native, spec$name))
  installed <- canonical(getFromNamespace(spec$name, "SCP"))
  list(name = spec$name, method = spec$method,
       archive_file_sha256 = digest::digest(spec$archive, algo = "sha256", file = TRUE),
       native_file_sha256 = digest::digest(spec$native, algo = "sha256", file = TRUE),
       archive_ast_sha256 = hash(archive), native_ast_sha256 = hash(native), installed_ast_sha256 = hash(installed),
       archive_native_identical = identical(archive, native), archive_installed_identical = identical(archive, installed),
       formals_identical = identical(archive$formals, installed$formals),
       archive = archive, installed = installed)
})
passed <- identical(package_identity$remote_sha, config$expected_commit) &&
  all(vapply(records, function(record) record$archive_native_identical && record$archive_installed_identical, logical(1)))
jsonlite::write_json(list(kind = "function-source-identity", passed = passed,
  package_identity = package_identity, expected_commit = config$expected_commit, functions = records,
  scope = "Function formals and bodies after R parsing/deparse; this is source identity, not algorithm validation."),
  config$output, auto_unbox = TRUE, pretty = TRUE, null = "null")
if (!passed) quit(status = 1L)
