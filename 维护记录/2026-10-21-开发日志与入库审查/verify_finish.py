import hashlib
import json
import subprocess
from pathlib import Path

HERE=Path(__file__).resolve().parent
baseline=json.loads((HERE/'protected-state.json').read_text(encoding='utf-8'))

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
checks={}
for name,root in [('wiki',Path('E:/research-wiki/知识库')),
                  ('gallery',Path('E:/research-wiki/画廊'))]:
    now={p.relative_to(root).as_posix():sha(p) for p in root.rglob('*') if p.is_file()
         and not any(part in p.parts for part in ('.git','__pycache__','.pytest_cache'))}
    assert now==baseline[name],name
    checks[name+'_files_unchanged']=len(now)
sources={'research-wiki':Path('E:/research-wiki/开发/staged/research-wiki'),
         'sci-figure-replica':Path('E:/桌面/ARIS/sci-figure-replica-dev-20261020/staged/sci-figure-replica')}
deployment=[]
for host in ('.agents','.codex','.claude'):
    for name,source in sources.items():
        target=Path('C:/Users/86186')/host/'skills'/name
        manifest=json.loads((target/'installation-manifest.json').read_text(encoding='utf-8'))
        mismatches=[]
        for row in manifest['files']:
            dest=Path(row['target']); src=source/dest.relative_to(target)
            if not src.is_file() or sha(src)!=sha(dest):mismatches.append(str(src))
        assert not mismatches,(host,name,mismatches)
        deployment.append({'host':host,'skill':name,'source_matches':len(manifest['files'])})
checks['source_and_installs']=deployment
dist=HERE/'frontend-dist'
compiled=Path('E:/research-wiki/开发/staged/research-wiki/app')
for relative in ['index.html',*['assets/'+p.name for p in (dist/'assets').glob('index-*')]]:
    assert sha(dist/relative)==sha(compiled/relative),relative
checks['fresh_build_matches_current_release']=True
status=subprocess.check_output(['git','-C','E:/research-wiki/知识库','status','--porcelain'],text=True)
assert not status,status
checks['formal_wiki_git_clean']=True
(HERE/'audit-final-verification.json').write_text(json.dumps(checks,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(checks,ensure_ascii=False))
