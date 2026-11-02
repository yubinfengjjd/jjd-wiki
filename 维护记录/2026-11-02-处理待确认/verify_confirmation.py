from pathlib import Path
import sys,json,re,hashlib,collections,subprocess
sys.path.insert(0,'C:/Users/86186/.agents/skills/research-wiki')
from rwiki.config import load_config
from rwiki.workflow import workflow_snapshot
from rwiki.pages import read_page
from rwiki.acceptance import entry_errors,acceptance_stale
from rwiki.method_implementations import implementation_status
from rwiki.read_cache import read_session
ROOT=Path('E:/research-wiki');WIKI=ROOT/'知识库';R=ROOT/'维护记录/2026-11-02-处理待确认'
def load(name):return json.loads((R/name).read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
rows=load('confirm-review.json');before=load('branch-states-before.json');identities=load('identities-before.json');protected=load('protected-before.json')
for rel,digest in protected.items():assert sha(WIKI/rel)==digest,rel
states={};after_states=collections.Counter();types=collections.Counter()
with read_session():
 for row in rows:
  p=WIKI/row['path'];meta,body=read_page(p);assert meta['status']=='ready',row['id']
  assert not entry_errors(load_config(Path('C:/Users/86186/.agents/skills/research-wiki/config.json')),p),row['id']
  assert not acceptance_stale(p),row['id']
  for key,value in identities[row['id']].items():assert meta.get(key)==value,(row['id'],key)
  old=(R/'backup'/row['path']).read_bytes()
  assert re.findall(rb'<!-- user:start -->.*?<!-- user:end -->',old,re.S)==re.findall(rb'<!-- user:start -->.*?<!-- user:end -->',p.read_bytes(),re.S),row['id']
  current=implementation_status(p,meta);assert current==before[row['id']],row['id']
  after_states.update(x['state'] for x in current);types.update([meta['method_kind']])
  states[row['id']]={'status':meta['status'],'acceptance_current':True,'algorithm_and_portability_unchanged':True}
 config=load_config(Path('C:/Users/86186/.agents/skills/research-wiki/config.json'))
 workflow=workflow_snapshot(config)
 assert not [p for p,i in workflow.items() if i.get('queue')=='confirm']
 assert {p:i for p,i in workflow.items() if i.get('queue')=='agent'}=={p:i for p,i in load('queue-before.json').items() if i.get('queue')=='agent'}
for name,data in [('queue-after.json',workflow),('confirmed-items.json',states)]:
 (R/name).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
report={'confirmed':len(rows),'confirmed_types':dict(types),'remaining_confirmation_queue':0,'remaining_agent_queue_unfiltered':sum(x.get('queue')=='agent' for x in workflow.values()),'protected_code_source_and_execution_records_unchanged':len(protected),'algorithm_states_unchanged':dict(after_states),'author_blocks_preserved':len(rows),'new_algorithm_receipts':0,'packages_installed':False,'commit':subprocess.check_output(['git','-C',str(ROOT),'rev-parse','HEAD'],text=True).strip()}
(R/'final-audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8');print(json.dumps(report,ensure_ascii=False))
