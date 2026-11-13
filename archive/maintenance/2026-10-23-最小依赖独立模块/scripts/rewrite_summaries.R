files <- list.files('portability', pattern='^result[.]rds$', recursive=TRUE, full.names=TRUE)
for (f in files) {
  x <- readRDS(f)
  jsonlite::write_json(list(method=x$method, state=x$state, error=x$error,
                            input_unchanged=x$input_unchanged),
                       sub('[.]rds$', '.json', f), auto_unbox=TRUE, pretty=TRUE)
}
cat('rewrote', length(files), '\n')
