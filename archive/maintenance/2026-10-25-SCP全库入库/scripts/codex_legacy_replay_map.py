"""Map actual pre-migration verified branches to their existing replay evidence."""
from pathlib import Path
import json,sys
R=Path('E:/research-wiki/知识库/methods')
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
sys.path.insert(0,'E:/research-wiki/开发/staged/research-wiki')
from rwiki.pages import read_page
from rwiki.method_implementations import implementation_status
rows=[]
for p in sorted(R.glob('*.md')):
 m,b=read_page(p); states={s['id']:s for s in implementation_status(p,m)}
 for impl in m.get('implementations',[]):
  if states.get(impl['id'],{}).get('state')!='verified':continue
  receipt=p.with_suffix('')/impl['verification']
  r=json.loads(receipt.read_text(encoding='utf-8'))
  rows.append({'family':p.stem,'implementation':impl['id'],'entrypoint':impl['entrypoint'],
   'verification':str(receipt),'command':r.get('command'),'scope':r.get('scope'),
   'inputs':r.get('inputs'),'outputs':r.get('outputs'),'environment':r.get('environment'),
   'note':'Replay against ISOLATED family assets, never run formal code then relabel its output as isolated. Preserve old receipt. Required to restore pre-existing capability.'})
out=A/'codex-legacy-verified-replay-map.json'
out.write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'branches':len(rows),'families':[r['family'] for r in rows],'map':str(out)},ensure_ascii=False))
