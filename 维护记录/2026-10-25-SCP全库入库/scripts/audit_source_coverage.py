"""Snapshot an in-progress inventory against independently parsed source facts."""
from pathlib import Path
import collections,json,re
A=Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库')
B=Path('E:/research-wiki-env/work/scp-full-ingest-20261025')
source=Path('E:/research-wiki-env/sources/scp-2026-10-22')
namespace=(source/'NAMESPACE').read_text(encoding='utf-8')
expected=[s.strip('"') for s in re.findall(r'^export\(([^)]+)\)',namespace,re.M)]
s3=re.findall(r'^S3method\(([^,]+),([^)]+)\)',namespace,re.M)
exports=json.loads((B/'coverage/exports.json').read_text(encoding='utf-8'))
branches=json.loads((B/'coverage/branches.json').read_text(encoding='utf-8'))
counts=collections.Counter(r['export'] for r in exports)
oracle=json.loads((A/'codex-source-enums.json').read_text(encoding='utf-8'))
missing_plot_types=[]
for owner in ['StatPlot','FeatureStatPlot','EnrichmentPlot','GSEAPlot','VelocityPlot']:
    expected_types=oracle['definitions'][owner]['enum_defaults']['plot_type']
    present={str(r['branch']) for r in branches if r['owner']==owner and r['parameter']=='plot_type'}
    missing_plot_types.extend([f'{owner}:{v}' for v in expected_types if v not in present])
entries=[r for r in exports if r['classification'] in ('analysis','analysis_backend','visualization')]
unresolved=[]
for row in entries:
    if not any(row.get(k) for k in ('entry','entrypoint','implementation_path','runtime','runtime_path')):
        unresolved.append(row['export'])
unprobed_claims=[f"{r['owner']}:{r['branch']}" for r in branches if str(r.get('dep_state','')).startswith('unprobed:') and '缺' in str(r.get('notes',''))]
summary={'scope':'in-progress snapshot; not a final acceptance','exports_expected':len(expected),'exports_observed':len(exports),
 'missing_exports':sorted(set(expected)-counts.keys()),'unexpected_exports':sorted(counts.keys()-set(expected)),
 'duplicate_exports':[k for k,v in counts.items() if v!=1],
 's3_methods_to_audit':[f'{g}.{c}' for g,c in s3],
 'primary_native_visual_apis':len(oracle['native_visual_entries']),
 'missing_named_plot_types':missing_plot_types,'class_counts':dict(collections.Counter(r['classification'] for r in exports)),
 'analysis_or_visual_rows_without_explicit_callable_mapping':unresolved,
 'unprobed_dependencies_misworded_as_missing':unprobed_claims,
 'next_review':'P1 structural enumeration is not full ingestion; resolve actual code/runtime/evidence pointers and S3 dispatch before completion.'}
(A/'codex-coverage-checkpoint1.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({k:v for k,v in summary.items() if k not in ('s3_methods_to_audit','analysis_or_visual_rows_without_explicit_callable_mapping')},ensure_ascii=False))
