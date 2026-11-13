"""Independent reproduction on an explicitly synthetic private rule fixture."""
from pathlib import Path
import argparse,json,sys,subprocess
from dataclasses import replace
p=argparse.ArgumentParser();p.add_argument('--skill',required=True);p.add_argument('--fixture',required=True);args=p.parse_args()
skill=Path(args.skill);root=Path(args.fixture)
assert not root.exists(),'Preserve earlier evidence; choose a new fixture'
root.mkdir(parents=True);(root/'methods').mkdir()
sys.path.insert(0,str(skill))
from rwiki.config import load_config
from rwiki.pages import write_page,read_page
from rwiki.lint import metadata_errors,lint
from rwiki.acceptance import entry_errors
from rwiki.server import create_app
from starlette.testclient import TestClient
c=replace(load_config(skill/'config.json'),wiki_root=root,port=8883)
meta={'type':'method','id':'controlled-tag-probe','title':'隔离规则测试夹具','status':'draft','tags':['单细胞分析'],
 'inputs':[],'outputs':[],'source':{'kind':'written'},'license':'GPL-3','cite':['SCP source commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0'],
 'favorite':False,'method_kind':'technical','summary':'仅用于受控标签的机械负例，不是科研知识或算法验证。',
 'data_contract':{'input':'隔离的元数据请求，不是科研输入。','output':'机械校验结果，不是算法输出。'}}
body='# 隔离规则测试夹具\n\n<!-- facts:start -->\n<!-- facts:end -->\n\n'
for h in ('用途','适用','不适用','输入','怎么做','代码','输出','知识关联检查'):
 body+='## '+h+'\n\n仅测试标签验证边界；不执行科学分析，不进入正式库。\n\n'
body+='<!-- user:start -->\n<!-- user:end -->\n'
page=root/'methods/controlled-tag-probe.md';write_page(page,meta,body)
for a in (['init','-q'],['add','-A'],['-c','user.name=fixture','-c','user.email=fixture@localhost','commit','-qm','mechanical fixture only']):subprocess.run(['git','-C',str(root),*a],check=True,capture_output=True)
before=page.read_bytes()
candidate=dict(meta,tags=['not-a-controlled-label'])
static_errors=metadata_errors(candidate)
client=TestClient(create_app(c))
response=client.post('/api/methods/controlled-tag-probe/tags',json={'tags':['not-a-controlled-label']})
after_meta,_=read_page(page)
report={'synthetic_fixture':str(root),'skill':str(skill),'unknown_tag_static_errors':static_errors,
 'api_status':response.status_code,'page_changed':page.read_bytes()!=before,'stored_tags':after_meta.get('tags'),
 'entry_errors_after_request':entry_errors(c,page),'lint_errors_after_request':[x for x in lint(c) if x.startswith('ERROR ')],
 'scope':'Actual isolated API/store/acceptance/lint; no formal pages, signoff or algorithm evidence touched.'}
(root/'probe-result.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8');print(json.dumps(report,ensure_ascii=False,indent=2))
