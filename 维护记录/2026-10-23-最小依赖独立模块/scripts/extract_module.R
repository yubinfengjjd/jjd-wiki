# Extract a verbatim SCP function closure into a standalone R module file.
# Usage: Rscript extract_module.R <scp_source_dir> <roots_csv> <out_file> <closure_json>
# - only top-level `name <- function` definitions are extracted
# - function text is copied verbatim from the pinned source (srcref)
# - S3 methods of selected generics are included
# - dynamic dispatch targets can be supplied with +name in roots
args <- commandArgs(trailingOnly = TRUE)
src <- normalizePath(args[1], mustWork = TRUE)
roots_arg <- args[2]
out <- args[3]
closure_out <- args[4]
exclude <- if (length(args) >= 5 && nzchar(args[5])) trimws(strsplit(args[5], ",")[[1]]) else character()

files <- sort(list.files(file.path(src, "R"), pattern = "[.]R$", full.names = TRUE))
defs <- list()
for (f in files) {
  ex <- tryCatch(parse(f, keep.source = TRUE), error = function(e) NULL)
  if (is.null(ex)) next
  lines <- readLines(f, warn = FALSE, encoding = "UTF-8")
  refs <- attr(ex, "srcref")
  for (i in seq_along(ex)) {
    e <- ex[[i]]
    if (!is.call(e) || !is.symbol(e[[1]]) || !as.character(e[[1]]) %in% c("<-", "=")) next
    if (!is.name(e[[2]])) next
    rhs <- e[[3]]
    if (!is.call(rhs) || !is.symbol(rhs[[1]]) || as.character(rhs[[1]]) != "function") next
    nm <- as.character(e[[2]])
    ref <- if (!is.null(refs)) refs[[i]] else NULL
    if (is.null(ref)) next
    from <- as.integer(ref[1]); to <- as.integer(ref[3])
    text <- paste(lines[from:to], collapse = "\n")
    # Standalone compatibility only: the palette data is loaded into the
    # module environment, so the namespace-qualified reference is replaced
    # with the same local object. No data or plotting logic changes.
    text <- gsub("SCP::palette_list", "palette_list", text, fixed = TRUE)
    defs[[nm]] <- list(name = nm, file = basename(f), from = from, to = to, text = text)
  }
}

roots <- trimws(strsplit(roots_arg, ",")[[1]])
roots <- roots[nzchar(roots)]
explicit <- sub("^[+]", "", roots[startsWith(roots, "+")])
roots <- sub("^[+]", "", roots)

# environment holding parsed functions for codetools (bodies only, never evaluated)
env <- new.env(parent = globalenv())
for (nm in names(defs)) {
  tryCatch(eval(parse(text = defs[[nm]]$text)[[1]], envir = env), error = function(e) NULL)
}
defined <- ls(env)

is_generic <- function(nm) {
  fn <- get(nm, envir = env)
  any(grepl("UseMethod", deparse(body(fn)), fixed = TRUE))
}
methods_of <- function(nm) {
  defined[startsWith(defined, paste0(nm, ".")) & !grepl("[.]<-$", defined)]
}

queue <- unique(c(roots, explicit))
seen <- character()
for (nm in roots) if (nm %in% defined && is_generic(nm)) queue <- c(queue, methods_of(nm))
repeat {
  cur <- queue[queue %in% defined & !queue %in% seen]
  if (!length(cur)) break
  nm <- cur[1]; seen <- c(seen, nm)
  fn <- get(nm, envir = env)
  g <- tryCatch(codetools::findGlobals(fn, merge = FALSE), error = function(e) list(functions = character()))
  inner <- intersect(g$functions, defined)
  queue <- unique(c(queue, inner))
  if (is_generic(nm)) queue <- unique(c(queue, methods_of(nm)))
}
missing <- setdiff(unique(c(roots, explicit)), seen)
if (length(missing)) stop("unknown roots: ", paste(missing, collapse = ", "))

sel <- defs[names(defs) %in% setdiff(seen, exclude)]
ord <- order(vapply(sel, function(d) d$file, ""), vapply(sel, function(d) d$from, 0L))
sel <- sel[ord]

hdr <- c(
  "# Minimal runtime module extracted verbatim from SCP-local 0.5.6 (GPL (>= 3)).",
  "# Source: https://github.com/zhanghao-njmu/SCP commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0",
  paste0("# Roots: ", paste(roots, collapse = ", ")),
  paste0("# Functions: ", paste(names(sel), collapse = ", ")),
  "# Function bodies are copied from the pinned source without algorithm changes.",
  "# Automatic installation is disabled by the caller. Local resources are loaded only by the caller.",
  ""
)
body <- unlist(lapply(sel, function(d) c(
  paste0("# ---- ", d$file, ":", d$from, "-", d$to, " : ", d$name, " ----"),
  d$text, "")))
writeLines(c(hdr, body), out, useBytes = TRUE)

json <- lapply(sel, function(d) list(name = d$name, file = d$file, from = d$from, to = d$to))
writeLines(jsonlite_like <- paste0(
  "{\n", paste(vapply(json, function(x) sprintf(
    '  {"name": "%s", "file": "%s", "from": %d, "to": %d}', x$name, x$file, x$from, x$to),
    ""), collapse = ",\n"), "\n}\n"), closure_out, useBytes = TRUE)
cat("wrote", out, "functions:", length(sel), "\n")
