"""Configure the authorized local auxiliary vault; never edit research entries."""
from pathlib import Path
import hashlib
import json
import shutil
from datetime import datetime
from machine_paths import resolve_input_path, resolve_dev_root, resolve_skill_root

BASE = Path(__file__).resolve().parents[1]
VAULT = resolve_input_path(BASE, '知识库')
RECORD = resolve_input_path(BASE, '维护记录') / '2026-10-22-Obsidian辅助与神经图谱'
SKILLS = [Path(r'C:\Users\86186') / relative for relative in
          ('.codex/skills/research-wiki', '.agents/skills/research-wiki', '.claude/skills/research-wiki')]
STAGED = resolve_skill_root(resolve_dev_root(BASE))
PLUGIN = 'research-wiki-neural-view'

RULES = '''
### Obsidian 辅助阅读与作者备注（2026-10-22）

- 仅将 `E:\\research-wiki\\知识库` 作为 vault；不把项目根、开发目录或画廊联接进 vault，不迁移业务页面或资产。
- Obsidian 用于阅读、搜索、反向链接、普通关系浏览及作者备注。签核、待办、确认、收藏/归档状态及删除继续通过现有网页/CLI；不得用插件重建另一套 workflow。
- 作者直接编辑限 `<!-- user:start -->` 与 `<!-- user:end -->` 之间。facts 由收录生成；frontmatter、其余正文按本文件既有分工维护。不要在 Obsidian 重命名、移动或删除正式条目，文件名就是业务 id。
- `.obsidian/` 是本机配置，不纳入 Wiki Git。新链接使用根目录绝对路径与双链；关闭自动更新内部链接仅防止额外改写，并不能禁止改名。属性显示源码，不用属性面板编辑嵌套 YAML 或业务字段。
- Obsidian 搜索/图谱排除 verify、__pycache__ 等过程目录；这不改变 Git 规则，verify 回放证据仍随 Wiki 提交。
- 科研神经图谱插件只读当前 vault，沿用正式页面路径/id，仅显示已有引用与原始状态。普通引用或视觉连线不等于 direct/适配关系、有效 workflow、执行或科学验证；业务判断以现有网页/CLI 为准。点击条目可打开原生笔记；插件不写页面、不运行代码、不联网。
- 不在 Obsidian 开发稿件/选题/排期等新业务。插件资产与本地配置可重新安装；停用插件不影响正式 Markdown、原网页/CLI 或作者备注。
'''

SKILL_NOTE = '''
### Obsidian 辅助窗口（2026-10-22）

作者可将 `E:\\research-wiki\\知识库` 作为 Obsidian vault 阅读与编辑 user 区块；不把项目根/画廊联接进 vault，不改名、移动或删除正式条目。facts/frontmatter/正文分工按正式 AGENTS.md；签核、待办、确认、状态与删除仍走同一网页/CLI workflow。`.obsidian/` 不入 Git，verify 证据仍入 Git。神经图谱仅为只读视觉浏览，不从连线推断语义兼容、有效状态或科学验证，不加入新的编辑/运行/联网功能。
'''


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    RECORD.mkdir(parents=True, exist_ok=True)
    receipt = RECORD / 'before.json'
    if receipt.exists():
        raise SystemExit('This one-time configuration already has a backup; inspect before rerunning.')
    targets = [VAULT / '.gitignore', VAULT / 'AGENTS.md',
               Path(r'C:\Users\86186\AppData\Roaming\obsidian\obsidian.json')]
    for skill in [STAGED, *SKILLS]:
        targets.extend([skill / 'SKILL.md', skill / 'assets/AGENTS.md'])
    originals = []
    for i, path in enumerate(targets):
        if path.exists():
            backup = RECORD / 'before' / str(i) / path.name
            backup.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, backup)
            originals.append({'path': str(path), 'backup': str(backup), 'sha256': digest(path)})
    pages = {str(p.relative_to(VAULT)): digest(p) for p in VAULT.rglob('*.md')
             if '.git' not in p.parts and '.obsidian' not in p.parts}
    receipt.write_text(json.dumps({'originals': originals, 'markdown_sha256': pages},
                                  ensure_ascii=False, indent=2), encoding='utf-8')

    ignore = VAULT / '.gitignore'
    text = ignore.read_text(encoding='utf-8')
    if '.obsidian/' not in text.splitlines():
        ignore.write_text(text.rstrip() + '\n.obsidian/\n', encoding='utf-8', newline='\n')
    rules = (VAULT / 'AGENTS.md').read_text(encoding='utf-8').rstrip() + '\n\n' + RULES.lstrip()
    for path in [VAULT / 'AGENTS.md', *[s / 'assets/AGENTS.md' for s in [STAGED, *SKILLS]]]:
        path.write_text(rules, encoding='utf-8', newline='\n')
    for skill in [STAGED, *SKILLS]:
        path = skill / 'SKILL.md'
        path.write_text(path.read_text(encoding='utf-8').rstrip() + '\n\n' + SKILL_NOTE.lstrip(),
                        encoding='utf-8', newline='\n')

    config = VAULT / '.obsidian'
    config.mkdir(exist_ok=True)
    def write(name, value):
        path = config / name
        if path.exists():
            raise RuntimeError(f'Unexpected existing configuration: {path}')
        path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    write('app.json', {'theme': 'obsidian', 'alwaysUpdateLinks': False, 'newLinkFormat': 'absolute',
        'useMarkdownLinks': False, 'propertiesInDocument': 'source', 'defaultViewMode': 'preview',
        'userIgnoreFilters': [r'/(^|\/)verify(\/|$)/', r'/(^|\/)__pycache__(\/|$)/',
                          r'/^(AGENTS|CLAUDE|log)\.md$/']})
    write('appearance.json', {'baseFontSize': 16, 'accentColor': '#d7c69e'})
    write('community-plugins.json', [PLUGIN])
    write('core-plugins.json', {'file-explorer': True, 'global-search': True, 'switcher': True,
        'graph': True, 'backlink': True, 'outgoing-link': True, 'tag-pane': True, 'properties': True,
        'page-preview': True, 'command-palette': True, 'editor-status': True, 'outline': True,
        'word-count': True, 'file-recovery': True, 'bookmarks': True,
        'sync': False, 'publish': False, 'webviewer': False, 'daily-notes': False,
        'templates': False, 'canvas': False, 'note-composer': False, 'bases': False})

    global_config = targets[2]
    settings = json.loads(global_config.read_text(encoding='utf-8'))
    for data in settings.setdefault('vaults', {}).values():
        if data.get('open'):
            data['open'] = False
    key = hashlib.sha256(str(VAULT).encode()).hexdigest()[:16]
    settings['vaults'][key] = {'path': str(VAULT), 'ts': int(datetime.now().timestamp()*1000), 'open': True}
    global_config.write_text(json.dumps(settings, ensure_ascii=False), encoding='utf-8')
    print(json.dumps({'record': str(RECORD), 'vault_id': key, 'configs': str(config),
                      'pages_snapshotted': len(pages), 'rule_copies': 5}, ensure_ascii=False))


if __name__ == '__main__':
    main()
