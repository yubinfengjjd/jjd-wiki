"""Layout migration safety checks use disposable Git repositories only."""
import importlib.util
import json
import subprocess
import sys
from pathlib import Path

import pytest

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))


def load():
    spec = importlib.util.spec_from_file_location('layout_migration', TOOLS / 'migrate-layout.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def fixture_repo(root):
    root.mkdir()
    subprocess.run(['git', 'init', str(root)], check=True, capture_output=True)
    (root / '.gitignore').write_text('record/\n', encoding='utf-8')
    (root / '知识库/raw').mkdir(parents=True)
    (root / '知识库/raw/original.bin').write_bytes(b'\x00\xffprotected\r\n')
    subprocess.run(['git', '-C', str(root), 'add', '.'], check=True)
    subprocess.run(['git', '-C', str(root), '-c', 'user.name=test', '-c', 'user.email=test@example.com',
                    'commit', '-qm', 'fixture'], check=True)
    return root


def test_move_rollback_bytes_and_retry(tmp_path):
    m = load()
    root = fixture_repo(tmp_path / 'vault')
    record = root / 'record'
    m.apply([(root, 'vault')], record, aliases=False)
    assert (root / 'wiki/raw/original.bin').read_bytes() == b'\x00\xffprotected\r\n'
    data = json.loads((record / 'manifest.json').read_text(encoding='utf-8'))
    assert data['moves'][0]['before'] == data['moves'][0]['after']
    m.rollback(record)
    assert (root / '知识库/raw/original.bin').is_file()
    with pytest.raises(ValueError, match='rolled back'):
        m.rollback(record)
    m.apply([(root, 'vault')], root / 'record/retry', aliases=False)


def test_dirty_and_conflict_rejected(tmp_path):
    m = load()
    root = fixture_repo(tmp_path / 'vault')
    (root / '知识库/raw/original.bin').write_bytes(b'edited')
    with pytest.raises(ValueError, match='dirty'):
        m.preflight([(root, 'vault')])
    (root / 'wiki').mkdir()
    with pytest.raises(ValueError, match='conflict'):
        m.preflight([(root, 'vault')])


def test_rollback_refuses_user_edits_and_additions(tmp_path):
    m = load()
    root = fixture_repo(tmp_path / 'vault')
    record = tmp_path / 'record'
    m.apply([(root, 'vault')], record, aliases=False)
    path = root / 'wiki/raw/original.bin'
    original = path.read_bytes()
    path.write_bytes(b'new')
    with pytest.raises(ValueError, match='modified'):
        m.rollback(record)
    path.write_bytes(original)
    (root / 'wiki/new.txt').write_text('user')
    with pytest.raises(ValueError, match='modified'):
        m.rollback(record)
    assert path.is_file()


def test_resolve_new_legacy_and_sibling(tmp_path):
    from machine_paths import resolve_dev_root, resolve_skill_root, resolve_input_path
    vault = tmp_path / 'vault'
    vault.mkdir()
    dev = tmp_path / 'jjd-wiki-dev'
    skill = dev / 'skills/research-wiki'
    skill.mkdir(parents=True)
    for name in ('wiki.py', 'config.example.json'):
        (skill / name).touch()
    assert resolve_dev_root(vault) == dev
    assert resolve_skill_root(dev) == skill
    (vault / 'wiki').mkdir()
    assert resolve_input_path(vault, '知识库/methods') == vault / 'wiki/methods'
    skill.rename(dev / 'research-wiki-temp')
    (dev / 'staged').mkdir()
    (dev / 'research-wiki-temp').rename(dev / 'staged/research-wiki')
    assert resolve_skill_root(dev) == dev / 'staged/research-wiki'


def test_dual_repo_config_and_junction_rollback(tmp_path):
    m = load()
    vault = fixture_repo(tmp_path / 'vault')
    dev = fixture_repo(tmp_path / 'dev')
    skill = dev / 'staged/research-wiki'
    skill.mkdir(parents=True)
    (skill / 'wiki.py').write_text('# fixture')
    (skill / 'config.example.json').write_text('{}')
    (dev / '.gitignore').write_text('record/\n**/config.json\n/staged/research-wiki/\n')
    subprocess.run(['git', '-C', str(dev), 'add', '-f', 'staged/research-wiki/wiki.py',
                    'staged/research-wiki/config.example.json', '.gitignore'], check=True)
    subprocess.run(['git', '-C', str(dev), '-c', 'user.name=test', '-c', 'user.email=t@example.com',
                    'commit', '-qm', 'skill'], check=True)
    cfg = skill / 'config.json'
    before = json.dumps({'wiki_root': str(vault / '知识库'), 'gallery_root': str(vault / '画廊'),
                         'taxonomy': str(skill / 'assets/scenario_taxonomy.json')}).encode('utf-8')
    cfg.write_bytes(before)
    record = tmp_path / 'journal'
    m.apply([(vault, 'vault'), (dev, 'dev')], record)
    target = dev / 'skills/research-wiki/config.json'
    assert Path(json.loads(target.read_text(encoding='utf-8'))['wiki_root']) == vault / 'wiki'
    assert m.linked(vault / '知识库')
    assert subprocess.run(['git', '-C', str(vault), 'check-ignore', '--no-index', '-q', '知识库']).returncode == 0
    assert (vault / '知识库/raw/original.bin').read_bytes() == b'\x00\xffprotected\r\n'
    m.rollback(record)
    assert cfg.read_bytes() == before
    assert not m.linked(vault / '知识库')
    assert subprocess.run(['git', '-C', str(vault), 'check-ignore', '--no-index', '-q', '知识库']).returncode != 0


def test_failed_alias_creation_can_roll_back(tmp_path, monkeypatch):
    m = load()
    root = fixture_repo(tmp_path / 'vault')
    def fail(*args):
        raise OSError('simulated junction failure')
    monkeypatch.setattr(m, 'junction', fail)
    record = tmp_path / 'record'
    with pytest.raises(OSError, match='simulated'):
        m.apply([(root, 'vault')], record)
    m.rollback(record)
    assert (root / '知识库/raw/original.bin').is_file()


def test_ignored_nested_git_and_obsidian_preserved(tmp_path):
    m = load()
    root = fixture_repo(tmp_path / 'vault')
    (root / '.gitignore').write_text('record/\n**/.obsidian/\n/维护记录/\n')
    subprocess.run(['git', '-C', str(root), 'add', '.gitignore'], check=True)
    subprocess.run(['git', '-C', str(root), '-c', 'user.name=t', '-c', 'user.email=t@example.com',
                    'commit', '-qm', 'ignore local artifacts'], check=True)
    private_state = root / '知识库/.obsidian/workspace.json'
    private_state.parent.mkdir()
    private_state.write_bytes(b'{"ignored":true}\r\n')
    nested = root / '维护记录/audit/pytest-tmp/repo'
    nested.mkdir(parents=True)
    subprocess.run(['git', 'init', str(nested)], capture_output=True, check=True)
    (nested / 'fixture.bin').write_bytes(b'ignored-fixture')
    before_wiki = m.snapshot(root / '知识库')
    before_audit = m.snapshot(root / '维护记录')
    record = tmp_path / 'record'
    m.apply([(root, 'vault')], record, aliases=False)
    assert m.snapshot(root / 'archive/maintenance') == before_audit
    assert m.snapshot(root / 'wiki') == before_wiki
    m.rollback(record)
    assert m.snapshot(root / '维护记录') == before_audit
    assert m.snapshot(root / '知识库') == before_wiki


def test_config_rewrite_normalizes_repeated_windows_separators():
    m = load()
    result = m.rewrite_config({'wiki_root': r'E:\\research-wiki\\知识库'},
                              [('E:/research-wiki/知识库', 'E:/research-wiki/wiki')])
    assert result['wiki_root'] == 'E:/research-wiki/wiki'


def test_interrupted_after_atomic_move_before_after_hash_can_rollback(tmp_path, monkeypatch):
    m = load()
    root = fixture_repo(tmp_path / 'vault')
    original = m.snapshot(root / '知识库')
    real_snapshot = m.snapshot
    def interrupted(path):
        if Path(path) == root / 'wiki':
            raise OSError('interrupted after rename')
        return real_snapshot(path)
    monkeypatch.setattr(m, 'snapshot', interrupted)
    record = tmp_path / 'record'
    with pytest.raises(OSError, match='interrupted'):
        m.apply([(root, 'vault')], record, aliases=False)
    monkeypatch.setattr(m, 'snapshot', real_snapshot)
    m.rollback(record)
    assert m.snapshot(root / '知识库') == original


def test_explicitly_deferred_locked_tree_is_untouched(tmp_path):
    m = load()
    root = fixture_repo(tmp_path / 'vault')
    before = m.snapshot(root / '知识库')
    result = m.apply([(root, 'vault')], tmp_path / 'record', aliases=False,
                     skip_paths=['知识库'])
    assert not any(item['old'] == '知识库' for item in result['moves'])
    assert m.snapshot(root / '知识库') == before
    assert not (root / 'wiki').exists()
