"""Publish only the reviewed source draft, interface prose and compiled notes."""
from pathlib import Path
import hashlib,json,shutil,subprocess,sys
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP续整理')
B=Path('E:/research-wiki-env/work/scp-ingestion-20261025')
ROOT=Path('E:/research-wiki');W=ROOT/'知识库';G=ROOT/'画廊'
S=ROOT/'开发/staged/research-wiki';sys.path.insert(0,str(S))
from rwiki.pages import read_page,write_page,get_block
from rwiki.runtime_contract import runtime_facts
eid='2026-10-22-scp-example__fig17-group-heatmap-dot'
release=json.loads((A/'draft-release-review.json').read_text(encoding='utf-8'))
assert release['approved_for_draft_publication'] is True
cand=B/'candidates/group-heatmap-dot'
facts=runtime_facts(cand,eid+'--heatmap','template')
assert facts['portability']['state']=='verified',facts
assert release['closure_hash']==facts['portability']['closure_hash']
baseline=json.loads((A/'baseline.json').read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
for k,root in [('wiki',W),('gallery',G),('development',S)]:
    for rel,digest in baseline[k].items():assert (root/rel).is_file() and sha(root/rel)==digest,(k,rel,'drift')
entry=Path('2026-10-22-scp-example/figures/fig17-group-heatmap-dot')
assert not (G/entry).exists(),'new source already exists; inspect, never overwrite'
assert not (W/f'layouts/{eid}.md').exists()
assert json.loads((B/'gallery'/entry/'meta.json').read_text(encoding='utf-8'))['status']=='draft'
before=A/'before-publication';assert not before.exists(),'publication already attempted; inspect'
before.mkdir()
changed=['index.md','log.md','interfaces/render-group-heatmap.md','methods/scp-visualization-interface.md','chart-types/heatmap.md']
for rel in changed:
    dest=before/'wiki'/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/rel,dest)
template=Path('templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap')
shutil.copytree(W/template,before/'wiki'/template)
shutil.copytree(W/'methods/scp-visualization-interface',before/'wiki/methods/scp-visualization-interface')
for name in ('index.json','index.html'):
    (before/'gallery').mkdir(exist_ok=True);shutil.copy2(G/name,before/'gallery'/name)
shutil.copytree(B/'gallery'/entry,G/entry)
for rel in changed[2:]:
    if rel.startswith('methods/'):
        oldm,oldb=read_page(W/rel);newm,newb=read_page(B/'wiki'/rel)
        for key in ('id','status','favorite'):assert oldm[key]==newm[key]
        assert get_block(oldb,'user')==get_block(newb,'user')
    shutil.copy2(B/'wiki'/rel,W/rel)
py=Path('C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe')
def cli(*args):
    with (A/'logs'/('publish-'+args[0]+'.log')).open('a',encoding='utf-8') as log:
        result=subprocess.run([str(py),'-X','utf8',str(S/'wiki.py'),'--config',str(S/'config.json'),*args],stdout=log,stderr=log)
    if result.returncode:raise RuntimeError(f'formal CLI failed: {args}; see log and before-publication; no author approval performed')
cli('ingest-figure',eid)
newpath=W/f'layouts/{eid}.md';m,_=read_page(newpath);_,body=read_page(B/'wiki'/f'layouts/{eid}.md')
assert m['status']=='pending_signoff' and not m.get('signedoff_version')
write_page(newpath,m,body)
cli('verify-template',template.name)
cli('check-entry',eid,'--record')
cli('check-entry','scp-visualization-interface','--record')
cli('save','SCP续整理：新增GroupHeatmap点阵来源草稿与最小依赖候选；保留作者签核门')
cli('lint');cli('pending','--json')
builder=Path('C:/Users/86186/.agents/skills/sci-figure-replica/scripts/build_index.py')
figpy=Path('C:/Users/86186/.codex/venvs/sci-figure-replica/Scripts/python.exe')
subprocess.run([str(figpy),'-X','utf8',str(builder),'--gallery',str(G)],check=True)
(A/'draft-publication.json').write_text(json.dumps({'layout':eid,'status':'pending_signoff','gallery_status':'draft','author_approved':False,'candidate_closure':release['closure_hash'],'backup':str(before),'formal_source':str(G/entry),'formal_old_template_replayed':template.name,'skills_changed':False,'service_restart_needed':False},ensure_ascii=False,indent=2),encoding='utf-8')
print('Draft source published; formal template not scaffolded; author approval remains pending.')
