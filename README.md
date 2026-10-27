# 科研知识库项目

一个 LLM Wiki + 可复用可视化模板库。知识以互链的 Markdown 页面为本体，脚本与网页只是薄外壳。

当前仅复刻和收录单 panel；图库为“单 panel 图样 / 可调用模板”两栏，整图只作只读溯源。

当前对话要求及逐项同步状态见 [当前要求与同步核查](文档/当前要求与同步核查.md)。执行规则见 [知识库 AGENTS.md](知识库/AGENTS.md)；GitHub 任务流程见 [GitHub 工作流](开发/staged/research-wiki/references/github-workflow.md)。早期设计文档中的旧路径与被替代流程仅作历史记录。

## 两个仓库

| 仓库 | 本地位置 | 内容 | 远程地址 | 默认分支 |
|---|---|---|---|---|
| `jjd-wiki` | `E:\research-wiki`（根仓库） | `知识库/`、`文档/`、`tools/`、`research wiki/`、本 README、`.github/` | https://github.com/yubinfengjjd/jjd-wiki | `main` |
| `jjd-wiki-dev` | `E:\research-wiki\开发`（独立仓库，自带 `.git`） | 代码、测试、技能源 `staged/research-wiki`、前端源码、`.github/` | https://github.com/yubinfengjjd/jjd-wiki-dev | `main` |

