args <- commandArgs(TRUE)
cand <- args[[1]]
out <- args[[2]]
dir.create(out, recursive=TRUE, showWarnings=FALSE)
local({
  tests <- list()
  check <- function(name, value) {
    tests[[name]] <<- isTRUE(value)
    cat(if(isTRUE(value)) 'PASS' else 'FAIL', name, '\n')
  }
  e <- new.env()
  globals_before <- ls(.GlobalEnv, all.names=TRUE)
  nested <- function() source(file.path(cand,'code/core.R'), local=e)
  nested()
  check('nested_source_no_global_helpers',identical(globals_before,ls(.GlobalEnv,all.names=TRUE)))
  check('public_exports_only',setequal(ls(e),c('ghdot_build_matrices','ghdot_plot_panel','plot_scp_group_heatmap_dot')))
  df <- read.csv(file.path(cand,'example/render-group-heatmap.csv'),check.names=FALSE)
  before <- serialize(df,NULL)
  built <- e$ghdot_build_matrices(df,list())
  reference <- readRDS('E:/research-wiki/维护记录/2026-10-25-SCP续整理/codex-native-reference/captured-dot.rds')
  strip <- function(x) {attr(x,'scaled:center')<-NULL;attr(x,'scaled:scale')<-NULL;x}
  check('value_equals_independently_rerun_upstream',identical(strip(built$matrices$CellType),strip(reference$mat_list$CellType)))
  check('percent_equals_independently_rerun_upstream',identical(built$percent$CellType,reference$mat_perc_list$CellType))
  p1 <- e$ghdot_plot_panel(list(heatmap=df),list(add_dot=TRUE))
  p2 <- e$ghdot_plot_panel(list(heatmap=df),list(add_dot=TRUE))
  check('repeat_calls_return_native_objects',inherits(p1$plot,'patchwork')&&inherits(p2$plot,'patchwork'))
  check('input_unchanged',identical(before,serialize(df,NULL)))
  rejects <- function(name,x) {
    value<-tryCatch({e$ghdot_build_matrices(x,list());FALSE},error=function(err)TRUE)
    check(name,value)
  }
  x<-df;x$value<-factor(x$value);rejects('factor_value_refused',x)
  x<-df;x$percent<-factor(x$percent);rejects('factor_percent_refused',x)
  x<-df;x$feature_order[x$feature==x$feature[1]]<-NA_real_;rejects('missing_order_refused',x)
  x<-df;x$matrix_order<-Inf;rejects('infinite_order_refused',x)
  x<-df;x$feature_order<-x$feature_order/10;rejects('fractional_order_refused',x)
  x<-df;x$feature_order<-x$feature_order-20;rejects('negative_order_refused',x)
  x<-df;x$feature_order[x$feature==unique(x$feature)[2]]<-x$feature_order[1];rejects('ambiguous_order_refused',x)
  x<-rbind(df,df[1,]);rejects('duplicate_joint_key_refused',x)
  x<-df;x$percent[1]<-75;rejects('percent_0to100_refused',x)
  x<-df;x$group[x$group==unique(x$group)[1]]<-"Patient's ductal cells"
  q<-tryCatch(e$ghdot_plot_panel(list(heatmap=x),list(add_dot=TRUE)),error=function(err)err)
  check('apostrophe_label_literal',!inherits(q,'error'))
  if(inherits(q,'error'))cat('QUOTE ERROR:',conditionMessage(q),'\n')
  jsonlite::write_json(tests,file.path(out,'checks.json'),auto_unbox=TRUE,pretty=TRUE)
  cat('TOTAL',length(tests),'FAILED',sum(!unlist(tests)),'\n')
  if(!all(unlist(tests)))quit(status=1)
})
