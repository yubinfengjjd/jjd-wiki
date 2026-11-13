from pathlib import Path
import hashlib
import json
import os
import subprocess
import sys
from urllib.request import urlopen

task = Path(__file__).resolve().parent
root = Path(r'E:\research-wiki\知识库')
sys.path.insert(0, str(Path(r'C:\Users\86186\.agents\skills\research-wiki')))
from rwiki.pages import read_page, get_block

sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
baseline = json.loads((task/'baseline.json').read_text(encoding='utf-8'))
for label, folder in [('gallery', root.parent/'画廊'), ('wiki', root)]:
    for rel, before in baseline[label].items():
        if label == 'wiki' and Path(rel).suffix == '.md':
            continue
        assert sha(folder/rel) == before, (label, rel)
protected = 0
old = root.parent/'维护记录/2026-10-21-待办模板化/baseline'
for path in old.rglob('*.md'):
    if not (root/path.relative_to(old)).is_file():
        continue
    try:
        before = get_block(read_page(path)[1], 'user')
    except Exception:
        continue
    assert get_block(read_page(root/path.relative_to(old))[1], 'user') == before
    protected += 1
with urlopen('http://127.0.0.1:8765/api/pages') as stream:
    pages = json.load(stream)
queued = [p['path'] for p in pages if p.get('workflow') and p['workflow']['queue']]
assert queued == [], queued
sources = [p for p in pages if p['meta']['type'] == 'layout' and p['meta']['status'] != 'archived']
assert len(sources) == 2
assert all(p['meta']['status'] == 'pending_template' and p['workflow']['stage'] == 'complete'
           and p['workflow']['label'] == '模板已就绪' for p in sources)
tids = ['2026-10-19-regression-stability__fig03-density-panel--density-scatter',
        '2026-10-19-regression-stability__fig04-boxplot-panel--boxplot']
assert all(read_page(root/'templates'/f'{tid}.md')[0]['status'] == 'ready' for tid in tids)
hosts = []
recommendations = {}
for query, expected in [('密度散点', tids[0]), ('箱线', tids[1])]:
    cli = subprocess.run([sys.executable,'-X','utf8',r'C:\Users\86186\.agents\skills\research-wiki\wiki.py',
                          'suggest','--q',query],capture_output=True,text=True,encoding='utf-8')
    assert cli.returncode == 0, cli.stderr
    candidates = json.loads(cli.stdout)
    ids = [p['id'] for p in candidates]
    assert expected in ids
    assert all(p['kind'] == 'template' and read_page(root/'templates'/f"{p['id']}.md")[0]['status'] == 'ready'
               for p in candidates)
    recommendations[query] = {'confirmed_template_found':expected, 'all_candidates_ready':True}
for host in ('.agents', '.codex', '.claude'):
    skill = Path(r'C:\Users\86186')/host/'skills/research-wiki'
    config = json.loads((skill/'config.json').read_text(encoding='utf-8'))
    assert Path(config['wiki_root']) == root
    manifest = json.loads((skill/'installation-manifest.json').read_text(encoding='utf-8'))
    assert all(sha(Path(x['target'])) == x['sha256'] for x in manifest['files'])
    cli = subprocess.run([sys.executable,'-X','utf8',str(skill/'wiki.py'),'pending'],
                         capture_output=True,text=True,encoding='utf-8')
    assert cli.returncode == 0 and cli.stdout == '', (host,cli.stdout,cli.stderr)
    hosts.append({'host':host,'files_verified':len(manifest['files']),'cli_pending':0})
report = dict(passed=True, author_confirmation='two new templates ready through mark-ready',
    source_statuses_preserved=['pending_template']*2,source_template_progress='complete',
    api_queued=queued, cli_and_api_same=True, gallery_files_unchanged=len(baseline['gallery']),
    all_existing_non_markdown_wiki_assets_unchanged=True,old_author_blocks_checked=protected,
    hosts=hosts,recommendations=recommendations,
    scope='Queue and state/asset preservation; no new scientific analysis or layout signoff')
(task/'live-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
(task/'api-pages.json').write_text(json.dumps(pages,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
