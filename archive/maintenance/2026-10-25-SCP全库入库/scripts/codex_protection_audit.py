"""Compare immutable inputs and author-controlled fields to the isolated baseline."""
from pathlib import Path
import hashlib, json, re, sys, subprocess
A = Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
R = Path('E:/research-wiki')
B = Path('E:/research-wiki-env/work/scp-full-ingest-20261025')
sys.path.insert(0,str(B/'development/staged/research-wiki'))
from rwiki.pages import read_page,parse_page
base = json.loads((A/'baseline.json').read_text(encoding='utf-8'))
post = json.loads((A/'post-p0-baseline.json').read_text(encoding='utf-8'))
def hash_file(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def delta(root,expected):
    return [rel for rel,h in expected.items() if not (root/rel).is_file() or hash_file(root/rel)!=h]
def author(body):
    m=re.search(r'<!-- user:start -->(.*?)<!-- user:end -->',body,re.S)
    return m.group(0) if m else None
initial_commit=subprocess.run(['git','-C',str(B/'wiki'),'rev-list','--max-parents=0','HEAD'],capture_output=True,text=True,check=True).stdout.strip().splitlines()[0]
def states(other):
    bad=[]
    for name in base['wiki']:
        rel=Path(name)
        if rel.suffix!='.md':continue
        if len(rel.parts)!=2 or rel.parts[0] not in {'methods','templates','layouts','chart-types','interfaces','projects'}: continue
        q=other/rel
        if not q.is_file(): continue
        raw=subprocess.run(['git','-C',str(B/'wiki'),'show',initial_commit+':'+rel.as_posix()],capture_output=True,check=True).stdout
        m,b,error=parse_page(raw.decode('utf-8'));assert not error
        n,c=read_page(q)
        for field in ['id','status','favorite','archived_from']:
            if m.get(field)!=n.get(field): bad.append({'page':str(rel),'field':field,'baseline':m.get(field),'current':n.get(field)})
        if author(b) is None and author(c) is None:continue
        # Git normalized some initial CRLF bytes. Do not confuse that with an edit.
        if other == R/'知识库':
            if hash_file(q) in {base['wiki'][name],post['wiki'].get(name)}:continue
            backup=A/'before-confirmed-dot'/rel
            if not backup.is_file():backup=A/'before-confirmed-dot'/rel.name
            if not backup.is_file() or hash_file(backup)!=base['wiki'][name]:
                bad.append({'page':str(rel),'field':'user_baseline_requires_raw_backup'});continue
            _,b=read_page(backup)
        else:
            # Formal raw bytes are independently protected above; P0 changed no author text.
            _,b=read_page(R/'知识库'/rel)
        if author(b)!=author(c):bad.append({'page':str(rel),'field':'user'})
    return bad
report={
 'fixed_source_changes':delta(Path('E:/research-wiki-env/sources/scp-2026-10-22'),base['source']),
 'formal_development_changes':delta(R/'开发/staged/research-wiki',base['development']),
 'formal_wiki_changes_since_post_p0':delta(R/'知识库',post['wiki']),
 'formal_original_asset_changes':[rel for rel in delta(R/'知识库',base['wiki']) if set(Path(rel).parts)&{'source','original_code'}],
 'initial_fixture_commit':initial_commit,
 'author_comparison_policy':'Formal unchanged files use original or independently checked post-P0 whole-file SHA256; changed pages require original raw backups. Git is used only for metadata because it normalized some CRLF. Isolated author bytes compare to protected formal bytes.',
 'formal_author_state_delta_from_pre_p0':states(R/'知识库'),
 'isolated_author_state_delta_from_pre_p0':states(B/'wiki'),
 'scope':'The explicitly approved fig17 P0 state change is expected; inspect all others. No status reset or source overwrite authorized.'}
(A/'codex-protection-current.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:(len(v) if isinstance(v,list) else v) for k,v in report.items()},ensure_ascii=False))
