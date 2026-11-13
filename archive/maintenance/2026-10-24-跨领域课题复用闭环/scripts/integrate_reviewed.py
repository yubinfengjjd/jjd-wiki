"""Guarded integration of a reviewed scratch delta; never stages/commits Git.

Prepare after all coding is finished; apply only after independent acceptance.
Every overwrite/removal has a saved original. File replacement is atomic, the
multi-file integration is inspectable/recoverable rather than crash-atomic.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
import subprocess

AUDIT=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
SOURCE=Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/development')
TARGET=Path('E:/research-wiki/开发')
PLAN=AUDIT/'reviewed-integration-plan.json'
SKIP={'.git','node_modules','__pycache__','.pytest_cache','.agents'}

def sha(p):
    if not p.is_file():return None
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1<<20),b''):h.update(b)
    return h.hexdigest()

def bounded(root,rel):
    p=root/rel
    if not p.resolve().is_relative_to(root.resolve()):
        raise RuntimeError('path escapes intended root: '+str(p))
    return p

def inventory():
    rows={}
    for component in ('staged/research-wiki','frontend'):
        for d,dirs,files in os.walk(SOURCE/component):
            dirs[:]=[x for x in dirs if x not in SKIP]
            for n in files:
                p=Path(d)/n
                if p.suffix not in ('.pyc','.pyo'):
                    rows[p.relative_to(SOURCE).as_posix()]=sha(p)
    return rows

def index_hash():
    r=subprocess.run(['git','-C',str(TARGET),'rev-parse','--git-path','index'],
                     check=True,capture_output=True,text=True)
    p=Path(r.stdout.strip())
    return sha(p if p.is_absolute() else TARGET/p)

def prepare():
    baseline=json.loads((AUDIT/'baseline.json').read_text(encoding='utf-8'))['development']
    now=inventory()
    changes=[]
    for rel in sorted(set(baseline)|set(now)):
        old,new=baseline.get(rel),now.get(rel)
        if old==new:continue
        if sha(bounded(TARGET,rel))!=old:
            raise RuntimeError('original changed since baseline; preserve and review: '+rel)
        if new is None and not rel.startswith('staged/research-wiki/app/'):
            raise RuntimeError('non-bundle removal needs explicit review: '+rel)
        changes.append({'path':rel,'old':old,'new':new})
    if PLAN.exists():raise RuntimeError('integration plan exists; preserve previous review')
    PLAN.write_text(json.dumps({'changes':changes,'index_before':index_hash()},
                              ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'prepared':len(changes),'plan':str(PLAN)},ensure_ascii=False))

def apply():
    plan=json.loads(PLAN.read_text(encoding='utf-8'))
    if index_hash()!=plan['index_before']:raise RuntimeError('Git index changed; stop for review')
    for row in plan['changes']:
        rel=row['path']
        if sha(bounded(TARGET,rel))!=row['old']:raise RuntimeError('target changed: '+rel)
        if sha(bounded(SOURCE,rel))!=row['new']:raise RuntimeError('reviewed source changed: '+rel)
    journal=[]
    for row in plan['changes']:
        rel=row['path'];dst=bounded(TARGET,rel);src=bounded(SOURCE,rel)
        backup=bounded(AUDIT/'integration-backup/development',rel)
        if row['old'] is not None:
            backup.parent.mkdir(parents=True,exist_ok=True)
            if backup.exists():raise RuntimeError('backup already exists; never overwrite: '+rel)
            shutil.copy2(dst,backup)
            if sha(backup)!=row['old']:raise RuntimeError('backup hash mismatch: '+rel)
        if sha(dst)!=row['old']:raise RuntimeError('target changed before replace: '+rel)
        if row['new'] is None:
            dst.unlink()  # exact individually reviewed obsolete bundle file
        else:
            dst.parent.mkdir(parents=True,exist_ok=True)
            tmp=dst.with_name(dst.name+'.codex-integrating')
            if tmp.exists():raise RuntimeError('temporary path exists; preserve: '+str(tmp))
            shutil.copy2(src,tmp)
            if sha(tmp)!=row['new']:raise RuntimeError('staging hash mismatch: '+rel)
            os.replace(tmp,dst)
        if sha(dst)!=row['new']:raise RuntimeError('integrated hash mismatch: '+rel)
        journal.append(row)
        (AUDIT/'integration-journal.json').write_text(
            json.dumps(journal,ensure_ascii=False,indent=2),encoding='utf-8')
    if index_hash()!=plan['index_before']:raise RuntimeError('Git index changed during integration')
    (AUDIT/'integration-verification.json').write_text(json.dumps({
        'files':len(journal),'hashes_verified':True,'git_index_unchanged':True,
        'scope':'reviewed source delta only; no Git stage/commit; no formal Wiki or install copy'},
        ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'integrated':len(journal),'git_index_unchanged':True}))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--apply',action='store_true')
    args=p.parse_args()
    apply() if args.apply else prepare()
