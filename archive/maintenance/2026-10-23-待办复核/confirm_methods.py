"""Apply the author's explicit confirmation through the public Wiki CLI."""
import hashlib,json,re,subprocess,urllib.request
from pathlib import Path

record=Path(__file__).parent
wiki=Path('E:/research-wiki/知识库')
py='C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe'
cli='C:/Users/86186/.agents/skills/research-wiki/wiki.py'
approved=json.loads((record/'pending-review.json').read_text(encoding='utf-8'))
pages=json.loads(urllib.request.urlopen('http://127.0.0.1:8765/api/pages',timeout=30).read())
by_path={p['path']:p for p in pages}
assert len(approved)==13
for item in approved:
    current=by_path[item['path']]
    assert current['meta']['id']==item['id'] and current['meta']['status']=='draft'
    assert current['workflow']['queue']=='confirm'
    assert current['implementation_status']==item['implementations']

before={'implementations':{p['path']:p.get('implementation_status',[]) for p in pages if p['meta']['type']=='method'},
        'user':{},'fields':{},'assets':{}}
for p in pages:
    path=wiki/p['path']
    text=path.read_text(encoding='utf-8')
    user=re.search(r'<!-- user:start -->(.*?)<!-- user:end -->',text,re.S)
    if user:before['user'][p['path']]=hashlib.sha256(user.group(1).encode()).hexdigest()
    before['fields'][p['path']]={k:p['meta'].get(k) for k in ('id','favorite','archived_from')}
for path in (wiki/'methods').rglob('*'):
    if path.is_file() and any(part in ('source','code','verification') for part in path.relative_to(wiki).parts) and '__pycache__' not in path.parts:
        before['assets'][path.relative_to(wiki).as_posix()]=hashlib.sha256(path.read_bytes()).hexdigest()
(record/'confirmation-before.json').write_text(json.dumps(before,ensure_ascii=False,indent=2),encoding='utf-8')
done=[]
for item in approved:
    result=subprocess.run([py,'-X','utf8',cli,'mark-ready',item['id']],capture_output=True,text=True,encoding='utf-8')
    (record/f"confirm-{item['id']}.log").write_text(result.stdout+result.stderr,encoding='utf-8')
    assert result.returncode==0,(item['id'],result.stderr)
    done.append(item['id'])
    (record/'confirmed-ids.json').write_text(json.dumps(done,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f'CONFIRMED {len(done)}/13 {item["id"]}',flush=True)

after=json.loads(urllib.request.urlopen('http://127.0.0.1:8765/api/pages',timeout=30).read())
after_by={p['path']:p for p in after}
for item in approved:assert after_by[item['path']]['meta']['status']=='ready'
for path,statuses in before['implementations'].items():assert after_by[path].get('implementation_status',[])==statuses,path
for path,fields in before['fields'].items():assert {k:after_by[path]['meta'].get(k) for k in fields}==fields,path
for path,digest in before['user'].items():
    user=re.search(r'<!-- user:start -->(.*?)<!-- user:end -->',(wiki/path).read_text(encoding='utf-8'),re.S)
    assert user and hashlib.sha256(user.group(1).encode()).hexdigest()==digest,path
for path,digest in before['assets'].items():assert hashlib.sha256((wiki/path).read_bytes()).hexdigest()==digest,path
queues={}
for p in after:
    queue=(p.get('workflow') or {}).get('queue')
    if queue:queues[queue]=queues.get(queue,0)+1
summary={'confirmed':done,'queues':queues,'implementation_status_unchanged':True,
         'protected_assets':len(before['assets']),'user_blocks_unchanged':len(before['user'])}
(record/'confirmation-result.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False),flush=True)
