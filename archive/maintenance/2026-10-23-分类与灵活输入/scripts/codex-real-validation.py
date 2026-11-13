"""Independently rerun the declared real rendering cases in a separate workspace."""
import importlib.util,json,sys
from pathlib import Path
path=Path(__file__).with_name('validate_bindings.py')
spec=importlib.util.spec_from_file_location('binding_cases',path)
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.WORK=Path('E:/research-wiki-env/tmp/codex-final-bindings-validation')
m.RECORD=Path(__file__).parents[1]/'codex-real-validation'
(m.RECORD/'logs').mkdir(parents=True,exist_ok=True)
if '--check-existing' not in sys.argv:
    m.main()
p=json.loads((m.RECORD/'binding-validation-review1.json').read_text(encoding='utf-8'))
summary=[]
for item in p['results']:
    assert item['inputs_unchanged'],item['name']
    if item['name']=='negative-missing':
        assert item['exit']!=0 and not item['out_exists']
        summary.append({'case':item['name'],'rejected':True,'input_unchanged':True})
    else:
        assert item['standard']['exit']==item['bound']['exit']==0,item['name']
        assert item['renamed_without_bindings']['exit']!=0,item['name']
        if item['name']!='r-dotplot-optional':
            assert item['comparison']['mean_abs_difference']==0,item['name']
        assert item['report']['source_sha256_matches_input_before'],item['name']
        summary.append({'case':item['name'],'input_unchanged':True,'pixel_MAD':item['comparison']['mean_abs_difference']})
(m.RECORD/'summary.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
print('INDEPENDENT_CASES_PASS',len(summary))
