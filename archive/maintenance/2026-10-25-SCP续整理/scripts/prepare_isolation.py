"""Snapshot current sources for the authorized SCP ingestion continuation."""
from pathlib import Path
import hashlib,json,shutil,subprocess
ROOT=Path('E:/research-wiki');A=ROOT/'维护记录/2026-10-25-SCP续整理'
B=Path('E:/research-wiki-env/work/scp-ingestion-20261025')
if B.exists():
 assert not (A/'baseline.json').exists(),'Prepared task exists; inspect instead of recreating'
 assert (B/'wiki/AGENTS.md').read_bytes()==(ROOT/'知识库/AGENTS.md').read_bytes(),'Unrecognized partial snapshot'
else:B.mkdir(parents=True)
skip=shutil.ignore_patterns('.git','node_modules','__pycache__','.pytest_cache','.obsidian','*.pyc','*.pyo')
for src,dst in ((ROOT/'开发/staged/research-wiki',B/'development/staged/research-wiki'),
                (ROOT/'开发/frontend',B/'development/frontend'),
                (ROOT/'知识库',B/'wiki'),(ROOT/'画廊',B/'gallery'),
                (ROOT/'开发/spec',B/'development/spec')):
 if src.exists() and not dst.exists():shutil.copytree(src,dst,ignore=skip)
fixture=ROOT/'开发/codex/R1-migrate.py';dst=B/'development/codex/R1-migrate.py'
dst.parent.mkdir(parents=True,exist_ok=True)
if dst.exists():assert dst.read_bytes()==fixture.read_bytes()
else:shutil.copy2(fixture,dst)
def hashes(root):
 out={}
 for p in root.rglob('*'):
  if p.is_file() and not set(p.relative_to(root).parts)&{'.git','__pycache__','.pytest_cache','.obsidian','node_modules'}:
   h=hashlib.sha256()
   with p.open('rb') as f:
    for c in iter(lambda:f.read(1<<20),b''):h.update(c)
   out[p.relative_to(root).as_posix()]=h.hexdigest()
 return out
baseline={'wiki':hashes(ROOT/'知识库'),'gallery':hashes(ROOT/'画廊'),
 'source':hashes(Path('E:/research-wiki-env/sources/scp-2026-10-22')),
 'development':hashes(ROOT/'开发/staged/research-wiki')}
baseline['development_git_status']=subprocess.run(['git','-C',str(ROOT/'开发'),'status','--porcelain=v1'],capture_output=True,text=True,check=True).stdout
index=subprocess.run(['git','-C',str(ROOT/'开发'),'rev-parse','--git-path','index'],capture_output=True,text=True,check=True).stdout.strip()
ip=Path(index);ip=ip if ip.is_absolute() else ROOT/'开发'/ip
baseline['development_git_index']=hashlib.sha256(ip.read_bytes()).hexdigest()
(A/'baseline.json').write_text(json.dumps(baseline,ensure_ascii=False,indent=2),encoding='utf-8')
cp=B/'development/staged/research-wiki/config.json';cfg=json.loads(cp.read_text(encoding='utf-8'))
cfg.update(wiki_root=str(B/'wiki'),gallery_root=str(B/'gallery'),port=8880)
cp.write_text(json.dumps(cfg,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
client=(ROOT/'维护记录/2026-10-24-跨领域课题复用闭环/scripts/devin_acp_client.py').read_text(encoding='utf-8')
client=client.replace('BASE = Path("E:/research-wiki-env/work/wiki-cross-domain-20261024")','BASE = Path("E:/research-wiki-env/work/scp-ingestion-20261025")')
client=client.replace('RECORD = Path("E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环")','RECORD = Path("E:/research-wiki/维护记录/2026-10-25-SCP续整理")')
(A/'scripts/devin_acp_client.py').write_text(client,encoding='utf-8')
print(json.dumps({'workspace':str(B),'baseline_files':{k:len(v) for k,v in baseline.items() if isinstance(v,dict)},'production_untouched':True},ensure_ascii=False))
