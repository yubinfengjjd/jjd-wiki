# Research Wiki

科研知识、可复用代码、公开样例与来源记录。内容仓库 [jjd-wiki](https://github.com/yubinfengjjd/jjd-wiki) 与工具仓库 [jjd-wiki-dev](https://github.com/yubinfengjjd/jjd-wiki-dev) 分开维护。知识级别、运行状态与科学验证分别记录；未运行材料不能据此标为验证通过。

## 当前目录

| 路径 | 内容 |
|---|---|
| `wiki/` | 正式知识页、L0 来源目录、L1 配方、L2 模板与方法、公开输入及原始运行收据 |
| `gallery/` | 图样、复刻来源与对照材料 |
| `docs/` | 当前使用与维护说明 |
| `tools/` | 本机路径配置、启动、依赖导出、部署与可逆迁移工具 |
| `integrations/obsidian/` | 可选 Obsidian 集成 |
| `archive/docs/`、`archive/maintenance/` | 历史设计、交接、核查和维护记录；原路径与旧要求保留为历史证据 |

本机独立开发检出仍可放在 `开发/`；新电脑推荐同级 `jjd-wiki-dev/`。根仓库忽略嵌套开发检出，两个仓库各自持有 Git 历史。第三方来源继续保留自己的许可证、出处与哈希；本仓库没有覆盖第三方材料的统一授权声明。私有课题数据、口令、token、私钥与本机配置不入库。

## 使用

先按场景检索，再查看输入定义、单位与分组，最后复制进课题目录运行：

```text
rwiki find <场景/图型/分析>
rwiki show <id>
rwiki use <id> --project <课题目录>
rwiki run --dir <副本>
```

使用副本中的 `RWIKI-USE.md`。课题数据与成图留在课题目录；装包或改统计逻辑前需作者确认。知识编辑规则见 `wiki/AGENTS.md`。

本机 Python 脚本使用 `D:\anaconda\python.exe -X utf8`。`tools/configure-machine.py --python-exe <科学运行器> --rscript-exe <Rscript> [--dev-root <开发检出>]` 生成被 Git 忽略的本机配置；不会安装依赖。命令包装器与启动器通过 `tools/machine-paths.ps1` 共用路径发现。`RWIKI_DEV_ROOT` 可指定开发检出，`RWIKI_CONFIG` 与 `RWIKI_PYTHON` 可指定配置和 Wiki 解释器。

`tools/deploy.py` 同步六处已安装技能副本，先备份并按哈希核验；部署门禁仍要求开发检出干净且 HEAD 等于本地 main、origin/main 或已推送 tag。Git 同步与技能部署分别执行。

## 旧布局迁移

旧目录 `知识库/`、`画廊/`、`文档/`、`维护记录/`、`obsidian-vault/` 分别迁到上表 canonical 路径。迁移工具仅移动文件，不改写来源、作者块或运行收据；本机忽略配置中的路径值会备份后更新。默认命令只检查，相关路径存在未提交内容或目标冲突会停止：

```powershell
D:\anaconda\python.exe -X utf8 tools/migrate-layout.py --check --repo both
D:\anaconda\python.exe -X utf8 tools/migrate-layout.py --apply --repo both --record .layout-migrations/layout-v3
D:\anaconda\python.exe -X utf8 tools/migrate-layout.py --rollback .layout-migrations/layout-v3
```

先提交相关路径中的既有改动，再 apply；不要先手动创建迁移目标目录。记录目录必须全新且位于被移动树之外。迁移记录包括逐文件前后哈希、Git 元数据审计备份与配置备份；本机旧目录 junction 被 Git 忽略。新克隆直接使用 canonical 路径，不依赖 junction。回滚会先检查目标树、配置和 junction；发现用户新增或修改文件时停止，避免覆盖新工作。回滚不修改 Git index、HEAD 或历史；若已提交迁移，另行审查 Git 的反向提交。
