"""Reversible, byte-preserving layout migration. Defaults to read-only --check.

Record directories must be outside moved trees. Rollback refuses changed bytes or
new files. No Git commits, package installation, source rewriting, or deployment.
"""
import argparse
import hashlib
import json
import os
import re
from pathlib import Path
import shutil
import stat
import subprocess
import sys
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor

from machine_paths import VAULT_LAYOUT, DEV_LAYOUT, resolve_dev_root


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def linked(path):
    if path.is_symlink():
        return True
    return os.name == 'nt' and path.exists() and bool(path.lstat().st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT)


def snapshot(path):
    if linked(path):
        raise ValueError(f'reparse point inside move: {path}')
    if path.is_file():
        return {'.': digest(path)}
    paths = []
    for folder, dirs, files in os.walk(path):
        for name in dirs + files:
            p = Path(folder) / name
            if linked(p):
                raise ValueError(f'reparse point inside move: {p}')
        for name in files:
            p = Path(folder) / name
            paths.append(p)
    with ThreadPoolExecutor(max_workers=8) as pool:
        hashes = pool.map(digest, paths)
        return {p.relative_to(path).as_posix(): value for p, value in zip(paths, hashes)}


def safe(root, name):
    path = root / name
    # Reject escaping or ancestor junctions before traversing/moving anything.
    path.resolve().relative_to(root.resolve())
    for parent in [path, *path.parents]:
        if parent == root:
            break
        if linked(parent):
            raise ValueError(f'reparse point: {parent}')
    return path


def preflight(repos, hash_files=True):
    moves = []
    for root, kind in repos:
        root = Path(root).resolve()
        top = subprocess.run(['git', '-C', str(root), 'rev-parse', '--show-toplevel'],
                             check=True, capture_output=True, text=True, encoding='utf-8').stdout.strip()
        if Path(top).resolve() != root:
            raise ValueError(f'not a repository root: {root}')
        mapping = VAULT_LAYOUT if kind == 'vault' else DEV_LAYOUT
        for old, new in mapping.items():
            existing_alias = root / old
            if linked(existing_alias) and (root / new).exists() and existing_alias.resolve() == (root / new).resolve():
                continue
            source, target = safe(root, old), safe(root, new)
            if source.exists() and target.exists():
                raise ValueError(f'conflict: both {source} and {target} exist')
            if source.exists():
                moves.append({'root': str(root), 'old': old, 'new': new,
                              'moved': False})
        paths = [p for pair in mapping.items() for p in pair]
        status = subprocess.run(['git', '-C', str(root), 'status', '--porcelain', '--untracked-files=all', '--', *paths],
                                capture_output=True, text=True, encoding='utf-8', check=True)
        if status.stdout.strip():
            raise ValueError(f'dirty migration paths in {root}:\n{status.stdout}')
    # Dirty/conflict rejection must be cheap, even with a large ignored node_modules tree.
    for m in moves:
        if hash_files:
            print('Hashing before: ' + m['old'], file=sys.stderr, flush=True)
        m['before'] = snapshot(Path(m['root']) / m['old']) if hash_files else {}
    return moves


def save(record, data):
    temporary = record / 'manifest.tmp'
    temporary.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    temporary.replace(record / 'manifest.json')


def rewrite_config(value, replacements):
    if isinstance(value, dict):
        return {k: rewrite_config(v, replacements) for k, v in value.items()}
    if isinstance(value, list):
        return [rewrite_config(v, replacements) for v in value]
    if isinstance(value, str):
        for old, new in sorted(replacements, key=lambda item: -len(item[0])):
            # Only path prefixes; no content/search-and-replace in user strings.
            normalized = value.replace('\\', '/')
            unc = normalized.startswith('//')
            normalized = re.sub('/+', '/', normalized)
            if unc:
                normalized = '/' + normalized
            if normalized.casefold() == old.casefold() or normalized.casefold().startswith(old.casefold() + '/'):
                return new + normalized[len(old):]
    return value


