# Independent caller-side portability probe, not algorithm/visual validation.
args <- commandArgs(trailingOnly=TRUE)
root <- normalizePath(args[1],winslash="/",mustWork=TRUE)
code_dir <- file.path(root,"code")
target_env <- new.env(parent=.GlobalEnv)
before <- ls(.GlobalEnv,all.names=TRUE)
result <- tryCatch({source(file.path(root,"nested","driver.R"));list(ok=TRUE)},
 error=function(e)list(ok=FALSE,error=conditionMessage(e)))
result$global_additions <- setdiff(ls(.GlobalEnv,all.names=TRUE),c(before,"result"))
cat(jsonlite::toJSON(result,auto_unbox=TRUE,pretty=TRUE),"\n")
if(!isTRUE(result$ok))quit(status=1)
