"""Independent native-trace/render comparisons on copied public closures."""
from pathlib import Path
import hashlib, json, os, subprocess, time
from PIL import Image, ImageChops, ImageStat

A=Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
B=Path('E:/research-wiki-env/work/scp-full-ingest-20261025')
stamp=time.strftime('%Y%m%dT%H%M%S',time.gmtime())
T=Path('E:/research-wiki-env/work')/('codex-scp-visual-probe-'+stamp)
T.mkdir(exist_ok=False)
index=json.loads((B/'coverage/modules-index.json').read_text(encoding='utf-8'))
report={'scope':'Independent copied public modules; original-native control comparison only, not scientific or author approval','snapshot':str(T),'modules':{}}
for fn in ['CellDimPlot3D','FeatureDimPlot3D','GraphPlot']:
    mid=next(r['module'] for r in index if r['entry']==fn)
    src=B/'coverage/modules'/mid
    raw=json.loads((src/'runtime.json').read_bytes()); spec=raw['implementations'][0]
    files={}
    for rel in spec['files']:
        target=(T/fn/rel).resolve()
        assert target.is_relative_to(T.resolve())
        target.parent.mkdir(parents=True,exist_ok=True)
        data=(src/rel).read_bytes();target.write_bytes(data)
        files[rel]=hashlib.sha256(data).hexdigest()
    report['modules'][fn]={'source_module':mid,'files':files}

driver=r'''
suppressPackageStartupMessages(library(jsonlite))
load('E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda')
before <- digest::digest(pancreas_sub,algo='sha256')
results <- list()
test <- function(n,expr) {
 results[[n]] <<- tryCatch({ force(expr); list(state='passed') },error=function(e)list(state='error',error=conditionMessage(e)))
}
fields <- c('x','y','z','type','mode','name','text','marker')
canonical <- function(traces)lapply(traces,function(t)t[intersect(fields,names(t))])
test('CellDimPlot3D_native_traces', {
 e <- new.env(parent=baseenv());source('CellDimPlot3D/code/module.R',local=e)
 p <- e$CellDimPlot3D(pancreas_sub,group.by='CellType',reduction='PCA',dims=1:3,width=900,height=650)
 actual <- plotly::plotly_build(p)$x$data
 ref <- readRDS('E:/research-wiki-env/work/codex-scp-native-3d/cell-traces.rds')
 eq <- all.equal(canonical(actual),canonical(ref),tolerance=1e-10,check.attributes=TRUE)
 if(!isTRUE(eq))stop(paste(eq,collapse='; '))
 saveRDS(actual,'cell-traces.rds')
 htmlwidgets::saveWidget(p,'cell.html',selfcontained=FALSE)
})
test('FeatureDimPlot3D_native_traces', {
 e <- new.env(parent=baseenv());source('FeatureDimPlot3D/code/module.R',local=e)
 p <- e$FeatureDimPlot3D(pancreas_sub,features='Neurog3',reduction='PCA',dims=1:3,width=900,height=650)
 actual <- plotly::plotly_build(p)$x$data
 ref <- readRDS('E:/research-wiki-env/work/codex-scp-native-3d/feature-traces.rds')
 eq <- all.equal(canonical(actual),canonical(ref),tolerance=1e-10,check.attributes=TRUE)
 if(!isTRUE(eq))stop(paste(eq,collapse='; '))
 saveRDS(actual,'feature-traces.rds')
 htmlwidgets::saveWidget(p,'feature.html',selfcontained=FALSE)
})
test('GraphPlot_real_graph_render', {
 e <- new.env(parent=baseenv());source('GraphPlot/code/module.R',local=e)
 x <- readRDS('E:/research-wiki-env/work/codex-scp-native-graph/graph-real-neighbours.rds')
 h <- digest::digest(x,algo='sha256')
 for(kind in c('straight','curved')) {
  p <- e$GraphPlot(node=x$node,edge=x$edge,node_group='group',edge_line=kind)
  ggplot2::ggsave(paste0('graph-',kind,'.png'),p,width=8,height=6,dpi=150,bg='white')
 }
 stopifnot(identical(h,digest::digest(x,algo='sha256')))
})
results$input_unchanged <- identical(before,digest::digest(pancreas_sub,algo='sha256'))
writeLines(toJSON(results,auto_unbox=TRUE,pretty=TRUE),'probe-result.json')
'''
(T/'driver.R').write_text(driver,encoding='utf-8')
env=os.environ.copy()
env.update(R_LIBS_USER='E:/research-wiki-env/R-lib-scp/4.5',TEMP='E:/research-wiki-env/tmp',TMP='E:/research-wiki-env/tmp',PROCESSOR_ARCHITECTURE='AMD64')
for key in ['R_HOME','R_ARCH','LANG','LC_ALL','LC_CTYPE']:env.pop(key,None)
p=subprocess.run(['D:/R-4.5.0/bin/x64/Rscript.exe','--vanilla','driver.R'],cwd=T,env=env,capture_output=True,encoding='utf-8',errors='replace',timeout=240)
(T/'probe.log').write_text(p.stdout+'\n'+p.stderr,encoding='utf-8')
report['exit']=p.returncode
if (T/'probe-result.json').is_file():report['results']=json.loads((T/'probe-result.json').read_text(encoding='utf-8'))
report['native_pixel_comparisons']={}
for kind in ['straight','curved']:
    actual=T/('graph-'+kind+'.png')
    original=Path('E:/research-wiki-env/work/codex-scp-native-graph')/actual.name
    if actual.is_file() and original.is_file():
        with Image.open(actual) as aa, Image.open(original) as bb:
            a,b=aa.convert('RGB'),bb.convert('RGB')
            result={'actual_size':a.size,'native_size':b.size,'same_size':a.size==b.size}
            if a.size==b.size:
                diff=ImageChops.difference(a,b)
                result.update(pixels_identical=diff.getbbox() is None,mean_abs_channel_difference=ImageStat.Stat(diff).mean)
            report['native_pixel_comparisons'][kind]=result
report['code_still_current']={fn:all((B/'coverage/modules'/r['source_module']/rel).is_file() and hashlib.sha256((B/'coverage/modules'/r['source_module']/rel).read_bytes()).hexdigest()==h for rel,h in r['files'].items()) for fn,r in report['modules'].items()}
out=A/('codex-visual-probe-'+stamp+'.json')
out.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'evidence':str(out),'results':report.get('results'),'native_pixel_comparisons':report['native_pixel_comparisons'],'code_still_current':report['code_still_current'],'exit':p.returncode},ensure_ascii=False))
