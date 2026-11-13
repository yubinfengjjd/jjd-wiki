"""Deploy this reviewed local queue fix; back up changed files and check every hash."""
from pathlib import Path
import hashlib
import json
import shutil
from datetime import datetime, timezone

task = Path(__file__).resolve().parent
source = Path(r'E:\research-wiki\开发\staged\research-wiki')
skip = {'.git', '__pycache__', '.pytest_cache', 'node_modules'}
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
files = [p for p in source.rglob('*') if p.is_file() and not set(p.relative_to(source).parts)&skip
         and p.name != 'installation-manifest.json' and p.suffix not in {'.pyc', '.pyo'}]
report = []
for host in ('.agents', '.codex', '.claude'):
    target = Path(r'C:\Users\86186')/host/'skills/research-wiki'
    assert target.resolve() == target.absolute()
    records, changed, removed = [], [], []
    def backup(dest):
        if dest.is_file():
            back = task/'backup'/host/dest.relative_to(target)
            back.parent.mkdir(parents=True, exist_ok=True)
            if not back.exists():
                shutil.copy2(dest, back)
    for p in files:
        rel = p.relative_to(source)
        dest = target/rel
        assert dest.resolve().is_relative_to(target)
        if not dest.is_file() or sha(dest) != sha(p):
            backup(dest)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(p, dest)
            changed.append(rel.as_posix())
        assert sha(dest) == sha(p)
        records.append(dict(path=rel.as_posix(), source=str(p), target=str(dest), sha256=sha(p)))
    allowed = {p.relative_to(source).as_posix() for p in files if p.is_relative_to(source/'app')}
    for dest in (target/'app').rglob('*'):
        if dest.is_file() and dest.relative_to(target).as_posix() not in allowed:
            assert dest.resolve().is_relative_to((target/'app').resolve())
            backup(dest)
            removed.append(dest.relative_to(target).as_posix())
            dest.unlink()
    manifest = target/'installation-manifest.json'
    backup(manifest)
    manifest.write_text(json.dumps(dict(skill='research-wiki', source=str(source),target=str(target),
        installed_at=datetime.now(timezone.utc).isoformat(),maintenance_record=str(task),
        update='Derived remaining-action queue shared by CLI, API and frontend; no signoff state rewrites',
        files=records),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    report.append(dict(host=host, files_verified=len(records), changed=changed, old_bundles_backed_up=removed))
(task/'deployment-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps([dict(host=x['host'], verified=x['files_verified'], changed=len(x['changed'])) for x in report]))
