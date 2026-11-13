"""Independent baseline comparison; read-only for product and original assets."""
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path('E:/research-wiki')
RECORD = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT / '开发/staged/research-wiki'))
from rwiki.pages import read_page

base = json.loads((RECORD / 'baseline.json').read_text(encoding='utf-8'))
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
source_failures = []
for name, digest in base['sources'].items():
    path = ROOT / name
    if not path.is_file() or sha(path) != digest:
        source_failures.append(name)
author_failures = []
for name, old in base['authors'].items():
    path = ROOT / name
    if not path.is_file():
        author_failures.append({'page': name, 'reason': 'missing'})
        continue
    meta, body = read_page(path)
    blocks = re.findall(r'<!-- user:start -->.*?<!-- user:end -->', body, flags=re.S)
    now = {'id': meta.get('id'), 'status': meta.get('status'), 'favorite': meta.get('favorite'),
           'user_sha256': hashlib.sha256('\n'.join(blocks).encode()).hexdigest()}
    if now != old:
        author_failures.append({'page': name, 'before': old, 'after': now})
changed = []
for name, digest in base['files'].items():
    path = ROOT / name
    if not path.is_file():
        changed.append({'path': name, 'change': 'deleted'})
    elif sha(path) != digest:
        changed.append({'path': name, 'change': 'modified'})
new = []
skip = {'.git', 'node_modules', '__pycache__', '.pytest_cache', '.obsidian', 'dist'}
for directory in ['开发/staged/research-wiki', '开发/frontend', '知识库']:
    for path in (ROOT / directory).rglob('*'):
        if path.is_file() and not any(part in skip for part in path.relative_to(ROOT / directory).parts):
            name = path.relative_to(ROOT).as_posix()
            if name not in base['files']:
                new.append(name)
result = {'protected_sources_checked': len(base['sources']), 'protected_pages_checked': len(base['authors']),
          'source_failures': source_failures, 'author_failures': author_failures,
          'changed_files': changed, 'new_files': new}
(RECORD / 'codex-integrity.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'protected_sources':len(base['sources']), 'protected_pages':len(base['authors']),
                  'source_failures':source_failures,'author_failures':author_failures,
                  'modified_or_deleted':len(changed),'new_files':len(new)},ensure_ascii=False))
if source_failures or author_failures:
    raise SystemExit(1)
