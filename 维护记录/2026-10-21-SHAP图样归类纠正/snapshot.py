from pathlib import Path
from urllib.request import urlopen
import hashlib
import json
import shutil
task = Path(__file__).resolve().parent
root = Path(r'E:\research-wiki\知识库')
baseline = {}
for key, folder in [('wiki',root),('gallery',root.parent/'画廊')]:
    baseline[key] = {p.relative_to(folder).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()
                     for p in folder.rglob('*') if p.is_file() and not {'.git','__pycache__'}&set(p.relative_to(folder).parts)}
assert not (task/'baseline.json').exists()
(task/'baseline.json').write_text(json.dumps(baseline,ensure_ascii=False,indent=2),encoding='utf-8')
for directory in ('methods','templates','layouts'):
    for page in (root/directory).glob('*.md'):
        dest = task/'before'/page.relative_to(root)
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(page,dest)
for endpoint in ('pages','graph'):
    with urlopen('http://127.0.0.1:8765/api/'+endpoint) as stream:
        (task/f'{endpoint}.json').write_bytes(stream.read())
print('Baseline and API comparison fixtures saved.')
