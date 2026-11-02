import json
import sys
from pathlib import Path

STAGED = Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/development/staged/research-wiki')
sys.path.insert(0, str(STAGED))
from fastapi.testclient import TestClient
from rwiki.config import load_config
from rwiki.server import create_app


if __name__ == '__main__':
    client = TestClient(create_app(load_config(STAGED / 'config.json')))
    summaries = []
    for path, params in [('/api/discover-methods', {'limit': 100}),
                         ('/api/discover-methods', {'limit': -1}),
                         ('/api/method-taxonomy', {}),
                         ('/api/page', {'path': 'methods/gene-set-scoring.md'})]:
        response = client.get(path, params=params)
        data = response.json()
        result = {'path': path, 'params': params, 'status': response.status_code}
        if path == '/api/discover-methods' and response.status_code == 200:
            result.update(candidates=len(data['candidates']),
                          executable_ids=[c['id'] for c in data['candidates'] if c['executable']],
                          context_only=len(data['context_only']), scope_note=data['scope_note'])
            assert all(c['method_kind'] == 'analysis' for c in data['candidates'])
            assert all(c['readiness']['verified'] for c in data['candidates'] if c['executable'])
        summaries.append(result)
    print(json.dumps(summaries, ensure_ascii=False, indent=2))
