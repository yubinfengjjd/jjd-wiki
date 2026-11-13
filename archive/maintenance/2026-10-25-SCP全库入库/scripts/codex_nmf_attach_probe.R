out<-'E:/research-wiki/维护记录/2026-10-25-SCP全库入库/native-oracles'
setwd(out);x<-readRDS('real-counts-subset.rds')
run<-function(){set.seed(11);tryCatch({fit<-NMF::nmf(t(x),rank=3);list(ok=TRUE,class=class(fit))},error=function(e)list(ok=FALSE,error=conditionMessage(e)))}
a<-run()
suppressPackageStartupMessages(library(NMF))
b<-run()
jsonlite::write_json(list(namespace_only=a,after_library=b),file.path(out,'nmf-attachment-probe.json'),auto_unbox=TRUE,pretty=TRUE)
cat(jsonlite::toJSON(list(namespace_only=a,after_library=b),auto_unbox=TRUE),'\n')
