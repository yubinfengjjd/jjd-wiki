from pathlib import Path
import sys,json,re,hashlib,subprocess,os
sys.path.insert(0,'C:/Users/86186/.agents/skills/research-wiki')
from rwiki.pages import read_page,write_page
from rwiki.method_implementations import implementation_status
ROOT=Path('E:/research-wiki');WIKI=ROOT/'知识库';R=ROOT/'维护记录/2026-11-02-处理待确认'
rows=json.loads((R/'confirm-review.json').read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,data):p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
baseline=R/'protected-before.json'
if not baseline.exists():
 protected={}
 for folder in ('methods','templates','recipes'):
  for p in (WIKI/folder).rglob('*'):
   if p.is_file() and any(x in p.relative_to(WIKI).parts for x in ['code','source','verification','verify','runs']) and '__pycache__' not in p.parts:
    protected[p.relative_to(WIKI).as_posix()]=sha(p)
 dump(baseline,protected)
branches={};identities={}
for row in rows:
 p=WIKI/row['path'];raw=p.read_bytes();meta,body=read_page(p)
 assert meta['status']=='draft' and meta['method_kind'] in ['technical','workflow']
 backup=R/'backup'/row['path'];backup.parent.mkdir(parents=True,exist_ok=True);backup.write_bytes(raw)
 a=p.with_suffix('')/'acceptance.json'
 if a.exists():
  dest=R/'backup'/a.relative_to(WIKI);dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(a.read_bytes())
 branches[row['id']]=implementation_status(p,meta)
 identities[row['id']]={k:meta.get(k) for k in ['id','favorite','archived_from','method_kind','implementations','code_roles','theory_methods']}
 user=re.findall(rb'<!-- user:start -->.*?<!-- user:end -->',raw,re.S)
 body=body.replace('其余为 not_run，页面保持 draft。','其余仍为 not_run；资料确认与实现运行验证分别记录。')
 body=body.replace('以下范围由当前字节的实际收据核对，页面保持 draft。','以下范围由当前字节的实际收据核对；资料确认与逐分支运行验证分别记录。')
 if row['id']=='scp-source-catalog':
  body=body.replace('verified / draft |','verified / ready |').replace('not_run / draft |','not_run / ready |')
  body=body.replace('状态以当前文件计算；不以这些计数宣称全库验收完成。','以上为来源整理阶段的数量；本轮只确认资料内容，当前实现状态仍按文件与收据计算，不以这些计数宣称全库验收完成。')
 notice=('## 资料确认记录（2026-11-02）\n\n'
         '作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。'
         'ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。'
         '正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。\n\n')
 assert '## 资料确认记录（2026-11-02）' not in body
 body=body.replace('<!-- user:start -->',notice+'<!-- user:start -->',1)
 write_page(p,meta,body)
 now=p.read_bytes();newuser=re.findall(rb'<!-- user:start -->.*?<!-- user:end -->',now,re.S)
 if newuser!=user:
  assert len(user)==len(newuser)==1
  now=now.replace(newuser[0],user[0],1);p.write_bytes(now)
 assert re.findall(rb'<!-- user:start -->.*?<!-- user:end -->',p.read_bytes(),re.S)==user
dump(R/'branch-states-before.json',branches);dump(R/'identities-before.json',identities)
env={**os.environ,'TEMP':'E:/research-wiki-env/tmp','TMP':'E:/research-wiki-env/tmp','MPLCONFIGDIR':'E:/research-wiki-env/tmp/mpl'}
checks=[]
for row in rows:
 cmd=['D:/anaconda/python.exe','-X','utf8','C:/Users/86186/.agents/skills/research-wiki/wiki.py','check-entry',row['id']]
 run=subprocess.run(cmd,env=env,capture_output=True,text=True,encoding='utf-8',errors='replace')
 (R/(row['id']+'-check.json')).write_text(run.stdout,encoding='utf-8')
 result=json.loads(run.stdout);assert result['passed'] and run.returncode==0,(row['id'],result,run.stderr)
 checks.append({'id':row['id'],'passed':True,'warning_count':len(result['warnings'])})
 print(row['id'],'check-entry passed',flush=True)
dump(R/'checks.json',checks)
print('All 17 checks passed; no status changes yet. Protected source/code/receipts captured.',flush=True)
