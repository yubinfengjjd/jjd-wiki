"""Independent new-process invocation of manifest-only copied files."""
from pathlib import Path
import hashlib,json,os,shutil,subprocess,sys
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP续整理')
C=Path('E:/research-wiki-env/work/scp-ingestion-20261025/candidates/group-heatmap-dot')
sys.path.insert(0,'E:/research-wiki/开发/staged/research-wiki')
from rwiki.runtime_contract import runtime_facts
manifest=json.loads((C/'runtime.json').read_text(encoding='utf-8'))
facts=runtime_facts(C,manifest['id'],'template')
assert facts['portability']['state']=='verified',facts
dest=A/'codex-portable-final';assert not dest.exists(),'inspect previous run; do not overwrite evidence'
pkg=dest/'pkg';pkg.mkdir(parents=True)
for rel in ['runtime.json',*manifest['files']]:
    p=pkg/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(C/rel,p)
shutil.copytree(C/'example',dest/'input-default')
shutil.copytree(A/'codex-numeric-ids',dest/'input-numeric',ignore=shutil.ignore_patterns('out-*'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
env=os.environ.copy()
for key in list(env):
    if 'SCP_LOCAL' in key.upper() or key in ('R_PROFILE_USER','R_ENVIRON_USER','LC_ALL','LC_CTYPE','LANG'):env.pop(key,None)
env.update(PROCESSOR_ARCHITECTURE='AMD64',R_LIBS_USER='E:/research-wiki-env/R-lib-scp/4.5',TEMP='E:/research-wiki-env/tmp',TMP='E:/research-wiki-env/tmp')
results={}
for kind in ('default','numeric'):
    data=dest/f'input-{kind}';out=dest/f'output-{kind}'
    inputs={p.name:sha(p) for p in data.iterdir() if p.is_file()}
    cmd=['D:/R-4.5.0/bin/x64/Rscript.exe','--vanilla',str(pkg/manifest['entry']),'--data',str(data),'--out',str(out),'--style',str(dest/'input-default/style.json')]
    r=subprocess.run(cmd,cwd=dest,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=120)
    (dest/f'{kind}.log').write_text(r.stdout+'\n'+r.stderr,encoding='utf-8')
    assert r.returncode==0,(kind,r.returncode,r.stderr[-1000:])
    assert all((out/f'figure.{ext}').is_file() for ext in ('png','pdf','svg'))
    assert inputs=={p.name:sha(p) for p in data.iterdir() if p.is_file()}
    results[kind]={'command':cmd,'exit_code':r.returncode,'input_unchanged':True,'outputs':{p.name:sha(p) for p in out.iterdir() if p.is_file()}}
    if kind=='default':assert sha(out/'figure.png')==sha(A/'codex-native-reference/native-dot.png')
    else:
        svg=(out/'figure.svg').read_text(encoding='utf-8')
        assert '>001</text>' in svg and '>01</text>' in svg,'leading zero identities lost in SVG'
results['runtime_facts']=facts
(A/'codex-portable-final.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'new_process_runs':2,'input_unchanged':True,'default_png_equals_independent_native':True,'numeric_keys_preserved':True,'portability':facts['portability']},ensure_ascii=False))
