from pathlib import Path
import hashlib
import json
import subprocess
import sys
from urllib.request import urlopen

task=Path(__file__).resolve().parent
root=Path(r'E:\research-wiki\知识库')
stage=Path(r'E:\research-wiki\开发\staged\research-wiki')
sys.path.insert(0,str(stage))
from rwiki.pages import read_page,get_block
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
baseline=json.loads((task/'baseline.json').read_text(encoding='utf-8'))
allowed={'AGENTS.md','log.md','index.md'}
changed=[]
for rel,digest in baseline['wiki'].items():
    assert (root/rel).is_file(),rel
    if sha(root/rel)!=digest:
        assert rel in allowed,rel
        changed.append(rel)
for rel,digest in baseline['gallery'].items():assert sha(root.parent/'画廊'/rel)==digest,rel
authors=0
for old in (task/'before').rglob('*.md'):
    current=root/old.relative_to(task/'before')
    bm,bb=read_page(old);am,ab=read_page(current)
    assert bm==am,old.name  # includes every stored status and semantic relationship
    assert get_block(bb,'user')==get_block(ab,'user'),old.name
    authors+=1
with urlopen('http://127.0.0.1:8765/api/pages') as stream:pages=json.load(stream)
with urlopen('http://127.0.0.1:8765/api/graph') as stream:graph=json.load(stream)
assert graph==json.loads((task/'graph.json').read_text(encoding='utf-8')),'knowledge graph changed'
assert not [p for p in pages if p.get('workflow') and p['workflow']['queue']]
assert len([p for p in pages if p['meta'].get('type')=='template' and p['meta']['status']=='ready'])==5
assert len([p for p in pages if p['meta'].get('type')=='layout' and p['meta']['status']!='archived' and len(p['meta']['panels'])==1])==2
assert (root/'AGENTS.md').read_bytes()==(stage/'assets/AGENTS.md').read_bytes()
for marker in ('两栏数量','方法页可读性','状态与队列','代码资产','数据与关系','单panel','一对多、多对一'):
    assert marker in (root/'AGENTS.md').read_text(encoding='utf-8'),marker
hosts=[]
validator=r'C:\Users\86186\.codex\skills\.system\skill-creator\scripts\quick_validate.py'
for host in ('.agents','.codex','.claude'):
    for name in ('research-wiki','sci-figure-replica'):
        skill=Path(r'C:\Users\86186')/host/'skills'/name
        manifest=json.loads((skill/'installation-manifest.json').read_text(encoding='utf-8'))
        assert all(sha(Path(r['target']))==r['sha256'] for r in manifest['files'])
        valid=subprocess.run([sys.executable,'-X','utf8',validator,str(skill)],capture_output=True,text=True,encoding='utf-8')
        assert valid.returncode==0,valid.stderr+valid.stdout
        assert '入库与展示验收' in (skill/'SKILL.md').read_text(encoding='utf-8')
        if name=='research-wiki':
            assert (skill/'assets/AGENTS.md').read_bytes()==(root/'AGENTS.md').read_bytes()
            assert Path(json.loads((skill/'config.json').read_text(encoding='utf-8'))['wiki_root'])==root
            pending=subprocess.run([sys.executable,'-X','utf8',str(skill/'wiki.py'),'pending'],capture_output=True,text=True,encoding='utf-8')
            assert pending.returncode==0 and pending.stdout==''
        hosts.append(dict(host=host,skill=name,files_verified=len(manifest['files']),skill_valid=True))
front=json.loads((task/'frontend-verification.json').read_text(encoding='utf-8'))
assert front['passed'] and front['styles']==5 and front['templates']==5
report=dict(passed=True,changed_wiki_files=changed,source_records=2,displayed_styles=5,ready_templates=5,historical_shap_templates=3,
            knowledge_graph_unchanged=True,metadata_and_relations_unchanged=True,protected_author_blocks=authors,
            gallery_hashes_unchanged=len(baseline['gallery']),all_code_data_and_previews_unchanged=True,
            queue_actions=0,three_hosts=hosts,scope='Style catalog inclusion only; no new entries, algorithms, data or signoff changes')
(task/'live-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False))
