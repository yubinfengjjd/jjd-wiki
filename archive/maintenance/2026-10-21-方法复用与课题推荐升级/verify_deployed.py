from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys
from urllib.request import urlopen
from urllib.parse import urlencode, quote

task = Path(__file__).resolve().parent
base = json.loads((task/'baseline.json').read_text(encoding='utf-8'))
root = Path(r'E:\research-wiki\知识库')
gallery = Path(r'E:\research-wiki\画廊')
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
assert all((gallery/p).is_file() and sha(gallery/p) == digest for p,digest in base['gallery'].items())
protected_assets = [p for p in base['wiki'] if '/source/' in p or '/code/' in p or p.endswith(('.png','.pdf','.svg','.csv','spec.json','spec.pending.json'))]
assert all(sha(root/p) == base['wiki'][p] for p in protected_assets)
author = lambda p: p.read_bytes().split(b'<!-- user:start -->',1)[1].split(b'<!-- user:end -->',1)[0]
protected_pages = [p for p in base['wiki'] if p.endswith('.md') and p.split('/')[0] in {'layouts','templates','methods','interfaces'} and len(p.split('/')) == 2]
for p in protected_pages:
    assert author(root/p) == author(task/'baseline/wiki'/p), p
deployed = []
for host in ['.agents','.codex','.claude']:
    for skill in ['research-wiki','sci-figure-replica']:
        folder = Path(r'C:\Users\86186')/host/'skills'/skill
        manifest = json.loads((folder/'installation-manifest.json').read_text(encoding='utf-8'))
        for item in manifest['files']:
            assert sha(Path(item['source'])) == item['sha256'] == sha(Path(item['target'])), item['path']
        deployed.append({'host':host,'skill':skill,'files':len(manifest['files'])})
def get(path, binary=False):
    with urlopen('http://127.0.0.1:8765'+path,timeout=15) as response:
        data=response.read()
    return data if binary else json.loads(data)
pages=get('/api/pages'); relations=get('/api/relations'); graph=get('/api/graph')
assert len(relations)==5
assert len([e for e in graph['links'] if e['kind']=='relation'])==5
by_path={p['path']:p for p in pages}
for relation in relations:
    assert relation in by_path[relation['method']]['relations']
    assert relation in by_path[relation['figure']]['relations']
    assert relation in get('/api/page?'+urlencode({'path':relation['figure']}))['relations']
methods={p['meta']['id']:p['meta']['status'] for p in pages if p['meta']['type']=='method'}
assert methods['paired-reference-visual-comparison']==methods['repeated-benchmark-distribution']=='archived'
downloaded=0; inventories={}
for page in pages:
    if page['meta']['type'] not in {'method','template','layout'}: continue
    if page['meta']['type']=='layout' and len(page['meta']['panels'])!=1: continue
    kind={'method':'methods','template':'templates','layout':'layouts'}[page['meta']['type']]
    prefix='/api/'+kind+'/'+quote(page['meta']['id'])
    listing=get(prefix+'/code-files')
    inventories[page['path']]=len(listing['files'])
    for item in listing['files']:
        params=urlencode({'variant':item['variant'],'path':item['path']})
        raw=get(prefix+'/code-download?'+params,True)
        assert hashlib.sha256(raw).hexdigest()==item['sha256'] and len(raw)==item['size']
        viewed=get(prefix+'/code?'+params)
        assert viewed['sha256']==item['sha256']
        downloaded+=1
src=Path(r'E:\research-wiki\开发\staged\research-wiki')
served=get('/',True)
assert served==(src/'app/index.html').read_bytes()
for asset in re.findall(rb'(?:src|href)="(/assets/[^" ]+)"',served):
    assert get(asset.decode(),True)==(src/'app'/asset.decode().lstrip('/')).read_bytes()
cli_results=[]
for host in ['.agents','.codex','.claude']:
    command=[r'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe','-X','utf8',str(Path(r'C:\Users\86186')/host/'skills/research-wiki/wiki.py')]
    result=subprocess.run(command+['lint'],capture_output=True,encoding='utf-8',check=True)
    candidates=json.loads(subprocess.check_output(command+['suggest-methods','--q','回归','--columns','observed,predicted','--limit','5'],encoding='utf-8'))
    assert {x['id'] for x in candidates}=={'regression-resampling-evaluation','shap-explanation'}
    cli_results.append({'host':host,'lint':result.stdout.strip(),'methods':[x['id'] for x in candidates]})
report={'gallery_unchanged':len(base['gallery']),'source_and_figure_assets_unchanged':len(protected_assets),
        'author_blocks_unchanged':len(protected_pages),'deployments':deployed,'relations':len(relations),
        'download_byte_hash_checks':downloaded,'code_files':inventories,'deployed_app_matches':True,
        'cli_checks':cli_results,'methods':methods}
(task/'formal-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k not in {'code_files','cli_checks','methods'}},ensure_ascii=False))
