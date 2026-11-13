"""Read-only, official-provider state snapshot; never edits notes or receipts."""
from pathlib import Path
import collections,json,sys,time
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
B=Path('E:/research-wiki-env/work/scp-full-ingest-20261025')
sys.path.insert(0,'E:/research-wiki/开发/staged/research-wiki')
from rwiki.pages import read_page
from rwiki.config import load_config
from rwiki.method_implementations import implementation_status, implementation_metadata_errors
from rwiki.acceptance import ready_for_use
kind=sys.argv[1] if len(sys.argv)>1 else 'formal'
config=load_config(Path('C:/Users/86186/.agents/skills/research-wiki/config.json') if kind=='formal' else B/'development/staged/research-wiki/config.json')
rows=[]
for p in sorted((config.wiki_root/'methods').glob('*.md')):
    meta,body=read_page(p)
    states=implementation_status(p,meta)
    rows.append({'id':meta['id'],'title':meta.get('title'),'kind':meta.get('method_kind'),'status':meta.get('status'),
      'ready_for_use':ready_for_use(config,p,meta),'metadata_errors':implementation_metadata_errors(meta),
      'implementations':[{'id':s['id'],'state':s['state'],'scope':s['scope'],
         'entry':s['runtime'].get('entry'),'entry_function':s['runtime'].get('entry_function'),
         'runtime_mode':s['runtime'].get('mode'),'dependency_match':s['runtime'].get('dependency_match'),
         'portability':s['runtime'].get('portability',{})} for s in states]})
stamp=time.strftime('%Y%m%dT%H%M%S',time.gmtime())
out=A/f'codex-method-states-{kind}-{stamp}.json'
out.write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'snapshot':str(out),'pages':len(rows),'ready_for_use':[r['id'] for r in rows if r['ready_for_use']],
 'implementation_states':dict(collections.Counter(s['state'] for r in rows for s in r['implementations'])),
 'bad_metadata':[r['id'] for r in rows if r['metadata_errors']]},ensure_ascii=False))
