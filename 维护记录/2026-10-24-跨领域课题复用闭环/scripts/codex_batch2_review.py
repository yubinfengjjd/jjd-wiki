"""Independent batch-2 integration probes, isolated fixtures only.

No process signals, formal Wiki writes, environment changes, or installs.
"""
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

BASE = Path('E:/research-wiki-env/work/wiki-cross-domain-20261024')
SOURCE = Path(os.environ.get('RWIKI_REVIEW_SOURCE', BASE / 'development/staged/research-wiki'))
sys.path.insert(0, str(SOURCE))
from rwiki import project_state as ps
from rwiki import store, usage
from rwiki.errors import WikiError
from rwiki.pages import write_page, read_page

RESULTS = []

def case(name, fn):
    try:
        fn()
        RESULTS.append({'case': name, 'passed': True})
    except Exception as e:
        RESULTS.append({'case': name, 'passed': False,
                        'error': f'{type(e).__name__}: {e}'})

def git(root, *args):
    p = subprocess.run(['git', '-C', str(root), *args], capture_output=True,
                       text=True, encoding='utf-8')
    if p.returncode:
        raise AssertionError(p.stderr.strip())
    return p.stdout

def must_reject(fn, reason):
    try:
        fn()
    except WikiError:
        return
    raise AssertionError(reason)

def seeded(base, *, family='score-family', code=True, unhashed=False):
    root = base / 'project'
    root.mkdir()
    ps.init_project(root, title='Independent isolated batch2 review')
    (root / 'input.csv').write_text('v\n1\n', encoding='utf-8')
    (root / 'code.R').write_text('# isolated fixture\n', encoding='utf-8')
    if unhashed:
        (root / 'input.csv').unlink()
        ps.add_object(root, 'input', 'native', path='input.csv')
        (root / 'input.csv').write_text('v\n1\n', encoding='utf-8')
        inputs = ['object:input']
    else:
        inputs = ['file:input.csv']
    ps.add_task(root, 'compute', family_id=family, implementation_id='impl', inputs=inputs)
    (root / 'output.csv').write_text('v\n2\n', encoding='utf-8')
    ps.record_run(root, 'run1', 'compute', status='completed', command='Rscript code.R',
                  code=['file:code.R'] if code else [], outputs=['output.csv'],
                  checks=['fixture output checked'])
    return root

def method(wiki, name):
    write_page(wiki / 'methods' / f'{name}.md',
               {'type':'method', 'id':name, 'title':name, 'status':'ready',
                'method_kind':'analysis', 'implementations':[{'id':'impl'}]},
               f'# {name}\n\n## 使用记录\n\n<!-- user:start -->\nkeep\n<!-- user:end -->\n')

def scoped_save():
    with tempfile.TemporaryDirectory(prefix='scope-', dir=BASE) as tmp:
        parent = Path(tmp)
        wiki = parent / 'knowledge'
        wiki.mkdir()
        (wiki / 'methods').mkdir()
        (wiki / 'a.md').write_text('old\n')
        (wiki / 'log.md').write_text('# log\n')
        (parent / 'sibling.txt').write_text('old\n')
        git(parent, 'init')
        git(parent, 'add', '.')
        git(parent, '-c','user.name=review-fixture','-c','user.email=review@localhost',
            'commit','-m','isolated fixture baseline')
        (parent / 'sibling.txt').write_text('staged unrelated\n')
        git(parent, 'add', 'sibling.txt')
        before_index = git(parent, 'diff', '--cached', '--binary')
        (parent / 'untracked.txt').write_text('untracked unrelated\n')
        (wiki / 'a.md').write_text('new\n')
        old = git(parent, 'rev-parse','HEAD').strip()
        with patch('rwiki.facts.refresh_facts'), patch.object(store, 'build_index', return_value='# index\n'):
            store.save(SimpleNamespace(wiki_root=wiki), 'isolated scoped save')
        assert git(parent, 'rev-parse','HEAD').strip() != old, 'nested wiki change not committed at all'
        assert git(parent, 'show','HEAD:knowledge/a.md') == 'new\n'
        assert git(parent, 'show','HEAD:sibling.txt') == 'old\n', 'unrelated sibling committed'
        assert git(parent, 'diff','--cached','--binary') == before_index, 'unrelated staged index altered'
        assert (parent / 'untracked.txt').read_text() == 'untracked unrelated\n'
        assert '?? untracked.txt' in git(parent,'status','--porcelain')

