import sys, tempfile
from pathlib import Path
SKILL = Path(r'E:\research-wiki\开发\staged\research-wiki')
sys.path[:0] = [str(SKILL), str(SKILL / 'tests')]
import conftest
import test_t3
from rwiki.acceptance import acceptance_stale, ready_for_use, record_acceptance
from rwiki.usage import record_use
from rwiki.workflow import workflow_snapshot

tmp = Path(tempfile.mkdtemp(dir=r'E:\research-wiki-env\tmp'))
config, config_path = conftest.workspace.__wrapped__(tmp)
config, config_path = test_t3.candidates.__wrapped__((config, config_path))
alpha = config.wiki_root / 'templates/alpha.md'
record_acceptance(config, alpha)
before = (ready_for_use(config, alpha), acceptance_stale(alpha), workflow_snapshot(config)['templates/alpha.md'])
record_use(config, 'alpha', 'usage-check', 'Usage check', 'D:/demo/fig.png', None)
after = (ready_for_use(config, alpha), acceptance_stale(alpha), workflow_snapshot(config)['templates/alpha.md'])
print({'before': before, 'after': after})
assert before[0] and not before[1]
assert after[0], 'record-use must not make an accepted template unusable'
