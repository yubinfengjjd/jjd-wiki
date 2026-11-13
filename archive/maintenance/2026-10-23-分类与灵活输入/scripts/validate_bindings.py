"""Run the real R/Python templates with standard and bound inputs and compare outputs."""
import csv
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageStat

ROOT = Path(r'E:/research-wiki')
SKILL = ROOT / '开发/staged/research-wiki'
CONFIG = SKILL / 'config.json'
WIKI_PY = Path(r'C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe')
WIKI = ROOT / '知识库'
WORK = Path(r'E:/research-wiki-env/tmp/rw-bindings')
RECORD = ROOT / '维护记录/2026-10-23-分类与灵活输入'

ENV = dict(os.environ)
ENV.update({
    'TEMP': r'E:/research-wiki-env/tmp', 'TMP': r'E:/research-wiki-env/tmp',
    'MPLCONFIGDIR': r'E:/research-wiki-env/tmp/mpl',
    'PROCESSOR_ARCHITECTURE': 'AMD64',
    'R_LIBS_USER': r'E:/research-wiki-env/R-lib-scp/4.5',
})
for key in ('LC_ALL', 'LC_CTYPE', 'LANG'):
    ENV.pop(key, None)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_rows(path):
    with path.open(encoding='utf-8-sig', newline='') as stream:
        reader = csv.DictReader(stream)
        return reader.fieldnames, list(reader)


def write_rows(path, header, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='utf-8', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=header, lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)


def rename(source, target, mapping, drop=()):
    header, rows = read_rows(source)
    out_header = [name for name in header if name not in drop]
    out_rows = []
    for row in rows:
        item = {}
        for name in out_header:
            item[mapping.get(name, name)] = row[name]
        out_rows.append(item)
    write_rows(target, [mapping.get(name, name) for name in out_header], out_rows)
    return {mapping.get(name, name): name for name in out_header}


def run(*args):
    result = subprocess.run([str(WIKI_PY), '-X', 'utf8', str(SKILL / 'wiki.py'),
                             '--config', str(CONFIG), *map(str, args)],
                            capture_output=True, text=True, encoding='utf-8', env=ENV)
    return result


def compare(a, b):
    with Image.open(a) as left, Image.open(b) as right:
        if left.size != right.size:
            return {'same_size': False, 'size_a': left.size, 'size_b': right.size,
                    'mean_abs_difference': None}
        diff = ImageChops.difference(left.convert('RGB'), right.convert('RGB'))
        return {'same_size': True, 'size_a': left.size, 'size_b': right.size,
                'mean_abs_difference': round(sum(ImageStat.Stat(diff).mean) / 3, 9),
                'same_bytes': a.read_bytes() == b.read_bytes()}


def case(name, template, source_name, mapping, drop=(), bindings_mapping=None):
    base = WORK / name
    if base.exists():
        shutil.rmtree(base)
    author = base / 'author'
    author.mkdir(parents=True)
    template_dir = WIKI / 'templates' / template
    source = template_dir / 'example' / source_name
    renamed = rename(source, author / 'my_data.csv', mapping, drop=drop)
    table_key = json.loads((template_dir / 'spec.json').read_text(encoding='utf-8'))['tables']
    table_key = next(iter(table_key))
    columns = bindings_mapping or {internal: external for external, internal in renamed.items()}
    bindings = {'tables': {table_key: {'file': 'my_data.csv', 'columns': columns}}}
    bindings_path = base / 'bindings.json'
    bindings_path.write_text(json.dumps(bindings, ensure_ascii=False, indent=2), encoding='utf-8')

    example_before = digest(source)
    author_file = author / 'my_data.csv'
    author_before = digest(author_file)

    standard = run('render', template, '--data', template_dir / 'example', '--out', base / 'standard')
    bound = run('render', template, '--data', author, '--bindings', bindings_path,
                '--out', base / 'bound')
    negative = {'renamed_without_bindings': run(
        'render', template, '--data', author, '--out', base / 'no-bindings')}
    example_after = digest(source)
    author_after = digest(author_file)
    if example_before != example_after or author_before != author_after:
        raise SystemExit(f'{name}: an input changed during render')
    result = {
        'name': name, 'template': template, 'table_key': table_key,
        'source': source_name, 'source_sha256': example_before,
        'source_sha256_after': example_after,
        'input_file': 'author/my_data.csv',
        'input_sha256_before': author_before, 'input_sha256_after': author_after,
        'inputs_unchanged': example_before == example_after and author_before == author_after,
        'bindings': bindings,
        'standard': {'exit': standard.returncode, 'stderr': standard.stderr[-800:]},
        'bound': {'exit': bound.returncode, 'stderr': bound.stderr[-800:]},
        'renamed_without_bindings': {'exit': negative['renamed_without_bindings'].returncode,
                                     'stderr': negative['renamed_without_bindings'].stderr[-800:]},
    }
    if standard.returncode == 0 and bound.returncode == 0:
        result['comparison'] = compare(base / 'standard/figure.png', base / 'bound/figure.png')
        result['standard']['figure_sha256'] = digest(base / 'standard/figure.png')
        result['bound']['figure_sha256'] = digest(base / 'bound/figure.png')
        report = json.loads((base / 'bound/bindings-report.json').read_text(encoding='utf-8'))
        item = report['tables'][0]
        result['report'] = {
            'mapping': item['mapping'], 'omitted_optional': item['omitted_optional'],
            'extras_preserved': item['extras_preserved'], 'checks': item['checks'],
            'warnings': item['warnings'], 'semantics': item['semantics'],
            'source_sha256': item['source_sha256'],
            'source_sha256_matches_input_before': item['source_sha256'] == author_before,
        }
    return result