def junction(alias, target):
    if os.name == 'nt':
        env = dict(os.environ, RWIKI_ALIAS=str(alias), RWIKI_TARGET=str(target))
        subprocess.run(['powershell', '-NoProfile', '-NonInteractive', '-Command',
                        "New-Item -ItemType Junction -Path $env:RWIKI_ALIAS -Target $env:RWIKI_TARGET -ErrorAction Stop | Out-Null"],
                       env=env, check=True, capture_output=True)
    else:
        alias.symlink_to(target, target_is_directory=True)


def apply(repos, record, aliases=True):
    moves = preflight(repos)
    # Parse and validate ignored configs before the first filesystem mutation.
    for root, kind in repos:
        if kind == 'dev':
            for relative in ('staged/research-wiki/config.json', 'skills/research-wiki/config.json'):
                cfg = Path(root) / relative
                if cfg.is_file():
                    if subprocess.run(['git', '-C', str(root), 'check-ignore', '-q', str(cfg)]).returncode:
                        raise ValueError(f'local config must be Git ignored: {cfg}')
                    json.loads(cfg.read_text(encoding='utf-8'))
    record = Path(record).resolve()
    if record.exists():
        raise ValueError(f'record already exists: {record}')
    for m in moves:
        for key in ('old', 'new'):
            if record.is_relative_to(Path(m['root']) / m[key]):
                raise ValueError('record must be outside moved trees')
    record.mkdir(parents=True)
    data = {'schema_version': 1, 'created_at': datetime.now(timezone.utc).isoformat(),
            'state': 'applying', 'moves': moves, 'configs': [], 'aliases': [], 'excludes': []}
    # Backup Git metadata for audit only; rollback never overwrites newer index/HEAD.
    for index, (root, kind) in enumerate(repos):
        metadata = subprocess.run(['git', '-C', str(root), 'rev-parse', '--absolute-git-dir'],
                                  check=True, capture_output=True, text=True).stdout.strip()
        backup = record / 'metadata' / str(index)
        backup.mkdir(parents=True)
        for name in ('HEAD', 'index', 'config'):
            source = Path(metadata) / name
            if source.is_file():
                shutil.copy2(source, backup / name)
    save(record, data)
    try:
        for m in moves:
            source, target = Path(m['root']) / m['old'], Path(m['root']) / m['new']
            target.parent.mkdir(parents=True, exist_ok=True)
            m['move_intent'] = True
            save(record, data)
            source.rename(target)
            m['moved'] = True
            print('Verifying move: ' + m['old'] + ' -> ' + m['new'], file=sys.stderr, flush=True)
            m['after'] = snapshot(target)
            save(record, data)
            if m['after'] != m['before']:
                raise ValueError(f'files changed during migration; inspect journal before continuing: {target}')
        replacements = [(str(Path(m['root']) / m['old']).replace('\\', '/'),
                         str(Path(m['root']) / m['new']).replace('\\', '/')) for m in moves]
        for root, kind in repos:
            if kind != 'dev':
                continue
            cfg = Path(root) / 'skills/research-wiki/config.json'
            if not cfg.exists():
                continue
            ignored = subprocess.run(['git', '-C', str(root), 'check-ignore', '-q', str(cfg)]).returncode == 0
            if not ignored:
                raise ValueError(f'local config must be Git ignored: {cfg}')
            before = cfg.read_bytes()
            updated = rewrite_config(json.loads(before.decode('utf-8')), replacements)
            if updated == json.loads(before.decode('utf-8')):
                continue
            backup = record / f'config-{len(data["configs"])}.json'
            backup.write_bytes(before)
            after_bytes = (json.dumps(updated, ensure_ascii=False, indent=2) + '\n').encode('utf-8')
            entry = {'path': str(cfg), 'backup': backup.name, 'before': digest(backup),
                     'after': hashlib.sha256(after_bytes).hexdigest()}
            data['configs'].append(entry)
            save(record, data)
            cfg.write_bytes(after_bytes)
            save(record, data)
        # Only config bytes were modified after the verified atomic moves.
        # Check those exact files; rereading every immutable input is redundant.
        for m in moves:
            target = Path(m['root']) / m['new']
            for entry in data['configs']:
                cfg = Path(entry['path'])
                if cfg.is_relative_to(target):
                    value = digest(cfg)
                    if value != entry['after']:
                        raise ValueError('configuration changed during migration')
                    m['after'][cfg.relative_to(target).as_posix()] = value
        save(record, data)
        if aliases:
            # Ignore aliases only AFTER clean-source preflight. Repository-wide
            # legacy ignores would hide untracked author evidence before migration.
            for index, (root, kind) in enumerate(repos):
                excludes_name = subprocess.run(['git', '-C', str(root), 'rev-parse', '--git-path', 'info/exclude'],
                                               check=True, capture_output=True, text=True).stdout.strip()
                excludes = Path(excludes_name)
                if not excludes.is_absolute():
                    excludes = Path(root) / excludes
                before = excludes.read_bytes() if excludes.exists() else b''
                patterns = ['/' + m['old'] for m in moves if m['root'] == str(Path(root).resolve())
                            and (Path(m['root']) / m['new']).is_dir()]
                if not patterns:
                    continue
                updated = before + ('\n# rwiki layout compatibility junctions\n' + '\n'.join(patterns) + '\n').encode('utf-8')
                backup = record / f'exclude-{index}.bin'
                backup.write_bytes(before)
                entry = {'path': str(excludes), 'backup': backup.name, 'existed': excludes.exists(),
                         'before': digest(backup), 'after': hashlib.sha256(updated).hexdigest()}
                data['excludes'].append(entry)
                save(record, data)
                excludes.parent.mkdir(parents=True, exist_ok=True)
                excludes.write_bytes(updated)
            for m in moves:
                alias, target = Path(m['root']) / m['old'], Path(m['root']) / m['new']
                if not target.is_dir():
                    continue
                alias.parent.mkdir(parents=True, exist_ok=True)
                entry = {'path': str(alias), 'target': str(target)}
                data['aliases'].append(entry)
                save(record, data)
                junction(alias, target)
        data['state'] = 'applied'
        save(record, data)
    except Exception:
        data['state'] = 'incomplete'
        save(record, data)
        raise
    return data


