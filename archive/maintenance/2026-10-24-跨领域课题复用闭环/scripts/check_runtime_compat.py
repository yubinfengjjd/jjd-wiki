"""Compare current real-library manifest facts with pre-edit parser."""
import importlib.util
import json
from pathlib import Path

ROOT = Path('E:/research-wiki')
AUDIT = ROOT / '维护记录/2026-10-24-跨领域课题复用闭环'
WORK = Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/development')


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main():
    old = module('old_runtime', AUDIT / 'before/development/staged/research-wiki/rwiki/runtime_contract.py')
    new = module('new_runtime', WORK / 'staged/research-wiki/rwiki/runtime_contract.py')
    compared, regressions, newly_parsed = [], [], []
    for category, kind in [('methods', 'method'), ('templates', 'template')]:
        for manifest in sorted((ROOT / '知识库' / category).glob('*/runtime.json')):
            asset = manifest.parent
            entry_id = asset.name
            old_m, old_errors = old.read_manifest(asset, entry_id, kind)
            new_m, new_errors = new.read_manifest(asset, entry_id, kind)
            if old_m is None:
                if new_m is not None:
                    newly_parsed.append({'asset': str(asset), 'prior_issues': old_errors})
                continue
            if new_m is None:
                regressions.append({'asset': str(asset), 'issues': new_errors})
                continue
            for old_i, new_i in zip(old_m['implementations'], new_m['implementations']):
                before = old.closure_hash(asset, old_i)
                after = new.closure_hash(asset, new_i)
                compared.append(f'{category}/{entry_id}/{old_i["id"]}')
                if before != after:
                    regressions.append({'asset': str(asset), 'implementation': old_i['id'],
                                        'before': before, 'after': after})
    return {'compared_existing_implementations': len(compared), 'regressions': regressions,
            'newly_parseable_assets': newly_parsed}


if __name__ == '__main__':
    result = main()
    print(json.dumps(result, ensure_ascii=False, indent=2))
    raise SystemExit(bool(result['regressions']))
