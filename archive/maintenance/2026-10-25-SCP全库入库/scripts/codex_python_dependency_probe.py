"""Presence-only probe of the existing bio-python interpreter; no package imports."""
from pathlib import Path
import importlib.util, importlib.metadata, json, sys
names = {'numpy':'numpy','pandas':'pandas','anndata':'anndata','scanpy':'scanpy',
 'scvelo':'scvelo','scvi':'scvi-tools','scanorama':'scanorama','bbknn':'bbknn',
 'leidenalg':'leidenalg','palantir':'palantir','wot':'wot','phate':'phate',
 'pacmap':'pacmap','trimap':'trimap','largevis':'largevis','scrublet':'scrublet',
 'doubletdetection':'doubletdetection','magic':'magic-impute','cellrank':'cellrank'}
result={'interpreter':sys.executable,'scope':'presence-only; not module import, algorithm execution or scientific validation','modules':{}}
for module,distribution in names.items():
    spec=importlib.util.find_spec(module)
    try: version=importlib.metadata.version(distribution)
    except importlib.metadata.PackageNotFoundError: version=None
    result['modules'][module]={'distribution':distribution,'spec_found':spec is not None,'distribution_version':version}
out=Path('E:/research-wiki/维护记录/2026-10-25-SCP全库入库/codex-python-presence.json')
out.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False))
