"""Isolated audit reproductions. Never mutates the formal Wiki or gallery."""
import json
import sys
from dataclasses import replace
from datetime import datetime
from pathlib import Path

SKILL = Path('E:/research-wiki/开发/staged/research-wiki')
HERE = Path(__file__).resolve().parent
sys.path[:0] = [str(SKILL), str(SKILL / 'tests')]

import conftest
import test_templates
from fastapi.testclient import TestClient
from PIL import Image
from rwiki.ingest import ingest_figure
from rwiki.lint import lint
from rwiki.methods import scaffold_method
from rwiki.pages import read_page, write_page
from rwiki.server import create_app
from rwiki.suggest import suggest_methods
from rwiki.templates import mark_ready, verify_template
from rwiki.workflow import replay_available, workflow_snapshot

results = {}
RUN = datetime.now().strftime('%Y%m%dT%H%M%S%f')

def workspace(name):
    target = HERE / 'fixtures' / RUN / name
    target.mkdir(parents=True, exist_ok=False)
    return conftest.workspace.__wrapped__(target)

def fake(name):
    return test_templates.fake_template.__wrapped__(
        test_templates.approved.__wrapped__(workspace(name)))

# Source v2 still carries v1's approved flag. Refresh must not become approval.
config, _ = workspace('reingest-signoff')
config = replace(config, single_panel_only=True)
gallery_path = next(config.gallery_root.glob('*/figures/*/meta.json'))
gallery_meta = json.loads(gallery_path.read_text(encoding='utf-8'))
gallery_meta['figure']['panel_map'] = {'A': 'bar'}
conftest.update_gallery(config, status='approved', figure=gallery_meta['figure'])
ingest_figure(config, conftest.ENTRY_ID)
page = config.wiki_root / f'layouts/{conftest.ENTRY_ID}.md'
conftest.update_gallery(config, version=2)
ingest_figure(config, conftest.ENTRY_ID)
first = read_page(page)[0]['status']
ingest_figure(config, conftest.ENTRY_ID)
second = read_page(page)[0]['status']
results['new_version_reingest'] = {
    'single_panel_only': config.single_panel_only,
    'after_version_bump': first, 'after_repeat_ingest': second,
    'author_signoff_called': False,
    'bug_reproduced': first == 'pending_signoff' and second == 'pending_template'}

# Any existing PNG is sufficient for mark-ready; no successful verify required.
config, _, target = fake('preview-without-replay')
Image.new('RGB', (8, 8), 'white').save(target / 'preview.png')
mark_ready(config, target.name)
results['ready_without_replay'] = {
    'status': read_page(target.with_suffix('.md'))[0]['status'],
    'verify_receipt_exists': (target / 'verify/verify.json').exists(),
    'bug_reproduced': read_page(target.with_suffix('.md'))[0]['status'] == 'ready'
        and not (target / 'verify/verify.json').exists()}

# A successful replay remains valid after replacing its executable with failure.
config, _, target = fake('changed-code-after-replay')
verify_template(config, target.name)
before = replay_available(target)
entry = target / 'code/render.py'
entry.write_text("raise RuntimeError('audit intentionally changed entry after replay')\n",
                 encoding='utf-8')
after = replay_available(target)
workflow = workflow_snapshot(config)[f'templates/{target.name}.md']
results['stale_replay'] = {
    'before_code_change': before, 'after_code_change': after,
    'queue': workflow['queue'], 'stage': workflow['stage'],
    'bug_reproduced': before and after and workflow['queue'] == 'confirm'}

# Method confirmation currently accepts the completely blank scaffold body.
config, _ = workspace('empty-method-confirmation')
native = config.wiki_root.parent / 'native.py'
native.write_text('# isolated audit fixture only\n', encoding='utf-8')
scaffold_method(config, 'empty-note', 'Empty audit note', 'none', from_path=native)
with TestClient(create_app(config)) as client:
    response = client.post('/api/methods/empty-note/confirm')
diagnostics = lint(config)
methods = suggest_methods(config)
results['empty_method_confirmation'] = {
    'http_status': response.status_code,
    'status': read_page(config.wiki_root / 'methods/empty-note.md')[0]['status'],
    'lint': diagnostics, 'suggested': [item['id'] for item in methods],
    'purpose': methods[0]['purpose'] if methods else None,
    'bug_reproduced': response.status_code == 200 and not diagnostics
        and any(item['id'] == 'empty-note' and not item['purpose'] for item in methods)}

(HERE / 'reproductions.json').write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding='utf-8')
print(json.dumps(results, ensure_ascii=False, indent=2))
assert all(row['bug_reproduced'] for row in results.values())