def rollback(record):
    record = Path(record).resolve()
    data = json.loads((record / 'manifest.json').read_text(encoding='utf-8'))
    if data['state'] == 'rolled_back':
        raise ValueError('record already rolled back')
    pairs = set(VAULT_LAYOUT.items()) | set(DEV_LAYOUT.items())
    aliases_allowed, config_allowed = set(), set()
    for m in data['moves']:
        root = Path(m['root'])
        if not root.is_absolute() or (m['old'], m['new']) not in pairs:
            raise ValueError('invalid migration record path')
        # The old path may be our alias; validate its identity separately below.
        safe(root, m['new'])
        old, target = root / m['old'], root / m['new']
        if m.get('move_intent') and not m.get('moved') and target.exists() and not old.exists():
            # Atomic rename may have completed just before the process stopped.
            # The full before-hash comparison below must still pass.
            m['moved'] = True
        if Path(m['old']).parent != Path('.'):
            safe(root, str(Path(m['old']).parent))
        aliases_allowed.add((str(root / m['old']), str(root / m['new'])))
        if m['new'] == 'skills/research-wiki':
            config_allowed.add(str(root / m['new'] / 'config.json'))
    for entry in data['configs']:
        if entry['path'] not in config_allowed or Path(entry['backup']).name != entry['backup']:
            raise ValueError('invalid migration config record path')
    for entry in data.get('excludes', []):
        expected = []
        for root in {m['root'] for m in data['moves']}:
            value = subprocess.run(['git', '-C', root, 'rev-parse', '--git-path', 'info/exclude'],
                                   check=True, capture_output=True, text=True).stdout.strip()
            path = Path(value)
            expected.append((path if path.is_absolute() else Path(root) / path).resolve())
        if Path(entry['path']).resolve() not in expected or Path(entry['backup']).name != entry['backup']:
            raise ValueError('invalid Git exclude record path')
        allowed = (entry['after'],) if data['state'] == 'applied' else (entry['before'], entry['after'])
        current = digest(Path(entry['path'])) if Path(entry['path']).exists() else hashlib.sha256(b'').hexdigest()
        if current not in allowed or digest(record / entry['backup']) != entry['before']:
            raise ValueError(f'modified Git exclude: {entry["path"]}')
    # Validate everything before removing aliases or restoring any bytes.
    for entry in data['aliases']:
        if (entry['path'], entry['target']) not in aliases_allowed:
            raise ValueError('invalid migration alias record path')
        alias = Path(entry['path'])
        if (alias.exists() or linked(alias)) and (not linked(alias) or alias.resolve() != Path(entry['target']).resolve()):
            raise ValueError(f'modified compatibility alias: {alias}')
    for m in data['moves']:
        if m['moved']:
            target = Path(m['root']) / m['new']
            actual = snapshot(target) if target.exists() else None
            expected = dict(m.get('after', m['before']))
            # An interrupted config write may precede the final tree snapshot.
            # Accept only the explicitly journaled old/new config hashes.
            if actual is not None and data['state'] != 'applied':
                for entry in data['configs']:
                    cfg = Path(entry['path'])
                    if cfg.is_relative_to(target):
                        key = cfg.relative_to(target).as_posix()
                        if actual.get(key) in (entry['before'], entry['after']):
                            actual[key] = expected.get(key)
            if actual != expected:
                raise ValueError(f'modified migrated files: {target}')
            old = Path(m['root']) / m['old']
            if old.exists() and not any(str(old) == e['path'] for e in data['aliases']):
                raise ValueError(f'rollback conflict: {old}')
    for entry in data['configs']:
        allowed = (entry['after'],) if data['state'] == 'applied' else (entry['before'], entry['after'])
        if digest(Path(entry['path'])) not in allowed or digest(record / entry['backup']) != entry['before']:
            raise ValueError(f'modified config or backup: {entry["path"]}')
    for entry in reversed(data['aliases']):
        alias = Path(entry['path'])
        if linked(alias):
            alias.rmdir() if os.name == 'nt' else alias.unlink()
    for entry in data['configs']:
        shutil.copy2(record / entry['backup'], entry['path'])
    for entry in data.get('excludes', []):
        path = Path(entry['path'])
        if entry['existed']:
            shutil.copy2(record / entry['backup'], path)
        else:
            path.unlink()
    for m in reversed(data['moves']):
        if m['moved']:
            old = Path(m['root']) / m['old']
            old.parent.mkdir(parents=True, exist_ok=True)
            (Path(m['root']) / m['new']).rename(old)
    data['state'] = 'rolled_back'
    save(record, data)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group()
    action.add_argument('--check', action='store_true')
    action.add_argument('--apply', action='store_true')
    action.add_argument('--rollback', type=Path, metavar='RECORD')
    parser.add_argument('--repo', choices=('vault', 'dev', 'both'), default='both')
    parser.add_argument('--vault-root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--dev-root', type=Path)
    parser.add_argument('--record', type=Path)
    args = parser.parse_args()
    try:
        if args.rollback:
            rollback(args.rollback)
            return
        repos = []
        if args.repo in ('vault', 'both'):
            repos.append((args.vault_root.resolve(), 'vault'))
        if args.repo in ('dev', 'both'):
            repos.append((resolve_dev_root(args.vault_root, args.dev_root), 'dev'))
        if args.apply:
            if not args.record:
                parser.error('--apply requires --record (a new local audit directory)')
            data = apply(repos, args.record)
            result = {'state': data['state'], 'record': str(args.record.resolve()),
                      'moves': len(data['moves']), 'files': sum(len(m['after']) for m in data['moves']),
                      'aliases': len(data['aliases']), 'configs': len(data['configs'])}
        else:
            moves = preflight(repos, hash_files=False)
            result = {'check_only': True, 'moves': [{k: m[k] for k in ('root', 'old', 'new')} |
                                                   {'hashes_checked': False} for m in moves]}
        print(json.dumps(result, ensure_ascii=False, indent=2))
    except (ValueError, OSError, subprocess.CalledProcessError) as exc:
        parser.exit(1, str(exc) + '\n')


if __name__ == '__main__':
    main()
