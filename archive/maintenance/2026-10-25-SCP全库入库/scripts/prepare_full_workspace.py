from pathlib import Path
import hashlib,json,shutil,subprocess,datetime
R=Path('E:/research-wiki');A=R/'维护记录/2026-10-25-SCP全库入库'
B=Path('E:/research-wiki-env/work/scp-full-ingest-20261025')
assert not B.exists(),'Full task already prepared; inspect instead of repeating'
B.mkdir(parents=True);(A/'logs').mkdir(exist_ok=True)
ignore=shutil.ignore_patterns('.git','node_modules','__pycache__','.pytest_cache','.obsidian','*.pyc')
for src,dst in [(R/'知识库',B/'wiki'),(R/'画廊',B/'gallery'),(R/'开发/staged/research-wiki',B/'development/staged/research-wiki'),(R/'开发/frontend',B/'development/frontend'),(R/'开发/spec',B/'development/spec')]:
    shutil.copytree(src,dst,ignore=ignore)
def hashes(root):
    return {p.relative_to(root).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in root.rglob('*') if p.is_file() and not set(p.relative_to(root).parts)&{'.git','node_modules','__pycache__','.pytest_cache','.obsidian'}}
data={k:hashes(p) for k,p in [('wiki',R/'知识库'),('gallery',R/'画廊'),('development',R/'开发/staged/research-wiki'),('source',Path('E:/research-wiki-env/sources/scp-2026-10-22'))]}
index=subprocess.run(['git','-C',str(R/'开发'),'rev-parse','--git-path','index'],capture_output=True,text=True,check=True).stdout.strip();ip=Path(index);ip=ip if ip.is_absolute() else R/'开发'/ip
data['development_index']=hashlib.sha256(ip.read_bytes()).hexdigest()
(A/'baseline.json').write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')
cfg=B/'development/staged/research-wiki/config.json';c=json.loads(cfg.read_text(encoding='utf-8'));c.update(wiki_root=str(B/'wiki'),gallery_root=str(B/'gallery'),port=8882);cfg.write_text(json.dumps(c,ensure_ascii=False,indent=2),encoding='utf-8')
client=(R/'维护记录/2026-10-25-SCP续整理/scripts/devin_acp_client.py').read_text(encoding='utf-8').replace('E:/research-wiki-env/work/scp-ingestion-20261025','E:/research-wiki-env/work/scp-full-ingest-20261025').replace('E:/research-wiki/维护记录/2026-10-25-SCP续整理','E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
(A/'scripts/devin_acp_client.py').write_text(client,encoding='utf-8')
shutil.copy2(R/'文档/SCP持续入库与新规则/full-library-plan.md',B/'full-library-plan.md')
subprocess.run(['git','-C',str(B/'wiki'),'init','-b','codex/scp-full-baseline'],capture_output=True,check=True)
subprocess.run(['git','-C',str(B/'wiki'),'add','-A'],capture_output=True,check=True)
subprocess.run(['git','-C',str(B/'wiki'),'-c','user.name=research-wiki','-c','user.email=research-wiki@localhost','commit','-qm','isolate current formal wiki baseline'],capture_output=True,check=True)
state={'status':'preparing_full_ingestion','scope':'ALL SCP analysis methods and visualizations, not one chart','workspace':str(B),'source_commit':'b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0','source_exports':142,'coding_owner':'Devin CLI swe-2-max','review_owner':'Codex','author_confirmed_fig17':True,'all_new_others_author_approved':False,'no_install':True,'no_codex_subagents':True,'paper_harness_prohibited':True,'baseline_precedes_confirmed_dot_publication':True,'updated_at':datetime.datetime.now(datetime.timezone.utc).isoformat()}
(A/'task-state.json').write_text(json.dumps(state,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'workspace':str(B),'baseline_counts':{k:len(v) for k,v in data.items() if isinstance(v,dict)}},ensure_ascii=False))
