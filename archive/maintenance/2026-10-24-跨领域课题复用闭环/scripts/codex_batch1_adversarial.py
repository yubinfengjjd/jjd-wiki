"""Independent review probes. Scratch-only fixtures, no original project writes."""
import sys
import os
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(os.environ.get('RWIKI_REVIEW_SOURCE',
    'E:/research-wiki-env/work/wiki-cross-domain-20261024/development/staged/research-wiki'))))
from rwiki import project_state as ps
from rwiki import domain_profiles as dp
from rwiki.errors import WikiError


def make_project(tmp_path, **task_options):
    root = tmp_path / 'project'
    root.mkdir()
    ps.init_project(root)
    (root / 'input.bin').write_bytes(b'input-v1')
    (root / 'out.csv').write_text('x\n1\n', encoding='utf-8')
    ps.add_object(root, 'matrix', 'matrix', path='input.bin', basis='verified',
                  properties={'assay': 'expression', 'organism': 'mouse', 'id_system': 'symbol'})
    ps.add_task(root, 'analyze', inputs=['object:matrix'], **task_options)
    return root


def completed(root, rid='r1', **kwargs):
    args = dict(status='completed', command='Rscript analysis-v1.R',
                inputs=['object:matrix'], outputs=['out.csv'], checks=['row count checked'])
    args.update(kwargs)
    return ps.record_run(root, rid, 'analyze', **args)


def receipt_path(root, run_id='r1'):
    return ps.state_dir(root) / ps.load_project(root)['runs'][run_id]['receipt']


def design_check(state):
    report = dp.evaluate_profile(state, 'bioinformatics_single_cell')
    return next(c for c in report['checks'] if c['id'] == 'design')


def test_conflicting_evidence_not_silently_satisfied(tmp_path):
    root = make_project(tmp_path)
    ps.add_observation(root, 'old', 'design_defined', value='true', basis='verified')
    ps.add_observation(root, 'new', 'design_defined', value='false', basis='verified')
    check = design_check(ps.load_project(root))
    assert check['state'] != 'satisfied', check


def test_unscoped_observation_not_satisfy_another_object(tmp_path):
    root = make_project(tmp_path)
    ps.add_object(root, 'other', 'matrix', path='out.csv')
    ps.add_observation(root, 'other-design', 'design_defined', about='object:other',
                       value='true', basis='author_stated')
    check = design_check(ps.load_project(root))
    assert check['state'] != 'satisfied', check


def test_deleted_object_not_satisfy_current_materials(tmp_path):
    root = make_project(tmp_path)
    (root / 'input.bin').unlink()
    report = dp.evaluate_profile(ps.load_project(root), 'bioinformatics_single_cell')
    check = next(c for c in report['checks'] if c['id'] == 'expression_object')
    assert check['state'] != 'satisfied', check


def test_different_command_not_deduplicated(tmp_path):
    root = make_project(tmp_path)
    completed(root)
    result = completed(root, 'r2', command='Rscript corrected-analysis-v2.R')
    assert result['duplicate_of'] is None, result


def test_missing_old_output_not_treated_as_completed_duplicate(tmp_path):
    root = make_project(tmp_path)
    completed(root)
    (root / 'out.csv').unlink()
    with pytest.raises(WikiError):
        completed(root, 'r2')


def test_declared_task_input_not_silently_omitted(tmp_path):
    root = make_project(tmp_path)
    try:
        completed(root, inputs=[])
    except WikiError:
        return
    import json
    receipt = json.loads(receipt_path(root).read_text(encoding='utf-8'))
    assert 'object:matrix' in receipt['inputs'], receipt


def test_revision_conflict_does_not_replace_running_receipt(tmp_path):
    root = make_project(tmp_path)
    ps.record_run(root, 'r1', 'analyze', status='running', command='initial')
    receipt = receipt_path(root)
    before = receipt.read_bytes()
    with pytest.raises(WikiError):
        completed(root, expected_revision=0)
    assert receipt.read_bytes() == before


def test_relative_external_path_rejected(tmp_path):
    root = make_project(tmp_path)
    ps.add_data_root(root, str(Path.cwd()))
    with pytest.raises(WikiError):
        ps.external_path(ps.load_project(root), 'relative.csv')


def test_changed_source_file_alias_reaches_object_consumers(tmp_path):
    root = make_project(tmp_path)
    completed(root)
    (root / 'input.bin').write_bytes(b'input-v2')
    report = ps.impact_analysis(root, ['file:input.bin'])
    assert 'analyze' in {item['id'] for item in report['tasks']}, report


def test_stale_parent_propagates_even_before_intermediate_bytes_change(tmp_path):
    root = make_project(tmp_path)
    completed(root)
    parent = next(iter(ps.load_project(root)['artifacts']))
    ps.add_task(root, 'plot', inputs=[f'artifact:{parent}'])
    (root / 'plot.png').write_bytes(b'rendered-from-v1')
    ps.record_run(root, 'plot1', 'plot', status='completed', command='render',
                  inputs=[f'artifact:{parent}'], outputs=['plot.png'], checks=['inspected'])
    (root / 'input.bin').write_bytes(b'input-v2')
    report = ps.check_project(root)
    child = next(item for item in report['artifacts'].values() if item['path'] == 'plot.png')
    assert child['freshness'] != 'current', child


