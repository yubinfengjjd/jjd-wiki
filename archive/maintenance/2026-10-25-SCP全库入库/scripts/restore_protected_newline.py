"""Restore the sole newline-only author-block drift caused by a prose edit."""
from pathlib import Path
import json,re,hashlib
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
R=Path('E:/research-wiki/知识库')
B=Path('E:/research-wiki-env/work/scp-full-ingest-20261025/wiki')
rel=Path('methods/scp-visualization-interface.md')
p=R/rel
old=p.read_bytes(); baseline=(B/rel).read_bytes()
pat=rb'<!-- user:start -->.*?<!-- user:end -->'
a=re.search(pat,old,re.S); b=re.search(pat,baseline,re.S)
assert a and b
assert a.group().replace(b'\r\n',b'\n')==b.group().replace(b'\r\n',b'\n'), 'Not merely line endings; do not replace author text'
new=old[:a.start()]+b.group()+old[a.end():]
if new!=old:
    (A/'before-post-p0-prose/technical-before-newline-restore.md').write_bytes(old)
    p.write_bytes(new)
print('Protected author block now byte-identical to baseline.')
post=json.loads((A/'post-p0-baseline.json').read_text(encoding='utf-8'))
post['wiki']={p.relative_to(R).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in R.rglob('*') if p.is_file() and not set(p.relative_to(R).parts)&{'.git','node_modules','__pycache__','.pytest_cache','.obsidian'}}
(A/'post-p0-prose-baseline.json').write_text(json.dumps(post,ensure_ascii=False,indent=2),encoding='utf-8')