def association():
    with tempfile.TemporaryDirectory(prefix='association-', dir=BASE) as tmp:
        base=Path(tmp)
        root=seeded(base)
        wiki=base/'wiki'
        method(wiki,'different-family')
        with patch.object(usage,'save'):
            must_reject(lambda: usage.record_method_use(SimpleNamespace(wiki_root=wiki),
                        'different-family','study','Study',project_root=root,run_id='run1'),
                        'a run bound to score-family was recorded as successful different-family use')

def valid_method_use():
    with tempfile.TemporaryDirectory(prefix='valid-use-',dir=BASE) as tmp:
        base=Path(tmp)
        root=seeded(base)
        wiki=base/'wiki'
        method(wiki,'score-family')
        before_user=read_page(wiki/'methods/score-family.md')[1].split('<!-- user:start -->')[1]
        with patch.object(usage,'save'):
            usage.record_method_use(SimpleNamespace(wiki_root=wiki),'score-family','study','Study',
                                    project_root=root,run_id='run1')
            usage.record_method_use(SimpleNamespace(wiki_root=wiki),'score-family','study','Study',
                                    project_root=root,run_id='run1')
        meta,body=read_page(wiki/'projects/study.md')
        assert meta['methods']==['score-family']
        assert body.count('分析运行 `run1`')==1
        assert 'impl' in body, 'successful-use record omits exact implementation scope'
        after=read_page(wiki/'methods/score-family.md')[1]
        assert after.split('<!-- user:start -->')[1]==before_user, 'method author block changed'

def lesson_noop_preserves_review():
    import inspect
    with tempfile.TemporaryDirectory(prefix='lesson-noop-',dir=BASE) as tmp:
        root=seeded(Path(tmp))
        ps.add_lesson(root,'lesson1','same claim',applies_to='same scope',evidence=['run:run1'])
        args={}
        if 'decision' in inspect.signature(ps.review_lesson).parameters:
            ps.add_decision(root,'fixture-review','other','Isolated fixture disposition only',
                            scope='isolated lesson fixture',note='Not actual author approval')
            args['decision']='decision:fixture-review'
        ps.review_lesson(root,'lesson1','accepted',reviewed_by='isolated fixture reviewer',**args)
        ps.add_lesson(root,'lesson1','same claim',applies_to='same scope',evidence=['run:run1'])
        assert ps.load_project(root)['lessons']['lesson1']['status']=='accepted', 'no-op retry invalidated unchanged review'

def code_identity():
    with tempfile.TemporaryDirectory(prefix='no-code-', dir=BASE) as tmp:
        root=seeded(Path(tmp),code=False)
        must_reject(lambda: usage._verified_current_run(root,'run1'),
                    'successful-use accepted with no code provenance')

def changed_code():
    with tempfile.TemporaryDirectory(prefix='changed-code-',dir=BASE) as tmp:
        root=seeded(Path(tmp))
        (root/'code.R').write_text('# new implementation\n')
        must_reject(lambda: usage._verified_current_run(root,'run1'),
                    'changed actual code accepted as current successful use')

def missing_hash():
    with tempfile.TemporaryDirectory(prefix='unhashed-',dir=BASE) as tmp:
        root=seeded(Path(tmp),unhashed=True)
        must_reject(lambda: usage._verified_current_run(root,'run1'),
                    'unhashed input accepted as verified-current successful use')

