"""Independent source-only closure audit. Does not certify algorithms or figures."""
from pathlib import Path
import concurrent.futures, hashlib, json, os, shutil, subprocess, time

A = Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
B = Path('E:/research-wiki-env/work/scp-full-ingest-20261025')
stamp = time.strftime('%Y%m%dT%H%M%S', time.gmtime())
dest = Path('E:/research-wiki-env/work') / ('codex-scp-load-' + stamp)
dest.mkdir(exist_ok=False)
index = json.loads((B/'coverage/modules-index.json').read_text(encoding='utf-8'))
env = os.environ.copy()
env.update(R_LIBS_USER='E:/research-wiki-env/R-lib-scp/4.5', TEMP='E:/research-wiki-env/tmp', TMP='E:/research-wiki-env/tmp', PROCESSOR_ARCHITECTURE='AMD64')
for k in ['R_HOME','R_ARCH','LANG','LC_ALL','LC_CTYPE']:
    env.pop(k, None)

DRIVER = r'''
suppressPackageStartupMessages(library(jsonlite))
spec <- fromJSON('spec.json', simplifyVector=FALSE)
ns0 <- loadedNamespaces(); s0 <- search(); o0 <- options()
e <- new.env(parent=baseenv())
r <- tryCatch({
  source(spec$entry, local=e)
  stopifnot(is.function(e[[spec$entry_function]]))
  list(state='loaded', exposed=ls(e, all.names=TRUE))
}, error=function(e) list(state='error', error=conditionMessage(e)))
r$namespaces_added <- setdiff(loadedNamespaces(),ns0)
r$search_unchanged <- identical(s0,search())
r$options_changed <- union(setdiff(names(options()),names(o0)),names(o0)[!vapply(names(o0),function(n) identical(o0[[n]],getOption(n)),TRUE)])
writeLines(toJSON(r,auto_unbox=TRUE,pretty=TRUE),'result.json')
'''

def one(row):
    mid = row['module']
    src = B/'coverage/modules'/mid
    dst = dest/mid
    dst.mkdir()
    result = {'module':mid, 'entry':row.get('entry'), 'scope':'source-only; no algorithm execution'}
    try:
        raw = (src/'runtime.json').read_bytes()
        spec = json.loads(raw)['implementations'][0]
        hashes = {}
        for rel in spec['files']:
            p = src/rel
            data = p.read_bytes()
            q = dst/rel; q.parent.mkdir(parents=True,exist_ok=True); q.write_bytes(data)
            hashes[rel] = hashlib.sha256(data).hexdigest()
        result['files'] = hashes
        result['manifest_sha256'] = hashlib.sha256(raw).hexdigest()
        (dst/'spec.json').write_text(json.dumps(spec),encoding='utf-8')
        (dst/'driver.R').write_text(DRIVER,encoding='utf-8')
        p = subprocess.run(['D:/R-4.5.0/bin/x64/Rscript.exe','--vanilla','driver.R'],cwd=dst,env=env,capture_output=True,encoding='utf-8',errors='replace',timeout=90)
        (dst/'load.log').write_text(p.stdout+'\n'+p.stderr,encoding='utf-8')
        result['exit'] = p.returncode
        result['result'] = json.loads((dst/'result.json').read_text(encoding='utf-8')) if (dst/'result.json').is_file() else {'state':'no_result'}
        result['snapshot_still_current'] = all((src/rel).is_file() and hashlib.sha256((src/rel).read_bytes()).hexdigest()==h for rel,h in hashes.items())
    except Exception as e:
        result['audit_error'] = str(e)
    return result

with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
    rows = list(pool.map(one,index))
report = {'scope':'independent per-module fresh-process source-only audit; not algorithm/visual/portability acceptance', 'snapshot':str(dest), 'modules':rows}
out = A/('codex-module-load-'+stamp+'.json')
out.write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
bad = [{'module':r['module'],'error':r.get('audit_error') or r.get('result')} for r in rows if r.get('result',{}).get('state')!='loaded']
print(json.dumps({'evidence':str(out),'modules':len(rows),'loaded':len(rows)-len(bad),'failures':bad,'source_side_effects':[r['module'] for r in rows if not r.get('result',{}).get('search_unchanged',True) or r.get('result',{}).get('options_changed')],'stale_snapshots':[r['module'] for r in rows if r.get('snapshot_still_current') is False]},ensure_ascii=False))
