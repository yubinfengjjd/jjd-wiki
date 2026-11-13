from pathlib import Path
import hashlib
import json
import shutil
from datetime import datetime, timezone

task = Path(__file__).resolve().parent
sources = {
    'research-wiki': Path(r'E:\research-wiki\开发\staged\research-wiki'),
    'sci-figure-replica': Path(r'E:\桌面\ARIS\sci-figure-replica-dev-20261020\staged\sci-figure-replica')}
skip = {'.git', '__pycache__', '.pytest_cache', 'node_modules'}
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
reports = []
for host in ['.agents', '.codex', '.claude']:
    for name, src in sources.items():
        target = (Path(r'C:\Users\86186')/host/'skills'/name).resolve()
        assert target == Path(r'C:\Users\86186')/host/'skills'/name
        files = [p for p in src.rglob('*') if p.is_file() and not set(p.relative_to(src).parts)&skip
                 and p.name != 'installation-manifest.json' and p.suffix not in {'.pyc', '.pyo'}]
        records, changed = [], []
        for p in files:
            rel = p.relative_to(src)
            dest = target/rel
            assert dest.resolve().is_relative_to(target)
            if not dest.exists() or sha(dest) != sha(p):
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(p, dest)
                changed.append(rel.as_posix())
            assert sha(dest) == sha(p)
            records.append({'path':rel.as_posix(),'source':str(p),'target':str(dest),'sha256':sha(p)})
        # Vite replaces only its own app tree. Remove obsolete installed hashed
        # bundles there, already backed up at T00, to keep the deployed app exact.
        removed = []
        if name == 'research-wiki':
            allowed = {p.relative_to(src).as_posix() for p in files if p.is_relative_to(src/'app')}
            app = (target/'app').resolve()
            assert app.is_relative_to(target)
            for p in app.rglob('*'):
                if p.is_file() and p.relative_to(target).as_posix() not in allowed:
                    assert p.resolve().is_relative_to(app)
                    removed.append(p.relative_to(target).as_posix())
                    p.unlink()
        manifest = {'skill':name,'source':str(src),'target':str(target),
                    'installed_at':datetime.now(timezone.utc).isoformat(),
                    'maintenance_record':str(task),'update':'Bounded method families, explicit many-to-many relations, readonly native code, project discovery and adaptation',
                    'files':records}
        (target/'installation-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
        reports.append({'host':host,'skill':name,'files_verified':len(records),'changed':changed,'old_app_assets_removed':removed})
(task/'deployment-verification.json').write_text(json.dumps(reports,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps([dict(host=x['host'],skill=x['skill'],verified=x['files_verified'],changed=len(x['changed'])) for x in reports]))