两个仓库都是 GitHub 免费账号下的私有仓库，默认分支 `main`，没有远端分支保护，已处于本地门禁模式（`protection: local`），合并只能经 `wiki.py gh merge`（见下文“本地门禁”）。`知识库\` 不是单独的 git 仓库，而是根仓库的子目录；根仓库的 `.gitignore` 忽略 `/开发/`，两者互不跟踪。bootstrap 之前本地分支仍叫 `master`；bootstrap 把它改名为只留本地的 `legacy/master`，并构造新的 `main`（dev 过滤重放历史，vault 为一次快照）。不要在主检出上检出 `legacy/master`：旧历史跟踪了画廊与维护记录，切过去再切回会把这些文件从磁盘删除。

任务、评审与验收在 GitHub 的 Milestone / Issue / PR 中进行，文件任务书已停用（旧任务书已迁为 Issue）。知识库写入只在 `task/*` 任务分支上由 `wiki.py save` 提交；`main` 与长期分支上 save 与网页写入都会被拒。流程由 `wiki.py gh` 子命令实现，项目自带，任何 agent（Codex、Claude、Devin、Kiro 等）都按同一方式使用。

## 目录

```text
research-wiki\                  jjd-wiki 仓库根
  知识库\            正式 LLM Wiki。页面、模板代码、方法笔记都在这里
     AGENTS.md       规则层：agent 的维护手册
     layouts\        单 panel 来源图样（历史整图仅保留归档记录）
     templates\      单图模板（spec.json + code/ + example/）
     methods\        方法笔记（source/ 原代码、code/ 可复用模板；GPL 源码目录不入库）
     interfaces\     数据接口（列定义 + 一行代表什么、单位与相近接口区别）
     chart-types\    图型概念页（何时选它、与相近图型区别、常见误用）
     projects\       课题页（用过什么、怎么适配、图在哪）
     .protected-hashes.json   作者 user 块字节基准（gh protect-baseline 生成，CI 核验）
  文档\              requirements / design / handoff / session / features（功能索引）
  tools\             launcher.ps1（双击启动）、deploy.py（部署技能副本）与其测试
  research wiki\     一个 Obsidian vault 的配置与插件（.obsidian\、.claudian\）
  画廊\              原始层，sci-figure-replica 的产物，知识库只读（不入库）
  维护记录\          本地验收与部署证据（不入库）
  开发\                         jjd-wiki-dev 仓库根（独立仓库）
     staged\research-wiki\   代码、技能 SKILL.md 与 references\、前端构建产物
     frontend\               React 源码
     obsidian-neural-view\   Obsidian 神经图谱插件源码
     ci\config.ci.json       CI 用配置（本机 config.json 不入库）
     review\                 历史评审记录与旧任务书（已迁为 Issue，只读）
     test-gallery\  test-gallery-p2\  test-wiki-r1\  preview-wiki\   本地测试与预览数据（不入库）
     codex\                  Codex 运行记录（不入库）
     qa\   spec\
```

## 本地门禁（替代远端分支保护）

个人免费账号的私有仓库不支持分支保护（保护 API 返回 403）。此时 bootstrap 把仓库记为本地门禁模式，等价门禁在本机执行：

- 合并只经 `wiki.py gh merge <pr>`：CI 检查非空且全部通过，最新一条 Codex 评审标记为 pass 且针对 PR 当前 head，才合并；否则回帖阻断原因并保持未合并。不在网页上点合并，也不直接运行 `gh pr merge`。
- 评审须由非编码 agent（Codex 角色）用 `wiki.py gh review` 回帖，编码 agent 不评审自己的 PR。
- pre-push hook 拒绝直接推送 `main`、`project/*`、`ingest/*`（新建长期分支且等于 `origin/main` 除外）和任何 `legacy/*`，并对每次推送运行 `gh guard`。
- hook 不入库：新克隆或新机器先运行 `wiki.py gh install-hook --repo dev` 与 `wiki.py gh install-hook --repo vault`。

账号支持分支保护时，bootstrap 同时配置远端保护，本地门禁照常保留。

## 不推送的内容

由两个仓库的 `.gitignore`、`知识库/.gitignore` 的 GPL 托管块与 `gh guard` 共同保证：

- `画廊/`（受版权的论文图）及开发仓库里的画廊副本 `test-gallery*/`
- `维护记录/`（含本机绝对路径的本地证据；Issue 只记相对路径与 sha256）
- GPL 方法页的源码目录（`知识库/methods/<id>/code/`、`source/`）与带 GPL 许可头的代码
- 课题数据 `**/wiki-use/_project/`
- 本机配置 `开发/staged/research-wiki/config.json`、Codex 运行记录 `开发/codex/`
- `*.lnk`、`Rplots.pdf`、`.launcher.log`、`.codegraph/`、`.omo/` 等本机产物
- 超过 5 MB 的单个文件、含本机绝对路径的新增内容（`.push-guard-allow` 只能按条豁免 `abs-path` 与 `size`，须写理由）
- `legacy/*` 分支（旧 master 历史只留本地）

GitHub 上的 vault 因此缺少 GPL 源码、画廊与维护记录：CI 用 `lint --ci`，缺失项报 `LOCAL-ONLY`；完整 lint 与方法复核只在本机主检出或带联接的 worktree 中运行。

## 双击打开

双击项目根目录的 **`启动知识库 - 快捷方式.lnk`**（启动脚本位于 `tools/`）：

- 后台起服务，打开一个独立的浏览器应用窗口；
- 关掉这个窗口，服务会自动停止；
- 出错或想查时间线看 `.launcher.log`。

窗口是 Chrome（没有则 Edge）的应用模式，使用临时独立配置，不带你平时的插件与登录。若服务已在终端里跑着，双击只会开窗口，关窗口不会停那个服务。

主检出停在 `main` 时网页只适合阅读与浏览，写入（签核、确认、改标签等）会被拒并提示先 `start-task`。要在网页里写入：先 `wiki.py gh start-task … --worktree`，按输出设置 `$env:RWIKI_WIKI_ROOT` 后在同一终端运行 `tools\launcher.ps1`，launcher 会把它以 `--wiki-root` 传给 server。

## 命令行启动

```powershell
$env:TEMP=$env:TMP='E:\research-wiki-env\tmp'; $env:MPLCONFIGDIR='E:\research-wiki-env\tmp\mpl'
$rw = 'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe'
& $rw -X utf8 'C:\Users\86186\.claude\skills\research-wiki\wiki.py' serve
```

浏览器打开 http://127.0.0.1:8765 。写入任务分支检出时加全局参数 `--wiki-root <检出>\知识库`（放在 `serve` 之前）。

## 技能安装与项目的关系

技能必须放在 Claude / Codex 的固定目录才能被发现，所以这些是**部署副本**，源在 `开发\staged\research-wiki`：

- `C:\Users\86186\.agents\skills\research-wiki\`
- `C:\Users\86186\.claude\skills\research-wiki\`
- `C:\Users\86186\.codex\skills\research-wiki\`
- `C:\Users\86186\.cc-switch\skills\research-wiki\`
- `C:\Users\86186\.config\opencode\skills\research-wiki\`
- `sci-figure-replica` 同样安装于 `.agents`、`.codex`、`.claude` 三处，其配置的画廊路径指向本项目的 `画廊\`。

部署前核对 `research-wiki` 的五处安装与 `sci-figure-replica` 的三处安装，共八份技能。research-wiki 用 `python tools\deploy.py <维护记录目录> "<说明>"` 同步五处（逐文件备份、清理旧构建产物、写 manifest 并按哈希核验）；部署只在 `开发` 工作区干净且 HEAD 等于 `origin/main` 或恰为已推送 tag 时进行，manifest 记录 `source_commit`/`source_tag`。`python tools\deploy.py --verify-only` 只比较五处副本与 staged 的哈希，不写入。sci-figure-replica 的源不在本项目，沿用其维护记录中的部署。同步应包含对应的 `references/`、规则、代码、构建产物并核对清单。

技能 config.json（本机文件，不入库；模板见 `config.example.json`）里的 `wiki_root`、`gallery_root` 指向本项目的 `知识库\` 与 `画廊\`，`github` 段记录 owner、两个仓库名与本地路径。

## 不进项目的

- Python 环境：`C:\Users\86186\.codex\venvs\research-wiki`（跑 wiki.py）、`E:\research-wiki-env\bio-python`（本机实验环境，知识库不再管理）
- 临时文件与缓存：`E:\research-wiki-env\tmp`、`E:\research-wiki-env\pip-cache`（C 盘不写）
- 并行任务的 worktree：`E:\research-wiki-env\worktrees`（`start-task --worktree` 创建，合并后自动移除）

运行依赖与独立性口径见 `知识库/AGENTS.md`“最小运行闭包与独立性证据”和 `开发/staged/research-wiki/references/minimal-runtime.md`；独立迁移验证与算法验证分开记录。
