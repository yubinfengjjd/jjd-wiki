"""Create a trial-local candidate skill whose default library is isolated."""
from pathlib import Path
import hashlib
import json
import os
import shutil

AUDIT=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
SOURCE=Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/development/staged/research-wiki')
PILOT=Path('E:/青光眼单细胞/wiki-use/acceptance-20261024')
FIXTURE=Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/pilot-evidence/wiki')
DEST=PILOT/'.agents/skills/research-wiki'
SKIP={'.git','__pycache__','.pytest_cache','node_modules'}

def hashes(root):
    out={}
    for d,dirs,files in os.walk(root):
        dirs[:]=[n for n in dirs if n not in SKIP]
        for n in files:
            p=Path(d)/n
            if p.suffix not in ('.pyc','.pyo'):
                out[p.relative_to(root).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
    return out

if not FIXTURE.is_dir():raise SystemExit('isolated Wiki fixture missing')
before=hashes(SOURCE)
if DEST.exists():
    if not getattr(DEST,'is_junction',lambda:False)() or DEST.resolve()!=SOURCE.resolve():
        raise SystemExit('unexpected existing trial skill; preserve and review')
    archive=PILOT/'evidence/source-skill-link-original'
    if archive.exists():raise SystemExit('link archive exists; never overwrite')
    archive.parent.mkdir(parents=True,exist_ok=True)
    # Rename the link object itself, never traverse/copy/delete its target.
    os.rename(DEST,archive)
shutil.copytree(SOURCE,DEST,ignore=shutil.ignore_patterns(*SKIP))
if hashes(DEST)!=before or hashes(SOURCE)!=before:
    raise SystemExit('source changed or copy mismatch; do not use trial skill')
config_path=DEST/'config.json'
config=json.loads(config_path.read_text(encoding='utf-8'))
config.update(wiki_root=str(FIXTURE),port=8879)
config_path.write_text(json.dumps(config,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
old_rules=FIXTURE/'AGENTS.md'
rule_backup=AUDIT/'a25-fixture-original-AGENTS.md'
if rule_backup.exists():raise SystemExit('fixture rule backup exists; preserve and review')
shutil.copy2(old_rules,rule_backup)
shutil.copy2(SOURCE/'assets/AGENTS.md',old_rules)
report={'candidate_source':str(SOURCE),'trial_skill':str(DEST),
        'isolated_library':str(FIXTURE),'source_hashes':before,
        'trial_hashes':hashes(DEST),'intentional_config_override':['wiki_root','port'],
        'fixture_rule_override':{'path':'AGENTS.md',
            'source':'reviewed candidate assets/AGENTS.md',
            'sha256':hashlib.sha256(old_rules.read_bytes()).hexdigest()},
        'scope':'trial-local management skill copy, not dependency/global installation; no production writes'}
(AUDIT/'a25-trial-skill-before-phase2.json').write_text(
    json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'trial_skill':str(DEST),'files':len(before),
                  'default_library_isolated':True},ensure_ascii=False))
