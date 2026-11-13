"""Independent audit driver: this run's scores -> explicit bindings -> copied native renderer."""
import csv
import hashlib
import importlib.util
import json
import shutil
from pathlib import Path

import yaml

WIKI = Path('E:/research-wiki/知识库')
ROOT = Path('E:/research-wiki-env/work/wiki-cross-domain-20261024/native-probe')
TEMPLATE_ID = '2026-10-22-scp-example__fig16-cell-density--ridge'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


if __name__ == '__main__':
    template = WIKI / 'templates' / TEMPLATE_ID
    copied = ROOT / 'density-template'
    manifest = json.loads((template / 'runtime.json').read_text(encoding='utf-8'))
    file_hashes = {}
    for relative in [*manifest['files'], 'spec.json', 'runtime.json']:
        target = copied / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(template / relative, target)
        file_hashes[relative] = sha(target)
    spec = json.loads((copied / 'spec.json').read_text(encoding='utf-8'))
    interface = WIKI / 'interfaces/render-cell-feature-values.md'
    contract = yaml.safe_load(interface.read_text(encoding='utf-8').split('---', 2)[1])
    spec['tables']['density']['columns'] = contract['columns']
    # The function accepts plain numbers: no grouping/aggregation/statistical test here.
    scores_path = ROOT / 'out/scores.csv'
    before = sha(scores_path)
    with scores_path.open(encoding='utf-8', newline='') as stream:
        scores = list(csv.DictReader(stream))
    assert len(scores) == 10100
    assert len({row['cell_id'] for row in scores}) == len(scores)
    groups = list(dict.fromkeys(row['celltype_declared'] for row in scores))
    author_dir = ROOT / 'plot-author-input'
    author_dir.mkdir(exist_ok=True)
    author_file = author_dir / 'ap1_scores.csv'
    header = [*scores[0], 'feature_label', 'feature_rank', 'celltype_rank']
    with author_file.open('w', encoding='utf-8', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=header)
        writer.writeheader()
        for row in scores:
            writer.writerow({**row, 'feature_label': 'AP1_Seurat_module_score',
                             'feature_rank': 1, 'celltype_rank': groups.index(row['celltype_declared']) + 1})
    helper = Path('E:/research-wiki/开发/staged/research-wiki/rwiki/input_binding.py')
    helper_spec = importlib.util.spec_from_file_location('audit_binding', helper)
    binding = importlib.util.module_from_spec(helper_spec)
    helper_spec.loader.exec_module(binding)
    config = {'tables': {'density': {'file': author_file.name, 'columns': {
        'cell': 'cell_id', 'feature': 'feature_label', 'value': 'score',
        'group': 'celltype_declared', 'feature_order': 'feature_rank',
        'group_order': 'celltype_rank'}}}}
    reports = binding.prepare_tables(spec, config, author_dir, ROOT / 'plot-bound')
    assert sha(scores_path) == before
    with (ROOT / 'plot-bound/render-cell-feature-values.csv').open(encoding='utf-8', newline='') as stream:
        mapped = list(csv.DictReader(stream))
    assert len(mapped) == len(scores)
    assert [(r['cell'], r['group'], r['value']) for r in mapped] == [
        (r['cell_id'], r['celltype_declared'], r['score']) for r in scores]
    style = {'title': 'AP1 module score in the existing retinal object',
             'subtitle': '10,100 cells; pooled GSM samples; descriptive score in arbitrary units',
             'group_by': 'Declared cell type', 'split_by': 'All.groups',
             'group_levels': groups, 'feature_levels': ['AP1_Seurat_module_score'],
             'dpi': 192, 'sizing': {'mode': 'adaptive', 'base_in': 8.0}}
    (ROOT / 'density-style.json').write_text(json.dumps(style, indent=2), encoding='utf-8')
    (ROOT / 'plot-bindings.json').write_text(json.dumps(config, indent=2), encoding='utf-8')
    report = {'scope': 'Independent software result-to-figure probe, not agent-entry or biological validation',
              'template': TEMPLATE_ID, 'files': file_hashes, 'scores_sha256': before,
              'binding_helper_sha256': sha(helper), 'interface_sha256': sha(interface),
              'rows': len(mapped), 'groups': groups,
              'checks': ['cell ids/order/score values preserved exactly',
                         'declared cell types only; GSM samples pooled without disease inference',
                         'no statistical test or p-value supplied'],
              'bindings': binding.report_payload(reports)}
    (ROOT / 'plot-mapping-verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps({'rows': len(mapped), 'groups': len(groups), 'template_files': len(file_hashes),
                      'value_preservation': 'exact'}, ensure_ascii=False))
