"""Synthetic validator probes only; receipts here never prove execution."""
import hashlib
import json
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0,'E:/research-wiki/开发/staged/research-wiki')
from rwiki.runtime_contract import closure_hash, runtime_facts
from rwiki.method_implementations import implementation_status

record=Path(__file__).parents[1]
probe=record/'codex-probes'/datetime.now().strftime('contract-%H%M%S-%f')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def fixture(name,kind='template',resources=False):
    root=probe/name/'demo'
    (root/'code').mkdir(parents=True)
    (root/'code/run.R').write_text('run <- function(x) x\n',encoding='utf-8')
    item={'id':'demo' if kind=='template' else 'branch','entry':'code/run.R',
          'entry_function':'run','language':'R','runtime_mode':'standalone',
          'files':['code/run.R'],'resources':[],'required_packages':{'R':[]},
          'optional_packages':{},'evidence':{'portability':'verification/portable.json'}}
    if resources:
        (root/'data').mkdir()
        (root/'data/palette.txt').write_text('ORIGINAL',encoding='utf-8')
        item['resources']=[{'path':'data/palette.txt','sha256':sha(root/'data/palette.txt'),'role':'palette'}]
    manifest={'schema_version':1,'kind':kind,'id':'demo'}
    if kind=='method':manifest['implementations']=[item]
    else:manifest.update(item)
    (root/'runtime.json').write_text(json.dumps(manifest),encoding='utf-8')
    receipt={'schema_version':1,'implementation':item['id'],'state':'passed',
             'scope':'Synthetic structural validator fixture only; no execution',
             'command':'synthetic fixture','checks':['structure only'],'environment':{},
             'closure_hash':closure_hash(root,item),'files':{'code/run.R':sha(root/'code/run.R')}}
    (root/'verification').mkdir()
    (root/'verification/portable.json').write_text(json.dumps(receipt),encoding='utf-8')
    return root,manifest

def rebind(root,manifest):
    (root/'runtime.json').write_text(json.dumps(manifest),encoding='utf-8')
    item=manifest['implementations'][0] if manifest['kind']=='method' else manifest
    target=root/'verification/portable.json'
    receipt=json.loads(target.read_text(encoding='utf-8'))
    receipt['closure_hash']=closure_hash(root,item)
    receipt['files']={name:sha(root/name) for name in item['files']}
    target.write_text(json.dumps(receipt),encoding='utf-8')

results={}
root,manifest=fixture('resource',resources=True)
results['resource_before']=runtime_facts(root,'demo','template')['portability']['state']
(root/'data/palette.txt').write_text('CHANGED',encoding='utf-8')
results['resource_changed']=runtime_facts(root,'demo','template')['portability']['state']

root,manifest=fixture('resource-valid',resources=True)
manifest['files'].append('data/palette.txt')
rebind(root,manifest)
results['valid_resource_before']=runtime_facts(root,'demo','template')['portability']['state']
(root/'data/palette.txt').write_text('CHANGED',encoding='utf-8')
results['valid_resource_changed']=runtime_facts(root,'demo','template')['portability']['state']

root,manifest=fixture('resource-wrong-declaration',resources=True)
manifest['files'].append('data/palette.txt')
manifest['resources'][0]['sha256']='0'*64
rebind(root,manifest)
results['wrong_declared_resource_hash']=runtime_facts(root,'demo','template')['portability']['state']

root,manifest=fixture('malformed')
manifest['resources']=7
(root/'runtime.json').write_text(json.dumps(manifest),encoding='utf-8')
try:
    results['malformed_resources']=runtime_facts(root,'demo','template')['portability']['state']
except Exception as error:
    results['malformed_resources']=type(error).__name__+': '+str(error)

root,manifest=fixture('entry-mismatch',kind='method')
(root/'code/other.R').write_text('other <- function(x) x+1\n',encoding='utf-8')
meta={'id':'demo','type':'method','method_kind':'analysis','summary':'Demo',
      'data_contract':{'input':'x','output':'y'},'implementations':[{'id':'branch','title':'Branch',
      'language':'R','entrypoint':'code/other.R:other','dependencies':[]}]}
results['different_registered_entry']=implementation_status(root.with_suffix('.md'),meta)[0]['runtime']['portability']['state']
meta['implementations'][0]['entrypoint']='code/run.R:other'
results['different_registered_function']=implementation_status(root.with_suffix('.md'),meta)[0]['runtime']['portability']['state']

(record/'codex-contract-probes.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
print(json.dumps(results))
failures=[]
if results['resource_changed']=='verified':failures.append('resource change kept verified')
if results['valid_resource_before']!='verified':failures.append('valid resource receipt is rejected')
if results['valid_resource_changed']=='verified':failures.append('valid resource change kept verified')
if results['wrong_declared_resource_hash']=='verified':failures.append('wrong declared resource hash is accepted')
if results['malformed_resources'].startswith('TypeError:'):failures.append('malformed manifest crashes parser')
if results['different_registered_entry']=='verified':failures.append('portability proof is for a different entry')
if results['different_registered_function']=='verified':failures.append('portability proof is for a different function')
if failures:
    print('REVIEW_FINDINGS: '+'; '.join(failures))
    raise SystemExit(1)