def main():
    WORK.mkdir(parents=True, exist_ok=True)
    results = []
    results.append(case(
        'r-dotplot', '2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot',
        'render-dotplot-long.csv',
        {'group': 'cell_type', 'feature': 'gene_symbol', 'avg_expression': 'mean_expr',
         'pct_expressed': 'positive_percent', 'target_group': 'target_cell_type'},
        bindings_mapping={'group': 'cell_type', 'feature': 'gene_symbol',
                          'avg_expression': 'mean_expr', 'pct_expressed': 'positive_percent',
                          'target_group': 'target_cell_type'}))
    results.append(case(
        'r-dotplot-optional', '2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot',
        'render-dotplot-long.csv',
        {'group': 'cell_type', 'feature': 'gene_symbol', 'avg_expression': 'mean_expr',
         'pct_expressed': 'positive_percent', 'target_group': 'target_cell_type'},
        drop=('target_group',),
        bindings_mapping={'group': 'cell_type', 'feature': 'gene_symbol',
                          'avg_expression': 'mean_expr', 'pct_expressed': 'positive_percent'}))
    results.append(case(
        'r-bar', '2026-10-22-scp-example__fig09-bar--bar', 'render-cell-metadata.csv',
        {'cell': 'barcode', 'group': 'cell_type', 'stat': 'phase'}))
    results.append(case(
        'r-bar-optional', '2026-10-22-scp-example__fig09-bar--bar', 'render-cell-metadata.csv',
        {'cell': 'barcode', 'group': 'cell_type', 'stat': 'phase'}, drop=('cell',),
        bindings_mapping={'group': 'cell_type', 'stat': 'phase'}))
    results.append(case(
        'python-shap', '2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar',
        'shap-summary.csv',
        {'feature': 'variable', 'shap': 'mean_abs_shap', 'percent': 'contribution_percent'}))

    # A missing required internal column must fail before execution.
    base = WORK / 'negative-missing'
    if base.exists():
        shutil.rmtree(base)
    author = base / 'author'
    author.mkdir(parents=True)
    header, rows = read_rows(WIKI / 'templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/example/render-dotplot-long.csv')
    write_rows(author / 'bad.csv', ['cell_type', 'gene_symbol', 'positive_percent'],
               [{'cell_type': row['group'], 'gene_symbol': row['feature'],
                 'positive_percent': row['pct_expressed']} for row in rows])
    bad_before = digest(author / 'bad.csv')
    bindings = base / 'bindings.json'
    bindings.write_text(json.dumps({'tables': {'dotplot': {'file': 'bad.csv', 'columns': {
        'group': 'cell_type', 'feature': 'gene_symbol', 'pct_expressed': 'positive_percent'}}}}),
        encoding='utf-8')
    failed = run('render', '2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot',
                 '--data', author, '--bindings', bindings, '--out', base / 'out')
    results.append({'name': 'negative-missing', 'exit': failed.returncode,
                    'stderr': failed.stderr[-800:],
                    'out_exists': (base / 'out/figure.png').exists(),
                    'input_sha256_before': bad_before,
                    'input_sha256_after': digest(author / 'bad.csv'),
                    'inputs_unchanged': bad_before == digest(author / 'bad.csv')})

    payload = {'generated_at': '2026-10-23', 'work': str(WORK), 'results': results}
    (RECORD / 'binding-validation-review1.json').write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8', newline='\n')
    (RECORD / 'logs' / 'binding-validation-review1.log').write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps(payload, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
