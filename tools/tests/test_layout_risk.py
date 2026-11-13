"""Risk classification must survive moves, including deletion/addition rename pairs."""
from pathlib import Path
import sys

import pytest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from machine_paths import resolve_dev_root, resolve_skill_root

DEV = resolve_dev_root(ROOT)
sys.path.insert(0, str(resolve_skill_root(DEV)))
from rwiki.risk import load_rules, risk_tier


@pytest.mark.parametrize('repository,old,new,expected', [
    *[('dev', f'staged/research-wiki/rwiki/{name}.py', f'skills/research-wiki/rwiki/{name}.py', 'high')
      for name in ('ghflow', 'push_guard', 'writer_lock', 'store', 'risk')],
    ('dev', 'staged/research-wiki/SKILL.md', 'skills/research-wiki/SKILL.md', 'high'),
    ('dev', 'staged/research-wiki/assets/AGENTS.md', 'skills/research-wiki/assets/AGENTS.md', 'high'),
    ('dev', 'staged/research-wiki/references/github-workflow.md', 'skills/research-wiki/references/github-workflow.md', 'high'),
    ('dev', 'review/round/report.md', 'archive/review/round/report.md', 'low'),
    ('dev', 'operations/changes.md', 'archive/operations/changes.md', 'normal'),
    ('dev', 'frontend/src/App.tsx', 'apps/web/src/App.tsx', 'normal'),
    ('dev', 'obsidian-neural-view/main.js', 'plugins/obsidian-neural-view/main.js', 'normal'),
    ('vault', '知识库/AGENTS.md', 'wiki/AGENTS.md', 'high'),
    ('vault', '知识库/.protected-hashes.json', 'wiki/.protected-hashes.json', 'high'),
    ('vault', '知识库/log.md', 'wiki/log.md', 'low'),
    ('vault', '文档/nested/notes.md', 'archive/docs/nested/notes.md', 'low'),
    ('vault', '知识库/methods/example.md', 'wiki/methods/example.md', 'normal'),
    ('vault', '维护记录/session/report.md', 'archive/maintenance/session/report.md', 'normal'),
])
def test_real_rules_keep_old_and_canonical_path_tiers(repository, old, new, expected):
    rules = load_rules(DEV if repository == 'dev' else ROOT)
    assert risk_tier([old], rules)[0] == expected
    assert risk_tier([new], rules)[0] == expected
    # The production rename detector emits both names; it must retain the tier.
    assert risk_tier([old, new], rules)[0] == expected


@pytest.mark.parametrize('root', [ROOT, DEV])
def test_governance_changes_stay_high_when_mixed_with_new_docs(root):
    rules = load_rules(root)
    assert risk_tier(['docs/getting-started.md'], rules)[0] == 'low'
    assert risk_tier(['docs/getting-started.md', '.github/risk-tiers.json'], rules)[0] == 'high'
    assert risk_tier([], rules)[0] == 'normal'
