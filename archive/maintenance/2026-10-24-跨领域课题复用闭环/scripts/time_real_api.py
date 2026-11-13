"""Read-only baseline/candidate API timing on the same actual Wiki."""
import json
import sys
import time
from pathlib import Path

source=Path(sys.argv[1])
sys.path.insert(0,str(source))
from fastapi.testclient import TestClient
from rwiki.config import load_config
from rwiki.server import create_app

client=TestClient(create_app(load_config(source/'config.json')))
rows=[]
for url in ('/api/method-taxonomy','/api/pages','/api/graph'):
    started=time.perf_counter()
    r=client.get(url)
    elapsed=time.perf_counter()-started
    data=r.json()
    rows.append({'url':url,'status':r.status_code,'seconds':round(elapsed,3),
                 'bytes':len(r.content),
                 'items':len(data) if isinstance(data,list) else None})
print(json.dumps({'source':str(source),'results':rows},ensure_ascii=False,indent=2))
