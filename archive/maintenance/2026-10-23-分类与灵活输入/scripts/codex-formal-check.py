import json,urllib.request,re,hashlib
from pathlib import Path
base='http://127.0.0.1:8765'
get=lambda p:urllib.request.urlopen(base+p,timeout=30).read()
t=json.loads(get('/api/method-taxonomy'))
pages=json.loads(get('/api/pages'))
families=[p for p in pages if p['meta'].get('type')=='method' and p['meta'].get('method_kind')=='analysis' and p['meta'].get('status')!='archived']
assert len(families)==t['total']==15
assert len({p['meta']['id'] for p in families})==15
for d in t['domains']:
    matches=[p for p in families if d['value'] in p['meta'].get('tags',[])]
    assert len(matches)==d['count']
    for q in d['purposes']:
        assert sum(q['value'] in p['meta'].get('purposes',[]) for p in matches)==q['count']
optional={}
for template,column in [('2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot','target_group'),('2026-10-22-scp-example__fig09-bar--bar','cell')]:
    import urllib.parse
    page=json.loads(get('/api/page?'+urllib.parse.urlencode({'path':f'templates/{template}.md'})))
    contract=page['input_contract']
    assert contract['bindings'] is True
    values=[c for table in contract['tables'] for c in table['columns'] if c['name']==column]
    assert values and all(c['required'] is False for c in values)
    optional[template]=column
index=get('/')
staged=Path('E:/research-wiki/开发/staged/research-wiki/app')
assert index==(staged/'index.html').read_bytes()
assets=re.findall(rb'(?:src|href)="(/assets/[^" ]+)"',index)
for a in assets:
    name=a.decode()
    assert get(name)==(staged/name.lstrip('/')).read_bytes()
out={'base':base,'families':15,'distinct_ids':15,'domains':t['domains'],'purposes':t['purposes'],
     'author_confirmed':sum(p['meta']['status']=='ready' for p in families),
     'author_pending':sum(p['meta']['status']=='draft' for p in families),
     'optional_fields':optional,'index_matches_staged':True,'entry_assets_checked':len(assets)}
record=Path(__file__).parents[1]
(record/'formal-service-check.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in out.items() if k not in ('domains','purposes','optional_fields')},ensure_ascii=False))
