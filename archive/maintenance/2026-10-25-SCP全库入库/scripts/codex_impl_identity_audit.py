"""Read-only legacy implementation identity/entrypoint review."""
from pathlib import Path
import json, sys, time
sys.path.insert(0,'E:/research-wiki-env/work/scp-full-ingest-20261025/development/staged/research-wiki')
from rwiki.pages import read_page
formal=Path('E:/research-wiki/知识库/methods')
isolated=Path('E:/research-wiki-env/work/scp-full-ingest-20261025/wiki/methods')
rows=[]
for f in sorted(formal.glob('*.md')):
    g=isolated/f.name
    if not g.is_file():
        rows.append({'page':f.stem,'removed_page':True});continue
    fm,_=read_page(f); bm,_=read_page(g)
    old={i['id']:i for i in fm.get('implementations',[]) or []}
    new={i['id']:i for i in bm.get('implementations',[]) or []}
    for iid,v in old.items():
        n=new.get(iid)
        if n is None or v.get('entrypoint')!=n.get('entrypoint') or (v.get('verification') and v.get('verification')!=n.get('verification')):
            rows.append({'page':f.stem,'implementation':iid,'old_entry':v.get('entrypoint'),'new_entry':n.get('entrypoint') if n else None,'old_verification':v.get('verification'),'new_verification':n.get('verification') if n else None,'old_code_still_present':(isolated/f.stem/v.get('entrypoint','').split(':')[0]).is_file()})
stamp=time.strftime('%Y%m%dT%H%M%S',time.gmtime())
out=Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')/('codex-impl-identities-'+stamp+'.json')
out.write_text(json.dumps({'scope':'in-progress snapshot; changed entry/receipt needs review, not automatic rejection','changes':rows},ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'evidence':str(out),'changes':rows},ensure_ascii=False))