def receipt_mismatch():
    with tempfile.TemporaryDirectory(prefix='receipt-',dir=BASE) as tmp:
        root=seeded(Path(tmp))
        state=ps.load_project(root)
        receipt=ps.state_dir(root)/state['runs']['run1']['receipt']
        data=json.loads(receipt.read_text(encoding='utf-8'))
        data['outputs'][0]['sha256']='f'*64
        receipt.write_text(json.dumps(data),encoding='utf-8')
        must_reject(lambda: usage._verified_current_run(root,'run1'),
                    'receipt output hash disagrees but successful-use accepted')

def lesson_review_invalidated():
    with tempfile.TemporaryDirectory(prefix='lesson-',dir=BASE) as tmp:
        root=seeded(Path(tmp))
        ps.add_lesson(root,'lesson1','same claim',applies_to='same scope', evidence=['run:run1'])
        import inspect
        review_args={}
        if 'decision' in inspect.signature(ps.review_lesson).parameters:
            ps.add_decision(root,'fixture-review','other',
                            'Isolated software fixture disposition, not a real author approval',
                            scope='isolated test lesson only',note='NO formal Wiki writes or signoff')
            review_args['decision']='decision:fixture-review'
        ps.review_lesson(root,'lesson1','accepted',reviewed_by='isolated fixture reviewer',**review_args)
        ps.add_observation(root,'new','additional contradictory observation',value='false')
        ps.add_lesson(root,'lesson2','same claim',applies_to='same scope',evidence=['observation:new'])
        item=ps.load_project(root)['lessons']['lesson1']
        assert item['status']=='pending', 'new evidence silently merged into accepted reviewed draft'

def lesson_scope():
    with tempfile.TemporaryDirectory(prefix='lesson-scope-',dir=BASE) as tmp:
        root=seeded(Path(tmp))
        must_reject(lambda: ps.add_lesson(root,'lesson1','global sounding claim',evidence=['run:run1']),
                    'lesson with no applicability boundary accepted despite scoped-draft contract')

def replaced_lock():
    with tempfile.TemporaryDirectory(prefix='replaced-lock-',dir=BASE) as tmp:
        root=Path(tmp)/'project'
        root.mkdir()
        ps.init_project(root,title='isolated recovery race fixture')
        lock=ps.state_dir(root)/ps.LOCK_FILE
        lock.write_text('12345')
        def probe(pid):
            lock.write_text('54321')  # replacement writer arrives after original identity read
            return 'dead'  # refers only to 12345, never to the replacement
        with patch.object(ps,'_pid_liveness',side_effect=probe), \
             patch.object(ps.os,'kill',side_effect=AssertionError('must never signal')):
            ps.recover_project(root,release_lock=True)
        assert lock.is_file() and lock.read_text()=='54321', 'replacement writer lock was released'

def quarantined_tmp():
    with tempfile.TemporaryDirectory(prefix='quarantine-',dir=BASE) as tmp:
        root=Path(tmp)/'project'
        root.mkdir()
        ps.init_project(root,title='isolated quarantine fixture')
        directory=ps.state_dir(root)
        (directory/'uncommitted.tmp').write_text('retain evidence')
        with patch.object(ps.os,'kill',side_effect=AssertionError('must never signal')):
            report=ps.recover_project(root,clean_staging=True)
        assert not report['staging_tmps'], 'quarantined evidence is reclassified as active staging'
        retained=[p for p in (directory/'_quarantine').rglob('*.tmp')]
        assert len(retained)==1 and retained[0].read_text()=='retain evidence'
        before={str(p.relative_to(directory)):p.read_bytes() for p in retained}
        ps.recover_project(root,clean_staging=True)
        after={str(p.relative_to(directory)):p.read_bytes() for p in (directory/'_quarantine').rglob('*.tmp')}
        assert after==before, 'second recovery moved already quarantined evidence again'

