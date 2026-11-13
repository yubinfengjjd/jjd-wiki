"""Independent pilot review; no scientific computations or source writes."""
from pathlib import Path
import csv, hashlib, json, math, sys
from copy import deepcopy
from datetime import datetime, timezone

A=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
P=Path('E:/青光眼单细胞/wiki-use/acceptance-20261024')
B=Path('E:/research-wiki-env/work/wiki-cross-domain-20261024')
T=P/'.agents/skills/research-wiki'
W=B/'pilot-evidence/wiki'

def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for chunk in iter(lambda:f.read(1<<20),b''):h.update(chunk)
 return h.hexdigest()

def table(p):
 with p.open(encoding='utf-8-sig',newline='') as f:return list(csv.DictReader(f))

def main():
 raw=table(P/'analysis/de-rgclike-vs-others-allmarkers.csv')
 mapped=table(P/'analysis/render-de-results.csv')
 assert len(raw)==len(mapped)==7403
 assert len({r['gene'] for r in raw})==7403
 floor=min(float(r['p_val_adj']) for r in raw if float(r['p_val_adj'])>0)/2
 zero=0
 for x,y in zip(raw,mapped):
  for c in ('gene','group1','group2'):assert x[c]==y[c],(c,x[c],y[c])
  for a,b in (('avg_log2FC','avg_log2FC'),('pct.1','pct_1'),('pct.2','pct_2'),('p_val','p_val')):
   assert math.isclose(float(x[a]),float(y[b]),rel_tol=1e-13,abs_tol=0),(a,x[a],y[b])
  adj=float(x['p_val_adj']); zero+=adj==0
  expected=floor if adj==0 else adj
  assert math.isclose(expected,float(y['p_val_adj']),rel_tol=1e-13,abs_tol=0)
  assert all(math.isfinite(float(y[k])) for k in ('avg_log2FC','pct_1','pct_2','p_val','p_val_adj'))
  assert all(0<=float(y[k])<=1 for k in ('pct_1','pct_2','p_val','p_val_adj'))
 assert zero==71
 assert {r['group1'] for r in raw}=={'RGC_like'} and {r['group2'] for r in raw}=={'others'}
 root=W/'methods/differential-expression'
 manifest=json.loads((root/'runtime.json').read_text(encoding='utf-8'))
 impl=next(i for i in manifest['implementations'] if i['id']=='scp-detest')
 receipt=json.loads((root/'verification/scp-detest-standalone.json').read_text(encoding='utf-8'))
 closure={}
 for rel in impl['files']:
  f=P/'scripts/wiki-scp-detest'/Path(rel).name
  assert sha(f)==sha(root/rel)==receipt['executed_files'][rel]
  closure[rel]=sha(f)
 baseline=json.loads((A/'a25-trial-skill-before-phase2-reviewed.json').read_text(encoding='utf-8'))
 trial_bad=[rel for rel,digest in baseline['trial_hashes'].items() if not (T/rel).is_file() or sha(T/rel)!=digest]
 assert not trial_bad,trial_bad
 fb=json.loads((A/'a25-isolated-library-baseline.json').read_text(encoding='utf-8'))
 fixture_bad=[rel for rel,digest in fb['files'].items() if rel!='AGENTS.md' and (not (W/rel).is_file() or sha(W/rel)!=digest)]
 assert not fixture_bad,fixture_bad
 assert (W/'AGENTS.md').read_bytes()==(T/'assets/AGENTS.md').read_bytes()
 for rid in ('run-de-rgclike-001','run-render-de-volcano-001'):
  rr=json.loads((P/f'wiki-use/_project/runs/{rid}/receipt.json').read_text(encoding='utf-8'))
  for item in rr['outputs']:assert sha(P/item['path'])==item['sha256'],item['path']
 report={'at':datetime.now(timezone.utc).isoformat(),'reviewer':'Codex',
  'raw_rows':len(raw),'mapped_rows':len(mapped),'zero_p_values':zero,'render_floor':floor,
  'mapping':'same row keys and numbers except documented 71 adjusted-p display floors; no aggregate or unit conversion',
  'runtime_closure':closure,'trial_skill_unchanged_files':len(baseline['trial_hashes']),
  'isolated_wiki_unchanged_except_preapproved_AGENTS':len(fb['files'])-1,
  'raw_sha256':sha(P/'analysis/de-rgclike-vs-others-allmarkers.csv'),
  'diagnostics_gap':'0-byte JSON remains; historical process diagnostics/exit success not established',
  'visual_review':'Codex actually opened PNG: RGC_like, diff_pct X, signed -log10 adjusted p Y, log2FC color; top display floor; labels visible. This is the native SCP variant, not a conventional log2FC X volcano.',
  'scientific_limits':'cell-level descriptive markers for preexisting labels; not donor-level inference or independent annotation validation',
  'status':'passed_scoped_output_mapping_and_provenance_checks_with_diagnostics_gap'}
 (A/'a25-independent-output-review.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
 print(json.dumps(report,ensure_ascii=False,indent=2))

if __name__=='__main__':main()
