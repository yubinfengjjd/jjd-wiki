import json, shutil, sys
from pathlib import Path
sys.path.insert(0, 'scripts')
import install_modules as im
record = Path('.').resolve()
for method, config in im.MODULES.items():
    asset = im.WIKI / 'methods' / method
    manifest = json.loads((asset / 'runtime.json').read_text(encoding='utf-8'))
    impls = {item['id']: item for item in manifest['implementations']}
    for iid, key in config['portability'].items():
        target = record / 'portability' / key / 'code'
        if target.exists():
            shutil.rmtree(target)
        target.mkdir(parents=True)
        for name in impls[iid]['files']:
            source = asset / name
            relative = Path(name).relative_to('code')
            destination = target / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
        print(key, '->', ', '.join(impls[iid]['files']))
