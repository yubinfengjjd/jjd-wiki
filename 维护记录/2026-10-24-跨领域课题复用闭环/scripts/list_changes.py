import hashlib
import json
from pathlib import Path

AUDIT = Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
WORK = Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/development')
SKIP = {'__pycache__', '.pytest_cache', 'node_modules', '.git', '.agents'}


def main():
    old = json.loads((AUDIT / 'baseline.json').read_text(encoding='utf-8'))['development']
    found = {}
    for directory in ['staged/research-wiki', 'frontend']:
        for path in (WORK / directory).rglob('*'):
            relative = path.relative_to(WORK)
            if path.is_file() and not any(p in SKIP for p in relative.parts):
                found[relative.as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    changed = []
    for key in sorted(set(old) | set(found)):
        if old.get(key) != found.get(key):
            path = WORK / key
            changed.append({'path': key, 'change': 'added' if key not in old else
                            'deleted' if key not in found else 'modified',
                            'bytes': path.stat().st_size if path.is_file() else None,
                            'sha256': found.get(key)})
    return changed


if __name__ == '__main__':
    print(json.dumps(main(), ensure_ascii=False, indent=2))
