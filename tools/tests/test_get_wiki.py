"""The public bootstrap selects pages without pulling asset files into checkout."""
import os
import subprocess
from pathlib import Path

import pytest


@pytest.mark.skipif(os.name != 'nt', reason='PowerShell Windows bootstrap')
@pytest.mark.parametrize('profile', ['light', 'full'])
def test_bootstrap_two_sibling_repositories(tmp_path, profile):
    script = Path(__file__).resolve().parents[1] / 'get-wiki.ps1'
    sources = []
    for name in ('vault', 'dev'):
        root = tmp_path / name
        root.mkdir()
        subprocess.run(['git', '-C', str(root), 'init', '-q'], check=True)
        (root / 'README.md').write_text(name)
        if name == 'vault':
            page = root / 'wiki/methods/demo.md'
            page.parent.mkdir(parents=True)
            page.write_text('knowledge')
            asset = root / 'wiki/methods/demo/code/analysis.R'
            asset.parent.mkdir(parents=True)
            asset.write_text('code')
            (root / 'wiki/methods/demo/runtime.json').write_text('{}')
            (root / 'gallery').mkdir()
            (root / 'gallery/original.txt').write_text('raw gallery')
        subprocess.run(['git', '-C', str(root), 'add', '.'], check=True)
        subprocess.run(['git', '-C', str(root), '-c', 'user.name=test', '-c',
                        'user.email=test@example.invalid', 'commit', '-qm', 'fixture'], check=True)
        sources.append(root)
    destination = tmp_path / 'download'
    result = subprocess.run(['powershell', '-NoProfile', '-NonInteractive', '-ExecutionPolicy',
        'Bypass', '-File', str(script), '-Destination', str(destination), '-Profile', profile,
        '-VaultUrl', str(sources[0]), '-DevUrl', str(sources[1])],
        capture_output=True, text=True, encoding='utf-8', errors='replace')
    assert result.returncode == 0, result.stdout + result.stderr
    vault = destination / 'jjd-wiki'
    assert (destination / 'jjd-wiki-dev/README.md').is_file()
    assert (vault / 'wiki/methods/demo.md').is_file()
    assert (vault / 'wiki/methods/demo/runtime.json').is_file()
    assert (vault / 'wiki/methods/demo/code/analysis.R').exists() == (profile == 'full')
    assert (vault / 'gallery/original.txt').exists() == (profile == 'full')
