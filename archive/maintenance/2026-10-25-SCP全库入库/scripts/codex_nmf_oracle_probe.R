out<-'E:/research-wiki/维护记录/2026-10-25-SCP全库入库/native-oracles'
setwd(out)
SCP_LOCAL_ROOT<-'E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local'
options(SCP.local.root=SCP_LOCAL_ROOT);source(file.path(SCP_LOCAL_ROOT,'load_scp_local.R'))
x<-readRDS('real-counts-subset.rds')
f<-SCP_local[['RunNMF.default']]
cat('native entry class:',class(f),'NMF installed:',requireNamespace('NMF',quietly=TRUE),'\n')
r<-tryCatch(withCallingHandlers(base::do.call(f,list(object=x,assay='RNA',nbes=3,nmf.method='NMF',verbose=FALSE,seed.use=11)),error=function(e){
  heads<-vapply(sys.calls(),function(z)paste(deparse(z[[1]]),collapse=''),character(1))
  writeLines(c(conditionMessage(e),heads),file.path(out,'nmf-native-error-stack-heads.txt'))
}),error=function(e)e)
cat('native result:',if(inherits(r,'error'))conditionMessage(r) else class(r),'\n')
set.seed(11)
p<-tryCatch(NMF::nmf(x=t(x),rank=3),error=function(e)e)
cat('direct package result:',if(inherits(p,'error'))conditionMessage(p) else class(p),'\n')
if(!inherits(p,'error'))saveRDS(list(W=NMF::basis(p),H=NMF::coef(p)),'nmf-package-only.rds')
