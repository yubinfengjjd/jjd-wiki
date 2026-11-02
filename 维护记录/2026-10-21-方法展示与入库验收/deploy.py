from pathlib import Path
import hashlib
import json
import shutil
from datetime import datetime, timezone

task=Path(__file__).resolve().parent
source=Path(r'E:\research-wiki\开发\staged\research-wiki')
replica=Path(r'E:\桌面\ARIS\sci-figure-replica-dev-20261020\staged\sci-figure-replica')
skip={'.git','__pycache__','.pytest_cache','node_modules'}
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=[p for p in source.rglob('*') if p.is_file() and not set(p.relative_to(source).parts)&skip
       and p.name!='installation-manifest.json' and p.suffix not in {'.pyc','.pyo'}]
reports=[]
for host in ('.agents','.codex','.claude'):
    target=Path(r'C:\Users\86186')/host/'skills/research-wiki'
    assert target.resolve()==target.absolute()
    records,changed,removed=[],[],[]
    def backup(dest,package='research-wiki'):
        if dest.is_file():
            base=Path(r'C:\Users\86186')/host/'skills'/package
            out=task/'backup'/host/package/dest.relative_to(base)
            out.parent.mkdir(parents=True,exist_ok=True)
            if not out.exists():shutil.copy2(dest,out)
    for p in files:
        rel=p.relative_to(source);dest=target/rel
        assert dest.resolve().is_relative_to(target)
        if not dest.is_file() or sha(dest)!=sha(p):
            backup(dest);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest);changed.append(rel.as_posix())
        assert sha(dest)==sha(p)
        records.append(dict(path=rel.as_posix(),source=str(p),target=str(dest),sha256=sha(p)))
    allowed={p.relative_to(source).as_posix() for p in files if p.is_relative_to(source/'app')}
    for dest in (target/'app').rglob('*'):
        if dest.is_file() and dest.relative_to(target).as_posix() not in allowed:
            assert dest.resolve().is_relative_to((target/'app').resolve())
            backup(dest);removed.append(dest.relative_to(target).as_posix());dest.unlink()
    manifest=target/'installation-manifest.json';backup(manifest)
    manifest.write_text(json.dumps(dict(skill='research-wiki',source=str(source),target=str(target),
        installed_at=datetime.now(timezone.utc).isoformat(),maintenance_record=str(task),
        update='Method presentation, explicit historical template origins, and aligned ingestion acceptance',
        files=records),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    reports.append(dict(host=host,skill='research-wiki',files_verified=len(records),changed=changed,old_bundles_backed_up=removed))
    target=Path(r'C:\Users\86186')/host/'skills/sci-figure-replica'
    assert target.resolve()==target.absolute()
    dest=target/'SKILL.md';backup(dest,'sci-figure-replica');shutil.copy2(replica/'SKILL.md',dest)
    mp=target/'installation-manifest.json';backup(mp,'sci-figure-replica')
    manifest=json.loads(mp.read_text(encoding='utf-8'))
    matches=[r for r in manifest['files'] if r['path']=='SKILL.md']
    assert len(matches)==1
    matches[0]['sha256']=sha(dest)
    manifest.update(installed_at=datetime.now(timezone.utc).isoformat(),maintenance_record=str(task),
                    update='Align single-panel provenance, method presentation and Wiki ingestion acceptance')
    mp.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    assert all(sha(Path(r['target']))==r['sha256'] for r in manifest['files'])
    assert sha(dest)==sha(replica/'SKILL.md')
    reports.append(dict(host=host,skill='sci-figure-replica',files_verified=len(manifest['files']),changed=['SKILL.md']))
(task/'deployment-verification.json').write_text(json.dumps(reports,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps([dict(host=r['host'],skill=r['skill'],verified=r['files_verified'],changed=len(r['changed'])) for r in reports]))
