"""Read-only byte integrity check against this run's pre-edit baselines."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path('E:/research-wiki')
AUDIT = ROOT / '维护记录/2026-10-24-跨领域课题复用闭环'


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for part in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(part)
    return digest.hexdigest()


def check():
    baseline = json.loads((AUDIT / 'baseline.json').read_text(encoding='utf-8'))
    results = {}
    for section, root in [('sources', ROOT), ('project', Path('E:/青光眼单细胞')),
                          ('development', ROOT / '开发')]:
        errors = []
        for relative, entry in baseline[section].items():
            expected = entry['sha256'] if isinstance(entry, dict) else entry
            path = root / relative
            if not path.is_file() or sha(path) != expected:
                errors.append(relative)
        results[section] = {'checked': len(baseline[section]), 'changed_or_missing': errors}
    gallery = json.loads((AUDIT / 'gallery-baseline.json').read_text(encoding='utf-8'))
    results['gallery_source_and_metadata'] = {
        'checked': len(gallery),
        'changed_or_missing': [key for key, digest in gallery.items()
             if not (ROOT / '画廊' / key).is_file() or sha(ROOT / '画廊' / key) != digest]}
    author_errors, actual_blocks = [], 0
    for key, entry in baseline['author_pages'].items():
        path = ROOT / key
        if not path.is_file():
            author_errors.append(key)
            continue
        text = path.read_text(encoding='utf-8')
        if re.search(r'^<!-- user:start -->\s*$', text, re.M):
            actual_blocks += 1
        fields = [line for line in text.splitlines() if line.startswith(('id:', 'status:', 'favorite:'))]
        try:
            user = text.split('<!-- user:start -->', 1)[1].split('<!-- user:end -->', 1)[0]
        except IndexError:
            user = None
        if {'fields': fields, 'user': user} != entry:
            author_errors.append(key)
    results['author_fields_and_marker_fragments'] = {
        'checked': len(baseline['author_pages']), 'actual_line_delimited_user_blocks': actual_blocks,
        'note': 'Initial baseline includes rule-document marker examples; do not count them as author blocks.',
        'changed_or_missing': author_errors}
    return results


if __name__ == '__main__':
    report = check()
    print(json.dumps(report, ensure_ascii=False, indent=2))
    raise SystemExit(any(item['changed_or_missing'] for item in report.values()))