def fresh_state_under_recovery_lock():
    with tempfile.TemporaryDirectory(prefix='recovery-state-',dir=BASE) as tmp:
        root=Path(tmp)/'project'
        root.mkdir()
        ps.init_project(root,title='isolated interleaving fixture')
        (root/'input.csv').write_text('v\n1\n')
        (root/'code.R').write_text('# fixture\n')
        (root/'out.csv').write_text('v\n2\n')
        ps.add_task(root,'task1',inputs=['file:input.csv'])
        original=ps.load_project
        fired=False
        def scheduled_load(path):
            nonlocal fired
            state=original(path)
            if not fired:
                fired=True
                ps.record_run(root,'legit','task1',status='completed',command='Rscript code.R',
                              code=['file:code.R'],outputs=['out.csv'],checks=['fixture checked'])
            return state
        with patch.object(ps,'load_project',side_effect=scheduled_load), \
             patch.object(ps.os,'kill',side_effect=AssertionError('must never signal')):
            ps.recover_project(root,clean_orphans=True)
        state=original(root)
        receipt=ps.state_dir(root)/state['runs']['legit']['receipt']
        assert receipt.is_file(), 'recovery quarantined receipt committed after its initial state read'

def task_scope_no_borrowed_objects():
    from rwiki.domain_profiles import evaluate_profile
    with tempfile.TemporaryDirectory(prefix='task-scope-',dir=BASE) as tmp:
        root=seeded(Path(tmp))
        (root/'unrelated.bin').write_bytes(b'unrelated expression dataset')
        ps.add_object(root,'unrelated','matrix',path='unrelated.bin',basis='verified',
                      properties={'assay':'expression','organism':'mouse','id_system':'symbol'})
        report=evaluate_profile(ps.load_project(root),'bioinformatics_single_cell',subject='task:compute')
        check=next(c for c in report['checks'] if c['id']=='expression_object')
        assert check['state']!='satisfied', 'task using input.csv borrowed unrelated.bin object evidence'

def observation_file_alias_upstream_stale():
    from rwiki.domain_profiles import evaluate_profile
    with tempfile.TemporaryDirectory(prefix='observation-alias-',dir=BASE) as tmp:
        root=seeded(Path(tmp))
        ps.add_object(root,'outalias','matrix',path='output.csv',basis='verified')
        ps.add_task(root,'downstream',inputs=['object:outalias'])
        (root/'evidence.txt').write_text('design inspected for original output')
        ps.add_observation(root,'design','design_defined',about='object:outalias',
                           basis='verified',value='true',evidence='evidence.txt')
        (root/'input.csv').write_text('v\n99\n')
        report=evaluate_profile(ps.load_project(root),'bioinformatics_single_cell',subject='task:downstream')
        check=next(c for c in report['checks'] if c['id']=='design')
        assert check['state']!='satisfied', 'verified claim about object/path alias bypassed upstream-stale artifact'

if __name__=='__main__':
    for name,fn in [('nested_repo_save_preserves_siblings',scoped_save),
                    ('method_use_requires_matching_family',association),
                    ('method_use_requires_code_identity',code_identity),
                    ('method_use_rejects_changed_code',changed_code),
                    ('method_use_rejects_unhashed_input',missing_hash),
                    ('method_use_rejects_receipt_hash_conflict',receipt_mismatch),
                    ('lesson_reopens_when_evidence_changes',lesson_review_invalidated),
                    ('lesson_requires_scope',lesson_scope),
                    ('recovery_preserves_replacement_writer_lock',replaced_lock),
                    ('recovery_quarantine_is_idempotent',quarantined_tmp),
                    ('recovery_reloads_state_under_lock',fresh_state_under_recovery_lock),
                    ('task_scope_cannot_borrow_unrelated_objects',task_scope_no_borrowed_objects),
                    ('observation_file_alias_respects_upstream_stale',observation_file_alias_upstream_stale)]:
        case(name,fn)
    case('valid_method_use_and_idempotent_retry',valid_method_use)
    case('unchanged_lesson_retry_preserves_review',lesson_noop_preserves_review)
    print(json.dumps({'passed':sum(i['passed'] for i in RESULTS),
                      'failed':sum(not i['passed'] for i in RESULTS),
                      'cases':RESULTS},ensure_ascii=False,indent=2))
    sys.exit(1 if any(not i['passed'] for i in RESULTS) else 0)
