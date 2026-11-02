from pathlib import Path
import hashlib,json,re,subprocess,sys
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP续整理')
ROOT=Path('E:/research-wiki');B=Path('E:/research-wiki-env/work/scp-ingestion-20261025')
sys.path.insert(0,str(ROOT/'开发/staged/research-wiki'))
from rwiki.pages import parse_page,get_block,read_page
baseline=json.loads((A/'baseline.json').read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
result={}
for k,root in [('gallery',ROOT/'画廊'),('source',Path('E:/research-wiki-env/sources/scp-2026-10-22')),('development',ROOT/'开发/staged/research-wiki')]:
    changed=[rel for rel,h in baseline[k].items() if not(root/rel).is_file() or sha(root/rel)!=h]
    if k=='gallery':assert set(changed)<= {'index.html','index.json'},changed
    else:assert not changed,changed
    result[k]={'checked':len(baseline[k]),'changed':changed}
originals=[rel for rel in baseline['wiki'] if '/source/' in rel or '/original_code/' in rel or '/code/SCP-local/' in rel]
assert all(sha(ROOT/'知识库'/rel)==baseline['wiki'][rel] for rel in originals)
result['wiki_original_files_unchanged']=len(originals)
protected=[]
for rel in baseline['wiki']:
    if not re.fullmatch(r'(methods|templates|layouts)/[^/]+\.md',rel):continue
    current=ROOT/'知识库'/rel
    # Git's clean filter normalizes CRLF. Exact current baseline SHA is a
    # stronger check for untouched pages; changed pages use byte backups.
    if sha(current)==baseline['wiki'][rel]:
        protected.append(rel)
        continue
    before=A/'before-publication/wiki'/rel
    assert before.is_file() and sha(before)==baseline['wiki'][rel],(rel,'missing exact baseline backup')
    old=before.read_bytes().decode('utf-8')
    om,ob,error=parse_page(old);assert error is None,(rel,error)
    nm,nb=read_page(ROOT/'知识库'/rel)
    for key in ('id','status','favorite','signedoff_version','gallery_version','template_panels'):
        assert om.get(key)==nm.get(key),(rel,key)
    assert get_block(ob,'user')==get_block(nb,'user'),(rel,'author bytes')
    protected.append(rel)
result['protected_existing_pages']=len(protected)
idx=subprocess.run(['git','-C',str(ROOT/'开发'),'rev-parse','--git-path','index'],capture_output=True,text=True,check=True).stdout.strip()
idx=Path(idx);idx=idx if idx.is_absolute() else ROOT/'开发'/idx
result['development_index_unchanged']=sha(idx)==baseline['development_git_index'];assert result['development_index_unchanged']
eid='2026-10-22-scp-example__fig17-group-heatmap-dot'
meta,_=read_page(ROOT/'知识库/layouts'/f'{eid}.md')
gallery=ROOT/'画廊/2026-10-22-scp-example/figures/fig17-group-heatmap-dot'
gm=json.loads((gallery/'meta.json').read_text(encoding='utf-8'))
assert meta['status']=='pending_signoff' and gm['status']=='draft' and not meta.get('signedoff_version')
raw=Path('E:/research-wiki-env/sources/scp-2026-10-22/R/SCP-plot.R').read_bytes().splitlines(keepends=True)
assert (gallery/'original_code/groupheatmap.R').read_bytes()==b''.join(raw[7910:9036])
assert not (ROOT/'知识库/templates'/f'{eid}--heatmap.md').exists()
result['new_source']={'layout':meta['status'],'gallery':gm['status'],'exact_original_excerpt':True,'author_approval':False,'formal_template_created':False}
changed=[rel for rel,h in baseline['wiki'].items() if sha(ROOT/'知识库'/rel)!=h]
result['wiki_changed']=changed
(A/'codex-post-publication.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False))
