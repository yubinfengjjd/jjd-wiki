from pathlib import Path
import json,hashlib,shutil,subprocess
base=Path(r'E:\research-wiki')
out=base/'维护记录'/'2026-10-21-方法复用与课题推荐升级'
skip={'.git','node_modules','__pycache__','.pytest_cache'}
def snap(src,dest):
    files={}
    for p in src.rglob('*'):
        if not p.is_file() or any(x in skip for x in p.relative_to(src).parts): continue
        rel=p.relative_to(src); files[rel.as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
        if dest:
            target=dest/rel; target.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(p,target)
    return files
records={}
for name,path in [('development',base/'开发'/'staged'/'research-wiki'),('frontend',base/'开发'/'frontend'),('wiki',base/'知识库')]:
    records[name]=snap(path,out/'baseline'/name)
records['gallery']=snap(base/'画廊',None)
for host in ['.agents','.codex','.claude']:
    for skill in ['research-wiki','sci-figure-replica']:
        p=Path(r'C:\Users\86186')/host/'skills'/skill
        records[host+'/'+skill]=snap(p,out/'baseline'/'installed'/host/skill)
rep=Path(r'E:\桌面\ARIS\sci-figure-replica-dev-20261020\staged\sci-figure-replica')
records['replica_source']=snap(rep,out/'baseline'/'replica-source')
(out/'baseline.json').write_text(json.dumps(records,ensure_ascii=False,indent=2),encoding='utf-8')
for name,path in [('development',base/'开发'),('wiki',base/'知识库')]:
    (out/(name+'-status-before.txt')).write_text(subprocess.check_output(['git','-C',str(path),'status','--short'],encoding='utf-8'),encoding='utf-8')
print({k:len(v) for k,v in records.items()})
