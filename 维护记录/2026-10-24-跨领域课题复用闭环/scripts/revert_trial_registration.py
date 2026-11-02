"""Undo only this trial's unintended use record, preserving append-only audit log."""
from pathlib import Path
from datetime import datetime,timezone
import json
import shutil
import subprocess

ROOT=Path('E:/research-wiki')
AUDIT=ROOT/'维护记录/2026-10-24-跨领域课题复用闭环'
BAD='5119fa326da14210bf9ba1224d6f7d5e86bfc96a'

def git(*args):
    p=subprocess.run(['git','-C',str(ROOT),*args],check=True,capture_output=True)
    return p.stdout

if git('rev-parse','HEAD').decode().strip()!=BAD:
    raise SystemExit('HEAD changed; stop and review, never reset other history')
if git('diff','--name-only') or git('diff','--cached','--name-only'):
    raise SystemExit('tracked work/index dirty; stop rather than overwrite')
paths=[p.decode('utf-8') for p in git('diff-tree','--no-commit-id','--name-only','-r','-z',BAD).split(b'\0') if p]
if len(paths)!=5 or any(Path(p).parts[0]!='知识库' or 'source' in Path(p).parts
                       or 'original_code' in Path(p).parts for p in paths):
    raise SystemExit('unexpected commit scope; stop and review')
for rel in paths:
    target=ROOT/rel
    if not target.resolve().is_relative_to((ROOT/'知识库').resolve()):
        raise SystemExit('path escaped intended Wiki')
    if target.is_file():
        backup=AUDIT/'unintended-registration-backup'/rel
        if backup.exists():raise SystemExit('backup exists; do not overwrite')
        backup.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(target,backup)
log=ROOT/'知识库/log.md'
old_log=log.read_bytes()
git('revert','--no-commit',BAD)
stamp=datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')
note=(f'\n## [{stamp}] 撤回隔离验收误登记\n\n'
      f'验收会话误执行的使用登记（{BAD[:12]}）已撤回，正式方法/模板关联与项目页恢复。'
      '课题隔离目录中的图与运行材料继续保留，仅作软件实验；不构成方法调用验证或作者签核。'
      '本日志保留原事件并追加纠正说明，Git 留存针对性撤回记录。\n')
log.write_bytes(old_log+note.encode('utf-8'))
git('add','--','知识库/log.md')
git('-c','user.name=research-wiki','-c','user.email=research-wiki@localhost',
    'commit','-m','Revert unintended acceptance use record and retain audit log','--',*paths)
head=git('rev-parse','HEAD').decode().strip()
report={'unintended_commit':BAD,'targeted_revert_commit':head,'paths':paths,
        'log_previous_bytes_preserved':log.read_bytes().startswith(old_log),
        'scope':'only own trial registration reverted; untracked docs/work untouched; no reset/clean/stash'}
(AUDIT/'unintended-registration-recovery.json').write_text(
    json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(report,ensure_ascii=False,indent=2))
