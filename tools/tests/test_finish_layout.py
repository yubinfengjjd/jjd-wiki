"""Deferred finishing preserves tracked originals excluded by new ignore rules."""
import importlib.util
import json
import subprocess
import sys
from pathlib import Path

import pytest

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace('-', '_'), TOOLS / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def init(root):
    root.mkdir()
    for args in [('init', '-q'), ('config', 'user.name', 'test'),
                 ('config', 'user.email', 'test@example.com')]:
        subprocess.run(['git', '-C', str(root), *args], check=True)
    (root / '.gitignore').write_text('wiki/**/*.bin\n', 'utf-8')
    subprocess.run(['git', '-C', str(root), 'add', '.'], check=True)
    subprocess.run(['git', '-C', str(root), 'commit', '-qm', 'init'], check=True)
    return root


def test_preserves_tracked_ignored_assets_and_deploys_after_commit(tmp_path, monkeypatch):
    m, migration = load('finish-layout'), load('migrate-layout')
    root, dev = init(tmp_path / 'vault'), init(tmp_path / 'dev')
    original = root / '知识库/raw/original.bin'
    original.parent.mkdir(parents=True)
    original.write_bytes(b'\x00original\xff\r\n')
    m.git(root, 'add', '--', '知识库')
    m.git(root, 'commit', '-qm', 'original')
    calls, real_run = [], m.run

    def run(args, **kwargs):
        if 'migrate-layout.py' in str(args[3] if len(args) > 3 else ''):
            migration.apply([(root, 'vault'), (dev, 'dev')], tmp_path / 'audit/layout', aliases=False)
            return
        if any(str(arg).endswith('deploy.py') for arg in args):
            assert not m.git(root, 'status', '--porcelain').strip()
            calls.append(args)
            return
        return real_run(args, **kwargs)

    monkeypatch.setattr(m, 'run', run)
    monkeypatch.setattr(m, 'resolve_dev_root', lambda _: dev)
    monkeypatch.setattr(sys, 'argv', ['finish-layout.py', '--vault-root', str(root),
                                    '--record', str(tmp_path / 'audit')])
    assert m.main() == 0
    tree = m.git(root, 'ls-tree', '-rz', 'HEAD').decode('utf-8')
    assert 'wiki/raw/original.bin' in tree and '知识库/' not in tree
    assert (root / 'wiki/raw/original.bin').read_bytes() == b'\x00original\xff\r\n'
    marker = json.loads((root / 'docs/modernization/layout-completion.json').read_text('utf-8'))
    assert marker['layout_state'] == 'complete' and marker['preserved_tracked_files'] == 1
    assert not marker['git_pushed']
    assert len(calls) == 2


def test_refuses_dirty_worktree_before_creating_audit(tmp_path, monkeypatch):
    m = load('finish-layout')
    root, dev = init(tmp_path / 'vault'), init(tmp_path / 'dev')
    (root / 'uncommitted.txt').write_text('preserve me', 'utf-8')
    monkeypatch.setattr(m, 'resolve_dev_root', lambda _: dev)
    monkeypatch.setattr(sys, 'argv', ['finish-layout.py', '--vault-root', str(root),
                                    '--record', str(tmp_path / 'audit')])
    with pytest.raises(SystemExit):
        m.main()
    assert not (tmp_path / 'audit').exists()
