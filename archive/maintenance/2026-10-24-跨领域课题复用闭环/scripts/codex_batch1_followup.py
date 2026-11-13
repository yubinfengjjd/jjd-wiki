"""Generalized review probes for freshness, code identity and atomic sidecars."""
import json
from pathlib import Path

import pytest
from codex_batch1_adversarial import completed, design_check, dp, make_project, ps


def test_changed_observation_evidence_not_verified_current(tmp_path):
    root = make_project(tmp_path)
    (root / 'design.txt').write_text('design version one')
    ps.add_observation(root, 'design', 'design_defined', value='true', basis='verified',
                       evidence='design.txt')
    (root / 'design.txt').write_text('design replaced; needs reinspection')
    check = design_check(ps.load_project(root))
    assert check['state'] != 'satisfied', check


def test_unknown_conditional_requirement_is_not_exempt(tmp_path):
    import yaml
    root = make_project(tmp_path)
    profile = dict(dp.load_profiles()['deep_learning'])
    profile['prerequisites'] = [{'id': 'conditional_weights', 'type': 'object',
        'match': {'kind': 'weights'}, 'when': {'type': 'observation',
        'match': {'claim': 'training_requested'}}}]
    profile_file = root / 'profiles.yaml'
    profile_file.write_text(yaml.safe_dump({'schema_version': 1,
        'profiles': {'conditional_test': profile}}), encoding='utf-8')
    report = dp.evaluate_profile(ps.load_project(root), 'conditional_test', profiles_path=profile_file)
    check = report['checks'][0]
    assert check['state'] != 'not_applicable', check


def test_same_command_does_not_prove_unchanged_code(tmp_path):
    root = make_project(tmp_path)
    code = root / 'analysis.R'
    code.write_text('# computation v1')
    completed(root, command='Rscript analysis.R')
    code.write_text('# corrected computation v2')
    result = completed(root, 'r2', command='Rscript analysis.R')
    assert result['duplicate_of'] is None, result


def test_corrupted_parseable_receipt_not_reusable(tmp_path):
    root = make_project(tmp_path)
    completed(root)
    (ps.state_dir(root) / 'runs/r1/receipt.json').write_text('{}')
    result = completed(root, 'r2')
    assert result['duplicate_of'] is None, result


def test_explicit_stale_result_not_reusable(tmp_path):
    root = make_project(tmp_path)
    completed(root)
    ps.mark_stale(root, ps.impact_analysis(root, ['object:matrix']), reason='known invalidation')
    result = completed(root, 'r2')
    assert result['duplicate_of'] is None, result


def test_source_change_propagates_via_file_dependency(tmp_path):
    root = make_project(tmp_path)
    completed(root)
    ps.add_task(root, 'plot', inputs=['file:out.csv'])
    (root / 'plot.png').write_bytes(b'plot-v1')
    ps.record_run(root, 'plot1', 'plot', status='completed', command='render',
                  inputs=['file:out.csv'], outputs=['plot.png'], checks=['inspected'])
    (root / 'input.bin').write_bytes(b'input-v2')
    report = ps.check_project(root)
    child = next(item for item in report['artifacts'].values() if item['path'] == 'plot.png')
    assert child['freshness'] != 'current', child


def test_summary_failure_does_not_commit_inconsistent_receipt(tmp_path, monkeypatch):
    root = make_project(tmp_path)
    ps.record_run(root, 'r1', 'analyze', status='running', command='initial')
    state_path = ps.state_dir(root) / 'project.json'
    receipt_path = ps.state_dir(root) / 'runs/r1/receipt.json'
    before_state, before_receipt = state_path.read_bytes(), receipt_path.read_bytes()
    original = ps.os.replace
    def fail_summary(source, target):
        if Path(target).name == 'summary.md':
            raise OSError('simulated summary rename failure')
        return original(source, target)
    monkeypatch.setattr(ps.os, 'replace', fail_summary)
    try:
        completed(root)
    except (OSError, ps.WikiError):
        assert state_path.read_bytes() == before_state
        assert receipt_path.read_bytes() == before_receipt
    else:
        # If a derived-file failure is recoverably committed, receipt and state
        # still need to agree and must expose the derived summary recovery gap.
        state = json.loads(state_path.read_text())
        receipt = json.loads(receipt_path.read_text())
        assert state['runs']['r1']['status'] == receipt['status']
