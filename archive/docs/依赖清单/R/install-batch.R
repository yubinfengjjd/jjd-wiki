# Batch dependency preparation only. No scientific code or workflow is executed.
if (.Platform$OS.type == "windows") invisible(Sys.setlocale("LC_CTYPE", "English_United States.utf8"))
args <- commandArgs(trailingOnly = TRUE)
value <- function(flag, default = NULL) {
  at <- match(flag, args)
  if (is.na(at)) return(default)
  if (at == length(args) || startsWith(args[at + 1L], "--")) stop("Missing value: ", flag)
  args[at + 1L]
}
if ("--help" %in% args) {
  cat("Rscript install-batch.R --lib <Wiki-only library> [--profile runtime|pending|all]",
      "[--report <directory>] [--install] [--bioc 3.21]\n",
      "Default: presence check only. --install explicitly installs the selected batch.\n")
  quit(status = 0)
}
lib <- value("--lib")
if (is.null(lib)) stop("--lib must identify a dedicated Wiki library; system libraries are never a default")
profile <- match.arg(value("--profile", "runtime"), c("runtime", "pending", "all"))
bioc <- value("--bioc", "3.21")
install <- "--install" %in% args
full_args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", full_args[startsWith(full_args, "--file=")][1L])
base_dir <- dirname(normalizePath(script, winslash = "/", mustWork = TRUE))
plan <- read.delim(file.path(base_dir, "plan.tsv"), stringsAsFactors = FALSE,
                   check.names = FALSE, fileEncoding = "UTF-8", comment.char = "", na.strings = NULL)
if (profile != "all") plan <- plan[as.character(plan[[profile]]) == "1", , drop = FALSE]
if (install && paste(R.version$major, strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1], sep = ".") != "4.5") {
  stop("Use R 4.5.x for this Bioconductor baseline; select a separate compatible profile for another R version")
}
if (install) dir.create(lib, recursive = TRUE, showWarnings = FALSE)
if (dir.exists(lib)) .libPaths(c(normalizePath(lib, winslash = "/"), .libPaths()))
installed <- function(name) nzchar(system.file(package = name))
source_matches <- function(row) {
  if (!installed(row$package)) return(FALSE)
  if (!(row$installer %in% c("github", "archive"))) return(TRUE)
  if (as.character(packageVersion(row$package)) != row$catalog_version) return(FALSE)
  if (row$installer == "archive") return(TRUE)
  actual <- packageDescription(row$package, fields = "RemoteSha")
  expected <- sub("^.*@", "", row$spec)
  is.character(actual) && length(actual) == 1L && !is.na(actual) && identical(unname(tolower(actual)), unname(tolower(expected)))
}
errors <- character()
attempt <- function(label, operation) {
  tryCatch(operation(), error = function(e) {
    errors[label] <<- conditionMessage(e)
    message("Failed (continuing batch): ", label, ": ", conditionMessage(e))
  })
}
if (install) {
  options(repos = c(CRAN = "https://cloud.r-project.org"))
  for (package in c("BiocManager", "remotes")) {
    if (!installed(package)) attempt(package, function() install.packages(package, lib = lib))
  }
  if (!installed("BiocManager") || !installed("remotes")) stop("Batch bootstrap failed; scientific installation did not start")
  attempt("Bioconductor", function() BiocManager::install(version = bioc, lib = lib, ask = FALSE, update = FALSE))
  if (as.character(BiocManager::version()) != bioc) stop("Bioconductor baseline mismatch; keep libraries separate")
  options(repos = BiocManager::repositories(version = bioc))
  regular <- plan$package[plan$installer == "repository"]
  regular <- regular[!vapply(regular, installed, logical(1))]
  if (length(regular)) attempt("repository batch", function() {
    BiocManager::install(regular, lib = lib, ask = FALSE, update = FALSE, dependencies = NA)
  })
  special <- plan[plan$installer %in% c("github", "archive"), , drop = FALSE]
  # Install special-source providers before their consumers (e.g. thisutils -> thisplot -> scop).
  while (nrow(special)) {
    ready <- which(vapply(special$depends_on, function(x) {
      !length(intersect(strsplit(x, ",", fixed = TRUE)[[1]], special$package))
    }, logical(1)))
    if (!length(ready)) ready <- 1L
    for (i in ready) {
      row <- special[i, ]
      if (source_matches(row)) next
      attempt(row$package, function() {
        if (row$installer == "github") {
          remotes::install_github(row$spec, lib = lib, dependencies = NA, upgrade = "never", build_vignettes = FALSE)
        } else {
          remotes::install_url(row$spec, lib = lib, dependencies = NA, upgrade = "never", build_vignettes = FALSE)
        }
      })
    }
    special <- special[-ready, , drop = FALSE]
  }
}
present <- vapply(plan$package, installed, logical(1))
matching <- vapply(seq_len(nrow(plan)), function(i) source_matches(plan[i, ]), logical(1))
versions <- vapply(plan$package, function(name) if (installed(name)) as.character(packageVersion(name)) else "", "")
report <- data.frame(package = plan$package, present = present, source_match = matching, version = versions,
                     installer = plan$installer, source_version = plan$catalog_version,
                     state = ifelse(present, ifelse(matching, "present-not-runtime-validated", "present-source-mismatch"), ifelse(plan$installer == "unresolved", "source-unresolved", "missing")),
                     stringsAsFactors = FALSE)
report_dir <- value("--report", file.path(dirname(lib), "dependency-reports"))
dir.create(report_dir, recursive = TRUE, showWarnings = FALSE)
write.table(report, file.path(report_dir, paste0("R-", profile, ".tsv")), sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
if (install) writeLines(paste(names(errors), errors, sep = "\t"), file.path(report_dir, "R-install-errors.txt"))
cat("Selected:", nrow(plan), "Present:", sum(present), "Missing:", sum(!present),
    "Unresolved sources:", sum(!present & plan$installer == "unresolved"), "\n")
cat("Report:", report_dir, "\nPresence does not establish namespace load or scientific validation.\n")
quit(status = if (all(present) && all(matching) && !length(errors)) 0L else 2L)
