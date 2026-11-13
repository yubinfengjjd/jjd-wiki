import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path('E:/research-wiki')
sys.path.insert(0, str(ROOT / '开发/staged/research-wiki'))
from rwiki.pages import read_page  # noqa: E402

baseline = json.loads((Path(__file__).resolve().parents[1] / 'baseline.json').read_text(encoding='utf-8'))
result = {'source_files': 0, 'source_mismatch': [], 'pages': 0, 'page_mismatch': [],
          'user_block_mismatch': [], 'ids_changed': []}
for relative, digest in baseline['sources'].items():
    path = ROOT / relative
    result['source_files'] += 1
    if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != digest:
        result['source_mismatch'].append(relative)
for relative, expected in baseline['authors'].items():
    path = ROOT / relative
    result['pages'] += 1
    if not path.is_file():
        result['page_mismatch'].append(relative)
        continue
    meta, body = read_page(path)
    if meta.get('id') != expected.get('id'):
        result['ids_changed'].append(relative)
    if meta.get('status') != expected.get('status') or bool(meta.get('favorite')) != bool(expected.get('favorite')):
        result['page_mismatch'].append(relative)
    blocks = re.findall(r'<!-- user:start -->.*?<!-- user:end -->', body, flags=re.S)
    if hashlib.sha256('\n'.join(blocks).encode()).hexdigest() != expected.get('user_sha256'):
        result['user_block_mismatch'].append(relative)
print(json.dumps(result, ensure_ascii=False, indent=2))
Path(__file__).resolve().parents[1] / 'integrity-after.json'
(Path(__file__).resolve().parents[1] / 'integrity-after.json').write_text(
    json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
