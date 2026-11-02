# Presence only. These names were misreported by old notes or are selected indirectly.
pkgs <- c('sva','GSVA','MAST','DESeq2','largeVis','uwot','MASS','RcppML')
inst <- installed.packages(); out <- list(scope='installed metadata only; not algorithm/load validation',packages=list())
for(p in pkgs) {
 i <- which(inst[,'Package']==p)
 out$packages[[p]]<-if(length(i))list(present=TRUE,version=unname(inst[i[1],'Version']),library=unname(inst[i[1],'LibPath']))else list(present=FALSE)
}
jsonlite::write_json(out,'E:/research-wiki/维护记录/2026-10-25-SCP全库入库/codex-r-additional-presence.json',auto_unbox=TRUE,pretty=TRUE)
cat(jsonlite::toJSON(out,auto_unbox=TRUE),'\n')
