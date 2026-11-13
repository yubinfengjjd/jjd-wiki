"""Independent reviewer probes, one R process at a time; no production writes."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

record=Path(__file__).parents[1]
scripts=record/'scripts'
wiki=Path('E:/research-wiki/知识库')
prefix=sys.argv[1] if len(sys.argv)>1 else 'codex-current'
methods_root=Path(sys.argv[2]) if len(sys.argv)>2 else wiki/'methods'
r='D:/R-4.5.0/bin/Rscript.exe'
cases=[('source',[r,'--vanilla',str(scripts/'codex-source-probe.R'),str(methods_root/'cell-quality-control/code/analysis.R')]),
       ('multi-module',[r,'--vanilla',str(scripts/'codex-multi-module-probe.R'),str(methods_root)]),
       ('qc',[r,'--vanilla',str(scripts/'codex-qc-probe.R'),str(methods_root/'cell-quality-control/code'),str(record/f'{prefix}-qc.rds')])]
results={}
for name,command in cases:
    log=record/f'{prefix}-{name}.log'
    with log.open('w',encoding='utf-8') as stream:
        process=subprocess.run(command,stdout=stream,stderr=subprocess.STDOUT,timeout=180)
    lines=log.read_text(encoding='utf-8',errors='replace').splitlines()
    results[name]={'exit':process.returncode,'log':str(log),'tail':lines[-8:]}
    print(json.dumps({'case':name,'exit':process.returncode,'tail':lines[-4:]},ensure_ascii=False))
for family in ['cell-quality-control','gene-set-scoring']:
    results[family+'-sha256']={p.name:hashlib.sha256(p.read_bytes()).hexdigest()
        for p in (methods_root/family/'code').glob('*') if p.is_file()}
(record/f'{prefix}-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
if any(item['exit'] for key,item in results.items() if not key.endswith('-sha256')):
    raise SystemExit(1)
