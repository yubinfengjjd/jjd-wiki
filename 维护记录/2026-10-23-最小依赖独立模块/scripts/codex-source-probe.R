record <- 'E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块'
args <- commandArgs(trailingOnly=TRUE)
module <- if(length(args)) args[1] else file.path(record, 'pilot/cellqc/code/analysis.R')
project <- file.path(record, 'codex-probes/project')
dir.create(project, recursive=TRUE, showWarnings=FALSE)
env <- new.env(parent=globalenv())
source(module, local=env)
cat('direct_source=PASS\n')
driver <- file.path(project, 'driver.R')
writeLines(sprintf('source(%s, local=TRUE)', deparse(module)),driver,useBytes=TRUE)
answer <- tryCatch({source(driver, local=new.env(parent=globalenv())); 'PASS'},
  error=function(e) paste('FAIL:',conditionMessage(e)))
cat('nested_project_source=',answer,'\n',sep='')
if(answer!='PASS') quit(status=1)
