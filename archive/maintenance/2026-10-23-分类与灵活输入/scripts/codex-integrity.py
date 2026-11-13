import sys,json,hashlib,re,subprocess
from pathlib import Path
sys.path.insert(0,'E:/research-wiki/开发/staged/research-wiki')
from rwiki.pages import read_page
import yaml
record=Path('E:/research-wiki/维护记录/2026-10-23-分类与灵活输入')
wiki=Path('E:/research-wiki/知识库')
baseline=(record/'wiki-baseline-head.txt').read_text(encoding='utf-8-sig').strip()
hashes=json.loads((record/'source-hashes-before.json').read_text(encoding='utf-8-sig'))
changed=[name for name,sha in hashes.items() if not Path(name).is_file() or hashlib.sha256(Path(name).read_bytes()).hexdigest()!=sha]
files=subprocess.check_output(['git','-C',str(wiki),'ls-tree','-r','--name-only',baseline],text=True,encoding='utf-8').splitlines()
fields=('id','status','favorite','archived_from')
protected=[]
count=0
for name in files:
    if not name.endswith('.md') or len(name.split('/'))!=2 or name.split('/')[0] not in ('methods','templates','layouts'):continue
    old=subprocess.check_output(['git','-C',str(wiki),'show',f'{baseline}:{name}'],text=True,encoding='utf-8')
    old_meta=yaml.safe_load(old.split('---',2)[1])
    current=wiki/name
    if not current.is_file():protected.append({'page':name,'error':'removed'});continue
    new_meta,new_body=read_page(current)
    for field in fields:
        if old_meta.get(field)!=new_meta.get(field):protected.append({'page':name,'field':field})
    block=lambda s: re.search(r'<!-- user:start -->(.*?)<!-- user:end -->',s,re.S).group(1)
    if block(old)!=block(current.read_text(encoding='utf-8')):protected.append({'page':name,'field':'user'})
    count+=1
out={'source_files':len(hashes),'source_changes':changed,'pages_checked':count,'protected_changes':protected,
     'rules_same_bytes':(wiki/'AGENTS.md').read_bytes()==Path('E:/research-wiki/开发/staged/research-wiki/assets/AGENTS.md').read_bytes()}
(record/'codex-integrity.json').write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(out,ensure_ascii=False,indent=2))
assert not changed and not protected and out['rules_same_bytes']
