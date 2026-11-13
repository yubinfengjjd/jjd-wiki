"""Hash-guarded, narrowly scoped rule/taxonomy deployment with exact backups.

No whole-skill replacement and no Git staging. Source taxonomy is authoritative;
the JSON schema enum is a checked derivative, not a second independent vocabulary.
"""
from pathlib import Path
from datetime import datetime,timezone
import argparse,hashlib,json,os,shutil,subprocess
A=Path('E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环')
S=Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/development')
R=Path('E:/research-wiki')
EXT=Path('E:/桌面/ARIS/sci-figure-replica-dev-20261020/staged/sci-figure-replica')
HOSTS=('.agents','.codex','.claude','.cc-switch','.config/opencode')
PLAN=A/'governance-sync-plan.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def write(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def prepare():
 assert not PLAN.exists(),'Existing plan must be reviewed, never overwritten'
 taxonomy=S/'spec/scenario_taxonomy.yaml'
 schema=S/'spec/metadata.schema.reviewed.json'
 ref=S/'spec/scenario-taxonomy.reference.md'
 new=read(taxonomy);old=read(EXT/'assets/scenario_taxonomy.yaml')
 authority=read(Path.home()/'.claude/skills/sci-figure-replica/assets/scenario_taxonomy.yaml')
 assert all(k in new['scenarios'] and new['scenarios'][k]['label']==v['label'] for k,v in authority['scenarios'].items())
 assert set(old['scenarios'])<=set(new['scenarios'])
 oldschema=read(EXT/'assets/metadata.schema.json');newschema=read(schema)
 expected=read(EXT/'assets/metadata.schema.json');expected['$defs']['scenario']['enum']=list(new['scenarios'])
 assert newschema==expected,'Only derived scenario enum may change'
 assert '10个主场景' not in ref.read_text(encoding='utf-8')
 rows=[];manifests=[];protected={}
 pairs=[('assets/scenario_taxonomy.yaml',taxonomy),('assets/metadata.schema.json',schema),('references/scenario-taxonomy.md',ref)]
 roots=[('primary-source',EXT)]+[(h,Path.home()/h/'skills/sci-figure-replica') for h in HOSTS]
 for label,root in roots:
  assert root.resolve()==root.absolute(),'No linked deployment root'
  excluded={x[0] for x in pairs}|{'installation-manifest.json'}
  for p in root.rglob('*'):
   if not p.is_file() or set(p.relative_to(root).parts)&{'.git','__pycache__','.pytest_cache','node_modules'}:continue
   if p.relative_to(root).as_posix() not in excluded:protected[str(p)]=sha(p)
  for rel,src in pairs:
   dst=root/rel
   if rel=='assets/metadata.schema.json':assert read(dst)==oldschema,(label,'unexpected custom schema')
   if rel=='references/scenario-taxonomy.md':assert dst.read_bytes()==(EXT/rel).read_bytes(),(label,'unexpected custom reference')
   if rel=='assets/scenario_taxonomy.yaml':
    assert read(dst) in (old,authority),(label,'unexpected custom taxonomy')
   rows.append({'label':label,'path':str(dst),'source':str(src),'old':sha(dst),'new':sha(src)})
  if label!='primary-source':
   mp=root/'installation-manifest.json';m=read(mp)
   assert m['skill']=='sci-figure-replica'
   for rel,_ in pairs:assert sum(x.get('path')==rel for x in m['files'])==1
   manifests.append({'label':label,'path':str(mp),'old':sha(mp)})
 formal=R/'知识库/AGENTS.md';initial=read(A/'a25-isolated-library-baseline.json')['files']['AGENTS.md']
 assert sha(formal)==initial,'Formal rule changed since reviewed baseline'
 rows.append({'label':'formal-wiki','path':str(formal),'source':str(S/'staged/research-wiki/assets/AGENTS.md'),'old':sha(formal),'new':sha(S/'staged/research-wiki/assets/AGENTS.md')})
 spec=R/'开发/spec/scenario_taxonomy.yaml'
 assert read(spec)==old,'Unexpected original development specification'
 rows.append({'label':'development-spec','path':str(spec),'source':str(taxonomy),'old':sha(spec),'new':sha(taxonomy)})
 write(PLAN,{'rows':rows,'manifests':manifests,'protected':protected,'scope':'3 external skill assets only; formal rule; source spec; preserve all other files'})
 print(json.dumps({'prepared':len(rows),'manifest_records':len(manifests)}))
def apply():
 plan=read(PLAN)
 for row in plan['rows']:
  assert sha(Path(row['path']))==row['old'],row['path']
  assert sha(Path(row['source']))==row['new'],row['source']
 for m in plan['manifests']:assert sha(Path(m['path']))==m['old']
 journal=[]
 def replace(dst,data,label):
  backup=A/'governance-sync-backup'/label/Path(*dst.parts[1:])
  assert not backup.exists(),'Never overwrite an earlier backup'
  backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(dst,backup)
  assert backup.read_bytes()==dst.read_bytes()
  tmp=dst.with_name(dst.name+'.codex-syncing');assert not tmp.exists()
  tmp.write_bytes(data);os.replace(tmp,dst)
 for row in plan['rows']:
  dst=Path(row['path']);assert sha(dst)==row['old']
  replace(dst,Path(row['source']).read_bytes(),row['label'])
  assert sha(dst)==row['new'];journal.append(row)
  write(A/'governance-sync-journal.json',journal)
 for entry in plan['manifests']:
  mp=Path(entry['path']);assert sha(mp)==entry['old'];m=read(mp)
  scoped=[row for row in plan['rows'] if row['label']==entry['label']]
  for row in scoped:
   rel=Path(row['path']).relative_to(mp.parent).as_posix()
   f=next(x for x in m['files'] if x['path']==rel)
   f['sha256']=row['new']
   if 'source' in f:f['source']=str(EXT/rel)
   if 'target' in f:f['target']=row['path']
  m.setdefault('scoped_updates',[]).append({'at':datetime.now(timezone.utc).isoformat(),'maintenance_record':str(A),'scope':'assets/scenario_taxonomy.yaml, assets/metadata.schema.json, references/scenario-taxonomy.md only; other skill files not redeployed or certified','files':[{k:row[k] for k in ('path','old','new')} for row in scoped]})
  replace(mp,(json.dumps(m,ensure_ascii=False,indent=2)+'\n').encode('utf-8'),entry['label'])
  for row in scoped:assert sha(Path(row['path']))==row['new']
 unrelated=[p for p,h in plan['protected'].items() if sha(Path(p))!=h]
 assert not unrelated,unrelated
 write(A/'governance-sync-verification.json',{'files':len(journal),'manifests':len(plan['manifests']),'all_scoped_hashes_verified':True,'backups':str(A/'governance-sync-backup'),'unrelated_files_hash_checked':len(plan['protected']),'no_unrelated_skill_files_changed':True})
 print(json.dumps({'synced_files':len(journal),'scoped_manifests':len(plan['manifests'])}))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--apply',action='store_true');args=p.parse_args()
 apply() if args.apply else prepare()
