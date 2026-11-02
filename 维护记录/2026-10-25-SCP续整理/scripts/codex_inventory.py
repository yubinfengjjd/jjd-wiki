"""Read-only inventory; a textual pointer is not verified semantic coverage."""
from pathlib import Path
import csv, hashlib, json, re, subprocess
ROOT=Path('E:/research-wiki')
AUDIT=ROOT/'维护记录/2026-10-25-SCP续整理'
SOURCE=Path('E:/research-wiki-env/sources/scp-2026-10-22')
BASE=json.loads((AUDIT/'baseline.json').read_text(encoding='utf-8'))
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
roots={'wiki':ROOT/'知识库','gallery':ROOT/'画廊','source':SOURCE,
       'development':ROOT/'开发/staged/research-wiki'}
protections={}
for k,root in roots.items():
    differences=[]
    for rel,sha in BASE[k].items():
        p=root/rel
        if not p.is_file() or digest(p)!=sha: differences.append(rel)
    protections[k]={'checked':len(BASE[k]),'changed_or_missing':differences}
idx=subprocess.run(['git','-C',str(ROOT/'开发'),'rev-parse','--git-path','index'],check=True,capture_output=True,text=True).stdout.strip()
idx=Path(idx);idx=idx if idx.is_absolute() else ROOT/'开发'/idx
protections['development_index_unchanged']=digest(idx)==BASE['development_git_index']
(AUDIT/'codex-protection-current.json').write_text(json.dumps(protections,ensure_ascii=False,indent=2),encoding='utf-8')
exports=re.findall(r'^export\(([^)]+)\)',(SOURCE/'NAMESPACE').read_text(encoding='utf-8'),re.M)
definitions={}
for p in (SOURCE/'R').glob('*.R'):
    for num,line in enumerate(p.read_text(encoding='utf-8-sig').splitlines(),1):
        m=re.match(r'^([A-Za-z][A-Za-z0-9_.]*)\s*(?:<-|=)\s*function\b',line)
        if m: definitions.setdefault(m[1],[]).append(f'{p.relative_to(SOURCE).as_posix()}:{num}')
pages=[]
for folder in ('methods','templates'):
    for p in (ROOT/'知识库'/folder).glob('*.md'):
        pages.append((p.relative_to(ROOT/'知识库').as_posix(),p.read_text(encoding='utf-8-sig')))
rows=[]
for name in sorted(set(exports)):
    refs=[rel for rel,body in pages if re.search(r'(?<![\w.])'+re.escape(name)+r'(?![\w.])',body)]
    rows.append({'export':name,'definition':' | '.join(definitions.get(name,[])),
       'existing_textual_pointers':' | '.join(refs),'interpretation':'textual pointer only; branch coverage requires actual receipt review'})
with (AUDIT/'namespace-crosswalk.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
(AUDIT/'namespace-crosswalk.json').write_text(json.dumps({'exports':len(exports),'unique_exports':len(rows),'rows':rows},ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'exports':len(exports),'unique_exports':len(rows),'protections':protections},ensure_ascii=False))
