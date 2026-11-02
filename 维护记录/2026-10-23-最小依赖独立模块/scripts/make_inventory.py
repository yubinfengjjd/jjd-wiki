import json
import sys
from pathlib import Path

sys.path.insert(0, 'E:/research-wiki/开发/staged/research-wiki')
from rwiki.pages import read_page  # noqa: E402
from rwiki.runtime_contract import runtime_facts  # noqa: E402

root = Path('E:/research-wiki/知识库')
methods = ['cell-quality-control', 'doublet-detection', 'dimensionality-reduction',
           'batch-integration', 'cell-type-annotation', 'differential-expression',
           'gene-set-enrichment', 'gene-set-scoring', 'trajectory-inference',
           'dynamic-feature-analysis', 'reference-mapping', 'rna-velocity']
inv = {'schema_version': 1, 'kind': 'dependency-inventory', 'date': '2026-10-23',
       'methods': [], 'templates': []}
for method in methods:
    page = root / 'methods' / f'{method}.md'
    meta, _ = read_page(page)
    facts = runtime_facts(page.with_suffix(''), method, 'method')
    entries = []
    for impl in meta.get('implementations', []):
        iid = impl.get('id')
        runtime = facts.get('implementations', {}).get(iid, {})
        pointer = impl.get('verification', '')
        receipt = page.with_suffix('') / pointer
        state = None
        if receipt.is_file():
            state = json.loads(receipt.read_text(encoding='utf-8')).get('state')
        entries.append({
            'old_entry': impl.get('entrypoint'), 'implementation': iid,
            'runtime_mode': runtime.get('mode'),
            'required_packages': runtime.get('required_packages'),
            'optional_packages': runtime.get('optional_packages'),
            'files': runtime.get('files'), 'resources': runtime.get('resources'),
            'portability': runtime.get('portability', {}).get('state'),
            'algorithm_state': state,
            'portability_evidence': runtime.get('portability', {}).get('evidence'),
            'algorithm_evidence': pointer,
            'source_functions': runtime.get('source', {}).get('functions'),
            'source_modifications': runtime.get('source', {}).get('modifications'),
        })
    inv['methods'].append({'id': method, 'implementations': entries})
for directory in sorted((root / 'templates').glob('2026-10-22-scp-example__*')):
    if not directory.is_dir():
        continue
    facts = runtime_facts(directory, directory.name, 'template')
    inv['templates'].append({
        'id': directory.name, 'runtime_mode': facts['mode'],
        'required_packages': facts['required_packages'],
        'optional_packages': facts['optional_packages'],
        'files': facts['files'], 'resources': facts['resources'],
        'portability': facts['portability']['state'],
        'portability_evidence': facts['portability']['evidence'],
    })
Path('dependency-inventory.json').write_text(
    json.dumps(inv, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

lines = ['# 逐实现 / 逐模板依赖清单', '', '日期：2026-10-23。机器可读版：`dependency-inventory.json`。', '',
         '## 方法实现', '']
for method in inv['methods']:
    lines.append(f"### {method['id']}")
    lines.append('| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |')
    lines.append('|---|---|---|---|---|---|---|---|---|')
    for entry in method['implementations']:
        req = '; '.join(f"{key}: {', '.join(value)}" for key, value in (entry['required_packages'] or {}).items()) or '—'
        opt = '; '.join(f"{key}: {', '.join(value)}" for key, value in (entry['optional_packages'] or {}).items()) or '—'
        res = '; '.join(resource['path'] for resource in entry['resources']) or '—'
        files = '; '.join(entry['files'] or []) or '—'
        lines.append(f"| {entry['implementation']} | {entry['runtime_mode']} | {req} | {opt} | {files} | {res} | "
                     f"{entry['portability']} | {entry['algorithm_state']} | `{entry['portability_evidence']}`; `{entry['algorithm_evidence']}` |")
    lines.append('')
lines += ['## 模板', '', '| 模板 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 证据 |',
          '|---|---|---|---|---|---|---|---|']
for template in inv['templates']:
    req = '; '.join(f"{key}: {', '.join(value)}" for key, value in template['required_packages'].items()) or '—'
    opt = '; '.join(f"{key}: {', '.join(value)}" for key, value in template['optional_packages'].items()) or '—'
    res = '; '.join(resource['path'] for resource in template['resources']) or '—'
    lines.append(f"| {template['id']} | {template['runtime_mode']} | {req} | {opt} | "
                 f"{'; '.join(template['files'])} | {res} | {template['portability']} | `{template['portability_evidence']}` |")
lines += ['', '## 上游函数与兼容改动', '']
for method in inv['methods']:
    for entry in method['implementations']:
        lines.append(f"### {method['id']} / {entry['implementation']}")
        iid = entry['implementation']
        if iid == 'seurat-label-transfer':
            lines.append('- 旧入口：`code/transfer.R` 本来就是显式 Seurat 调用，不含整库加载器；本轮补独立迁移证据。')
        elif iid.startswith('scp-monocle2') or iid.startswith('scp-monocle3'):
            lines.append('- 旧入口：原 `RunMonocle2`/`RunMonocle3` 只在完整 SCP bundle 中调用；本轮从固定源码拆分为 core / Seurat adapter / plot 分支。')
        else:
            lines.append('- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。')
        lines.append(f"- 新入口：`{entry['old_entry']}`")
        lines.append('- 上游函数：' + ('；'.join(entry['source_functions'] or []) or '—'))
        lines.append('- 兼容改动：' + ('；'.join(entry['source_modifications'] or []) or '—'))
        lines.append('')
Path('dependency-inventory.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
print('methods', len(inv['methods']), 'templates', len(inv['templates']))
