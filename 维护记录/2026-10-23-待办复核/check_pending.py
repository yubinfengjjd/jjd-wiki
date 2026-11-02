import json,subprocess,urllib.request
from pathlib import Path
from datetime import datetime

record=Path(__file__).parent
py='C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe'
cli='C:/Users/86186/.agents/skills/research-wiki/wiki.py'
pages=json.loads(urllib.request.urlopen('http://127.0.0.1:8765/api/pages',timeout=30).read())
pending=[p for p in pages if (p.get('workflow') or {}).get('queue') in ('agent','confirm','signoff')]
reports=[]
for page in pending:
    meta=page['meta']
    if page['workflow']['queue']=='confirm' and meta['type']=='method':
        result=subprocess.run([py,'-X','utf8',cli,'check-entry',meta['id']],capture_output=True,text=True,encoding='utf-8')
        checks=json.loads(result.stdout)
    else:
        checks={'passed':False,'errors':['需按实际工作流进一步处理']}
    reports.append({'path':page['path'],'id':meta.get('id'),'title':meta['title'],'purposes':meta.get('purposes',[]),
                    'queue':page['workflow']['queue'],'checks':checks,'implementations':page.get('implementation_status',[])})
(record/'pending-review.json').write_text(json.dumps(reports,ensure_ascii=False,indent=2),encoding='utf-8')
lines=['# 当前待办复核（2026-10-23）','',
       'CLI pending --json 返回空列表，网页无 agent 待办。剩余13项属于方法笔记作者确认；本记录不推进状态。','',
       '所有检查仅核对当前内容、关系与验证证据，不代替作者确认或真实课题科学验收。','',
       '| 方法笔记 | 用途 | 内容检查 | 当前实现 |','|---|---|---|---|']
for item in reports:
    statuses=item['implementations']
    verified=sum(s['state']=='verified' for s in statuses)
    state=f'{verified}/{len(statuses)} 个实现已验证'
    title=f"[{item['title']}](E:/research-wiki/知识库/{item['path']})"
    lines.append(f"| {title} | {'、'.join(item['purposes'])} | {'通过' if item['checks']['passed'] else '未通过'} | {state} |")
lines.extend(['','待确认只涉及笔记状态；SingleR、scDblFinder、scVelo等未运行分支仍保持not_run，不能因笔记确认变为可执行。',
              '未安装依赖、未添加算法、未改作者备注/收藏/状态、未删除或重新收录任何来源。'])
(record/'待确认清单.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(json.dumps({'total':len(reports),'agent':sum(p['queue']=='agent' for p in reports),
 'confirm':sum(p['queue']=='confirm' for p in reports),'content_passed':sum(p['checks']['passed'] for p in reports)},ensure_ascii=False))
assert all(p['checks']['passed'] for p in reports)
