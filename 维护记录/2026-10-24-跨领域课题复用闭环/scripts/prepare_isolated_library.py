"""Exact library fixture for consumer acceptance; never changes production Wiki."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess

SOURCE=Path('E:/research-wiki/知识库')
TARGET=Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/pilot-evidence/wiki')
AUDIT=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
if TARGET.exists():raise SystemExit('Fixture already exists; do not overwrite')
if not TARGET.resolve().is_relative_to(Path('E:/research-wiki-env/work/wiki-cross-domain-20261024').resolve()):
    raise SystemExit('unexpected fixture destination')
rows={}
for d,dirs,files in os.walk(SOURCE):
    dirs[:]=[n for n in dirs if n not in {'.git','.obsidian','__pycache__','.pytest_cache'}]
    for n in files:
        p=Path(d)/n
        if p.is_symlink():raise SystemExit('unexpected linked source file; review')
        rel=p.relative_to(SOURCE)
        dst=TARGET/rel
        dst.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(p,dst)
        before=hashlib.sha256(p.read_bytes()).hexdigest()
        if hashlib.sha256(dst.read_bytes()).hexdigest()!=before:
            raise SystemExit('copied bytes differ')
        rows[rel.as_posix()]=before
for args in [('init',),('add','-A'),('-c','user.name=acceptance-fixture',
             '-c','user.email=fixture@localhost','commit','-m','Isolated byte-exact Wiki acceptance fixture')]:
    subprocess.run(['git','-C',str(TARGET),*args],check=True,capture_output=True)
(AUDIT/'a25-isolated-library-baseline.json').write_text(
    json.dumps({'source':str(SOURCE),'fixture':str(TARGET),'files':rows,
                'scope':'software fixture only; existing evidence copied unchanged, no new signoff'},
               ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'fixture':str(TARGET),'copied_exact_files':len(rows)},ensure_ascii=False))
