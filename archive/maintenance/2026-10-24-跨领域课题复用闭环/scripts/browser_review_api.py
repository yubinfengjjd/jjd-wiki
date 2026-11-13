"""Local read-only-browser acceptance server for frozen candidate source."""
import os
import sys
from pathlib import Path
import uvicorn

ROOT=Path(os.environ.get('RWIKI_BROWSER_ROOT',
    'E:/research-wiki-env/work/wiki-cross-domain-20261024/review-batch2-snapshot-checkpoint1/staged/research-wiki'))
sys.path.insert(0,str(ROOT))
from rwiki.config import load_config
from rwiki.server import create_app

if __name__=='__main__':
    print(f'QA_API_PID={os.getpid()}',flush=True)
    uvicorn.run(create_app(load_config(ROOT/'config.json')),host='127.0.0.1',
                port=int(os.environ.get('RWIKI_BROWSER_PORT','8877')))
