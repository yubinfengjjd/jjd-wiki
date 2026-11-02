"""Review evidence only: inventory and copies before the sole Claude writer starts."""
import hashlib
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path('E:/research-wiki')
RECORD = ROOT / '维护记录/2026-10-23-最小依赖独立模块'
sys.path.insert(0, str(ROOT / '开发/staged/research-wiki'))
from rwiki.pages import read_page


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git(repo, *args):
    return subprocess.check_output(['git', '-C', str(repo), *args], encoding='utf-8')


if (RECORD / 'baseline.json').exists():
    raise SystemExit('Baseline already exists; refusing overwrite')
result = {'captured_at': datetime.now(timezone.utc).isoformat(), 'repos': {},
          'files': {}, 'sources': {}, 'authors': {}, 'inventory': []}
skip = {'.git', 'node_modules', '__pycache__', '.pytest_cache', '.obsidian', 'dist'}
for directory in ['开发/staged/research-wiki', '开发/frontend', '知识库']:
    base = ROOT / directory
    for path in base.rglob('*'):
        if not path.is_file() or any(part in skip for part in path.relative_to(base).parts):
            continue
        relative = path.relative_to(ROOT).as_posix()
        result['files'][relative] = digest(path)
        if 'source' in path.parts or 'original_code' in path.parts or 'SCP-local' in path.parts:
            result['sources'][relative] = result['files'][relative]
        if path.suffix.lower() in {'.py', '.r', '.md', '.json', '.tsx', '.ts', '.css', '.html', '.yaml', '.toml'}:
            target = RECORD / 'before' / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)
for path in (ROOT / '画廊').rglob('*'):
    if path.is_file() and not any(p in skip for p in path.parts):
        result['sources'][path.relative_to(ROOT).as_posix()] = digest(path)
for section in ['methods', 'templates', 'layouts', 'interfaces', 'chart-types', 'projects']:
    for path in sorted((ROOT / '知识库' / section).glob('*.md')):
        meta, body = read_page(path)
        blocks = re.findall(r'<!-- user:start -->.*?<!-- user:end -->', body, flags=re.S)
        result['authors'][path.relative_to(ROOT).as_posix()] = {
            'id': meta.get('id'), 'status': meta.get('status'), 'favorite': meta.get('favorite'),
            'user_sha256': hashlib.sha256('\n'.join(blocks).encode()).hexdigest()}
        if section in ['methods', 'templates']:
            result['inventory'].append({'page': path.relative_to(ROOT).as_posix(),
                'id': meta.get('id'), 'method_kind': meta.get('method_kind'),
                'implementations': meta.get('implementations', [])})
for name in ['开发', '知识库']:
    result['repos'][name] = {'head': git(ROOT / name, 'rev-parse', 'HEAD').strip(),
                             'status': git(ROOT / name, 'status', '--porcelain=v1')}
RECORD.mkdir(parents=True, exist_ok=True)
(RECORD / 'baseline.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps({'files': len(result['files']), 'protected_sources': len(result['sources']),
                  'protected_pages': len(result['authors']), 'baseline': str(RECORD / 'baseline.json')}, ensure_ascii=False))
