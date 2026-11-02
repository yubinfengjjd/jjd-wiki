from pathlib import Path
import hashlib,json,re,sys
import xml.etree.ElementTree as ET
from urllib.request import urlopen
from urllib.parse import urlencode

TASK=Path(__file__).resolve().parent;ROOT=Path(r'E:\research-wiki\知识库');GALLERY=Path(r'E:\research-wiki\画廊')
before=json.loads((TASK/'baseline.json').read_text(encoding='utf-8'))
hashfile=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for rel,digest in before['gallery'].items():assert hashfile(GALLERY/rel)==digest,rel
protected=[];authors=[]
for rel,digest in before['wiki'].items():
    if '/code/' in rel or '/source/' in rel or rel.endswith(('.csv','.png','.pdf','.svg','spec.json')):
        assert hashfile(ROOT/rel)==digest,rel;protected.append(rel)
    if rel.endswith('.md') and len(Path(rel).parts)==2:
        raw=(TASK/'baseline'/rel).read_bytes();now=(ROOT/rel).read_bytes()
        if b'<!-- user:start -->' in raw:
            part=lambda value:value.split(b'<!-- user:start -->',1)[1].split(b'<!-- user:end -->',1)[0]
            assert part(raw)==part(now),rel;authors.append(rel)
def api(path):
    with urlopen('http://127.0.0.1:8765'+path,timeout=8) as response:return json.load(response)
pages=api('/api/pages');by_path={p['path']:p for p in pages};relations=api('/api/relations')
summary=[]
for fig,chart in [('fig03-density-panel','density-scatter'),('fig04-boxplot-panel','boxplot')]:
    tid='2026-10-19-regression-stability__'+fig+'--'+chart;path='templates/'+tid+'.md';folder=ROOT/'templates'/tid
    page=api('/api/page?'+urlencode({'path':path}));assert page['meta']['status']=='draft'
    assert page['reuse']['sizing_declared'] and page['preview']['kind']=='replay'
    assert (folder/'preview.png').is_file()
    matching=[r for r in relations if r['figure']==path]
    assert matching and matching[0]['compatibility']=='adaptable' and matching[0]['verification']['state']=='not_run'
    inventory=api('/api/templates/'+tid+'/code-files')
    core=[f for f in inventory['files'] if f['path']=='code/core.py'][0]
    assert core['verification']['state']=='example' and core['sha256']==hashfile(folder/'code/core.py')
    for suffix in ['pdf','svg']:
        file=folder/'verify'/('figure.'+suffix)
        if suffix=='svg':
            svg=ET.parse(file).getroot();assert svg.tag.endswith('svg') and svg.get('viewBox')
        else:
            raw=file.read_bytes();assert raw.startswith(b'%PDF-') and b'%%EOF' in raw
            assert re.search(rb'/MediaBox\s*\[\s*0\s+0\s+([\d.]+)\s+([\d.]+)',raw)
    render=TASK/('cli-render-density' if chart=='density-scatter' else 'cli-render-boxplot')
    assert hashfile(render/'figure.png')==hashfile(folder/'preview.png')
    summary.append({'template':tid,'status':'draft','preview':'replay','sizing':page['reuse'],
                    'code_files':len(inventory['files']),'relationship':'adaptable, pipeline not_run','cli_render_matches_preview':True})
for host in ['.agents','.codex','.claude']:
    cfg=json.loads((Path(r'C:\Users\86186')/host/'skills/research-wiki/config.json').read_text(encoding='utf-8'))
    assert Path(cfg['wiki_root']).resolve()==ROOT
result={'passed':True,'gallery_hashes_unchanged':len(before['gallery']),'existing_assets_unchanged':len(protected),
        'author_blocks_preserved':len(authors),'templates':summary,'shared_install_roots':3,
        'scope':'no original gallery edits, no new analysis algorithms, no automatic ready/signoff'}
(TASK/'wiki-verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False))
