"""Freeze testable source/fixtures only, rejecting concurrent source changes."""
from pathlib import Path
import hashlib
import json
import shutil
import sys

BASE=Path('E:/research-wiki-env/work/wiki-cross-domain-20261024')
AUDIT=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
SOURCE=BASE/'development'
SKIP={'.git','node_modules','__pycache__','.pytest_cache','.agents'}
DIRS=('staged/research-wiki','frontend','spec','test-gallery','test-gallery-p2','qa','review')

def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(1<<20),b''):
            h.update(b)
    return h.hexdigest()

def inventory():
    rows={}
    for folder in DIRS:
        for p in (SOURCE/folder).rglob('*'):
            rel=p.relative_to(SOURCE)
            if p.is_file() and not any(x in SKIP for x in rel.parts) and p.suffix not in ('.pyc','.pyo'):
                rows[rel.as_posix()]=sha(p)
    helper=SOURCE/'codex/R1-migrate.py'
    if helper.is_file():
        rows['codex/R1-migrate.py']=sha(helper)
    return rows

if __name__=='__main__':
    name=sys.argv[1]
    if not name.startswith('review-batch2-snapshot-') or '/' in name or '\\' in name:
        raise SystemExit('invalid snapshot name')
    target=BASE/name
    if target.exists():
        raise SystemExit('snapshot exists; never overwrite')
    before=inventory()
    for rel in before:
        dest=target/rel
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(SOURCE/rel,dest)
    after=inventory()
    if before!=after:
        changed=sorted(k for k in set(before)|set(after) if before.get(k)!=after.get(k))
        raise SystemExit('source changed while freezing; snapshot invalid: '+repr(changed))
    bad=[rel for rel,digest in before.items() if sha(target/rel)!=digest]
    if bad:
        raise SystemExit('copied hash mismatch: '+repr(bad))
    (AUDIT/f'{name}-hashes.json').write_text(json.dumps(before,ensure_ascii=False,indent=2),encoding='utf-8')
    print(json.dumps({'snapshot':str(target),'files':len(before),'stable_during_copy':True},ensure_ascii=False))
