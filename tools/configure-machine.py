"""Create an ignored machine-local config, without installing or running analyses."""
import argparse
import json
from pathlib import Path

from machine_paths import resolve_dev_root


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--python-exe', required=True, type=Path)
    parser.add_argument('--rscript-exe', required=True, type=Path)
    parser.add_argument('--env-root', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--dev-root', type=Path)
    args = parser.parse_args()
    vault = Path(__file__).resolve().parents[1]
    try:
        dev = resolve_dev_root(vault, args.dev_root)
    except ValueError as exc:
        parser.error(str(exc))
    skill = dev / 'staged/research-wiki'
    env_root = (args.env_root or vault.parent / 'research-wiki-env').resolve()
    output = (args.output or skill / 'config.json').resolve()
    if output.exists():
        parser.error(f'配置已存在，先人工核对或备份，不覆盖：{output}')
    for path in (args.python_exe, args.rscript_exe, skill / 'assets/scenario_taxonomy.json'):
        if not path.is_file():
            parser.error(f'文件不存在：{path}')
    cfg = json.loads((skill / 'config.example.json').read_text(encoding='utf-8'))
    cfg.update(wiki_root=str(vault / '知识库'), gallery_root=str(vault / '画廊'),
               taxonomy=str(skill / 'assets/scenario_taxonomy.json'),
               python_exe=str(args.python_exe.resolve()), rscript_exe=str(args.rscript_exe.resolve()),
               sources_root=str(env_root / 'sources'), work_root=str(env_root / 'work/rwiki'),
               r_libs=[str(env_root / 'R-lib')],
               env={'vars': {'TEMP': str(env_root / 'tmp'), 'TMP': str(env_root / 'tmp'),
                             'MPLCONFIGDIR': str(env_root / 'tmp/mpl')}},
               github={'owner': 'yubinfengjjd', 'dev_repo': 'jjd-wiki-dev', 'vault_repo': 'jjd-wiki',
                       'dev_root': str(dev), 'vault_root': str(vault),
                       'worktree_root': str(env_root / 'worktrees')})
    output.parent.mkdir(parents=True, exist_ok=True)
    for relative in ('tmp/mpl', 'work/rwiki', 'sources', 'R-lib'):
        (env_root / relative).mkdir(parents=True, exist_ok=True)
    # Exclusive create prevents overwriting a config created after the check above.
    with output.open('x', encoding='utf-8') as stream:
        json.dump(cfg, stream, ensure_ascii=False, indent=2)
        stream.write('\n')
    print(f'已生成本机配置：{output}')
    print('未安装依赖、未连接远程电脑、未运行分析。')


if __name__ == '__main__':
    main()