def test_bad_nested_record_is_a_schema_error(tmp_path):
    import json
    root = make_project(tmp_path)
    path = ps.state_dir(root) / 'project.json'
    state = ps.load_project(root)
    state['objects']['matrix'] = 'corrupt record'
    path.write_text(json.dumps(state), encoding='utf-8')
    with pytest.raises(WikiError):
        ps.load_project(root)


def external_manifest(tmp_path, **extra):
    import json
    from rwiki.runtime_contract import read_manifest
    asset = tmp_path / 'external-method'
    asset.mkdir()
    impl = {'id': 'external', 'entry': 'example-tool', 'entry_kind': 'external_program',
            'language': 'CLI', 'runtime_mode': 'standalone', 'files': [],
            'resources': [], 'required_packages': {}, 'optional_packages': {},
            'source': {}, 'tools': [{'name': 'example-tool'}], **extra}
    (asset / 'runtime.json').write_text(json.dumps({'schema_version': 1,
          'kind': 'method', 'id': 'external-method', 'implementations': [impl]}), encoding='utf-8')
    return read_manifest(asset, 'external-method', 'method')


def test_valid_argv_can_repeat_a_flag(tmp_path):
    manifest, issues = external_manifest(tmp_path, invocation={'command': 'example-tool',
                                     'args': ['--input', 'a', '--input', 'b']})
    assert manifest is not None, issues


def test_nan_hardware_requirement_is_rejected(tmp_path):
    manifest, issues = external_manifest(tmp_path, hardware={'min_memory_gb': float('nan')})
    assert manifest is None, manifest


# Generalization coverage for the SAME review findings (added 2026-10-24).
import json

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


def test_implementation_id_does_not_prove_unchanged_code(tmp_path):
    root = make_project(tmp_path, implementation_id='known-branch')
    code = root / 'analysis.R'
    code.write_text('# computation v1')
    completed(root, command='Rscript analysis.R')
    code.write_text('# corrected computation v2')
    result = completed(root, 'r2', command='Rscript analysis.R')
    assert result['duplicate_of'] is None, result


def test_corrupted_parseable_receipt_not_reusable(tmp_path):
    root = make_project(tmp_path)
    completed(root)
    receipt_path(root).write_text('{}')
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
    receipt_file = receipt_path(root)
    before_state, before_receipt = state_path.read_bytes(), receipt_file.read_bytes()
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
        assert receipt_file.read_bytes() == before_receipt
    else:
        # If a derived-file failure is recoverably committed, receipt and state
        # still need to agree and must expose the derived summary recovery gap.
        state = json.loads(state_path.read_text())
        receipt = json.loads(receipt_path(root).read_text())
        assert state['runs']['r1']['status'] == receipt['status']


def test_failed_state_commit_does_not_publish_future_summary(tmp_path, monkeypatch):
    root = make_project(tmp_path)
    ps.record_run(root, 'r1', 'analyze', status='running', command='initial')
    folder = ps.state_dir(root)
    before = {name: (folder / name).read_bytes()
              for name in ['project.json', 'summary.md', str(receipt_path(root).relative_to(folder))]}
    original = ps.os.replace
    def fail_state(source, target):
        if Path(target).name == 'project.json':
            raise OSError('simulated authoritative state commit failure')
        return original(source, target)
    monkeypatch.setattr(ps.os, 'replace', fail_state)
    with pytest.raises((OSError, ps.WikiError)):
        completed(root)
    for name, data in before.items():
        assert (folder / name).read_bytes() == data, name


def test_unhashed_file_not_current(tmp_path):
    root = make_project(tmp_path)
    status = ps.material_state(ps.load_project(root), root,
                              path=root / 'input.bin', recorded_sha=None)
    assert status != 'current', status


def test_receipt_without_output_hash_not_reusable(tmp_path):
    root = make_project(tmp_path)
    (root / 'analysis.R').write_text('# stable computation')
    completed(root, code=['file:analysis.R'])
    path = receipt_path(root)
    receipt = json.loads(path.read_text())
    for output in receipt['outputs']:
        output.pop('sha256', None)
    path.write_text(json.dumps(receipt))
    result = completed(root, 'r2', code=['file:analysis.R'])
    assert result['duplicate_of'] is None, result


def test_observation_about_changed_object_not_current(tmp_path):
    root = make_project(tmp_path)
    (root / 'design.txt').write_text('design inspected for input version one')
    ps.add_observation(root, 'scoped-design', 'design_defined', about='object:matrix',
                       value='true', basis='verified', evidence='design.txt')
    (root / 'input.bin').write_bytes(b'replaced-data-version-two')
    report = dp.evaluate_profile(ps.load_project(root), 'bioinformatics_single_cell',
                                 subject='object:matrix')
    check = next(c for c in report['checks'] if c['id'] == 'design')
    assert check['state'] != 'satisfied', check
