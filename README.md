# Research Wiki

科研知识、可复用代码、公开样例与来源记录。内容仓库 [jjd-wiki](https://github.com/yubinfengjjd/jjd-wiki) 与工具仓库 [jjd-wiki-dev](https://github.com/yubinfengjjd/jjd-wiki-dev) 分开维护。知识级别、运行状态与科学验证分别记录；未运行材料不能据此标为验证通过。

## 当前目录

| 路径 | 内容 |
|---|---|
| `wiki/` | 正式知识页、L0 来源目录、L1 配方、L2 模板与方法、标准中间表接口（`interfaces/`）、步进决策树（`scenarios/`）、课题步进卡（`projects/`）、公开输入及原始运行收据 |
| `gallery/` | 图样、复刻来源与对照材料 |
| `docs/` | 当前使用与维护说明 |
| `tools/` | 本机路径配置、启动与部署工具 |

本机独立开发检出仍可放在 `开发/`；新电脑推荐同级 `jjd-wiki-dev/`。根仓库忽略嵌套开发检出，两个仓库各自持有 Git 历史。第三方来源继续保留自己的许可证、出处与哈希；本仓库没有覆盖第三方材料的统一授权声明。私有课题数据、口令、token、私钥与本机配置不入库。

## 使用

首次获取可选择轻量 `light` 或完整 `full` 配置，见 [快速开始](docs/getting-started.md)。`tools/get-wiki.ps1 -Destination <父目录> -Profile light` 获取两个同级仓库；按需补齐资产，正式维护前切换完整配置。既有完整检出保持完整。

先按场景与步进决策树检索，查看输入接口、下一步分析方向，或在独立 Web 操控台（Template Studio）完成表头映射、调参与试跑，最后派发进课题目录运行：

```text
rwiki find <场景/图型/分析>
rwiki show <id>
rwiki next <method_or_template_id>
rwiki use <id> --project <课题目录>
rwiki run --dir <副本>
rwiki project list
```

使用副本中的 `RWIKI-USE.md`。课题数据与成图留在课题目录；装包或改统计逻辑前需作者确认。知识编辑规则见 `wiki/AGENTS.md`。

本机 Python 脚本使用 `D:\anaconda\python.exe -X utf8`。`tools/configure-machine.py --python-exe <科学运行器> --rscript-exe <Rscript> [--dev-root <开发检出>]` 生成被 Git 忽略的本机配置；不会安装依赖。命令包装器与启动器通过 `tools/machine-paths.ps1` 共用路径发现。`RWIKI_DEV_ROOT` 可指定开发检出，`RWIKI_CONFIG` 与 `RWIKI_PYTHON` 可指定配置和 Wiki 解释器。
