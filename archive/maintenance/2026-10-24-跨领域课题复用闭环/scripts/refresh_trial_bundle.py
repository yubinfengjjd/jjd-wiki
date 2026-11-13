"""Refresh only reviewed compiled assets before the idle consumer resumes."""
from pathlib import Path
import hashlib
import json
import os
import shutil

AUDIT=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
SOURCE=Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/development/staged/research-wiki')
DEST=Path('E:/青光眼单细胞/wiki-use/acceptance-20261024/.agents/skills/research-wiki')
SKIP={'.git','__pycache__','.pytest_cache','node_modules'}
def hashes(root):
    rows={}
    for d,dirs,files in os.walk(root):
        dirs[:]=[n for n in dirs if n not in SKIP]
        for n in files:
            p=Path(d)/n
            if p.suffix not in ('.pyc','.pyo'):
                rows[p.relative_to(root).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
    return rows

old=json.loads((AUDIT/'a25-trial-skill-before-phase2.json').read_text(encoding='utf-8'))
if hashes(DEST)!=old['trial_hashes']:raise SystemExit('trial tool changed unexpectedly; preserve and review')
current=hashes(SOURCE)
changed=[r for r in set(old['source_hashes'])|set(current)
         if old['source_hashes'].get(r)!=current.get(r)]
if any(not r.startswith('app/') for r in changed):
    raise SystemExit('non-bundle source changed; new review required: '+repr(changed))
for rel in sorted(changed):
    dst=DEST/rel
    if not dst.resolve().is_relative_to(DEST.resolve()):raise SystemExit('trial target escaped')
    if dst.is_file():
        backup=AUDIT/'trial-bundle-v1'/rel
        if backup.exists():raise SystemExit('backup exists; no overwrite')
        backup.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(dst,backup)
    if rel not in current:
        dst.unlink()  # only exact obsolete reviewed app file, no recursive delete
    else:
        dst.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(SOURCE/rel,dst)
new=dict(old,source_hashes=current,trial_hashes=hashes(DEST),
         reviewed_bundle_updates=sorted(changed))
(AUDIT/'a25-trial-skill-before-phase2-reviewed.json').write_text(
    json.dumps(new,ensure_ascii=False,indent=2),encoding='utf-8')
(AUDIT/'a25-product-before-phase2.json').write_text(
    json.dumps(current,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'reviewed_bundle_updates':len(changed),'trial_tool_files':len(new['trial_hashes'])}))
