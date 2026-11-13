"""Independent review reproductions; only temporary fixture data is written."""
import sys, json, tempfile, hashlib
from pathlib import Path
sys.path.insert(0, 'E:/research-wiki/开发/staged/research-wiki')
from rwiki.input_binding import map_records, prepare_tables

results = {}
columns = {'group': {'type':'str'}, 'feature': {'type':'str'}}
try:
    h, rows, report = map_records(['feature'], [{'feature':'CD3'}], columns, {'group':'feature'})
    results['implicit_double_consumer'] = {'accepted': True, 'rows':rows}
except ValueError as e:
    results['implicit_double_consumer'] = {'accepted':False, 'error':str(e)}
with tempfile.TemporaryDirectory(dir='E:/research-wiki-env/tmp') as tmp:
    root=Path(tmp)
    source=root/'values.csv'
    source.write_bytes(b'n\r\n2\r\n')
    before=source.read_bytes()
    spec={'tables':{'t':{'interface':'values','columns':{'value':{'type':'int'}}}}}
    bindings={'tables':{'t':{'file':'values.csv','columns':{'value':'n'}}}}
    try:
        report=prepare_tables(spec, bindings, root, root)
        results['source_output_collision']={'accepted':True,'source_changed':before!=source.read_bytes(), 'source_hash_report_is_original':report[0]['source_sha256']==hashlib.sha256(before).hexdigest()}
    except ValueError as e:
        results['source_output_collision']={'accepted':False,'source_changed':before!=source.read_bytes(),'error':str(e)}
print(json.dumps(results, ensure_ascii=False,indent=2))
