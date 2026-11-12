verify_de_session <- function(code_dir, fixture, reference_result, report) {
  code_dir <- normalizePath(code_dir, mustWork=TRUE)
  e <- new.env(parent=globalenv())
  source(file.path(code_dir, 'analysis.R'), local=e)
  data <- new.env()
  load(fixture, envir=data)
  srt <- Seurat::NormalizeData(data$pancreas_sub, verbose=FALSE)
  future::plan('sequential')
  params <- list(group_by='CellType', group1='Ductal', group2='Endocrine',
    test.use='wilcox', only.pos=FALSE, fc.threshold=1, min.pct=.1,
    p.adjust.method='bonferroni', slot='data', assay='RNA', verbose=FALSE,
    BPPARAM=BiocParallel::SerialParam(), seed=11)
  before <- list(options=options(), search=search(), libs=.libPaths(),
                 input=serialize(srt,NULL), rng=.Random.seed)
  temp_before <- list.files(tempdir(), pattern='^rwiki-de-')
  one <- e$run_differential_expression(srt, parameters=params)
  two <- e$run_differential_expression(srt, parameters=params)
  reference <- readRDS(reference_result)
  error <- tryCatch({e$run_differential_expression(srt, parameters=list(group_by='missing_group')); NULL},
                    error=function(e)conditionMessage(e))
  checks <- list(two_actual_calls=TRUE,
    results_identical=identical(one$result,two$result),
    original_de_tools_identical=identical(one$result@tools,reference@tools),
    all_options_unchanged=identical(options(),before$options),
    search_unchanged=identical(search(),before$search),
    libpaths_unchanged=identical(.libPaths(),before$libs),
    input_unchanged=identical(serialize(srt,NULL),before$input),
    rng_unchanged=identical(.Random.seed,before$rng),
    worker_error_propagated=is.character(error) && grepl('Isolated DE worker failed',error,fixed=TRUE),
    temp_cleanup=identical(list.files(tempdir(),pattern='^rwiki-de-'),temp_before),
    reported_restoration=isTRUE(one$diagnostics$options_restored) && isTRUE(two$diagnostics$options_restored) &&
      isTRUE(one$diagnostics$search_restored) && isTRUE(two$diagnostics$search_restored))
  files <- setNames(lapply(c('analysis.R','de_native.R'),function(n)
    digest::digest(file.path(code_dir,n),algo='sha256',file=TRUE)),
    c('code/analysis.R','code/de_native.R'))
  record <- list(schema_version=1,implementation='scp-detest',
    state=if(all(unlist(checks))) 'passed' else 'failed',
    scope='Public pancreas Wilcoxon case: two actual isolated calls in one parent session, exact original DE tools output, error propagation and caller-state invariance; other test backends not run.',
    command='Rscript --vanilla -e source(session_regression.R); verify_de_session(code_dir, public_fixture, original_result, report)',
    checks=checks, environment=list(R=R.version.string,platform=R.version$platform),
    files=files,executed_files=files,error_case=error,
    process_isolation=TRUE,
    fixture_sha256=digest::digest(fixture,algo='sha256',file=TRUE),
    original_result_sha256=digest::digest(reference_result,algo='sha256',file=TRUE),
    oracle_note='DE tools are compared exactly. Whole Seurat objects from independently normalized inputs differ in NormalizeData time.stamp; two calls on the same input are still compared as whole objects.',
    execution_time_utc=format(Sys.time(),tz='UTC',usetz=TRUE))
  jsonlite::write_json(record,report,pretty=TRUE,auto_unbox=TRUE)
  print(checks)
  stopifnot(all(unlist(checks)))
  invisible(record)
}
