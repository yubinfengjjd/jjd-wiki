"""Read-only architecture probes; writes evidence only beside this script."""
import collections
import json
import os
import sys
import time
from pathlib import Path

ROOT = Path('E:/research-wiki')
OUT = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / '开发/staged/research-wiki'))
from rwiki.config import load_config
from rwiki.catalog import readable_pages
from rwiki.pages import read_page
from rwiki.links import extract_links, resolve
from rwiki.finder import load_catalog, find
from rwiki.read_cache import read_session

config = load_config(ROOT / '开发/staged/research-wiki/config.json', ROOT / '知识库')
pages = readable_pages(config.wiki_root)
catalog = load_catalog(config)
evidence = {
    'audit_date': '2026-11-13',
    'scope': 'local checked-out source, current pages/catalog and read-only lint; no scientific validation',
    'page_count': len(pages),
    'page_types': dict(collections.Counter(meta.get('type') for _, meta in pages)),
    'page_statuses': dict(collections.Counter(f"{m.get('type')}:{m.get('status', '-')}" for _, m in pages)),
    'catalog_count': len(catalog),
    'catalog_kinds': dict(collections.Counter(r['kind'] for r in catalog)),
    'catalog_usable': dict(collections.Counter(r['kind'] for r in catalog if r.get('usable'))),
    'catalog_run_states': dict(collections.Counter(r.get('run', '-') for r in catalog)),
}
page_set = {p.resolve(): p.relative_to(config.wiki_root).as_posix() for p, _ in pages}
edges = set()
degree = collections.Counter()
methods = []
for path, meta in pages:
    _, body = read_page(path)
    source = path.relative_to(config.wiki_root).as_posix()
    for target in extract_links(body):
        resolved = resolve(config.wiki_root, target).resolve()
        if resolved in page_set and resolved != path.resolve():
            edge = tuple(sorted((source, page_set[resolved])))
            edges.add(edge)
    if meta['type'] == 'method':
        methods.append({'id': meta['id'], 'title': meta['title'], 'kind': meta.get('method_kind'),
                        'status': meta.get('status'), 'implementations': len(meta.get('implementations') or [])})
for a, b in edges:
    degree[a] += 1
    degree[b] += 1
evidence['body_wikilink_graph'] = {
    'edges_undirected': len(edges), 'connected_nodes': len(degree),
    'isolated_nodes': [s for s in page_set.values() if s not in degree],
    'scope': 'body wikilinks only; excludes metadata relations, asset links and curation filtering',
}
evidence['methods'] = methods
queries = [
    '共表达', 'coexpression', 'WGCNA', '找出一起变化的基因模块',
    '差异表达', 'differential expression', '比较两组细胞哪些基因表达不同',
    '细胞注释', 'cell annotation', '判断每个细胞属于什么类型',
    '生存曲线', 'survival', '比较两组患者的随访结局',
    '批次效应', 'batch correction', '不同批次测出来的数据怎么整合',
    '火山图', 'volcano', '展示差异基因的变化幅度和显著性',
]
evidence['queries'] = []
with read_session():
    for query in queries:
        start = time.perf_counter()
        results = find(config, query, limit=5)
        evidence['queries'].append({'query': query, 'seconds': round(time.perf_counter() - start, 4),
            'top5': [{k: r.get(k) for k in ('id', 'kind', 'title', 'score', 'why', 'usable', 'run')} for r in results]})
(OUT / 'evidence.json').write_text(json.dumps(evidence, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps({k: v for k, v in evidence.items() if k not in ('methods', 'queries', 'body_wikilink_graph')}, ensure_ascii=False), flush=True)
print('Graph:', json.dumps(evidence['body_wikilink_graph'], ensure_ascii=False), flush=True)
print('Methods:', json.dumps(methods, ensure_ascii=False), flush=True)
for query in evidence['queries']:
    print(json.dumps({'query': query['query'], 'top5': [(r['id'], r['score']) for r in query['top5']]}, ensure_ascii=False), flush=True)
print('Starting read-only lint...', flush=True)
from rwiki.lint import lint
start = time.perf_counter()
with read_session():
    diagnostics = lint(config)
(OUT / 'lint.txt').write_text('\n'.join(diagnostics) + '\n', encoding='utf-8')
evidence['lint'] = {'seconds': round(time.perf_counter() - start, 2),
                    'counts': dict(collections.Counter(d.split(' ', 1)[0] for d in diagnostics)),
                    'diagnostics': diagnostics}
(OUT / 'evidence.json').write_text(json.dumps(evidence, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('Lint:', json.dumps(evidence['lint'], ensure_ascii=False), flush=True)
