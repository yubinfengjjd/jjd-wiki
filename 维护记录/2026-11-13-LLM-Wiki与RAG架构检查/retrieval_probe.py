"""Record the exact alias collision and the ranks of known method pages."""
import json
import re
import sys
from pathlib import Path

ROOT = Path('E:/research-wiki')
OUT = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / '开发/staged/research-wiki'))
from rwiki.config import load_config, load_taxonomy
from rwiki.finder import _expansions, _terms, find, load_catalog
from rwiki.read_cache import read_session

config = load_config(ROOT / '开发/staged/research-wiki/config.json', ROOT / '知识库')
terms = _terms('coexpression')
charts, tags = _expansions(config, terms)
collisions = []
for key, value in load_taxonomy(config.taxonomy).items():
    for name in [key, value.get('label', ''), *value.get('aliases', [])]:
        normalized = str(name).lower()
        for term in terms:
            if normalized and (term == normalized or (len(term) >= 2 and len(normalized) >= 2
                         and (term in normalized or normalized in term))):
                collisions.append({'tag': key, 'alias': name, 'term': term})

pairs = [
    ('differential expression', 'differential-expression'),
    ('比较两组细胞哪些基因表达不同', 'differential-expression'),
    ('cell annotation', 'cell-type-annotation'),
    ('判断每个细胞属于什么类型', 'cell-type-annotation'),
]
ranks = []
with read_session():
    for query, target in pairs:
        results = find(config, query, limit=1000)
        rank = next((i for i, r in enumerate(results, 1) if r['id'] == target), None)
        ranks.append({'query': query, 'target': target, 'rank': rank, 'returned': len(results)})
catalog = load_catalog(config)
result = {'alias_collision': {'query': 'coexpression', 'charts': sorted(charts), 'tags': sorted(tags),
                               'matches': collisions}, 'known_page_ranks': ranks,
          'catalog_page_types': sorted(set(r['kind'] for r in catalog)),
          'interpretation': 'diagnostic probes, not a labelled benchmark or a comparison against an implemented RAG system'}
(OUT / 'retrieval-probe.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps(result, ensure_ascii=False, indent=2))
