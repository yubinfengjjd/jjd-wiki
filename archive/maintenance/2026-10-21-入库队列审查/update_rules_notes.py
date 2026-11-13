from pathlib import Path
import hashlib
import json
import re
import sys

task = Path(__file__).resolve().parent
stage = Path(r'E:\research-wiki\开发\staged\research-wiki')
root = Path(r'E:\research-wiki\知识库')
sys.path.insert(0, str(stage))
from rwiki.pages import read_page, write_page, get_block

sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
baseline_path = task / 'baseline.json'
if not baseline_path.exists():
    baseline = {}
    for label, folder in [('wiki', root), ('gallery', root.parent/'画廊')]:
        baseline[label] = {p.relative_to(folder).as_posix(): sha(p) for p in folder.rglob('*')
                           if p.is_file() and not {'.git', '__pycache__'} & set(p.relative_to(folder).parts)}
    baseline_path.write_text(json.dumps(baseline, ensure_ascii=False, indent=2), encoding='utf-8')

skill_path = stage / 'SKILL.md'
text = skill_path.read_text(encoding='utf-8')
text = text.replace('`pending`，按 AGENTS.md“处理待办”拆模板', '`pending`，按实际剩余工作继续已有草稿或补齐模板；不按状态盲目重建')
extra = '\n\n待办按后端只读 `workflow` 派生，CLI与前端统一：无成功回放的模板归agent，成功回放草稿归作者确认；同一工作转到模板后来源不重复计数，选定panel已由ready模板完整覆盖则来源退出待办。`pending`只列仍需agent处理的来源ID，先读其现有模板与工作说明，不重复scaffold；为空不等于所有来源做过可选的layout回放。归档/删除导致有效覆盖缺失时重新列出，恢复后重算。保留来源签核、模板确认和运行证据各自含义，不为清零而改状态。'
assert '待办按后端只读 `workflow` 派生' not in text
skill_path.write_text(text + extra + '\n', encoding='utf-8', newline='\n')

rules_extra = '''

### 待办按剩余动作派生（CLI 与前端共用）

持久 status 表示来源签核/版式回放或模板确认阶段，不等于当前谁还有工作。后端只读 workflow 统一判断：

- 已签核来源尚缺有效模板覆盖：agent核查缺口、归档或关联，保留已完成部分。
- 已有草稿但无完整成功回放：agent继续该模板，不重复scaffold；来源不重复算一项。
- 草稿已有成功回放记录和对应输出：交作者确认，列入“待你确认”，不列agent待办；代码改变后仍应重新verify-template并核对回放，文件存在不证明科学有效。
- 所选panel已由ready模板完整覆盖：来源显示“模板已就绪”并退出待办，即使其status仍为pending_template。来源可选layout回放与单模板可用性分别记录。
- 待签核来源/新版本仍交作者签核；回放不自动确认。归档/删除模板导致覆盖缺失时重新派生待办，恢复后重算。

`pending`只列尚需agent处理的来源ID（包括已有未完成草稿）；先检查关联模板与当前说明，不见pending_template就重新拆模板。重复ingest或刷新不会新建待办记录或推进状态。不得为了清零而伪造layout验证、作者确认或删除来源。
'''
for path in (stage/'assets/AGENTS.md', root/'AGENTS.md'):
    text = path.read_text(encoding='utf-8')
    assert '### 待办按剩余动作派生' not in text
    text = text.replace('1. `wiki.py pending` 列出待处理的版式。', '1. `wiki.py pending` 列出尚需agent处理的来源；先查关联模板，继续已有草稿或补缺口，不重复新建。')
    text = text.replace('已签核，待拆 panel 与模板化 |', '已签核；模板进度按有效覆盖派生 |')
    path.write_text(text + rules_extra, encoding='utf-8', newline='\n')

tids = ['2026-10-19-regression-stability__fig03-density-panel--density-scatter',
        '2026-10-19-regression-stability__fig04-boxplot-panel--boxplot']
changed = []
for directory in ('layouts', 'templates', 'methods'):
    for path in (root/directory).glob('*.md'):
        if not any(token in path.stem for token in ('fig03-density-panel', 'fig04-boxplot-panel', 'regression-resampling-evaluation')):
            continue
        meta, body = read_page(path)
        author = get_block(body, 'user')
        chunks = re.split(r'(<!-- (?:facts|user):start -->.*?<!-- (?:facts|user):end -->)', body, flags=re.S)
        replacements = {
            '当前为draft，等待作者确认本轮模板回放；不因测试通过自动ready。来源签核继续保留。确认后可独立render，不以来源layout整体ready为前置。':
            '2026-10-21 作者明确确认本轮回放，已通过mark-ready标为可用。来源签核继续保留；可独立render，不以来源layout整体ready为前置。',
            '本轮verify-template/render入口回放已完成，模板待作者确认。后续模板化仍须完成代码与回放并由作者确认，不提前标ready。':
            '本轮verify-template/render入口回放已完成，2026-10-21作者已确认模板并标为ready，无需再次模板化。',
            'draft待作者确认。来源状态保留pending_template；无整图交付。':
            '作者已确认并标为ready。来源状态保留pending_template，完整模板覆盖已完成，不再列agent待办；无整图交付。',
            'draft待确认；来源与模板阶段仍分别记录。': '作者已确认模板为ready；来源与模板阶段分别记录。',
            '来源已签核待模板化，方法页为已确认笔记；本来源尚非可调用模板。':
            '来源已签核，关联模板已由作者确认可用；本来源用于参考，换数据调用关联模板。',
            '两张来源已签核、待模板化；': '两张来源已签核、关联模板已可用；',
            '目前draft待确认；不恢复旧草稿字节，也不自动ready。': '作者随后明确确认，两个模板已通过mark-ready标为可用。',
        }
        for index in range(0, len(chunks), 2):
            for old, new in replacements.items():
                chunks[index] = chunks[index].replace(old, new)
        new_body = ''.join(chunks)
        # Canonical source relationships describe the remaining adaptation, not stale implementation work.
        for relation in meta.get('figure_relations', []):
            if relation['figure'].startswith('layouts/'):
                relation['reason'] = relation['reason'].replace('且尚未模板化', '；已有对应绘图模板')
                relation['adaptation'] = relation['adaptation'].replace('另完成单 panel 模板化；', '使用对应单 panel 模板；')
                relation['adaptation'] = relation['adaptation'].replace('另确认摘要/须规则和待模板化实现', '另确认摘要/须规则并使用对应绘图模板')
        if new_body != body or meta.get('type') == 'method':
            assert get_block(new_body, 'user') == author
            write_page(path, meta, new_body)
            changed.append(path.relative_to(root).as_posix())

for tid in tids:
    path = root/'templates'/tid/'README.md'
    text = path.read_text(encoding='utf-8').replace('状态draft，模板回放待作者确认。', '2026-10-21 作者确认模板回放，状态ready。')
    path.write_text(text, encoding='utf-8', newline='\n')
    assert read_page(root/'templates'/f'{tid}.md')[0]['status'] == 'ready'
print(json.dumps({'notes_updated': changed, 'templates_author_confirmed': tids}, ensure_ascii=False))
