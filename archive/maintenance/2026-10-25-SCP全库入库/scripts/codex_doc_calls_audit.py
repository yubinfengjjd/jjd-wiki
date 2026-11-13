"""Read-only compare documented named args against pinned source signatures."""
from pathlib import Path
import ast,json,os,subprocess,time
B=Path('E:/research-wiki-env/work/scp-full-ingest-20261025')
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
t=ast.parse((B/'scripts/fill-pages2.py').read_text(encoding='utf-8'))
calls=next(ast.literal_eval(n.value) for n in t.body if isinstance(n,ast.Assign) and any(isinstance(x,ast.Name) and x.id=='CALLS' for x in n.targets))
raw=json.loads((B/'coverage/fn-ast.json').read_text(encoding='utf-8'))
fns={name:d for funcs in raw.values() for name,d in funcs.items() if name!='__toplevel__'}
stamp=time.strftime('%Y%m%dT%H%M%S',time.gmtime())
source=A/('codex-doc-call-input-'+stamp+'.json')
parsed=A/('codex-doc-call-parsed-'+stamp+'.json')
source.write_text(json.dumps(calls,ensure_ascii=False),encoding='utf-8')
env=os.environ.copy()
env.update(R_LIBS_USER='E:/research-wiki-env/R-lib-scp/4.5',TEMP='E:/research-wiki-env/tmp',TMP='E:/research-wiki-env/tmp',PROCESSOR_ARCHITECTURE='AMD64')
for key in ['R_HOME','R_ARCH','LANG','LC_ALL','LC_CTYPE']:env.pop(key,None)
p0=subprocess.run(['D:/R-4.5.0/bin/x64/Rscript.exe','--vanilla',str(A/'scripts/codex_parse_doc_calls.R'),str(source),str(parsed)],capture_output=True,encoding='utf-8',errors='replace',timeout=30,env=env)
if p0.returncode:raise RuntimeError(p0.stderr)
parsed_calls=json.loads(parsed.read_text(encoding='utf-8'))
issues=[]
for fn,text in calls.items():
    signatures=[d.get('formals',{}) for name,d in fns.items() if name==fn or name.startswith(fn+'.')]
    allowed=set().union(*(set(x) for x in signatures)) if signatures else set()
    r=parsed_calls[fn]
    if 'parse_error' in r:
        issues.append({'function':fn,'example':text,'parse_error':r['parse_error']});continue
    named=set(r.get('named_args') or [])
    unknown=sorted(named-allowed)
    if unknown:issues.append({'function':fn,'example':text,'unknown_named_args':unknown,'has_dots':any('...' in x for x in signatures),'source_formals_union':sorted(allowed)})
p=A/('codex-doc-calls-'+stamp+'.json')
p.write_text(json.dumps({'scope':'static named-argument review; ... may explicitly forward valid backend args, which requires actual evidence, not blanket rejection','issues':issues},ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'evidence':str(p),'calls':len(calls),'issues':[{'function':i['function'],'unknown_named_args':i.get('unknown_named_args'),'has_dots':i.get('has_dots'),'parse_error':i.get('parse_error')} for i in issues]},ensure_ascii=False))
