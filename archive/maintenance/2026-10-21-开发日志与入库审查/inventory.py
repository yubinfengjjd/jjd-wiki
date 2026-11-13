"""Read-only inventory and deployment comparison for the formal Wiki."""
import hashlib
import json
import sys
from collections import Counter
from pathlib import Path
from urllib.request import urlopen

HERE=Path(__file__).resolve().parent
ROOT=Path('E:/research-wiki/知识库')
STAGE=Path('E:/research-wiki/开发/staged/research-wiki')
sys.path.insert(0,str(STAGE))
from rwiki.pages import read_page

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def hashes(root):
    return {p.relative_to(root).as_posix():sha(p) for p in root.rglob('*')
            if p.is_file() and not any(s in p.parts for s in ('.git','__pycache__','.pytest_cache'))}

def get(route):
    with urlopen('http://127.0.0.1:8765'+route,timeout=30) as stream:return json.load(stream)

pages=get('/api/pages'); graph=get('/api/graph')
(HERE/'api-pages.json').write_text(json.dumps(pages,ensure_ascii=False,indent=2),encoding='utf-8')
hosts=[]
for host in ('.agents','.codex','.claude'):
    for name in ('research-wiki','sci-figure-replica'):
        target=Path('C:/Users/86186')/host/'skills'/name
        manifest=json.loads((target/'installation-manifest.json').read_text(encoding='utf-8'))
        bad=[row['target'] for row in manifest['files']
             if not Path(row['target']).is_file() or sha(Path(row['target']))!=row['sha256']]
        config=json.loads((target/'config.json').read_text(encoding='utf-8'))
        hosts.append(dict(host=host,skill=name,files=len(manifest['files']),mismatches=bad,
                          wiki_root=config.get('wiki_root'),gallery_root=config.get('gallery_root')))
assets=[]
for p in pages:
    if p['meta']['type'] not in ('layout','template','method'):continue
    m=p['meta'];kind=m['type']+'s'
    inventory=get('/api/'+kind+'/'+m['id']+'/code-files')
    assets.append({'page':p['path'],'files':len(inventory['files'])})
result={'counts':dict(Counter((p['meta']['type']+'/'+p['meta'].get('status','na')) for p in pages)),
        'queue_actions':[p['path'] for p in pages if (p.get('workflow') or {}).get('queue')],
        'installed':hosts,'wiki_rules_match':(ROOT/'AGENTS.md').read_bytes()==(STAGE/'assets/AGENTS.md').read_bytes(),
        'code_inventories':assets,'graph_nodes':len(graph['nodes']),'graph_edges':len(graph['links'])}
(HERE/'live-inventory.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
baseline={'wiki':hashes(ROOT),'gallery':hashes(ROOT.parent/'画廊')}
(HERE/'protected-state.json').write_text(json.dumps(baseline,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2))
