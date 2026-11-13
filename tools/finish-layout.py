"""Finish a deferred layout migration after applications release directory handles.

Run with the approved Python interpreter. No asset download, dependency installation,
Git push, or scientific execution occurs. Skill deployment uses the existing gate,
which may fetch Git references when HEAD differs from local main.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from machine_paths import resolve_dev_root, VAULT_LAYOUT


def run(args, **kwargs):
    return subprocess.run([str(arg) for arg in args], check=True, **kwargs)


def git(root, *args):
    return run(['git', '-C', root, *args], capture_output=True).stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--record', required=True, type=Path,
                        help='new external audit directory; never reuse a migration journal')
    parser.add_argument('--vault-root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    vault = args.vault_root.resolve()
    dev = resolve_dev_root(vault)
    record = args.record.resolve()
    if record.exists():
        parser.error('record already exists; choose a new audit directory')
    if record.is_relative_to(vault) or record.is_relative_to(dev):
        parser.error('use an external audit directory to keep both worktrees clean')
    for root in (vault, dev):
        if git(root, 'status', '--porcelain').strip():
            parser.error(f'uncommitted changes: {root}; preserve and commit them before migration')
    original = {}
    for item in git(vault, 'ls-files', '-sz').decode('utf-8').split('\0'):
        if not item:
            continue
        header, name = item.split('\t', 1)
        for old, new in VAULT_LAYOUT.items():
            if name.startswith(old + '/') and not (vault / new).exists():
                original[name] = (new + name[len(old):], header.split()[1])
                break
    record.mkdir(parents=True)
    (record / 'tracked-map.json').write_text(json.dumps(original, ensure_ascii=False, indent=2), 'utf-8')
    try:
        run([sys.executable, '-X', 'utf8', vault / 'tools/migrate-layout.py', '--apply',
             '--vault-root', vault, '--dev-root', dev, '--record', record / 'layout'])
        names = [target for target, _ in original.values()]
        # Explicitly preserve previously tracked materials even when current ignore
        # rules exclude their suffix. Never force-add unrelated local files.
        for offset in range(0, len(names), 20):
            git(vault, 'add', '-f', '--', *names[offset:offset + 20])
        staged = {}
        for item in git(vault, 'ls-files', '-sz').decode('utf-8').split('\0'):
            if item:
                header, name = item.split('\t', 1)
                staged[name] = header.split()[1]
        mismatch = [target for target, oid in original.values() if staged.get(target) != oid]
        if mismatch:
            raise ValueError(f'protected bytes differ in Git index: {mismatch[:5]}')
        for old in {name.split('/')[0] for name in original}:
            git(vault, 'rm', '-r', '--cached', '--ignore-unmatch', '--', old)
        if original:
            marker = vault / 'docs/modernization/layout-completion.json'
            marker.parent.mkdir(parents=True, exist_ok=True)
            marker.write_text(json.dumps({'layout_state': 'complete',
                'completed_at': datetime.now(timezone.utc).isoformat(),
                'preserved_tracked_files': len(original),
                'dev_source_commit': git(dev, 'rev-parse', 'HEAD').decode('utf-8').strip(),
                'git_pushed': False}, ensure_ascii=False, indent=2) + '\n', 'utf-8')
            git(vault, 'add', '--', marker.relative_to(vault).as_posix())
            git(vault, 'commit', '-qm', 'refactor: complete deferred knowledge directory migration')
        run([sys.executable, '-X', 'utf8', vault / 'tools/deploy.py', record / 'deployment',
             'Synchronize canonical paths after deferred layout migration', '--sync-config', '--dev-root', dev])
        run([sys.executable, '-X', 'utf8', vault / 'tools/deploy.py', '--verify-only', '--dev-root', dev])
    except (subprocess.CalledProcessError, OSError, ValueError) as error:
        print(f'Finishing stopped: {error}\nAudit: {record}\n'
              f'Inspect the journal before retrying. Reversible layout step: '
              f'{sys.executable} -X utf8 tools/migrate-layout.py --rollback "{record / "layout"}"', file=sys.stderr)
        return 1
    print(json.dumps({'state': 'complete', 'record': str(record),
                      'preserved_tracked_files': len(original), 'pushed': False}, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
