"""Independent, read-only module snapshot and real isolated R review probe."""
from pathlib import Path
import hashlib, json, os, shutil, subprocess, sys, time

A = Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
B = Path('E:/research-wiki-env/work/scp-full-ingest-20261025')
stamp = time.strftime('%Y%m%dT%H%M%S', time.gmtime())
T = Path('E:/research-wiki-env/work') / ('codex-scp-full-probe-' + stamp)
T.mkdir(exist_ok=False)
sys.path.insert(0, str(B / 'development/staged/research-wiki'))
from rwiki import runtime_contract as rc

summary = {'scope': 'in-progress independently copied modules; not final acceptance', 'copied_to':str(T), 'manifests': {}}
index = json.loads((B/'coverage/modules-index.json').read_text(encoding='utf-8'))
for row in index:
    asset = B/'coverage/modules'/row['module']
    if not (asset/'runtime.json').is_file():
        continue
    raw = json.loads((asset/'runtime.json').read_text(encoding='utf-8'))
    manifest, issues = rc.read_manifest(asset, raw['id'], 'method')
    summary['manifests'][asset.name] = {'valid': manifest is not None, 'issues': issues}
for name in ['RunMDS', 'RunNMF']:
    src = B/'coverage/modules'/next(row['module'] for row in index if row['entry']==name)
    dst = T/name
    dst.mkdir(exist_ok=True)
    raw = json.loads((src/'runtime.json').read_text(encoding='utf-8'))
    paths = raw['implementations'][0]['files']
    hashes = {}
    for rel in paths:
        (dst/rel).parent.mkdir(parents=True, exist_ok=True)
        data = (src/rel).read_bytes()
        (dst/rel).write_bytes(data)
        hashes[rel] = hashlib.sha256(data).hexdigest()
    (dst/'runtime.json').write_text(json.dumps(raw, ensure_ascii=False, indent=2),encoding='utf-8')
    summary[name] = {'files': hashes}

driver = r'''
suppressPackageStartupMessages(library(jsonlite))
x <- readRDS(INPUT)
before <- digest::digest(x, algo="sha256")
env <- new.env(parent=baseenv())
res <- list()
search_before <- search()
options_before <- options()
try_record <- function(name, expr) {
  res[[name]] <<- tryCatch({ force(expr); list(state="passed") },
                          error=function(e) list(state="error", error=conditionMessage(e)))
}
try_record("nested_source_MDS", {
  source("RunMDS/code/module.R", local=env)
  y <- env$RunMDS(x, assay="RNA", nmds=3, verbose=FALSE)
  oracle <- readRDS(MDSORACLE)
  canon <- function(m)sweep(m,2,sign(apply(m,2,function(v)v[which.max(abs(v))])),`*`)
  stopifnot(isTRUE(all.equal(canon(y@cell.embeddings),canon(oracle$embeddings),tolerance=1e-6,check.attributes=FALSE)))
  saveRDS(y,"public-mds.rds")
})
try_record("direct_default_MDS", {
  # Source text directly so the outer-source path bug does not hide other issues.
  source("RunMDS/code/module.R", local=env, chdir=FALSE)
  f <- attr(env$RunMDS, "scp_module_env")$RunMDS.default
  y <- f(x, assay="RNA", nmds=3, verbose=FALSE)
})
try_record("nested_project_driver", source("nested.R", local=env))
try_record("public_NMF", {
  source("RunNMF/code/module.R", local=env)
  z <- env$RunNMF(x, assay="RNA", nbes=3, nmf.method="NMF", verbose=FALSE, seed.use=11)
  oracle <- readRDS(NMFORACLE)
  stopifnot(isTRUE(all.equal(z@cell.embeddings,oracle$embeddings,tolerance=1e-5,check.attributes=FALSE)))
  stopifnot(isTRUE(all.equal(z@feature.loadings,oracle$loadings,tolerance=1e-5,check.attributes=FALSE)))
  saveRDS(z,"public-nmf.rds")
})
try_record("MDS_after_loading_NMF", {
  y2 <- env$RunMDS(x,assay="RNA",nmds=3,verbose=FALSE)
  stopifnot(identical(y2@cell.embeddings,y@cell.embeddings))
})
res$input_unchanged <- identical(before, digest::digest(x, algo="sha256"))
res$search_unchanged <- identical(search_before,search())
res$search_added <- setdiff(search(),search_before)
res$search_removed <- setdiff(search_before,search())
res$options_added <- setdiff(names(options()),names(options_before))
res$options_existing_changed <- intersect(names(options_before),names(options()))[!vapply(intersect(names(options_before),names(options())),function(n)identical(options_before[[n]],getOption(n)),TRUE)]
res$changed_options <- names(options())[!vapply(names(options()),function(n)identical(options_before[[n]],getOption(n)),TRUE)]
writeLines(toJSON(res, auto_unbox=TRUE, pretty=TRUE), "probe-result.json")
'''
for token,path in [('INPUT',A/'native-oracles/real-counts-subset.rds'),('MDSORACLE',A/'native-oracles/mds-cmdscale-matrix.rds'),('NMFORACLE',A/'native-oracles/nmf-native-minimal.rds')]:
    driver=driver.replace(token,json.dumps(str(path).replace('\\','/'),ensure_ascii=False))
(T/'driver.R').write_text(driver, encoding='utf-8')
(T/'nested.R').write_text('source("RunMDS/code/module.R", local=environment())\n',encoding='utf-8')
env = os.environ.copy()
env.update(R_LIBS_USER='E:/research-wiki-env/R-lib-scp/4.5', TEMP='E:/research-wiki-env/tmp', TMP='E:/research-wiki-env/tmp', PROCESSOR_ARCHITECTURE='AMD64')
for name in ['R_HOME','R_ARCH','LANG','LC_ALL','LC_CTYPE']:
    env.pop(name, None)
p = subprocess.run(['D:/R-4.5.0/bin/x64/Rscript.exe','--vanilla','driver.R'],cwd=T,env=env, capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=180)
(T/'probe.log').write_text(p.stdout+'\n'+p.stderr,encoding='utf-8')
summary['r_exit_code'] = p.returncode
if (T/'probe-result.json').is_file():
    summary['real_calls'] = json.loads((T/'probe-result.json').read_text(encoding='utf-8'))
(A/f'codex-module-probe-{stamp}.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'manifests':len(summary['manifests']),'invalid':{k:v for k,v in summary['manifests'].items() if not v['valid']},'real_calls':summary.get('real_calls'),'exit':p.returncode},ensure_ascii=False))
